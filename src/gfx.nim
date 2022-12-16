import std/[atomics, hashes, json, jsonutils, locks, os, sequtils, strformat],
       sokol/gfx as sgfx, sokol/glue as sglue,
       api, fuse, logging, io, primer

type
  SgsChunk {.packed.} = object
    lang: uint32
    profileVer: uint32

  SgsChunkRefl {.packed.} = object
    name: array[32, char]
    numInputs: int32
    numTextures: uint32
    numUniformBuffers: uint32
    numStorageImages: uint32
    numStorageBuffers: uint32
    flattenUbos: uint16
    debugInfo: uint16

  SgsChunkCsRefl {.packed.} = object
    numStorageImages: uint32
    numStorageBuffers: uint32

  SgsReflInput {.packed.} = object
    name: array[32, char]
    loc: int32
    semantic: array[32, char]
    semanticIndex: uint32
    format: uint32

  SgsReflTexture {.packed.} = object
    name: array[32, char]
    binding: int32
    imageDim: uint32
    multisample: uint8
    isArray: uint8

  SgsReflBuffer {.packed.} = object
    name: array[32, char]
    binding: int32
    sizeBytes: uint32
    arrayStride: uint32

  SgsReflUniformBuffer {.packed.} = object
    name: array[32, char]
    binding: int32
    sizeBytes: uint32
    arraySize: uint16

  ShaderSetupStageDesc = object
    refl: ref ShaderRefl
    code: pointer
    codeSize: int

  StageState = distinct uint32

  Stage = object
    name: array[32, char]
    nameHash: Hash
    state: StageState
    parent: GfxStage
    child: GfxStage
    next: GfxStage
    prev: GfxStage
    order: uint16
    enabled: bool
    singleEnabled: bool

  Command = distinct uint32

  RunCommandCallback = proc(buff: ptr UncheckedArray[uint8], offset: int): tuple[buff: ptr UncheckedArray[uint8], offset: int]

  CommandBufferRef = object
    key: uint32
    cmdBufferIdx: int
    cmd: Command
    paramsOffset: int

  CommandBuffer = object
    paramsBuffer: seq[uint8]
    refs: seq[CommandBufferRef]
    runningStage: GfxStage
    index: int
    stageOrder: uint16
    cmdIdx: uint16
  
  StreamBuffer = object
    buf: Buffer
    offset: Atomic[uint32]
    size: int

  GfxState = object
    stages: seq[Stage]
    cmdBuffersFeed: seq[CommandBuffer]
    cmdBuffersRender: seq[CommandBuffer]
    stageLock: Lock

    streamBuffers: seq[StreamBuffer]

    currentStageName: array[32, char]


const
  MaxStages = 1024
  MaxDepth = 64

  StageOrderDepthBits = 6
  StageOrderDepthMask = 0xfc00
  StageOrderIdBits = 10
  StageOrderIdMask = 0x03ff

  CheckerTextureSize = 128

  cmdBeginDefaultPass = Command(0)
  cmdBeginPass = Command(1)
  cmdApplyViewport = Command(2)
  cmdApplyScissorRect = Command(3)
  cmdApplyPipeline = Command(4)
  cmdApplyBindings = Command(5)
  cmdApplyUniforms = Command(6)
  cmdDraw = Command(7)
  cmdDispatch = Command(8)
  cmdFinishPass = Command(9)
  cmdUpdateBuffer = Command(10)
  cmdUpdateImage = Command(11)
  cmdAppendBuffer = Command(12)
  cmdBeginProfile = Command(13)
  cmdFinishProfile = Command(14)
  cmdStagePush = Command(15)
  cmdStagePop = Command(16)
  cmdCount = Command(17)

  SgsChunkCC = makeFourCC('S', 'G', 'S', ' ')
  SgsChunkStagCC = makeFourCC('S', 'T', 'A', 'G')
  SgsChunkReflCC = makeFourCC('R', 'E', 'F', 'L')
  SgsChunkCodeCC = makeFourCC('C', 'O', 'D', 'E')
  SgsChunkDataCC = makeFourCC('D', 'A', 'T', 'A')

  SgsLangGlesCC = makeFourCC('G', 'L', 'E', 'S')
  SgsLangHlslCC = makeFourCC('H', 'L', 'S', 'L')
  SgsLangGlslCC = makeFourCC('G', 'L', 'S', 'L')
  SgsLangMslCC = makeFourCC('M', 'S', 'L', ' ')

  SgsVertexFormatFloatCC = makeFourCC('F', 'L', 'T', '1')
  SgsVertexFormatFloat2CC = makeFourCC('F', 'L', 'T', '2')
  SgsVertexFormatFloat3CC = makeFourCC('F', 'L', 'T', '3')
  SgsVertexFormatFloat4CC = makeFourCC('F', 'L', 'T', '4')
  SgsVertexFormatIntCC = makeFourCC('I', 'N', 'T', '1')
  SgsVertexFormatInt2CC = makeFourCC('I', 'N', 'T', '2')
  SgsVertexFormatInt3CC = makeFourCC('I', 'N', 'T', '3')
  SgsVertexFormatInt4CC = makeFourCC('I', 'N', 'T', '4')

  SgsStageVertexCC = makeFourCC('V', 'E', 'R', 'T')
  SgsStageFragmentCC = makeFourCC('F', 'R', 'A', 'G')
  SgsStageComputeCC = makeFourCC('C', 'O', 'M', 'P')

  SgsImageDim1DCC = makeFourCC('1', 'D', ' ', ' ')
  SgsImageDim2DCC = makeFourCC('2', 'D', ' ', ' ')
  SgsImageDim3DCC = makeFourCC('3', 'D', ' ', ' ')
  SgsImageDimCubeCC = makeFourCC('C', 'U', 'B', 'E')
  SgsImageDimRectCC = makeFourCC('R', 'E', 'C', 'T')
  SgsImageDimBufferCC = makeFourCC('B', 'U', 'F', 'F')
  SgsImageDimSubpassCC = makeFourCC('S', 'U', 'B', 'P')

  ssNone = StageState(0)
  ssSubmitting = StageState(1)
  ssDone = StageState(2)

var
  ctx: GfxState

proc `==`*(a, b: Command): bool {.borrow.}
proc `<`*(a, b: CommandBufferRef): bool =
  result = a.key < b.key
proc `<=`*(a, b: CommandBufferRef): bool =
  result = a.key <= b.key

proc `==`*(a, b: StageState): bool {.borrow.}

proc strToShaderLang(s: string): ShaderLang =
  case s:
  of "gles":
    result = slGles
  of "hlsl":
    result = slHlsl
  of "msl":
    result = slMsl
  of "glsl":
    result = slGlsl
  else:
    result = slCount

proc strToShaderVertexFormat(s: string): VertexFormat =
  case s:
  of "float":
    result = vertexFormatFloat
  of "float2":
    result = vertexFormatFloat2
  of "float3":
    result = vertexFormatFloat3
  of "float4":
    result = vertexFormatFloat4
  of "byte4":
    result = vertexFormatByte4
  of "ubyte4":
    result = vertexFormatUbyte4
  of "ubyte4n":
    result = vertexFormatUbyte4n
  of "short2":
    result = vertexFormatShort2
  of "short2n":
    result = vertexFormatShort2n
  of "short4":
    result = vertexFormatShort4
  of "short4n":
    result = vertexFormatShort4n
  of "uint10n2":
    result = vertexFormatUint10N2
  else:
    result = vertexFormatNum

proc strToShaderTextureType(s: string; arr: bool): ImageType =
  case s:
  of "2d":
    result = if arr: imageTypeArray else: imageType2d
  of "3d":
    result = imageType3d
  of "cube":
    result = imageTypeCube
  else:
    result = imageTypeDefault

proc onPrepareShader(params: ptr AssetLoadParams;
        mem: ptr MemBlock): AssetLoadData {.cdecl.} =
  block outer:
    let shader = cast[ptr api.Shader](alloc0(sizeof(api.Shader)))
    if isNil(shader):
      result.asset = Asset(id: 0)
      break outer

    let info = addr(shader.info)

    var reader: MemReader
    initMemReader(addr(reader), mem.data, mem.size)

    var sgs: uint32
    readVar(addr(reader), sgs)
    if sgs != SgsChunkCC:
      assert false, "invalid sgs file"
      result.asset = Asset(id: 0)
      break outer

proc onLoadShader(data: ptr AssetLoadData; params: ptr AssetLoadParams;
        mem: ptr MemBlock): AssetLoadData {.cdecl.} =
  result

proc onFinalizeShader(data: ptr AssetLoadData; params: ptr AssetLoadParams;
        mem: ptr MemBlock): AssetLoadData {.cdecl.} =
  result

proc onReloadShader(handle: AssetHandle; prevAsset: Asset) {.cdecl.} =
  discard

proc onReleaseShader(asset: Asset) {.cdecl.} =
  discard

proc runBeginDefaultPassCb(buff: ptr UncheckedArray[uint8], offset: int): tuple[buff: ptr UncheckedArray[uint8], offset: int] =
  var curOffset = offset

  let passAction = cast[ptr PassAction](addr(buff[curOffset]))
  curOffset += sizeof(PassAction)
  let width = cast[ptr int32](addr(buff[curOffset]))
  curOffset += sizeof(int32)
  let height = cast[ptr int32](addr(buff[curOffset]))
  curOffset += sizeof(int32)

  cBeginDefaultPass(passAction, width[], height[])

  result = (buff: buff, offset: curOffset)

proc runBeginPassCb(buff: ptr UncheckedArray[uint8], offset: int): tuple[buff: ptr UncheckedArray[uint8], offset: int] =
  # echo "running begin pass callback!"
  # let passAction = cast[ptr PassAction](buff)
  # buff += sizeof(PassAction)
  # let pass = cast[ptr Pass](buff)[]
  # buff += sizeof(Pass)
  # sgfx.cBeginPass(pass, passAction)
  # result = (buff, 0)
  discard

proc runApplyViewportCb(buff: ptr UncheckedArray[uint8], offset: int): tuple[buff: ptr UncheckedArray[uint8], offset: int] =
  discard

proc runApplyScissorRectCb(buff: ptr UncheckedArray[uint8], offset: int): tuple[buff: ptr UncheckedArray[uint8], offset: int] =
  discard

proc runApplyPipelineCb(buff: ptr UncheckedArray[uint8], offset: int): tuple[buff: ptr UncheckedArray[uint8], offset: int] =
  discard

proc runApplyBindingsCb(buff: ptr UncheckedArray[uint8], offset: int): tuple[buff: ptr UncheckedArray[uint8], offset: int] =
  discard

proc runApplyUniformsCb(buff: ptr UncheckedArray[uint8], offset: int): tuple[buff: ptr UncheckedArray[uint8], offset: int] =
  discard

proc runDrawCb(buff: ptr UncheckedArray[uint8], offset: int): tuple[buff: ptr UncheckedArray[uint8], offset: int] =
  discard

proc runDispatchCb(buff: ptr UncheckedArray[uint8], offset: int): tuple[buff: ptr UncheckedArray[uint8], offset: int] =
  discard

proc runFinishPassCb(buff: ptr UncheckedArray[uint8], offset: int): tuple[buff: ptr UncheckedArray[uint8], offset: int] =
  cEndPass()
  result = (buff: buff, offset: offset)

proc runUpdateBufferCb(buff: ptr UncheckedArray[uint8], offset: int): tuple[buff: ptr UncheckedArray[uint8], offset: int] =
  discard

proc runUpdateImageCb(buff: ptr UncheckedArray[uint8], offset: int): tuple[buff: ptr UncheckedArray[uint8], offset: int] =
  discard

proc runAppendBufferCb(buff: ptr UncheckedArray[uint8], offset: int): tuple[buff: ptr UncheckedArray[uint8], offset: int] =
  discard

proc runBeginProfileSampleCb(buff: ptr UncheckedArray[uint8], offset: int): tuple[buff: ptr UncheckedArray[uint8], offset: int] =
  discard

proc runEndProfileSampleCb(buff: ptr UncheckedArray[uint8], offset: int): tuple[buff: ptr UncheckedArray[uint8], offset: int] =
  discard

proc runBeginStageCb(buff: ptr UncheckedArray[uint8], offset: int): tuple[buff: ptr UncheckedArray[uint8], offset: int] =
  var curOffset = offset

  let name = cast[cstring](addr(buff[curOffset]))
  curOffset += 32

  discard copyStr(ctx.currentStageName, name)

  result = (buff: buff, offset: curOffset)

proc runFinishStageCb(buff: ptr UncheckedArray[uint8], offset: int): tuple[buff: ptr UncheckedArray[uint8], offset: int] =
  ctx.currentStageName[0] = '\0'
  result = (buff: buff, offset: offset)

const runCommandCallbacks = [
    runBeginDefaultPassCb,
    runBeginPassCb,
    runApplyViewportCb,
    runApplyScissorRectCb,
    runApplyPipelineCb,
    runApplyBindingsCb,
    runApplyUniformsCb,
    runDrawCb,
    runDispatchCb,
    runFinishPassCb,
    runUpdateBufferCb,
    runUpdateImageCb,
    runAppendBufferCb,
    runBeginProfileSampleCb,
    runEndProfileSampleCb,
    runBeginStageCb,
    runFinishStageCb
  ]

proc initParamsBuff(cb: ptr CommandBuffer; size: int;
    offset: var int): ptr uint8 =
  block outer:
    if size == 0:
      break outer

    let currentLen = len(cb.paramsBuffer)
    setLen(cb.paramsBuffer, currentLen + int(alignMask(size, NaturalAlignment - 1)))
    offset = int(addr(cb.paramsBuffer[currentLen]) - addr(cb.paramsBuffer[0]))

    result = addr(cb.paramsBuffer[currentLen])

proc recordBeginStage(name: cstring; nameSize: int) =
  assert(nameSize == 32)

  let cb = addr(ctx.cmdBuffersFeed[coreApi.jobThreadIndex()])

  assert(bool(cb.runningStage.id), "draw related calls must come between begin_stage and end_stage")
  assert(cb.cmdIdx < uint16.high, "maximum number of graphics calls exceeded")

  var offset = 0
  let buff = initParamsBuff(cb, len(name), offset)

  let r = CommandBufferRef(
    key: uint32(cb.stageOrder shl 16) or uint32(cb.cmdIdx),
    cmdBufferIdx: cb.index,
    cmd: cmdStagePush,
    paramsOffset: offset
  )

  add(cb.refs, r)
  inc(cb.cmdIdx)
  copyMem(addr(buff[0]), name, nameSize)

proc beginStage(stage: GfxStage): bool {.cdecl.} =
  let cb = addr(ctx.cmdBuffersFeed[coreApi.jobThreadIndex()])

  var
    stg: ptr Stage
    stageName: cstring

  block outer:
    acquire(ctx.stageLock)
    stg = addr(ctx.stages[toIndex(stage.id)])
    assert(stg.state == ssNone, "already called begin on this stage")

    if not stg.enabled:
      release(ctx.stageLock)
      break outer

    stg.state = ssSubmitting
    cb.runningStage = stage
    cb.stageOrder = stg.order
    stageName = cast[cstring](addr(stg.name[0]))
    release(ctx.stageLock)

    recordBeginStage(cast[cstring](addr(stg.name[0])), len(stg.name))

    result = true

proc recordFinishStage() =
  let cb = addr(ctx.cmdBuffersFeed[coreApi.jobThreadIndex()])

  assert(bool(cb.runningStage.id), "draw related calls must come between begin_stage and end_stage")
  assert(cb.cmdIdx < uint16.high, "maximum number of graphics calls exceeded")

  let r = CommandBufferRef(
    key: uint32(cb.stageOrder shl 16) or uint32(cb.cmdIdx),
    cmdBufferIdx: cb.index,
    cmd: cmdStagePop,
    paramsOffset: len(cb.paramsBuffer)
  )

  add(cb.refs, r)

  inc(cb.cmdIdx)

proc finishStage() {.cdecl.} =
  let cb = addr(ctx.cmdBuffersFeed[coreApi.jobThreadIndex()])
  assert(bool(cb.runningStage.id), "must invoke `beginStage` before invoking this procedure")

  acquire(ctx.stageLock)
  let stage = addr(ctx.stages[toIndex(cb.runningStage.id)])
  assert(stage.state == ssSubmitting, "must call `begin` on this stage first")
  stage.state = ssDone
  release(ctx.stageLock)

  recordFinishStage()
  cb.runningStage.id = 0

proc beginDefaultPass(passAction: ptr PassAction; width, height: int32) {.cdecl.} =
  let cb = addr(ctx.cmdBuffersFeed[coreApi.jobThreadIndex()])

  assert(bool(cb.runningStage.id), "must invoke `beginStage` before invoking this procedure")
  assert(cb.cmdIdx < uint16.high, "maximum number of graphics calls exceeded")

  var offset = 0
  var buff = initParamsBuff(cb, sizeof(PassAction) + sizeof(int32) * 2, offset)

  let r = CommandBufferRef(
    key: uint32(cb.stageOrder shl 16) or uint32(cb.cmdIdx),
    cmdBufferIdx: cb.index,
    cmd: cmdBeginDefaultPass,
    paramsOffset: offset
  )

  add(cb.refs, r)
  inc(cb.cmdIdx)

  copyMem(addr(buff[0]), passAction, sizeof(passAction[]))
  buff += sizeof(passAction[])
  cast[ptr int](buff)[] = width
  buff += sizeof(int32)
  cast[ptr int](buff)[] = height

proc finishPass() {.cdecl.} =
  let cb = addr(ctx.cmdBuffersFeed[coreApi.jobThreadIndex()])

  assert(bool(cb.runningStage.id), "must invoke `beginStage` before invoking this procedure")
  assert(cb.cmdIdx < uint16.high, "maximum number of graphics calls exceeded")

  var offset = 0
  var buff = initParamsBuff(cb, sizeof(PassAction) + sizeof(int32) * 2, offset)

  let r = CommandBufferRef(
    key: uint32(cb.stageOrder shl 16) or uint32(cb.cmdIdx),
    cmdBufferIdx: cb.index,
    cmd: cmdFinishPass,
    paramsOffset: len(cb.paramsBuffer)
  )

  add(cb.refs, r)
  inc(cb.cmdIdx)

proc validateStageDependencies() =
  acquire(ctx.stageLock)
  for i in 0 ..< len(ctx.stages):
    let stage = addr(ctx.stages[i])
    if stage.state == ssDone and bool(stage.parent.id):
      let parent = addr(ctx.stages[toIndex(stage.parent.id)])
      if parent.state != ssDone:
        assert(
          false,
          &"attempting to execute stage {stage.name} which depends on {parent.name}, however {parent.name} is not rendered"
        )

proc executeCommandBuffer(cmds: var seq[CommandBuffer]): int =
  assert(coreApi.jobThreadIndex() == 0, "`executeCommandBuffer` must be invoked from main thread")
  # static:
  #   assert(sizeof())

  var cmdCount = 0
  let cmdBufferCount = coreApi.numJobThreads()

  for i in 0 ..< cmdBufferCount:
    let cb = addr(cmds[i])
    assert(cb.runningStage.id == 0, "command buffers must submit all calls and invoke `end_stage`")
    cmdCount += len(cb.refs)

  if bool(cmdCount):
    var 
      refs = newSeq[CommandbufferRef](cmdCount)
      curRefCount = 0

    for i in 0 ..< cmdBufferCount:
      let
        cb = addr(cmds[i])
        refCount = len(cb.refs)
      if bool(refCount):
        refs[curRefCount..(curRefCount + refCount - 1)] = cb.refs
        curRefCount += refCount
        setLen(cb.refs, 0)

    timSort(refs)

    for i in 0 ..< cmdCount:
      let
        r = addr(refs[i])
        cb = addr(cmds[r.cmdBufferIdx])
      
      discard runCommandCallbacks[int(r.cmd)](cast[ptr UncheckedArray[uint8]](addr(cb.paramsBuffer[0])), r.paramsOffset)
  
  for i in 0 ..< cmdBufferCount:
    setLen(cmds[i].paramsBuffer, 0)
    cmds[i].cmdIdx = 0
  
  result = cmdCount

proc executeCommandBuffers*() =
  validateStageDependencies()

  discard executeCommandBuffer(ctx.cmdBuffersRender)
  discard executeCommandBuffer(ctx.cmdBuffersFeed)

  for i in 0 ..< len(ctx.stages):
    ctx.stages[i].state = ssNone
  
  for i in 0 ..< len(ctx.streamBuffers):
    store(ctx.streamBuffers[i].offset, 0)

proc addChildStage(parent, child: GfxStage) =
  assert parent.id.bool
  assert child.id.bool

  let
    pParent = ctx.stages[parent.id.toIndex()].addr
    pChild = ctx.stages[child.id.toIndex()].addr

  if pParent.child.id.bool:
    let pFirstChild = ctx.stages[pParent.child.id.toIndex()].addr
    pFirstChild.prev = child
    pChild.next = pParent.child

  pParent.child = child

proc registerStage(name: cstring; parentStage: GfxStage): GfxStage {.cdecl.} =
  assert parentStage.id == 0 or parentStage.id <= ctx.stages.len().uint32
  assert ctx.stages.len() < MaxStages, "exceeded max stages"

  var stage = Stage(
    nameHash: hash(name),
    parent: parentStage,
    enabled: true,
    singleEnabled: true
  )
  copyStr(stage.name, name)

  result.id = toId(ctx.stages.len())

  var depth = 0'u16
  if parentStage.id.bool:
    let parentDepth = (ctx.stages[toIndex(
        parentStage.id)].order shr StageOrderDepthBits) and StageOrderDepthMask
    depth = parentDepth + 1

  assert depth < MaxDepth, "exceeded max stage dependency depth"

  stage.order = ((depth shl StageOrderDepthBits) and StageOrderDepthMask) or (
      toIndex(result.id) and StageOrderIdMask).uint16
  ctx.stages.add(stage)

  if parentStage.id.bool:
    parentStage.addChildStage(result)

proc fromJsonHook(a: var ShaderReflInput; b: JsonNode) =
  a.name = b{"name"}.getStr("")
  a.semantic = b{"semantic"}.getStr("")
  a.semanticIndex = b{"semantic_index"}.getInt(0)
  a.vertexFormat = strToShaderVertexFormat(b{"type"}.getStr(""))

proc fromJsonHook(a: var ShaderReflUniformBuffer; b: JsonNode) =
  a.name = b{"name"}.getStr("")
  a.numBytes = b{"block_size"}.getInt(0)
  a.binding = b{"binding"}.getInt(0)
  a.arraySize = b{"array"}.getInt(0)

proc fromJsonHook(a: var ShaderReflTexture; b: JsonNode) =
  a.name = b{"name"}.getStr("")
  a.binding = b{"binding"}.getInt(0)
  a.imageType = strToShaderTextureType(b{"dimension"}.getStr(""), b{
      "array"}.getBool(false))

proc fromJsonHook(a: var ShaderReflBuffer; b: JsonNode) =
  a.name = b{"name"}.getStr("")
  a.numBytes = b{"block_size"}.getInt(0)
  a.binding = b{"binding"}.getInt(0)
  a.arrayStride = b{"unsized_array_stride"}.getInt(1)

proc fromJsonHook(a: var ShaderRefl; b: JsonNode) =
  block outer:
    a.lang = strToShaderLang(b{"language"}.getStr(""))

    var jStage: JsonNode
    block determineStage:
      jStage = b{"vs"}
      if jStage != nil:
        a.stage = ssVs
        break determineStage

      jStage = b{"fs"}
      if jStage != nil:
        a.stage = ssFs
        break determineStage

      jStage = b{"cs"}
      if jStage != nil:
        a.stage = ssCs
        break determineStage

      a.stage = ssCount

    if a.stage == ssCount or a.stage == ssCs:
      logError("failed parsing shader reflection data: no valid stages")
      break outer

    a.profileVersion = b{"profile_version"}.getInt(0)
    a.codeType = if b{"bytecode"}.getBool(false): sctBytecode else: sctSource
    a.flattenUbos = b{"flatten_ubos"}.getBool(false)
    a.sourceFile = lastPathPart(jStage{"file"}.getStr(""))

    if a.stage == ssVs:
      let jInputs = jStage{"inputs"}
      if jInputs != nil:
        a.inputs.setLen(jInputs.len())
        for i, input in jInputs.getElems(@[]):
          fromJsonHook(a.inputs[i], input)

    let jUniformBuffers = jStage{"uniform_buffers"}
    if jUniformBuffers != nil:
      a.uniformBuffers.setLen(jUniformBuffers.len())
      for i, uniformBuffer in jUniformBuffers.getElems(@[]):
        fromJsonHook(a.uniformBuffers[i], uniformBuffer)
        if a.uniformBuffers[i].arraySize > 1:
          assert(not a.flattenUbos, "uniform buffer array should be generated with --flatten-ubos")

    let jTextures = jStage{"textures"}
    if jTextures != nil:
      a.textures.setLen(jTextures.len())
      for i, texture in jTextures.getElems(@[]):
        fromJsonHook(a.textures[i], texture)

    let jStorageImages = jStage{"storage_images"}
    if jStorageImages != nil:
      a.storageImages.setLen(jStorageImages.len())
      for i, storageImage in jStorageImages.getElems(@[]):
        fromJsonHook(a.storageImages[i], storageImage)

    let jStorageBuffers = jStage{"storage_buffers"}
    if jStorageBuffers != nil:
      a.storageBuffers.setLen(jStorageBuffers.len())
      for i, storageBuffer in jStorageBuffers.getElems(@[]):
        fromJsonHook(a.storageBuffers[i], storageBuffer)

proc parseShaderReflectJson(stageReflJson: cstring;
    stageReflJsonLen: int): ref ShaderRefl =
  block outer:
    result = new ShaderRefl

    try:
      fromJsonHook(result[], parseJson($stageReflJson))
    except:
      logError("failed parsing shader reflection json")
      break outer

proc setupShaderDesc(desc: ptr ShaderDesc; vsRefl: ref ShaderRefl; vs: pointer;
    vsSize: int; fsRefl: ref ShaderRefl; fs: pointer; fsSize: int;
    nameHandle: ptr uint32): ptr ShaderDesc {.cdecl.} =
  desc[] = ShaderDesc()

  let
    numStages = 2
    stages = [
      ShaderSetupStageDesc(refl: vsRefl, code: vs, codeSize: vsSize),
      ShaderSetupStageDesc(refl: fsRefl, code: fs, codeSize: fsSize)
    ]

  if nameHandle != nil:
    desc.label = cstring(fsRefl.sourceFile)

  for i in 0 ..< numStages:
    let stage = addr(stages[i])
    var stageDesc: ptr ShaderStageDesc

    case stage.refl.stage:
    of ssVs:
      stageDesc = addr(desc.vs)
      stageDesc.d3d11Target = "vs_5_0"
    of ssFs:
      stageDesc = addr(desc.fs)
      stageDesc.d3d11Target = "ps_5_0"
    else:
      assert(false, "not implemented")
      break

    if stage.refl.codeType == sctBytecode:
      stageDesc.bytecode.`addr` = cast[ptr UncheckedArray[uint8]](stage.code)
      stageDesc.byteCode.size = stage.codeSize
    elif stage.refl.codeType == sctSource:
      stageDesc.source = cast[cstring](stage.code)

    if stage.refl.stage == ssVs:
      for a in 0 ..< len(vsRefl.inputs):
        desc.attrs[a].name = cstring(vsRefl.inputs[a].name)
        desc.attrs[a].semName = cstring(vsRefl.inputs[a].semantic)
        desc.attrs[a].semIndex = int32(vsRefl.inputs[a].semanticIndex)

    for iub in 0 ..< len(stage.refl.uniformBuffers):
      let
        rub = addr(stage.refl.uniformBuffers[iub])
        ub = addr(stageDesc.uniformBlocks[rub.binding])
      ub.size = rub.numBytes
      if stage.refl.flattenUbos:
        ub.uniforms[0].arrayCount = int32(rub.arraySize)
        ub.uniforms[0].name = cstring(rub.name)
        ub.uniforms[0].`type` = uniformTypeFloat4

    for itex in 0 ..< len(stage.refl.textures):
      let
        rTex = addr(stage.refl.textures[itex])
        img = addr(stageDesc.images[rTex.binding])
      img.name = cstring(rTex.name)
      img.imageType = rTex.imageType

  result = desc

proc makeShaderWithData(vsDataSize: uint32; vsData: ptr UncheckedArray[uint32];
        vsReflSize: uint32; vsReflJson: ptr UncheckedArray[uint32];
            fsDataSize: uint32;
        fsData: ptr UncheckedArray[uint32]; fsReflSize: uint32;
            fsReflJson: ptr UncheckedArray[uint32]): api.Shader {.cdecl.} =

  var shaderDesc: ShaderDesc
  let
    vsRefl = parseShaderReflectJson(cast[cstring](addr(vsReflJson[0])), int(
        vsReflSize) - 1)
    fsRefl = parseShaderReflectJson(cast[cstring](addr(fsReflJson[0])), int(
        fsReflSize) - 1)

  result.shd = gfxApi.makeShader(
    setupShaderDesc(addr(shaderDesc), vsRefl, vsData, int32(vsDataSize), fsRefl,
        fsData, int32(fsDataSize), addr(result.info.nameHandle))
  )

proc initShaders*() =
  assetApi.registerAssetType(
    "shader",
    AssetCallbacks(
      onPrepare: onPrepareShader,
      onLoad: onLoadShader,
      onFinalize: onFinalizeShader,
      onReload: onReloadShader,
      onRelease: onReleaseShader
    ),
    nil,
    0,
    Asset(p: nil),
    Asset(p: nil),
    alfWaitOnLoad
  )

proc initCommandBuffers() =
  let numThreads = coreApi.numJobThreads()

  setLen(ctx.cmdBuffersFeed, numThreads)
  setLen(ctx.cmdBuffersRender, numThreads)

  for i in 0 ..< numThreads:
    ctx.cmdBuffersFeed[i].index = i
    ctx.cmdBuffersRender[i].index = i

proc init*() =
  sgfx.setup(Desc(context: sglue.context()))

  initLock(ctx.stageLock)

  initCommandBuffers()

  initShaders()

proc shutdown*() =
  deinitLock(ctx.stageLock)

  sgfx.shutdown()

gfxApi = GfxApi(
  staged: GfxDrawApi(
    begin: beginStage,
    finish: finishStage,
    beginDefaultPass: beginDefaultPass,
    finishPass: finishPass
  ),
  makeShader: cMakeShader,
  registerStage: registerStage,
  makeShaderWithData: makeShaderWithData,
)
