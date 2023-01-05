import api, primer, smath, three_d, shaders/wire,
       sokol/gfx as sgfx

from math import `mod`

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

proc gridXYPlane(spacing, spacingBold: float32; vp: ptr FLoat4x4f;
    frustum: array[8, Float3f]) {.cdecl.} =
  block outer:
    let
      color = smath.Color(r: 170, g: 170, b: 170, a: 255)
      boldColor = smath.Color(r: 255, g: 255, b: 255, a: 255)

      drawApi = addr(gfxApi.staged)

      adjustedSpacing = ceilScalar(maxScalar(spacing, 0.0001'f32))
      bb = emptyAABB()

    let nearPlaneNorm = normPlane(frustum[0], frustum[1], frustum[2])

    for i in 0 ..< 8:
      if i < 4:
        var offsetPt: Float3f
        storeVector3(addr(offsetPt), subVector(setVector(frustum[i]), mulVector(
            nearPlaneNorm, adjustedSpacing)))
        addPoint(addr(bb), Float3f(x: offsetPt.x, y: offsetPt.y, z: 0.0'f32))
      else:
        addPoint(addr(bb), Float3f(x: frustum[i].x, y: frustum[i].y, z: 0.0'f32))

    let
      nSpace = int32(adjustedSpacing)
      snapBox = aabbf(float32(int32(bb.xMin) - int32(bb.xMin) mod nSpace),
          float32(int32(bb.yMin) - int32(bb.yMin) mod nSpace), 0, float32(int32(
          bb.xMax) - int32(bb.xMax) mod nSpace), float32(int32(bb.yMax) - int32(
          bb.yMax) mod nSpace), 0)
      w = snapBox.xMax - snapBox.xMin
      h = snapBox.yMax - snapBox.yMin

    if nearEqualScalar(w, 0, 0.00001'f32) or nearEqualScalar(h, 0, 0.00001'f32):
      break outer

    let
      xLines = int32(w) div nSpace + 1
      yLines = int32(h) div nSpace + 1
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

      verts[ni].color = if yOffset != 0.0'f32:
        if not nearEqualScalar(yOffset mod spacingBold, 0.0'f32,
            0.0001'f32): color else: boldColor
        else: Red

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

      verts[ni].color = if xOffset != 0.0'f32:
        if not nearEqualScalar(xOffset mod spacingBold, 0.0'f32,
            0.0001'f32): color else: boldColor
        else: Green

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
    viewProj: ptr Float4x4f) {.cdecl.} =
  var frustum: array[8, Float3f]
  cameraApi.calcFrustumPointsRange(cam, frustum, -dist, dist)
  gridXYPlane(spacing, spacingBold, viewProj, frustum)

proc fragPlugin(plugin: ptr Plugin; operation: PluginOperation): int32 {.exportc,
    cdecl, dynlib.} =
  case operation:
  of poStep:
    discard
  of poInit:
    pluginApi = plugin.api

    cameraApi = cast[ptr CameraApi](pluginApi.getApi(atCamera))
    gfxApi = cast[ptr GfxApi](pluginApi.getApi(atGfx))

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
