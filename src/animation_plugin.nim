import ozz, sokol/app as sapp, sokol/gfx as sgfx,
       shaders/skinned_mesh,
       api, animation, io, tnt

type
  VsParams = object
    mvp: array[16, float32]
    model: array[16, float32]
    jointUv: array[2, float32]
    jointPixelWidth: float32

  AnimationContext = object
    jointTexture: sgfx.Image
    ozz: ptr ozz.Instance

    skinningTimeSec: float32
    skeletons: array[32, AssetHandle]
    animations: array[512, AssetHandle]
    meshes: array[1024, AssetHandle]

    vsParams: VsParams
    vBuf: sgfx.Buffer
    iBuf: sgfx.Buffer
    shader: api.Shader
    vLayout: api.VertexLayout
    pip: sgfx.Pipeline
    bindings: sgfx.Bindings

    initialized: bool

var
  ctx {.fragState.}: AnimationContext

  pluginApi {.fragState.}: ptr PluginApi
  coreApi {.fragState.}: ptr CoreApi
  gfxApi {.fragState.}: ptr GfxApi
  assetApi {.fragState.}: ptr AssetApi

proc onPrepareSkeleton(params: ptr AssetLoadParams;
    mem: ptr MemBlock): AssetLoadData {.cdecl.} =
  result.asset.id = 1

proc onLoadSkeleton(data: ptr AssetLoadData; params: ptr AssetLoadParams;
    mem: ptr MemBlock): bool {.cdecl.} =
  ozz.loadSkeleton(ctx.ozz, mem.data, uint(mem.size))
  result = true

proc onFinalizeSkeleton(data: ptr AssetLoadData; params: ptr AssetLoadParams;
    mem: ptr MemBlock) {.cdecl.} =
  discard

proc onReloadSkeleton(handle: AssetHandle; prevAsset: Asset) {.cdecl.} =
  discard

proc onReleaseSkeleton(asset: Asset) {.cdecl.} =
  discard

proc onPrepareAnimation(params: ptr AssetLoadParams;
    mem: ptr MemBlock): AssetLoadData {.cdecl.} =
  result.asset.id = 1

proc onLoadAnimation(data: ptr AssetLoadData; params: ptr AssetLoadParams;
    mem: ptr MemBlock): bool {.cdecl.} =
  ozz.loadAnimation(ctx.ozz, mem.data, uint(mem.size))
  result = true

proc onFinalizeAnimation(data: ptr AssetLoadData; params: ptr AssetLoadParams;
    mem: ptr MemBlock) {.cdecl.} =
  discard

proc onReloadAnimation(handle: AssetHandle; prevAsset: Asset) {.cdecl.} =
  discard

proc onReleaseAnimation(asset: Asset) {.cdecl.} =
  discard

proc onPrepareMesh(params: ptr AssetLoadParams;
    mem: ptr MemBlock): AssetLoadData {.cdecl.} =
  result.asset.id = 1

proc createVBufCb(p: ptr UncheckedArray[Vertex]; numVerts: uint) {.cdecl.} =
  var desc: sgfx.BufferDesc
  desc.`type` = bufferTypeVertexBuffer
  desc.data.`addr` = p
  desc.data.size = int(numVerts) * sizeof(ozz.Vertex)
  ctx.vBuf = gfxApi.makeBuffer(addr(desc))
  ctx.bindings.vertexBuffers[0] = ctx.vBuf

proc createIBufCb(p: ptr UncheckedArray[uint16]; numIndices: uint) {.cdecl.} =
  var desc: sgfx.BufferDesc
  desc.`type` = bufferTypeIndexBuffer
  desc.data.`addr` = p
  desc.data.size = int(numIndices) * sizeof(uint16)
  ctx.iBuf = gfxApi.makeBuffer(addr(desc))
  ctx.bindings.indexBuffer = ctx.iBuf
  ctx.initialized = true

proc onLoadMesh(data: ptr AssetLoadData; params: ptr AssetLoadParams;
    mem: ptr MemBlock): bool {.cdecl.} =
  ozz.loadMesh(ctx.ozz, mem.data, uint(mem.size), createVBufCb, createIBufCb)
  result = true

proc onFinalizeMesh(data: ptr AssetLoadData; params: ptr AssetLoadParams;
    mem: ptr MemBlock) {.cdecl.} =
  discard

proc onReloadMesh(handle: AssetHandle; prevAsset: Asset) {.cdecl.} =
  discard

proc onReleaseMesh(asset: Asset) {.cdecl.} =
  discard

proc init() =
  var d = ozz.Desc(
    maxPaletteJoints: 64,
    maxInstances: 1
  )
  ozz.setup(addr(d))

  var imgDesc: sgfx.ImageDesc
  imgDesc.width = jointTextureWidth()
  imgDesc.height = jointTextureHeight()
  imgDesc.numMipmaps = 1
  imgDesc.pixelFormat = pixelFormatRGBA32F
  imgDesc.usage = usageStream
  imgDesc.minFilter = filterNearest
  imgDesc.magFilter = filterNearest
  imgDesc.wrapU = wrapClampToEdge
  imgDesc.wrapV = wrapClampToEdge
  ctx.jointTexture = gfxApi.makeImage(addr(imgDesc))

  ctx.ozz = ozz.createInstance(0)

  ctx.vLayout.attributes[0].semantic = "POSITION"
  ctx.vLayout.attributes[0].offset = int32(offsetof(ozz.Vertex, position))
  ctx.vLayout.attributes[0].format = vertexFormatFloat3

  ctx.vLayout.attributes[1].semantic = "NORMAL"
  ctx.vLayout.attributes[1].offset = int32(offsetof(ozz.Vertex, normal))
  ctx.vLayout.attributes[1].format = vertexFormatByte4n

  ctx.vLayout.attributes[2].semantic = "TEXCOORD"
  ctx.vLayout.attributes[2].offset = int32(offsetof(ozz.Vertex, jointIndices))
  ctx.vLayout.attributes[2].format = vertexFormatUbyte4n

  
  ctx.vLayout.attributes[3].semantic = "TEXCOORD"
  ctx.vLayout.attributes[3].semanticIndex = 1
  ctx.vLayout.attributes[3].offset = int32(offsetof(ozz.Vertex, jointWeights))
  ctx.vLayout.attributes[3].format = vertexFormatUbyte4n

  ctx.shader = gfxApi.makeShaderWithData(skinnedMesh_vs_size, cast[
      ptr UncheckedArray[
      uint32]](addr(skinnedMesh_vs_data[0])), skinnedMesh_vs_refl_size, cast[
      ptr UncheckedArray[uint32]](addr(skinnedMesh_vs_refl_data[0])),
          skinnedMesh_fs_size,
      cast[ptr UncheckedArray[uint32]](addr(skinnedMesh_fs_data[0])),
      skinnedMesh_fs_refl_size, cast[ptr UncheckedArray[uint32]](addr(
      skinnedMesh_fs_refl_data[0]))
    )

  ctx.bindings.vsImages[0] = ctx.jointTexture

  var pipDesc = PipelineDesc(
    shader: ctx.shader.shd,
    indexType: indexTypeUint16,
    faceWinding: faceWindingCcw,
    cullMode: cullModeBack
  )
  pipDesc.depth.writeEnabled = true
  pipDesc.depth.compare = compareFuncLessEqual
  pipDesc.layout.buffers[0].stride = int32(sizeof(ozz.Vertex))
  ctx.pip = gfxApi.makePipeline(
    gfxApi.bindShaderToPipeline(addr(ctx.shader), addr(pipDesc), addr(ctx.vLayout))
  )

  assetApi.registerAssetType(
    "skeleton",
    AssetCallbacks(
      onPrepare: onPrepareSkeleton,
      onLoad: onLoadSkeleton,
      onFinalize: onFinalizeSkeleton,
      onReload: onReloadSkeleton,
      onRelease: onReleaseSkeleton
    ),
    nil,
    0,
    Asset(p: nil),
    Asset(p: nil),
    alfNone
  )

  assetApi.registerAssetType(
    "animation",
    AssetCallbacks(
      onPrepare: onPrepareAnimation,
      onLoad: onLoadAnimation,
      onFinalize: onFinalizeAnimation,
      onReload: onReloadAnimation,
      onRelease: onReleaseAnimation
    ),
    nil,
    0,
    Asset(p: nil),
    Asset(p: nil),
    alfNone
  )

  assetApi.registerAssetType(
    "mesh",
    AssetCallbacks(
      onPrepare: onPrepareMesh,
      onLoad: onLoadMesh,
      onFinalize: onFinalizeMesh,
      onReload: onReloadMesh,
      onRelease: onReleaseMesh
    ),
    nil,
    0,
    Asset(p: nil),
    Asset(p: nil),
    alfNone
  )

  ctx.skeletons[0] = assetApi.load("skeleton",
      "C:\\Users\\Zach\\dev\\shell-shocked\\assets\\ozz_skin_skeleton.ozz", nil,
      alfNone, 0)
  ctx.animations[0] = assetApi.load("animation",
      "C:\\Users\\Zach\\dev\\shell-shocked\\assets\\ozz_skin_animation.ozz",
      nil, alfNone, 0)
  ctx.meshes[0] = assetApi.load("mesh", "C:\\Users\\Zach\\dev\\shell-shocked\\assets\\ozz_skin_mesh.ozz",
      nil, alfNone, 0)

proc draw(mvp: ptr Mat4) {.cdecl} =
  if ozz.allLoaded(ctx.ozz) and ctx.initialized:
    ctx.skinningTimeSec += coreApi.deltaTime() * 1.0'f32
    ozz.updateInstance(ctx.ozz, ctx.skinningTimeSec)

    var imgData: ImageData
    imgData.subimage[0][0].`addr` = ozz.jointUploadBuffer()
    imgData.subimage[0][0].size = ozz.jointTexturePitch() * ozz.jointTextureHeight() * sizeof(float32)
    gfxApi.staged.updateImage(ctx.jointTexture, addr(imgData))
    ctx.vsParams.mvp = mvp[].raw
    ctx.vsParams.model = mat4d(1.0'f32).raw
    ctx.vsParams.jointUv = [ozz.jointTextureU(ctx.ozz), ozz.jointTextureV(ctx.ozz)]
    ctx.vsParams.jointPixelWidth = ozz.joinTexturePixelWidth()

    gfxApi.staged.applyPipeline(ctx.pip)
    gfxApi.staged.applyBindings(addr(ctx.bindings))
    gfxApi.staged.applyUniforms(shaderStageVs, 0, addr(ctx.vsParams), int32(sizeof(ctx.vsParams)))
    gfxApi.staged.draw(0, ozz.numTriangleIndices(ctx.ozz), 1)

proc frame() =
  discard

proc fragPluginEventHandler(e: ptr sapp.Event) {.cdecl, exportc, dynlib.} =
  case e.`type`:
  of eventTypeSuspended:
    discard
  of eventTypeRestored:
    discard
  of eventTypeMouseDown:
    discard
  of eventTypeMouseUp:
    discard
  of eventTypeMouseLeave:
    discard
  of eventTypeMouseMove:
    discard
  else:
    discard

proc fragPlugin(plugin: ptr Plugin; operation: PluginOperation): int32 {.exportc,
    cdecl, dynlib.} =
  case operation:
  of poStep:
    frame()
  of poInit:
    pluginApi = plugin.api

    coreApi = cast[ptr CoreApi](pluginApi.getApi(atCore))
    gfxApi = cast[ptr GfxApi](pluginApi.getApi(atGfx))
    assetApi = cast[ptr AssetApi](pluginApi.getApi(atAsset))

    init()

    pluginApi.injectApi("anim", 0, addr(animationApi))
  else:
    discard

proc fragPluginInfo(info: ptr PluginInfo) {.cdecl, exportc, dynlib.} =
  info.name[0..31] = toOpenArray("anim", 0, 31)
  info.desc[0..255] = toOpenArray("animation plugin", 0, 255)

animationApi = AnimationApi(
  draw: draw,
)
