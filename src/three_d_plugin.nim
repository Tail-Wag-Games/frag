import sokol/app as sapp, sokol/gfx as sgfx, sokol/shape as sshape,
       api, primer, shaders/[box, wire], three_d, tnt

type
  DebugShape = object
    vb: sgfx.Buffer
    ib: sgfx.Buffer
    numVerts: int32
    numIndices: int32

  DebugInstance = object
    tx1, tx2, tx3: Vec4
    scale: Vec3
    color: tnt.Color

  DebugUniforms = object
    viewProjMat: tnt.Mat4

  DebugState = object
    drawApi: ptr GfxDrawApi
    boxShader: sgfx.Shader
    wireShader: sgfx.Shader
    solidBoxPipeline: Pipeline
    wirePipeline: Pipeline
    dynVbuff: sgfx.Buffer
    instanceBuffer: sgfx.Buffer
    unitBox: DebugShape
    checkerTexture: Texture
    numVerts: int32
    boxDrawable: ElementRange

var
  ctx {.fragState.}: DebugState

  pluginApi {.fragState.}: ptr PluginApi
  cameraApi {.fragState.}: ptr CameraApi
  gfxApi {.fragState.}: ptr GfxApi

  instanceVertexLayout: VertexLayout
  wireVertexLayout: VertexLayout

const
  MaxDynVertices = 10000
  MaxInstances = 1000

proc gridXYPlane(spacing, spacingBold: float32; vp: ptr hmm.Mat4;
    frustum: array[8, Vec3]) {.cdecl.} =
  block outer:
    let
      color = tnt.Color(rgba: RGBA(r:170'u8, g:170'u8, b:170'u8, a:255'u8)) 
      boldColor = tnt.Color(rgba: RGBA(r: 255'u8, g: 255'u8, b: 255'u8, a: 255'u8))

      drawApi = addr(gfxApi.staged)

      adjustedSpacing = ceil(max(spacing, 0.0001'f32))

    var bb: AABB

    let nearPlaneNorm = normalizePlane(frustum[0], frustum[1], frustum[2])

    for i in 0 ..< 8:
      if i < 4:
        let offsetPt = frustum[i] - (nearPlaneNorm * spacing)
        addPoint(addr(bb), vec3(offsetPt.x, offsetPt.y, 0.0'f32))
      else:
        addPoint(addr(bb), vec3(frustum[i].x, frustum[i].y, 0.0'f32))

    let
      nSpace = int32(adjustedSpacing)
      snapBox = aabbf(
        float32(int32(bb.minMax.xMin) - int32(bb.minMax.xMin) mod nSpace),
        float32(int32(bb.minMax.yMin) - int32(bb.minMax.yMin) mod nSpace), 0.0'f32,
        float32(int32(bb.minMax.xMax) - int32(bb.minMax.xMax) mod nSpace),
        float32(int32(bb.minMax.yMax) - int32(bb.minMax.yMax) mod nSpace), 0.0'f32
      )
      w = snapBox.minMax.xMax - snapBox.minMax.xMin
      d = snapBox.minMax.yMax - snapBox.minMax.yMin

    if almostEqual(w, 0.0'f32) or almostEqual(d, 0.0'f32):
      break outer

    let
      xLines = int32(w) div nSpace + 1
      yLines = int32(d) div nSpace + 1
      numVerts = (xLines + yLines) * 2
      dataSize = int32(numVerts * sizeof(DebugVertex))

    var
      i = 0
      verts = newSeq[DebugVertex](numVerts)
    
    for yOffset in countup(snapBox.minMax.yMin, snapBox.minMax.yMax - 1, adjustedSpacing):
      verts[i].pos.x = snapBox.minMax.xMin
      verts[i].pos.y = 0
      verts[i].pos.z = yOffset

      let ni = i + 1
      verts[ni].pos.x = snapBox.minMax.xMax
      verts[ni].pos.y = 0
      verts[ni].pos.z = yOffset

      verts[ni].color = 
        if yOffset != 0.0'f32:
          if not almostEqual(yOffset mod spacingBold, 0.0'f32): color else: boldColor
        else: 
          tnt.Color(rgba: Rgba(r: 255, g: 0, b: 0, a: 255))

      verts[i].color = verts[ni].color

      i += 2

    for xOffset in countup(snapBox.minMax.xMin, snapBox.minMax.xMax, adjustedSpacing):
      verts[i].pos.x = xOffset
      verts[i].pos.y = 0
      verts[i].pos.z = snapBox.minMax.yMin

      let ni = i + 1
      assert(ni < numVerts)
      verts[ni].pos.x = xOffset
      verts[ni].pos.y = 0
      verts[ni].pos.z = snapBox.minMax.yMax

      verts[ni].color = 
        if xOffset != 0.0'f32:
          if not almostEqual(xOffset mod spacingBold, 0.0'f32): color else: boldColor
        else: 
          tnt.Color(rgba: Rgba(r: 0, g: 255, b: 0, a: 255))

      verts[i].color = verts[ni].color

      i += 2

    let offset = drawApi.appendBuffer(ctx.dynVbuff, cast[pointer](addr(verts[
        0])), dataSize)

    var bindings: Bindings
    bindings.vertexBuffers[0] = ctx.dynVbuff
    bindings.vertexBufferOffsets[0] = offset

    gfxApi.staged.applyPipeline(ctx.wirePipeline)
    gfxApi.staged.applyUniforms(shaderStageVs, 0, cast[pointer](vp), int32(
        sizeof(vp[])))
    gfxApi.staged.applyBindings(addr(bindings))
    gfxApi.staged.draw(0, numVerts, 1)


proc gridXYPlaneCam(spacing, spacingBold, dist: float32; cam: ptr Camera;
    viewProj: ptr tnt.Mat4) {.cdecl.} =
  let frustum = cameraApi.calcFrustumPointsRange(cam, -dist, dist)
  gridXYPlane(spacing, spacingBold, viewProj, frustum)

proc drawBoxes(boxes: ptr tnt.Box; numBoxes: int32; viewProjMat: ptr tnt.Mat4; mapType: DebugMapType; tints: ptr tnt.Color) {.cdecl.} =
  assert(numBoxes > 0)

  let drawApi = ctx.drawApi

  var
    map: Image
    alphaBlend = false
    uniforms = DebugUniforms(viewProjMat: viewProjMat[])

  case mapType
  of dmtWhite: map = gfxApi.whiteTexture()
  of dmtChecker: map = ctx.checkerTexture.img
  else: discard
  
  let instances = cast[ptr UncheckedArray[DebugInstance]](allocShared0(sizeof(DebugInstance) * numBoxes))

  for i in 0 ..< numBoxes:
    let 
      tx = addr(boxes[i].tx)
      instance = addr(instances[i])
    
    instance.tx1 = vec4(tx.pos.x, tx.pos.y, tx.pos.z, tx.rot[0][0])
    instance.tx2 = vec4(tx.rot[0][1], tx.rot[0][2], tx.rot[1][0], tx.rot[1][1])
    instance.tx3 = vec4(tx.rot[1][2], tx.rot[2][0], tx.rot[2][1], tx.rot[2][2])
    instance.scale = boxes[i].e * 2.0
    instance.color = if tints != nil: tints[i] else: White
    if tints != nil:
      instance.color = tints[i]
      alphaBlend = alphaBlend or tints[i].rgba.a < 255
    else:
      instance.color = White
    
  if alphaBlend:
    # TODO: sort boxes
    discard
    
  let instanceOffset = drawApi.appendBuffer(ctx.instanceBuffer, cast[pointer](addr(instances[0])), int32(sizeof(DebugInstance)) * numBoxes)

  # TODO: alphablend pipeline
  var bindings: Bindings
  bindings.vertexBuffers[0] = ctx.unitBox.vb
  bindings.vertexBuffers[1] = ctx.instanceBuffer
  bindings.vertexBufferOffsets[1] = instanceOffset
  bindings.indexBuffer = ctx.unitBox.ib
  bindings.fsImages[0] = map

  drawApi.applyPipeline(ctx.solidBoxPipeline)
  drawApi.applyUniforms(shaderStageVs, 0'i32, cast[pointer](addr(uniforms)), int32(sizeof(uniforms)))
  drawApi.applyBindings(addr(bindings))

  drawApi.draw(0, ctx.boxDrawable.numElements, 1)

proc drawBox(box: ptr tnt.Box; viewProjMat: ptr tnt.Mat4; mapType: DebugMapType; tint: tnt.Color) {.cdecl.} =
  drawBoxes(box, 1, viewProjMat, mapType, unsafeAddr(tint))

proc init() =
  instanceVertexLayout.attributes[0] = sshape.positionAttrDesc()
  
  instanceVertexLayout.attributes[1] = sshape.normalAttrDesc()
  
  instanceVertexLayout.attributes[2] = sshape.texcoordAttrDesc()
  
  instanceVertexLayout.attributes[3].semantic = "TEXCOORD"
  instanceVertexLayout.attributes[3].offset = int32(offsetOf(DebugInstance, tx1))
  instanceVertexLayout.attributes[3].semanticIndex = 1
  instanceVertexLayout.attributes[3].bufferIndex = 1
  
  instanceVertexLayout.attributes[4].semantic = "TEXCOORD"
  instanceVertexLayout.attributes[4].offset = int32(offsetOf(DebugInstance, tx2))
  instanceVertexLayout.attributes[4].semanticIndex = 2
  instanceVertexLayout.attributes[4].bufferIndex = 1
  
  instanceVertexLayout.attributes[5].semantic = "TEXCOORD"
  instanceVertexLayout.attributes[5].offset = int32(offsetOf(DebugInstance, tx3))
  instanceVertexLayout.attributes[5].semanticIndex = 3
  instanceVertexLayout.attributes[5].bufferIndex = 1
  
  instanceVertexLayout.attributes[6].semantic = "TEXCOORD"
  instanceVertexLayout.attributes[6].offset = int32(offsetOf(DebugInstance, scale))
  instanceVertexLayout.attributes[6].semanticIndex = 4
  instanceVertexLayout.attributes[6].bufferIndex = 1
  
  instanceVertexLayout.attributes[7].semantic = "TEXCOORD"
  instanceVertexLayout.attributes[7].offset = int32(offsetOf(DebugInstance, color))
  instanceVertexLayout.attributes[7].format = vertexFormatUbyte4n
  instanceVertexLayout.attributes[7].semanticIndex = 5
  instanceVertexLayout.attributes[7].bufferIndex = 1

  wireVertexLayout.attributes[0].semantic = "POSITION"
  wireVertexLayout.attributes[0].offset = int32(offsetOf(DebugVertex, pos))
  
  wireVertexLayout.attributes[1].semantic = "COLOR"
  wireVertexLayout.attributes[1].offset = int32(offsetOf(DebugVertex, color))
  wireVertexLayout.attributes[1].format = vertexFormatUbyte4n

  let
    solidBoxShader = gfxApi.makeShaderWithData(box_vs_size, cast[
      ptr UncheckedArray[
      uint32]](addr(box_vs_data[0])), box_vs_refl_size, cast[
      ptr UncheckedArray[uint32]](addr(box_vs_refl_data[0])), box_fs_size,
      cast[ptr UncheckedArray[uint32]](addr(box_fs_data[0])),
      box_fs_refl_size, cast[ptr UncheckedArray[uint32]](addr(
      box_fs_refl_data[0]))
    )
    wireShader = gfxApi.makeShaderWithData(wire_vs_size, cast[
      ptr UncheckedArray[
      uint32]](addr(wire_vs_data[0])), wire_vs_refl_size, cast[
      ptr UncheckedArray[uint32]](addr(wire_vs_refl_data[0])), wire_fs_size,
      cast[ptr UncheckedArray[uint32]](addr(wire_fs_data[0])),
      wire_fs_refl_size, cast[ptr UncheckedArray[uint32]](addr(
      wire_fs_refl_data[0]))
    )

  var solidPipelineDesc = PipelineDesc(
    cullMode: cullModeBack,
    indexType: indexTypeUint16,
    label: "three_d_debug_solid"
  )
  solidPipelineDesc.shader = solidBoxShader.shd
  solidPipelineDesc.layout.attrs[0] = sshape.positionAttrDesc()
  solidPipelineDesc.layout.attrs[1] = sshape.normalAttrDesc()
  solidPipelineDesc.layout.attrs[2] = sshape.texcoordAttrDesc()

  solidPipelineDesc.layout.attrs[3].offset = int32(offsetOf(DebugInstance, tx1))
  solidPipelineDesc.layout.attrs[3].format = vertexFormatFloat4
  solidPipelineDesc.layout.attrs[3].bufferIndex = 1

  solidPipelineDesc.layout.attrs[4].offset = int32(offsetOf(DebugInstance, tx2))
  solidPipelineDesc.layout.attrs[4].format = vertexFormatFloat4
  solidPipelineDesc.layout.attrs[4].bufferIndex = 1

  solidPipelineDesc.layout.attrs[5].offset = int32(offsetOf(DebugInstance, tx3))
  solidPipelineDesc.layout.attrs[5].format = vertexFormatFloat4
  solidPipelineDesc.layout.attrs[5].bufferIndex = 1

  solidPipelineDesc.layout.attrs[6].offset = int32(offsetOf(DebugInstance, scale))
  solidPipelineDesc.layout.attrs[6].format = vertexFormatFloat4
  solidPipelineDesc.layout.attrs[6].bufferIndex = 1

  solidPipelineDesc.layout.attrs[7].offset = int32(offsetOf(DebugInstance, color))
  solidPipelineDesc.layout.attrs[7].format = vertexFormatUbyte4n
  solidPipelineDesc.layout.attrs[7].bufferIndex = 1

  solidPipelineDesc.layout.buffers[0] = sshape.bufferLayoutDesc()
  solidPipelineDesc.layout.buffers[1].stride = int32(sizeof(DebugInstance))
  solidPipelineDesc.layout.buffers[1].stepFunc = vertexStepPerInstance
  solidPipelineDesc.depth.compare = compareFuncLessEqual
  solidPipelineDesc.depth.writeEnabled = true
  
  var wirePipelineDesc = PipelineDesc(
      shader: wireShader.shd,
      indexType: indexTypeNone,
      primitiveType: primitiveTypeLines,
      depth: DepthState(
        compare: compareFuncLessEqual,
        writeEnabled: true
      ),
      label: "three_d_debug_wire"
    )
  
  # wirePipelineDesc.colors[0].pixelFormat = pixelFormatRgba8
  wirePipelineDesc.layout.buffers[0].stride = int32(sizeof(DebugVertex))
  ctx.boxShader = solidBoxShader.shd
  ctx.wireShader = wireShader.shd
  ctx.solidBoxPipeline = gfxApi.makePipeline(addr(solidPipelineDesc))
  ctx.wirePipeline = gfxApi.makePipeline(
    gfxApi.bindShaderToPipeline(addr(wireShader), addr(wirePipelineDesc), addr(wireVertexLayout))
  )

  var vBufferDesc = BufferDesc(
    `type`: bufferTypeVertexBuffer,
    usage: usageStream,
    size: sizeof(DebugVertex) * MaxDynVertices,
    label: "three_d_vbuffer"
  )
  ctx.dynVbuff = gfxApi.makeBuffer(addr(vBufferDesc))

  var instanceBufferDesc = BufferDesc(
    `type`: bufferTypeVertexBuffer,
    usage: usageStream,
    size: sizeof(DebugInstance) * MaxInstances,
    label: "three_d_instance_buffer"
  )
  ctx.instanceBuffer = gfxApi.makeBuffer(addr(instanceBufferDesc))

  # var unitBox: DebugGeometry
  # let res = generateBoxGeometry(unitBox, vec3(0.5'f32, 0.5'f32, 0.5'f32))
  # assert(res)

  # echo repr unitBox

  var 
    vertices: array[6 * 1024, sshape.Vertex]
    indices: array[16 * 1024, uint16]
    buf: sshape.Buffer
    box = sshape.Box(
      width: 1.0'f32,
      height: 1.0'f32,
      depth: 1.0'f32,
      tiles: 10,
      randomColors: true
    )

  buf.vertices.buffer = sshape.Range(`addr`: addr(vertices[0]), size: sizeof(vertices))
  buf.indices.buffer = sshape.Range(`addr`: addr(indices[0]), size: sizeof(indices))
  buf = sshape.buildBox(buf, box)
  ctx.boxDrawable = sshape.elementRange(buf)

  var
    vBufDesc = sshape.vertexBufferDesc(buf)
    iBufDesc = sshape.indexBufferDesc(buf)
  ctx.unitBox.vb = gfxApi.makeBuffer(addr(vBufDesc))
  ctx.unitBox.ib = gfxApi.makeBuffer(addr(iBufDesc))
  ctx.unitBox.numVerts = int32(len(vertices))
  ctx.unitBox.numIndices = int32(len(indices))

  let checkerColors = [
    tnt.Color(rgba: Rgba(r: 200, g: 200, b: 200, a: 255)),
    tnt.Color(rgba: Rgba(r: 200, g: 200, b: 200, a: 255))
  ]
  ctx.checkerTexture = gfxApi.createCheckerTexture(64, 128, checkerColors)

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
    ctx.drawApi = addr(gfxApi.staged)

    init()

    pluginApi.injectApi("three_d", 0, addr(threeDApi))
  else:
    discard

proc fragPluginInfo(info: ptr PluginInfo) {.cdecl, exportc, dynlib.} =
  info.name[0..31] = toOpenArray("three_d", 0, 31)
  info.desc[0..255] = toOpenArray("3d related functionality", 0, 255)

threeDApi = ThreeDApi(
  debug: Debug(
    gridXYPlaneCam: gridXYPlaneCam,
    drawBox: drawBox,
    drawBoxes: drawBoxes,
  )
)
