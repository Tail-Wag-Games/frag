import std/[atomics, macros],
       sokol/app as sapp, sokol/gfx as sgfx,
       config, tnt, io

export
  config

type
  GfxStage* = object
    id*: uint32

  Config* = object
    appName*: cstring
    appTitle*: cstring
    pluginPath*: cstring

    plugins*: array[MaxPlugins, cstring]

    windowWidth*: int32
    windowHeight*: int32

    numJobThreads*: int32 = -1'i32
    maxActiveJobs*: int32
    jobStackSize*: int32

  ApiType* = distinct int32

  CoreApi* = object
    deltaTick*: proc(): uint64 {.cdecl.}
    deltaTime*: proc(): float32 {.cdecl.}
    frameIndex*: proc(): int64 {.cdecl.}
    dispatchJob*: proc(count: int32; callback: proc(start, finish,
        threadIdx: int32; userData: pointer) {.cdecl.}; userData: pointer;
        priority: JobPriority; tags: uint32): Job {.cdecl.}
    testAndDelJob*: proc(job: Job): bool {.cdecl.}
    numJobThreads*: proc(): int32 {.cdecl.}
    jobThreadIndex*: proc(): int32 {.cdecl.}

  PluginFailure* = distinct int32

  PluginOperation* = distinct int32

  Plugin* = object
    p*: pointer
    api*: ptr PluginApi
    version*: uint32
    failure*: PluginFailure
    nextVersion*: uint32
    lastWorkingVersion*: uint32

  PluginEvent* = distinct uint32

  MainCallback* = proc(ctx: ptr Plugin; e: PluginEvent)
  EventHandlerCallback* = proc(e: ptr sapp.Event)

  PluginInfo* = object
    version*: uint32
    deps*: ptr UncheckedArray[cstring]
    numDeps*: int32
    name*: array[32, char]
    desc*: array[256, char]

  PluginInfoCb* = proc(outInfo: ptr PluginInfo) {.cdecl.}

  PluginApi* = object
    load*: proc(name: cstring): bool {.cdecl.}
    injectApi*: proc(name: cstring; version: uint32; api: pointer) {.cdecl.}
    getApi*: proc(api: ApiType): pointer {.cdecl.}
    getApiByName*: proc(name: cstring; version: uint32): pointer {.cdecl.}

  AppEvent* = object

  AppApi* = object
    width*: proc(): int32 {.cdecl.}
    height*: proc(): int32 {.cdecl.}
    keyPressed*: proc(key: Keycode): bool {.cdecl.}
    name*: proc(): cstring {.cdecl.}
    windowSize*: proc(size: ptr Vec2) {.cdecl.}
    dpiScale*: proc(): float32 {.cdecl.}
    captureMouse*: proc() {.cdecl.}
    releaseMouse*: proc() {.cdecl.}

  ShaderCodeType* = distinct uint32
  ShaderLang* = distinct uint32
  ShaderStage* = distinct uint32

  ShaderReflInput* = object
    name*: array[32, char]
    semantic*: array[32, char]
    semanticIndex*: int32
    vertexFormat*: sgfx.VertexFormat

  ShaderReflUniformBuffer* = object
    name*: array[32, char]
    numBytes*: int32
    binding*: int32
    arraySize*: int32

  ShaderReflBuffer* = object
    name*: array[32, char]
    numBytes*: int32
    binding*: int32
    arrayStride*: int32

  ShaderReflTexture* = object
    name*: array[32, char]
    binding*: int32
    imageType*: sgfx.ImageType

  ShaderRefl* = object
    lang*: ShaderLang
    stage*: ShaderStage
    profileVersion*: int32
    sourceFile*: array[32, char]
    inputs*: seq[ShaderReflInput]
    textures*: seq[ShaderReflTexture]
    storageImages*: seq[ShaderReflTexture]
    storageBuffers*: seq[ShaderReflBuffer]
    uniformBuffers*: seq[ShaderReflUniformBuffer]
    codeType*: ShaderCodeType
    flattenUbos*: bool

  ShaderInfo* = object
    inputs*: array[maxVertexAttributes, ShaderReflInput]
    numInputs*: int32
    nameHandle*: uint32

  Shader* = object
    shd*: sgfx.Shader
    info*: ShaderInfo

  TextureLoadParams* = object
    firstMip*: int32
    minFilter*: Filter
    magFilter*: Filter
    wrapU*: Wrap
    wrapV*: Wrap
    wrapW*: Wrap
    fmt*: PixelFormat
    aniso*: int32
    srgb*: int32

  DepthLayers* {.union.} = object
    depth*: int32
    layers*: int32

  TextureInfo* = object
    nameHandle*: uint32
    imageType*: ImageType
    format*: PixelFormat
    memSizeBytes*: int32
    width*: int32
    height*: int32
    dl*: DepthLayers
    mips*: int32
    bpp*: int32

  Texture* = object
    img*: sgfx.Image
    info*: TextureInfo

  VertexAttribute* = object
    semantic*: cstring
    semanticIndex*: int32
    offset*: int32
    format*: VertexFormat
    bufferIndex*: int32

  VertexLayout* = object
    attributes*: array[maxVertexAttributes, VertexAttribute]

  GfxDrawApi* = object
    begin*: proc(stage: GfxStage): bool {.cdecl.}
    finish*: proc() {.cdecl.}
    updateBuffer*: proc(bufId: sgfx.Buffer; data: ptr sgfx.Range) {.cdecl.}
    beginDefaultPass*: proc(passAction: ptr PassAction; width,
        height: int32) {.cdecl.}
    beginPass*: proc(pass: Pass; passAction: ptr PassAction) {.cdecl.}
    applyViewport*: proc(x, y, width, height: int32; originTopLeft: bool) {.cdecl.}
    applyScissorRect*: proc(x, y, width, height: int32; originTopLeft: bool) {.cdecl.}
    applyPipeline*: proc(pip: Pipeline) {.cdecl.}
    applyBindings*: proc(bindings: ptr Bindings) {.cdecl.}
    applyUniforms*: proc(stage: sgfx.ShaderStage; ubIndex: int32; data: pointer;
        numBytes: int32) {.cdecl.}
    draw*: proc(baseElement: int32; numElements: int32;
        numInstances: int32) {.cdecl.}
    dispatch*: proc(threadGroupX, threadGroupY, threadGroupZ: int32) {.cdecl.}
    dispatchIndirect*: proc(buf: Buffer; offset: int32) {.cdecl.}
    drawIndexedInstancedIndirect*: proc(buf: Buffer; offset: int32) {.cdecl.}
    finishPass*: proc() {.cdecl.}
    appendBuffer*: proc(buf: Buffer; data: pointer;
        dataSize: int32): int32 {.cdecl.}
    updateImage*: proc(img: sgfx.Image; data: ptr ImageData) {.cdecl.}
    mapImage*: proc(img: Image; offset: int32; data: sgfx.Range) {.cdecl.}

  GfxApi* = object
    imm*: GfxDrawApi
    staged*: GfxDrawApi
    glFamily*: proc(): bool {.cdecl.}
    makeBuffer*: proc(desc: ptr BufferDesc): sgfx.Buffer {.cdecl.}
    makeImage*: proc(desc: ptr sgfx.ImageDesc): sgfx.Image {.cdecl.}
    makeShader*: proc(desc: ptr ShaderDesc): sgfx.Shader {.cdecl.}
    makePipeline*: proc(desc: ptr PipelineDesc): sgfx.Pipeline {.cdecl.}
    makePass*: proc(desc: ptr PassDesc): sgfx.Pass {.cdecl.}
    allocImage*: proc(): sgfx.Image {.cdecl.}
    allocShader*: proc(): sgfx.Shader {.cdecl.}
    initImage*: proc(imgId: sgfx.Image; desc: ptr sgfx.ImageDesc) {.cdecl.}
    initShader*: proc(shdId: sgfx.Shader; desc: ptr ShaderDesc) {.cdecl.}
    registerStage*: proc(name: cstring; parentStage: GfxStage): GfxStage {.cdecl.}
    makeShaderWithData*: proc(vsDataSize: uint32; vsData: ptr UncheckedArray[
        uint32]; vsReflSize: uint32; vsReflJson: ptr UncheckedArray[uint32];
            fsDataSize: uint32;
        fsData: ptr UncheckedArray[uint32]; fsReflSize: uint32;
            fsReflJson: ptr UncheckedArray[uint32]): Shader {.cdecl.}
    bindShaderToPipeline*: proc(shd: ptr Shader; pipDesc: ptr PipelineDesc;
        vl: ptr VertexLayout): ptr PipelineDesc {.cdecl.}
    getShader*: proc(shaderAssetHandle: AssetHandle): ptr api.Shader {.cdecl.}
    getTexture*: proc(textureAssetHandle: AssetHandle): ptr api.Texture {.cdecl.}

  VfsAsyncReadCallback* = proc(path: cstring; mem: ptr MemBlock;
      userData: pointer) {.cdecl.}
  VfsAsyncWriteCallback* = proc(path: cstring; bytesWritten: int64;
      mem: ptr MemBlock; userData: pointer) {.cdecl.}

  VfsFlag* = distinct uint32

  VfsApi* = object
    mount*: proc(path, alias: cstring; watch: bool): bool {.cdecl.}
    read*: proc(path: cstring; flags: VfsFlag): ptr MemBlock {.cdecl.}
    readAsync*: proc(path: cstring; flags: VfsFlag;
        readFn: VfsAsyncReadCallback; userData: pointer) {.cdecl.}

  Asset* {.union.} = object
    id*: uint
    p*: pointer

  AssetHandle* = object
    id*: uint32

  AssetLoadData* = object
    asset*: Asset
    userData1*: pointer
    userData2*: pointer

  AssetLoadFlag* = distinct uint32
  AssetState* = distinct uint32

  AssetLoadParams* = object
    path*: cstring
    params*: pointer
    tags*: uint32
    flags*: AssetLoadFlag

  AssetCallbacks* = object
    onPrepare*: proc(params: ptr AssetLoadParams;
        mem: ptr MemBlock): AssetLoadData {.cdecl.}
    onLoad*: proc(data: ptr AssetLoadData; params: ptr AssetLoadParams;
        mem: ptr MemBlock): bool {.cdecl.}
    onFinalize*: proc(data: ptr AssetLoadData; params: ptr AssetLoadParams;
        mem: ptr MemBlock) {.cdecl.}
    onReload*: proc(handle: AssetHandle; prevAsset: Asset) {.cdecl.}
    onRelease*: proc(asset: Asset) {.cdecl.}

  AssetApi* = object
    registerAssetType*: proc(name: cstring; callbacks: AssetCallbacks; paramsTypeName: cstring; paramsSize: int32;
                             failedObj, asyncObj: Asset;
                                 forcedFlags: AssetLoadFlag) {.cdecl.}
    load*: proc(name: cstring; path: cstring; params: pointer;
        flags: AssetLoadFlag; tags: uint32): AssetHandle {.cdecl.}
    asset*: proc(handle: AssetHandle): Asset {.cdecl.}

  Camera* = object
    forward*: Vec3
    right*: Vec3
    up*: Vec3
    pos*: Vec3

    quat*: Quaternion
    fFar*: float32
    fNear*: float32
    fov*: float32
    viewport*: Rectangle

  FpsCamera* = object
    cam*: Camera
    pitch*: float32
    yaw*: float32

  CameraApi* = object
    perspective*: proc(cam: ptr Camera; proj: ptr Mat4) {.cdecl.}
    view*: proc(cam: ptr Camera; view, invView: ptr Mat4) {.cdecl.}
    # calcFrustumPointsRange*: proc(cam: ptr Camera; frustum: ptr Frustum; fNear,
    #     fFar: float32) {.cdecl.}
    initFps*: proc(cam: ptr FpsCamera; fovDeg: float32; viewport: Rectangle; 
      fNear, fFar: float32) {.cdecl.}
    lookAtFps*: proc(cam: ptr FpsCamera; pos, target, up: Vec3) {.cdecl.}
    pitchFps*: proc(cam: ptr FpsCamera; pitch: float32) {.cdecl.}
    yawFps*: proc(cam: ptr FpsCamera; yaw: float32) {.cdecl.}
    forwardFps*: proc(cam: ptr FpsCamera; forward: float32) {.cdecl.}
    strafeFps*: proc(cam: ptr FpsCamera; strafe: float32) {.cdecl.}
    # pickingRay*: proc(cam: ptr Camera; sp: hmm_vec2): Ray {.cdecl.} 

  JobPriority* = enum
    jpHigh
    jpNormal
    jpLow
    jpCount

  Job* = ptr Atomic[int32]

template toId*(idx: int): uint32 = idx.uint32 + 1
template toIndex*(id: uint32): int = id.int - 1

const
  MaxKeycodes* = 512

  atCore* = ApiType(0)
  atPlugin* = ApiType(1)
  atApp* = ApiType(2)
  atGfx* = ApiType(3)
  atVfs* = ApiType(4)
  atAsset* = ApiType(5)
  atCamera* = ApiType(6)

  pfNone* = PluginFailure(0)
  pfSegfault* = PluginFailure(1)
  pfIllegal* = PluginFailure(2)
  pfAbort* = PluginFailure(3)
  pfMisalign* = PluginFailure(4)
  pfBounds* = PluginFailure(5)
  psStackOverflow* = PluginFailure(6)
  pfStateInvalidated* = PluginFailure(7)
  pfBadImage* = PluginFailure(8)
  pfOther* = PluginFailure(9)
  pfUser* = PluginFailure(0x100)

  poLoad* = PluginOperation(0)
  poStep* = PluginOperation(1)
  poUnload* = PluginOperation(2)
  poClose* = PluginOperation(3)
  poInit* = PluginOperation(4)

  alfNone* = AssetLoadFlag(0x0)
  alfAbsolutePath* = AssetLoadFlag(0x1)
  alfWaitOnLoad* = AssetLoadFlag(0x2)
  alfReload* = AssetLoadFlag(0x4)

  asZombie* = AssetState(0)
  asOk* = AssetState(1)
  asFailed* = AssetState(2)
  asLoading* = AssetState(3)

  vfsfNone* = VfsFlag(0x1)
  vfsfAbsolutePath* = VfsFlag(0x2)
  vfsfTextFile* = VfsFlag(0x4)
  vfsfAppend* = VfsFlag(0x8)

  sctSource* = ShaderCodeType(0)
  sctBytecode* = ShaderCodeType(1)

  slGles* = ShaderLang(0)
  slHlsl* = ShaderLang(1)
  slMsl* = ShaderLang(2)
  slGlsl* = ShaderLang(3)
  slCount* = ShaderLang(4)

  ssVs* = ShaderStage(0)
  ssFs* = ShaderStage(1)
  ssCs* = ShaderStage(2)
  ssCount* = ShaderStage(3)

converter toUint32*(lf: AssetLoadFlag): uint32 = uint32(lf)
converter toLoadFlag*(lf: uint32): AssetLoadFlag = AssetLoadFlag(lf)

converter toUint32*(lf: VfsFlag): uint32 = uint32(lf)
converter toVfsFlag*(lf: uint32): VfsFlag = VfsFlag(lf)

proc `==`*(a, b: ShaderCodeType): bool {.borrow.}
proc `==`*(a, b: ShaderStage): bool {.borrow.}

macro fragState*(t: typed): untyped =
  let typeNode = if t[0][1].kind == nnkSym:
      newIdentNode(t[0][1].strVal)
    elif t[0][1].kind == nnkPtrTy:
      nnkPtrTy.newTree(newIdentNode(t[0][1][0].strVal))
    else:
      newIdentNode("")

  let pragmaNode = quote do:
    {.emit: "#pragma section(\".state\", read, write)".}

  result = nnkStmtList.newTree(
    pragmaNode,
    nnkVarSection.newTree(
      nnkIdentDefs.newTree(
        nnkPragmaExpr.newTree(
          newIdentNode(t[0][0].strVal),
          nnkPragma.newTree(
            nnkExprColonExpr.newTree(
              newIdentNode("codegenDecl"),
              newLit("__declspec(allocate(\".state\")) $# $#")
      )
    )
      ),
      typeNode,
      newEmptyNode()
    )
    )
  )

when defined host:
  when defined debug:
    {.link: "../thirdparty/crd.lib".}
  else:
    {.link: "../thirdparty/cr.lib".}

  proc openPlugin*(ctx: ptr Plugin; fullpath: cstring): bool {.importc: "cr_plugin_open".}
  proc updatePlugin*(ctx: ptr Plugin; reloadCheck: bool = true): int32 {.importc: "cr_plugin_update", discardable.}
  proc pluginEvent*(ctx: ptr Plugin; e: pointer) {.importc: "cr_plugin_event".}
  proc closePlugin*(ctx: ptr Plugin) {.importc: "cr_plugin_close".}
