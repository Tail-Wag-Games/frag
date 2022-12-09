import std/[atomics, macros],
       sokol/gfx as sgfx,
       config, io, smath

export
  config, smath

type
  GfxStage* = object
    id*: uint32

  Config* = object
    appName*: cstring
    appTitle*: cstring

    plugins: array[MaxPlugins, cstring]

    windowWidth*: int32
    windowHeight*: int32

  ApiType* = distinct int32

  CoreApi* = object
    testAndDelJob*: proc(job: Job): bool {.cdecl.}
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
  EventHandlerCallback* = proc(e: ptr AppEvent)

  PluginInfo* = object
    name*: cstring

  PluginApi* = object
    getApi*: proc(api: ApiType): pointer {.cdecl.}

  AppEvent* = object

  AppApi* = object
    width*: proc(): int32 {.cdecl.}
    height*: proc(): int32 {.cdecl.}
    name*: proc(): cstring {.cdecl.}
    windowSize*: proc(sizie: ptr Float2f) {.cdecl.}
  
  ShaderStage* = distinct uint32

  ShaderReflInput* = object
    name*: cstring
    semantic*: cstring
    semanticIndex*: int32
    vertexFormat*: sgfx.VertexFormat

  ShaderRefl* = object

  ShaderInfo* = object
    inputs*: array[maxVertexAttributes, ShaderReflInput]
    numInputs*: int32
    nameHandle*: uint32

  Shader* = object
    shd*: sgfx.Shader
    info*: ShaderInfo

  GfxApi* = object
    registerStage*: proc(name: cstring; parentStage: GfxStage): GfxStage {.cdecl.}
    makeShaderWithData*: proc(vsDataSize: uint32; vsData: openArray[uint32];
        vsReflSize: uint32; vsReflJson: openArray[uint32]; fsDataSize: uint32;
        fsData: openArray[uint32]; fsReflSize: uint32; fsReflJson: openArray[uint32]): Shader {.cdecl.}

  VfsAsyncReadCallback* = proc(path: cstring; mem: ptr MemBlock;
      userData: pointer) {.cdecl.}
  VfsAsyncWriteCallback* = proc(path: cstring; bytesWritten: int64;
      mem: ptr MemBlock; userData: pointer) {.cdecl.}

  VfsFlag* = distinct uint32

  VfsApi* = object
    mount*: proc(path, alias: cstring; watch: bool): bool {.cdecl.}
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
        mem: ptr MemBlock): AssetLoadData {.cdecl.}
    onFinalize*: proc(data: ptr AssetLoadData; params: ptr AssetLoadParams;
        mem: ptr MemBlock): AssetLoadData {.cdecl.}
    onReload*: proc(handle: AssetHandle; prevAsset: Asset) {.cdecl.}
    onRelease*: proc(asset: Asset) {.cdecl.}

  AssetApi* = object
    registerAssetType*: proc(name: cstring; callbacks: AssetCallbacks; paramsTypeName: cstring; paramsSize: int32;
                             failedObj, asyncObj: Asset;
                                 forcedFlags: AssetLoadFlag) {.cdecl.}
    load*: proc(name: cstring; path: cstring; params: pointer;
        flags: AssetLoadFlag; tags: uint32): AssetHandle {.cdecl.}

  Camera* = object
    forward*: Float3f
    right*: Float3f
    up*: Float3f
    pos*: Float3f

    quat*: Float4f
    ffar*: float32
    fnear*: float32
    fov*: float32
    viewport*: Rectangle

  FpsCamera* = object
    cam*: Camera
    pitch*: float32
    yaw*: float32

  CameraApi* = object
    initFps*: proc(cam: ptr FpsCamera; fovDeg: float32; viewport: Rectangle;
        fnear, ffar: float32) {.cdecl.}
    lookAtFps*: proc(cam: ptr FpsCamera; pos, target, up: Float3f) {.cdecl.}

  JobPriority* = enum
    jpHigh
    jpNormal
    jpLow
    jpCount

  Job* = ptr Atomic[int32]

template toId*(idx: int): uint32 = idx.uint32 + 1
template toIndex*(id: uint32): int = id.int - 1

const
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

  ssVs* = ShaderStage(0)
  ssFs* = ShaderStage(1)
  ssCs* = ShaderStage(2)
  ssCount* = ShaderStage(3)

converter toUint32*(lf: AssetLoadFlag): uint32 = uint32(lf)
converter toLoadFlag*(lf: uint32): AssetLoadFlag = AssetLoadFlag(lf)

converter toUint32*(lf: VfsFlag): uint32 = uint32(lf)
converter toVfsFlag*(lf: uint32): VfsFlag = VfsFlag(lf)

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
  proc closePlugin*(ctx: ptr Plugin) {.importc: "cr_plugin_close".}

when isMainModule:
  dumpTree:
    var ctx {.fragState.}: ShellShockedState