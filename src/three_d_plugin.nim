import sokol/app as sapp, sokol/gfx as sgfx,
       api, primer, shaders/wire, three_d, tnt

type
  DebugState = object
    dynVbuff: Buffer
    wireShader: sgfx.Shader
    wirePipeline: sgfx.Pipeline
    numVerts: int32


var
  ctx {.fragState.}: DebugState

  pluginApi {.fragState.}: ptr PluginApi
  cameraApi {.fragState.}: ptr CameraApi
  gfxApi {.fragState.}: ptr GfxApi

  wireVertexLayout: VertexLayout

const
  MaxDynVertices = 10000

proc gridXYPlane(spacing, spacingBold: float32; vp: ptr Mat4;
    frustum: Frustum) {.cdecl.} =
  block outer:
    let
      color = [170'u8, 170'u8, 170'u8, 255'u8] 
      boldColor = [255'u8, 255'u8, 255'u8, 255'u8]

      drawApi = addr(gfxApi.staged)

      adjustedSpacing = ceil(max(spacing, 0.0001'f32))

    var bb: AABBf

    let nearPlaneNorm = normalize(frustum[0].xyz, frustum[1].xyz, frustum[2].xyz)

    for i in 0 ..< 8:
      if i < 4:
        let offsetPt = frustum[i].xyz - (nearPlaneNorm * spacing)
        addPoint(bb, vec3(offsetPt.x, offsetPt.y, 0.0'f32))
      else:
        addPoint(bb, vec3(frustum[i].xyz.x, frustum[i].xyz.y, 0.0'f32))

    let
      nSpace = int32(adjustedSpacing)
      snapBox = aabb(
        float32(int32(bb.xMin) - int32(bb.xMin) mod nSpace),
        float32(int32(bb.yMin) - int32(bb.yMin) mod nSpace), 0.0'f32,
        float32(int32(bb.xMax) - int32(bb.xMax) mod nSpace),
        float32(int32(bb.yMax) - int32(bb.yMax) mod nSpace), 0.0'f32
      )
      w = snapBox.xMax - snapBox.xMin
      d = snapBox.yMax - snapBox.yMin

    if eq(w, 0.0'f32) or eq(d, 0.0'f32):
      break outer

    let
      xLines = int32(w) div nSpace + 1
      yLines = int32(d) div nSpace + 1
      numVerts = (xLines + yLines) * 2
      dataSize = int32(numVerts * sizeof(DebugVertex))

    var
      i = 0
      verts = newSeq[DebugVertex](dataSize)
    for yOffset in countup(snapBox.yMin, snapBox.yMax - 1, adjustedSpacing):
      verts[i].pos.x = snapBox.xMin
      verts[i].pos.y = yOffset
      verts[i].pos.z = 0

      let ni = i + 1
      verts[ni].pos.x = snapBox.xMax
      verts[ni].pos.y = yOffset
      verts[ni].pos.z = 0

      verts[ni].color = 
        if yOffset != 0.0'f32:
          if not eq(yOffset mod spacingBold, 0.0'f32): color else: boldColor
        else: 
          Red

      verts[i].color = verts[ni].color

      i += 2

    for xOffset in countup(snapBox.xMin, snapBox.xMax, adjustedSpacing):
      verts[i].pos.x = xOffset
      verts[i].pos.y = snapBox.yMin
      verts[i].pos.z = 0

      let ni = i + 1
      assert(ni < numVerts)
      verts[ni].pos.x = xOffset
      verts[ni].pos.y = snapBox.yMax
      verts[ni].pos.z = 0

      verts[ni].color = 
        if xOffset != 0.0'f32:
          if not eq(xOffset mod spacingBold, 0.0'f32): color else: boldColor
        else: 
          Green

      verts[i].color = verts[ni].color

      i += 2

    let offset = drawApi.appendBuffer(ctx.dynVbuff, cast[pointer](addr(verts[
        0])), dataSize)
    ctx.numVerts += numVerts

    var bindings: Bindings
    bindings.vertexBuffers[0] = ctx.dynVbuff
    bindings.vertexBufferOffsets[0] = offset

    gfxApi.staged.applyPipeline(ctx.wirePipeline)
    gfxApi.staged.applyUniforms(shaderStageVs, 0, cast[pointer](vp), int32(
        sizeof(vp[])))
    gfxApi.staged.applyBindings(addr(bindings))
    gfxApi.staged.draw(0, numVerts, 1)


proc gridXYPlaneCam(spacing, spacingBold, dist: float32; cam: ptr Camera;
    viewProj: ptr Mat4) {.cdecl.} =
  var frustum: Frustum
  cameraApi.calcFrustumPointsRange(cam, addr(frustum), -dist, dist)
  gridXYPlane(spacing, spacingBold, viewProj, frustum)

proc init() =
  wireVertexLayout.attributes[0].semantic = "POSITION"
  wireVertexLayout.attributes[0].offset = int32(offsetOf(DebugVertex, pos))
  wireVertexLayout.attributes[1].semantic = "COLOR"
  wireVertexLayout.attributes[1].offset = int32(offsetOf(DebugVertex, color))
  wireVertexLayout.attributes[1].format = vertexFormatUbyte4n

  let wireShader = gfxApi.makeShaderWithData(wire_vs_size, cast[
      ptr UncheckedArray[
      uint32]](addr(wire_vs_data[0])), wire_vs_refl_size, cast[
      ptr UncheckedArray[uint32]](addr(wire_vs_refl_data[0])), wire_fs_size,
      cast[ptr UncheckedArray[uint32]](addr(wire_fs_data[0])),
      wire_fs_refl_size, cast[ptr UncheckedArray[uint32]](addr(
      wire_fs_refl_data[0]))
    )
  var wirePipelineDesc = PipelineDesc(
      shader: wireShader.shd,
      indexType: indexTypeNone,
      primitiveType: primitiveTypeLines,
      depth: DepthState(
        compare: compareFuncLessEqual,
        writeEnabled: true,
        pixelFormat: pixelFormatDepth
      ),
      sampleCount: 4,
      label: "three_d_debug_wire"
    )
  
  wirePipelineDesc.colors[0].pixelFormat = pixelFormatRgba8
  wirePipelineDesc.layout.buffers[0].stride = int32(sizeof(DebugVertex))

  let wirePipeline = gfxApi.makePipeline(
    gfxApi.bindShaderToPipeline(addr(wireShader), addr(wirePipelineDesc), addr(wireVertexLayout))
  )

  ctx.wireShader = wireShader.shd
  ctx.wirePipeline = wirePipeline

  var vBufferDesc = BufferDesc(
    `type`: bufferTypeVertexBuffer,
    usage: usageStream,
    size: sizeof(DebugVertex) * MaxDynVertices,
    label: "three_d_vbuffer"
  )
  ctx.dynVbuff = gfxApi.makeBuffer(addr(vBufferDesc))

proc fragPluginEventHandler(e: ptr sapp.Event) {.cdecl, exportc, dynlib.} =
  discard

proc fragPlugin(plugin: ptr Plugin; operation: PluginOperation): int32 {.exportc,
    cdecl, dynlib.} =
  case operation:
  of poStep:
    discard
  of poInit:
    pluginApi = plugin.api

    cameraApi = cast[ptr CameraApi](pluginApi.getApi(atCamera))
    gfxApi = cast[ptr GfxApi](pluginApi.getApi(atGfx))

    init()

    pluginApi.injectApi("three_d", 0, addr(threeDApi))
  else:
    discard

proc fragPluginInfo(info: ptr PluginInfo) {.cdecl, exportc, dynlib.} =
  info.name[0..31] = toOpenArray("three_d", 0, 31)
  info.desc[0..255] = toOpenArray("3d related functionality", 0, 255)

threeDApi = ThreeDApi(
  debug: Debug(
    gridXYPlaneCam: gridXYPlaneCam
  )
)
