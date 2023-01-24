import std/[atomics, hashes, json, jsonutils, locks, os, sequtils, strformat],
       sokol/gfx as sgfx, sokol/glue as sglue, stb_image,
       api, fuse, logging, io, primer

type
  SgsIffChunk = object
    pos: int64
    size: uint32
    fourCC: uint32
    parentId: int32

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

  RunCommandCallback = proc(buff: ptr UncheckedArray[uint8],
      offset: int): tuple[buff: ptr UncheckedArray[uint8], offset: int]

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

  TextureManager = object
    whiteTexture: Texture
    blackTexture: Texture
    checkerTexture: Texture
    defaultMinFilter: Filter
    defaultMagFilter: Filter
    defaultAniso: int32
    defaultFirstMip: int32

  GfxState = object
    stages: seq[Stage]
    cmdBuffersFeed: seq[CommandBuffer]
    cmdBuffersRender: seq[CommandBuffer]
    stageLock: Lock
    textureManager: TextureManager

    streamBuffers: seq[StreamBuffer]

    currentStageName: array[32, char]

    lastShaderError: bool


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
  cmdDispatchIndirect = Command(9)
  cmdDrawIndexedInstancedIndirect = Command(10)
  cmdFinishPass = Command(11)
  cmdUpdateBuffer = Command(12)
  cmdUpdateImage = Command(13)
  cmdAppendBuffer = Command(14)
  cmdBeginProfile = Command(15)
  cmdFinishProfile = Command(16)
  cmdStagePush = Command(17)
  cmdStagePop = Command(18)
  cmdCount = Command(19)

  SgsChunkCC = makeFourCC('S', 'G', 'S', ' ')
  SgsChunkStageCC = makeFourCC('S', 'T', 'A', 'G')
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

proc fourCCToShaderLang(fourCC: uint32): ShaderLang =
  if fourCC == SgsLangGlesCC:
    result = slGles
  elif fourCC == SgsLangHlslCC:
    result = slHlsl
  elif fourCC == SgsLangMslCC:
    result = slMsl
  elif fourCC == SgsLangGlslCC:
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

proc fourCCToShaderVertexFormat(fourCC: uint32;
    semantic: cstring): VertexFormat =
  if fourCC == SgsVertexFormatFloatCC:
    result = vertexFormatFloat
  elif fourCC == SgsVertexFormatFloat2CC:
    result = vertexFormatFloat2
  elif fourCC == SgsVertexFormatFloat3CC:
    result = vertexFormatFloat3
  elif fourCC == SgsVertexFormatFloat4CC and semantic == "COLOR":
    result = vertexFormatFloat4
  elif fourCC == SgsVertexFormatFloat4CC:
    result = vertexFormatFloat4
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

proc fourCCToShaderTextureType(fourCC: uint32; isArray: bool): ImageType =
  block outer:
    if isArray and fourCC == SgsImageDim2DCC:
      result = imageTypeArray
      break outer
    elif not isArray:
      if fourCC == SgsImageDim2DCC:
        result = imageType2d
        break outer
      elif fourCC == SgsImageDim3DCC:
        result = imageType3d
        break outer
      elif fourCC == SgsImageDimCubeCC:
        result = imageTypeCube
        break outer

    result = imageTypeDefault

proc getSgsIffChunk(reader: ptr MemReader; size: int64;
    fourCC: uint32): SgsIffChunk =
  block outer:
    var e: int64 = if size > 0: min(reader.pos + size,
        reader.top) else: reader.top
    e -= 8
    if reader.pos >= e:
      result.pos = -1
      break outer

    var ch = (cast[ptr uint32](addr(reader.data[reader.pos])))[]
    if ch == fourCC:
      var chunkSize: uint32
      reader.pos += sizeof(uint32)
      readVar(reader, chunkSize)
      result.pos = reader.pos
      result.size = chunkSize
      break outer

    let buff = reader.data
    for offset in reader.pos ..< e:
      ch = (cast[ptr uint32](addr(buff[offset])))[]
      if ch == fourCC:
        var chunkSize: uint32
        reader.pos = offset + sizeof(uint32)
        readVar(reader, chunkSize)
        result.pos = reader.pos
        result.size = chunkSize
        break outer

    result.pos = -1

proc parseShaderReflectBin(reflData: pointer;
    reflSize: uint32): ref ShaderRefl =
  var r: MemReader
  initMemReader(addr(r), reflData, int64(reflSize))

  var reflChunk: SgsChunkRefl
  readVar(addr(r), reflChunk)

  result = new(ShaderRefl)
  copyStr(result.sourceFile, reflChunk.name)
  result.flattenUbos = bool(reflChunk.flattenUbos)
  setLen(result.inputs, reflChunk.numInputs)
  setLen(result.uniformBuffers, reflChunk.numUniformBuffers)
  setLen(result.textures, reflChunk.numTextures)
  setLen(result.storageImages, reflChunk.numStorageImages)
  setLen(result.storageBuffers, reflChunk.numStorageBuffers)

  if bool(reflChunk.numInputs):
    for i in 0 ..< reflChunk.numInputs:
      var input: SgsReflInput
      readVar(addr(r), input)
      result.inputs[i].semanticIndex = int32(input.semanticIndex)
      result.inputs[i].vertexFormat = fourCCToShaderVertexFormat(input.format,
          cast[cstring](addr(input.semantic[0])))
      copyStr(result.inputs[i].name, input.name)
      copyStr(result.inputs[i].semantic, input.semantic)

  if bool(reflChunk.numUniformBuffers):
    for i in 0 ..< reflChunk.numUniformBuffers:
      var ub: SgsReflUniformBuffer
      readVar(addr(r), ub)
      result.uniformBuffers[i].numBytes = int32(ub.sizeBytes)
      result.uniformBuffers[i].binding = ub.binding
      result.uniformBuffers[i].arraySize = int32(ub.arraySize)
      copyStr(result.uniformBuffers[i].name, ub.name)

  if bool(reflChunk.numTextures):
    for i in 0 ..< reflChunk.numTextures:
      var t: SgsReflTexture
      readVar(addr(r), t)
      result.textures[i].binding = t.binding
      result.textures[i].imageType = fourCCToShaderTextureType(t.imageDim, bool(t.isArray))
      copyStr(result.textures[i].name, t.name)
      
  if bool(reflChunk.numStorageImages):
    for i in 0 ..< reflChunk.numStorageImages:
      var img: SgsReflTexture
      readVar(addr(r), img)
      result.storageImages[i].binding = img.binding
      result.storageImages[i].imageType = fourCCToShaderTextureType(
          img.imageDim, bool(img.isArray))
      copyStr(result.storageImages[i].name, img.name)

  if bool(reflChunk.numStorageBuffers):
    for i in 0 ..< reflChunk.numStorageBuffers:
      var b: SgsReflBuffer
      readVar(addr(r), b)
      result.storageBuffers[i].numBytes = int32(b.sizeBytes)
      result.storageBuffers[i].binding = b.binding
      result.storageBuffers[i].arrayStride = int32(b.arrayStride)
      copyStr(result.storageBuffers[i].name, b.name)

type
  ShaderStageSetupDesc = object
    refl: ref ShaderRefl
    code: pointer
    codeSize: int32

proc setupShaderDesc(desc: ptr ShaderDesc; vsRefl: ref ShaderRefl; vs: pointer;
    vsSize: int32; fsRefl: ref ShaderRefl; fs: pointer; fsSize: int32;
    nameHandle: ptr uint32): ptr ShaderDesc =
  let
    numStages = 2
    stages = [
      ShaderStageSetupDesc(refl: vsRefl, code: vs, codeSize: vsSize),
      ShaderStageSetupDesc(refl: fsRefl, code: fs, codeSize: fsSize)
    ]
  
  for i in 0 ..< numStages:
    let stage = unsafeAddr(stages[i])
    var stageDesc: ptr sgfx.ShaderStageDesc = nil
    case stage.refl.stage:
    of ssVs:
      stageDesc = addr(desc.vs)
      stageDesc.d3d11Target = "vs_5_0"
    of ssFs:
      stageDesc = addr(desc.fs)
      stageDesc.d3d11Target = "ps_5_0"
    else:
      assert(false, "not implemented")

    if stage.refl.codeType == sctBytecode:
      stageDesc.bytecode.`addr` = stage.code
      stageDesc.bytecode.size = stage.codeSize
    elif stage.refl.codeType == sctSource:
      stageDesc.source = cast[cstring](stage.code)

    if stage.refl.stage == ssVs:
      for a in 0 ..< len(vsRefl.inputs):
        desc.attrs[a].name = cast[cstring](addr(vsRefl.inputs[a].name[0]))
        desc.attrs[a].semName = cast[cstring](addr(vsRefl.inputs[a].semantic[0]))
        desc.attrs[a].semIndex = int32(vsRefl.inputs[a].semanticIndex)
    
    for iub in 0 ..< len(stage.refl.uniformBuffers):
      let 
        rub = addr(stage.refl.uniformBuffers[iub])
        ub = addr(stageDesc.uniformBlocks[rub.binding])
      ub.size = rub.numBytes
      if stage.refl.flattenUbos:
        ub.uniforms[0].arrayCount = int32(rub.arraySize)
        ub.uniforms[0].name = cast[cstring](addr(rub.name[0]))
        ub.uniforms[0].`type` = uniformTypeFloat4
    
    for itex in 0 ..< len(stage.refl.textures):
      let 
        rtex = addr(stage.refl.textures[iTex])
        img = addr(stageDesc.images[rtex.binding])
      img.name = cast[cstring](addr(rtex.name[0]))
      img.imageType = rtex.imageType
  
  result = desc

proc setupComputeShaderDesc(desc: ptr ShaderDesc; csRefl: ref ShaderRefl;
    cs: pointer; csSize: int32; nameHandle: ptr uint32): ptr ShaderDesc =
  let
    numStages = 1
    stages = [ShaderSetupStageDesc(refl: csRefl, code: cs, codeSize: csSize)]

  for i in 0 ..< numStages:
    let stage = unsafeAddr(stages[i])
    var stageDesc: ptr sgfx.ShaderStageDesc = nil
    case stage.refl.stage:
    of ssCs:
      stageDesc = addr(desc.cs)
      stageDesc.d3d11Target = "cs_5_0"
    else:
      assert(false, "not implemented")

    if stage.refl.codeType == sctBytecode:
      stageDesc.bytecode.`addr` = stage.code
      stageDesc.bytecode.size = stage.codeSize
    elif stage.refl.codeType == sctSource:
      stageDesc.source = cast[cstring](stage.code)

    for iub in 0 ..< len(stage.refl.uniformBuffers):
      let
        rub = addr(stage.refl.uniformBuffers[iub])
        ub = addr(stageDesc.uniformBlocks[rub.binding])
      ub.size = rub.numBytes
      if stage.refl.flattenUbos:
        ub.uniforms[0].arrayCount = int32(rub.arraySize)
        ub.uniforms[0].name = cast[cstring](addr(rub.name[0]))
        ub.uniforms[0].`type` = uniformTypeFloat4

    for iTex in 0 ..< len(stage.refl.textures):
      let
        rTex = addr(stage.refl.textures[iTex])
        img = addr(stageDesc.images[rTex.binding])
      img.name = cast[cstring](addr(rTex.name[0]))
      img.imageType = rTex.imageType

    for iImg in 0 ..< len(stage.refl.storageImages):
      let
        rImg = addr(stage.refl.storageImages[iImg])
        img = addr(stageDesc.images[rImg.binding])
      img.name = cast[cstring](addr(rImg.name[0]))
      img.imageType = rImg.imageType

  result = desc


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

    discard seekr(addr(reader), sizeof(uint32), wCurrent)

    var sInfo: SgsChunk
    readVar(addr(reader), sInfo)

    var stageChunk = getSgsIffChunk(addr(reader), 0, SgsChunkStageCC)
    while stageChunk.pos != -1:
      var stageType: uint32
      readVar(addr(reader), stageType)

      if stageType == SgsStageVertexCC:
        let reflectChunk = getSgsIffChunk(addr(reader), int64(stageChunk.size), SgsChunkReflCC)
        if reflectChunk.pos != -1:
          let refl = parseShaderReflectBin(
            addr(reader.data[reflectChunk.pos]), reflectChunk.size
          )
          info.inputs[0..len(refl.inputs)-1] = refl.inputs
          info.numInputs = int32(len(refl.inputs))

      discard seekr(addr(reader), stageChunk.pos + int64(stageChunk.size), wBegin)
      stageChunk = getSgsIffChunk(addr(reader), 0, SgsChunkStageCC)

    shader.shd = gfxApi.allocShader()
    assert(bool(shader.shd.id))

    result.asset.p = shader


proc onLoadShader(data: ptr AssetLoadData; params: ptr AssetLoadParams;
        mem: ptr MemBlock): bool {.cdecl.} =
  result = true

proc onFinalizeShader(data: ptr AssetLoadData; params: ptr AssetLoadParams;
        mem: ptr MemBlock) {.cdecl.} =

  block outer:
    var
      shaderDesc: ShaderDesc
      vsRefl, fsRefl, csRefl: ref ShaderRefl
      vsData, fsData, csData: ptr uint8
      vsSize = 0'i32
      fsSize = 0'i32
      csSize = 0'i32

      reader: MemReader
      sgs: uint32
      sInfo: SgsChunk

    initMemReader(addr(reader), mem.data, mem.size)
    readVar(addr(reader), sgs)
    if sgs != SgsChunkCC:
      assert(false, "invalid shader SGS file")
      break outer

    discard seekr(addr(reader), sizeof(uint32), wCurrent)
    readVar(addr(reader), sInfo)

    var stageChunk = getSgsIffChunk(addr(reader), 0, SgsChunkStageCC)
    while stageChunk.pos != -1:
      var
        stageType: uint32
        stage: api.ShaderStage
        codeType = sctSource
      readVar(addr(reader), stageType)

      var codeChunk = getSgsIffChunk(addr(reader), int64(stageChunk.size), SgsChunkCodeCC)
      if codeChunk.pos == -1:
        codeChunk = getSgsIffChunk(addr(reader), int64(stageChunk.size), SgsChunkDataCC)
        if codeChunk.pos == -1:
          assert(false, "neither data nor code chunk found in shader SGS file")
          break outer
        codeType = sctBytecode

      if stageType == SgsStageVertexCC:
        vsData = addr(reader.data[codeChunk.pos])
        vsSize = int32(codeChunk.size)
        stage = ssVs
      elif stageType == SgsStageFragmentCC:
        fsData = addr(reader.data[codeChunk.pos])
        fsSize = int32(codeChunk.size)
        stage = ssFs
      elif stageType == SgsStageComputeCC:
        csData = addr(reader.data[codeChunk.pos])
        csSize = int32(codeChunk.size)
        stage = ssCs
      else:
        assert(false, "not implemented")
        stage = ssCount

      discard seekr(addr(reader), int64(codeChunk.size), wCurrent)
      let reflectChunk = getSgsIffChunk(addr(reader), int64(stageChunk.size -
          codeChunk.size), SgsChunkReflCC)
      if reflectChunk.pos != -1:
        let refl = parseShaderReflectBin(addr(reader.data[reflectChunk.pos]),
            reflectChunk.size)
        refl.lang = fourCCToShaderLang(sinfo.lang)
        refl.stage = stage
        refl.profileVersion = int32(sinfo.profileVer)
        refl.codeType = codeType

        if stageType == SgsStageVertexCC:
          vsRefl = refl
        elif stageType == SgsStageFragmentCC:
          fsRefl = refl
        elif stageType == SgsStageComputeCC:
          csRefl = refl
        discard seekr(addr(reader), int64(reflectChunk.size), wCurrent)

      discard seekr(addr(reader), stageChunk.pos + int64(stageChunk.size), wBegin)
      stageChunk = getSgsIffChunk(addr(reader), 0, SgsChunkStageCC)

    if csRefl != nil and csData != nil:
      discard setupComputeShaderDesc(addr(shaderDesc), csRefl, csData, csSize, nil)
    else:
      discard setupShaderDesc(addr(shaderDesc), vsRefl, vsData, vsSize, fsRefl,
          fsData, fsSize, nil)

    let shader = cast[ptr api.Shader](data.asset.p)
    gfxApi.initShader(shader.shd, addr(shaderDesc))

proc onReloadShader(handle: AssetHandle; prevAsset: Asset) {.cdecl.} =
  discard

proc onReleaseShader(asset: Asset) {.cdecl.} =
  discard

proc onPrepareTexture(params: ptr AssetLoadParams;
        mem: ptr MemBlock): AssetLoadData {.cdecl.} =
  # block outer:
  #   let
  #     tex = cast[ptr Texture](alloc0(sizeof(Texture)))
  #     info = addr(tex.info)
  #     (dir, name, ext) = splitFile($params.path)

  #   var numComponents: int32
  #   if bool(infoFromMemory(cast[ptr char](mem.data), int32(mem.size), addr(info.width), addr(info.height), addr(numComponents))):
  #     if bool(is_16_bit_from_memory(mem.data, int32(mem.size))):
  discard



proc onLoadTexture(data: ptr AssetLoadData; params: ptr AssetLoadParams;
        mem: ptr MemBlock): bool {.cdecl.} =
  result = true

proc onFinalizeTexture(data: ptr AssetLoadData; params: ptr AssetLoadParams;
        mem: ptr MemBlock) {.cdecl.} =
  discard

proc onReloadTexture(handle: AssetHandle; prevAsset: Asset) {.cdecl.} =
  discard

proc onReleaseTexture(asset: Asset) {.cdecl.} =
  discard

proc runBeginDefaultPassCb(buff: ptr UncheckedArray[uint8], offset: int): tuple[
    buff: ptr UncheckedArray[uint8], offset: int] =
  var curOffset = offset

  let passAction = cast[ptr PassAction](addr(buff[curOffset]))
  curOffset += sizeof(PassAction)
  let width = cast[ptr int32](addr(buff[curOffset]))
  curOffset += sizeof(int32)
  let height = cast[ptr int32](addr(buff[curOffset]))
  curOffset += sizeof(int32)

  cBeginDefaultPass(passAction, width[], height[])

  result = (buff: buff, offset: curOffset)

proc runBeginPassCb(buff: ptr UncheckedArray[uint8], offset: int): tuple[
    buff: ptr UncheckedArray[uint8], offset: int] =
  var curOffset = offset
  let passAction = cast[ptr PassAction](addr(buff[curOffset]))
  curOffset += sizeof(PassAction)
  let pass = cast[ptr Pass](addr(buff[curOffset]))[]
  curOffset += sizeof(Pass)
  sgfx.cBeginPass(pass, passAction)
  result = (buff: buff, offset: curOffset)

proc runApplyViewportCb(buff: ptr UncheckedArray[uint8], offset: int): tuple[
    buff: ptr UncheckedArray[uint8], offset: int] =
  discard

proc runApplyScissorRectCb(buff: ptr UncheckedArray[uint8], offset: int): tuple[
    buff: ptr UncheckedArray[uint8], offset: int] =
  discard

proc runApplyPipelineCb(buff: ptr UncheckedArray[uint8], offset: int): tuple[
    buff: ptr UncheckedArray[uint8], offset: int] =
  var curOffset = offset
  let pipId = cast[ptr Pipeline](addr(buff[curOffset]))[]
  curOffset += sizeof(Pipeline)

  applyPipeline(pipId)

  result = (buff: buff, offset: curOffset)

proc runApplyBindingsCb(buff: ptr UncheckedArray[uint8], offset: int): tuple[
    buff: ptr UncheckedArray[uint8], offset: int] =
  var curOffset = offset
  let bindings = cast[ptr Bindings](addr(buff[curOffset]))[]
  applyBindings(bindings)
  curOffset += sizeof(Bindings)
  result = (buff: buff, offset: curOffset)

proc runApplyUniformsCb(buff: ptr UncheckedArray[uint8], offset: int): tuple[
    buff: ptr UncheckedArray[uint8], offset: int] =
  var curOffset = offset
  let stage = cast[ptr sgfx.ShaderStage](addr(buff[curOffset]))[]
  curOffset += sizeof(sgfx.ShaderStage)
  let ubIndex = cast[ptr int32](addr(buff[curOffset]))[]
  curOffset += sizeof(int32)
  let numBytes = cast[ptr int32](addr(buff[curOffset]))[]
  curOffset += sizeof(int32)
  applyUniforms(stage, ubIndex, Range(`addr`: addr(buff[curOffset]),
      size: numBytes))
  curOffset += sizeof(numBytes)
  result = (buff: buff, offset: curOffset)

proc runDrawCb(buff: ptr UncheckedArray[uint8], offset: int): tuple[
    buff: ptr UncheckedArray[uint8], offset: int] =
  var curOffset = offset
  let baseElement = cast[ptr int32](addr(buff[curOffset]))[]
  curOffset += sizeof(int32)
  let numElements = cast[ptr int32](addr(buff[curOffset]))[]
  curOffset += sizeof(int32)
  let numInstances = cast[ptr int32](addr(buff[curOffset]))[]
  curOffset += sizeof(int32)
  draw(baseElement, numElements, numInstances)
  result = (buff: buff, offset: curOffset)

proc runDispatchCb(buff: ptr UncheckedArray[uint8], offset: int): tuple[
    buff: ptr UncheckedArray[uint8], offset: int] =
  var curOffset = offset
  let threadGroupX = cast[ptr int32](addr(buff[curOffset]))[]
  curOffset += sizeof(int32)
  let threadGroupY = cast[ptr int32](addr(buff[curOffset]))[]
  curOffset += sizeof(int32)
  let threadGroupZ = cast[ptr int32](addr(buff[curOffset]))[]
  curOffset += sizeof(int32)
  dispatch(threadGroupX, threadGroupY, threadGroupZ)
  result = (buff: buff, offset: curOffset)

proc runDispatchIndirectCb(buff: ptr UncheckedArray[uint8], offset: int): tuple[
    buff: ptr UncheckedArray[uint8], offset: int] =
  var curOffset = offset
  let buf = cast[ptr sgfx.Buffer](addr(buff[curOffset]))[]
  curOffset += sizeof(sgfx.Buffer)
  let bufferOffset = cast[ptr int32](addr(buff[curOffset]))[]
  curOffset += sizeof(int32)
  dispatchIndirect(buf, bufferOffset)
  result = (buff: buff, offset: curOffset)

proc runDrawIndexedInstancedIndirect(buff: ptr UncheckedArray[uint8],
    offset: int): tuple[buff: ptr UncheckedArray[uint8], offset: int] =
  var curOffset = offset
  let buf = cast[ptr sgfx.Buffer](addr(buff[curOffset]))[]
  curOffset += sizeof(sgfx.Buffer)
  let bufferOffset = cast[ptr int32](addr(buff[curOffset]))[]
  curOffset += sizeof(int32)
  drawIndexedInstancedIndirect(buf, bufferOffset)
  result = (buff: buff, offset: curOffset)

proc runFinishPassCb(buff: ptr UncheckedArray[uint8], offset: int): tuple[
    buff: ptr UncheckedArray[uint8], offset: int] =
  cEndPass()
  result = (buff: buff, offset: offset)

proc runUpdateBufferCb(buff: ptr UncheckedArray[uint8], offset: int): tuple[
    buff: ptr UncheckedArray[uint8], offset: int] =
  discard

proc runUpdateImageCb(buff: ptr UncheckedArray[uint8], offset: int): tuple[
    buff: ptr UncheckedArray[uint8], offset: int] =
  discard

proc runAppendBufferCb(buff: ptr UncheckedArray[uint8], offset: int): tuple[
    buff: ptr UncheckedArray[uint8], offset: int] =
  var curOffset = offset
  let streamIndex = cast[ptr int32](addr(buff[curOffset]))[]
  curOffset += sizeof(int32)
  let buf = cast[ptr Buffer](addr(buff[curOffset]))[]
  curOffset += sizeof(Buffer)
  let streamOffset = cast[ptr int32](addr(buff[curOffset]))[]
  curOffset += sizeof(int32)
  let dataSize = cast[ptr int32](addr(buff[curOffset]))[]
  curOffset += sizeof(int32)

  assert(streamIndex < len(ctx.streamBuffers))
  assert(len(ctx.streamBuffers) > 0)
  let sBuff = addr(ctx.streamBuffers[streamIndex])
  assert(sBuff != nil)
  assert(sBuff.buf.id == buf.id, "streaming buffers probably destroyed during render or update")
  mapBuffer(buf, streamOffset, Range(`addr`: addr(buff[curOffset]),
      size: dataSize))
  curOffset += dataSize

  result = (buff: buff, offset: curOffset)

proc runBeginProfileSampleCb(buff: ptr UncheckedArray[uint8],
    offset: int): tuple[buff: ptr UncheckedArray[uint8], offset: int] =
  discard

proc runEndProfileSampleCb(buff: ptr UncheckedArray[uint8], offset: int): tuple[
    buff: ptr UncheckedArray[uint8], offset: int] =
  discard

proc runBeginStageCb(buff: ptr UncheckedArray[uint8], offset: int): tuple[
    buff: ptr UncheckedArray[uint8], offset: int] =
  var curOffset = offset

  let name = cast[cstring](addr(buff[curOffset]))
  curOffset += 32

  discard copyStr(ctx.currentStageName, name)

  result = (buff: buff, offset: curOffset)

proc runFinishStageCb(buff: ptr UncheckedArray[uint8], offset: int): tuple[
    buff: ptr UncheckedArray[uint8], offset: int] =
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
    runDispatchIndirectCb,
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
    offset = int(uint(addr(cb.paramsBuffer[currentLen]) - addr(cb.paramsBuffer[0])))

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

proc beginDefaultPass(passAction: ptr PassAction; width,
    height: int32) {.cdecl.} =
  let cb = addr(ctx.cmdBuffersFeed[coreApi.jobThreadIndex()])

  assert(bool(cb.runningStage.id), "must invoke `beginStage` before invoking this procedure")
  assert(cb.cmdIdx < uint16.high, "maximum number of graphics calls exceeded")

  var
    offset = 0
    buff = initParamsBuff(cb, sizeof(PassAction) + sizeof(int32) * 2, offset)

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
  cast[ptr int32](buff)[] = width
  buff += sizeof(int32)
  cast[ptr int32](buff)[] = height

proc beginPass(pass: Pass; passAction: ptr PassAction) {.cdecl.} =
  let cb = addr(ctx.cmdBuffersFeed[coreApi.jobThreadIndex()])

  assert(bool(cb.runningStage.id), "must invoke `beginStage` before invoking this procedure")
  assert(cb.cmdIdx < uint16.high, "maximum number of graphics calls exceeded")

  var
    offset = 0
    buff = initParamsBuff(cb, sizeof(PassAction) + sizeof(Pass), offset)

  let r = CommandBufferRef(
    key: uint32(cb.stageOrder shl 16) or uint32(cb.cmdIdx),
    cmdBufferIdx: cb.index,
    cmd: cmdBeginPass,
    paramsOffset: offset
  )

  add(cb.refs, r)
  inc(cb.cmdIdx)

  copyMem(addr(buff[0]), passAction, sizeof(passAction[]))
  buff += sizeof(passAction[])
  cast[ptr Pass](buff)[] = pass

  setPassUsedFrame(pass.id, coreApi.frameIndex())

proc applyPipeline(pip: Pipeline) {.cdecl.} =
  let cb = addr(ctx.cmdBuffersFeed[coreApi.jobThreadIndex()])

  assert(bool(cb.runningStage.id), "must invoke `beginStage` before invoking this procedure")
  assert(cb.cmdIdx < uint16.high, "maximum number of graphics calls exceeded")

  var
    offset = 0
    buff = initParamsBuff(cb, sizeof(Pipeline), offset)

  let r = CommandBufferRef(
    key: uint32(cb.stageOrder shl 16) or uint32(cb.cmdIdx),
    cmdBufferIdx: cb.index,
    cmd: cmdApplyPipeline,
    paramsOffset: offset
  )

  add(cb.refs, r)
  inc(cb.cmdIdx)

  cast[ptr Pipeline](buff)[] = pip

  setPipelineUsedFrame(pip.id, coreApi.frameIndex())

proc applyBindings*(bindings: ptr Bindings) {.cdecl.} =
  let cb = addr(ctx.cmdBuffersFeed[coreApi.jobThreadIndex()])

  assert(bool(cb.runningStage.id), "must invoke `beginStage` before invoking this procedure")
  assert(cb.cmdIdx < uint16.high, "maximum number of graphics calls exceeded")

  var
    offset = 0
    buff = initParamsBuff(cb, sizeof(Bindings), offset)

  let r = CommandBufferRef(
    key: uint32(cb.stageOrder shl 16) or uint32(cb.cmdIdx),
    cmdBufferIdx: cb.index,
    cmd: cmdApplyBindings,
    paramsOffset: offset
  )

  add(cb.refs, r)
  inc(cb.cmdIdx)

  copyMem(buff, bindings, sizeof(bindings[]))

  let frameIdx = coreApi.frameIndex()
  for i in 0 ..< maxShaderstageBuffers:
    if bool(bindings.vertexBuffers[i].id):
      setBufferUsedFrame(bindings.vertexBuffers[i].id, frameIdx)
    else:
      break

  if bool(bindings.indexBuffer.id):
    setBufferUsedFrame(bindings.indexBuffer.id, frameIdx)

  for i in 0 ..< maxShaderstageImages:
    if bool(bindings.vsImages[i].id):
      setImageUsedFrame(bindings.vsImages[i].id, frameIdx)
    else:
      break

  for i in 0 ..< maxShaderstageBuffers:
    if bool(bindings.vsBuffers[i].id):
      setBufferUsedFrame(bindings.vsBuffers[i].id, frameIdx)
    else:
      break

  for i in 0 ..< maxShaderstageImages:
    if bool(bindings.fsImages[i].id):
      setImageUsedFrame(bindings.fsImages[i].id, frameIdx)
    else:
      break

  for i in 0 ..< maxShaderstageBuffers:
    if bool(bindings.fsBuffers[i].id):
      setBufferUsedFrame(bindings.fsBuffers[i].id, frameIdx)
    else:
      break

  for i in 0 ..< maxShaderstageImages:
    if bool(bindings.csImages[i].id):
      setImageUsedFrame(bindings.csImages[i].id, frameIdx)
    else:
      break

  for i in 0 ..< maxShaderstageBuffers:
    if bool(bindings.csBuffers[i].id):
      setBufferUsedFrame(bindings.csBuffers[i].id, frameIdx)
    else:
      break

  for i in 0 ..< maxShaderstageUavs:
    if bool(bindings.csBufferUavs[i].id):
      setBufferUsedFrame(bindings.csBufferUavs[i].id, frameIdx)
    else:
      break

  for i in 0 ..< maxShaderstageUavs:
    if bool(bindings.csImageUavs[i].id):
      setImageUsedFrame(bindings.csImageUavs[i].id, frameIdx)
    else:
      break

proc applyUniforms*(stage: sgfx.ShaderStage; ubIndex: int32; data: pointer;
    numBytes: int32) {.cdecl.} =
  let cb = addr(ctx.cmdBuffersFeed[coreApi.jobThreadIndex()])

  assert(bool(cb.runningStage.id), "must invoke `beginStage` before invoking this procedure")
  assert(cb.cmdIdx < uint16.high, "maximum number of graphics calls exceeded")

  var
    offset = 0
    buff = initParamsBuff(cb, sizeof(sgfx.ShaderStage) + sizeof(int32) * 2 +
        numBytes, offset)

  let r = CommandBufferRef(
    key: uint32(cb.stageOrder shl 16) or uint32(cb.cmdIdx),
    cmdBufferIdx: cb.index,
    cmd: cmdApplyUniforms,
    paramsOffset: offset
  )

  add(cb.refs, r)
  inc(cb.cmdIdx)

  cast[ptr sgfx.ShaderStage](buff)[] = stage
  buff += sizeof(sgfx.ShaderStage)
  cast[ptr int32](buff)[] = ubIndex
  buff += sizeof(int32)
  cast[ptr int32](buff)[] = numBytes
  buff += sizeof(int32)
  copyMem(buff, data, numBytes)

proc draw(baseElement: int32; numElements: int32;
    numInstances: int32) {.cdecl.} =
  let cb = addr(ctx.cmdBuffersFeed[coreApi.jobThreadIndex()])

  assert(bool(cb.runningStage.id), "must invoke `beginStage` before invoking this procedure")
  assert(cb.cmdIdx < uint16.high, "maximum number of graphics calls exceeded")

  var
    offset = 0
    buff = initParamsBuff(cb, sizeof(int32) * 3, offset)

  let r = CommandBufferRef(
    key: uint32(cb.stageOrder shl 16) or uint32(cb.cmdIdx),
    cmdBufferIdx: cb.index,
    cmd: cmdDraw,
    paramsOffset: offset
  )

  add(cb.refs, r)
  inc(cb.cmdIdx)

  cast[ptr int32](buff)[] = baseElement
  buff += sizeof(int32)
  cast[ptr int32](buff)[] = numElements
  buff += sizeof(int32)
  cast[ptr int32](buff)[] = numInstances

proc dispatch(threadGroupX, threadGroupY, threadGroupZ: int32) {.cdecl.} =
  let cb = addr(ctx.cmdBuffersFeed[coreApi.jobThreadIndex()])

  assert(bool(cb.runningStage.id), "must invoke `beginStage` before invoking this procedure")
  assert(cb.cmdIdx < uint16.high, "maximum number of graphics calls exceeded")

  var
    offset = 0
    buff = initParamsBuff(cb, sizeof(int32) * 3, offset)

  let r = CommandBufferRef(
    key: uint32(cb.stageOrder shl 16) or uint32(cb.cmdIdx),
    cmdBufferIdx: cb.index,
    cmd: cmdDispatch,
    paramsOffset: offset
  )

  add(cb.refs, r)
  inc(cb.cmdIdx)

  cast[ptr int32](buff)[] = threadGroupX
  buff += sizeof(int32)
  cast[ptr int32](buff)[] = threadGroupY
  buff += sizeof(int32)
  cast[ptr int32](buff)[] = threadGroupZ

proc dispatchIndirect(buf: sgfx.Buffer; bufferOffset: int32) {.cdecl.} =
  let cb = addr(ctx.cmdBuffersFeed[coreApi.jobThreadIndex()])

  assert(bool(cb.runningStage.id), "must invoke `beginStage` before invoking this procedure")
  assert(cb.cmdIdx < uint16.high, "maximum number of graphics calls exceeded")

  var
    offset = 0
    buff = initParamsBuff(cb, sizeof(sgfx.Buffer) + sizeof(int32), offset)

  let r = CommandBufferRef(
    key: uint32(cb.stageOrder shl 16) or uint32(cb.cmdIdx),
    cmdBufferIdx: cb.index,
    cmd: cmdDispatchIndirect,
    paramsOffset: offset
  )

  add(cb.refs, r)
  inc(cb.cmdIdx)

  cast[ptr sgfx.Buffer](buff)[] = buf
  buff += sizeof(sgfx.Buffer)
  cast[ptr int32](buff)[] = bufferOffset
  buff += sizeof(int32)

proc drawIndexedInstancedIndirect(buf: sgfx.Buffer;
    bufferOffset: int32) {.cdecl.} =
  let cb = addr(ctx.cmdBuffersFeed[coreApi.jobThreadIndex()])

  assert(bool(cb.runningStage.id), "must invoke `beginStage` before invoking this procedure")
  assert(cb.cmdIdx < uint16.high, "maximum number of graphics calls exceeded")

  var
    offset = 0
    buff = initParamsBuff(cb, sizeof(sgfx.Buffer) + sizeof(int32), offset)

  let r = CommandBufferRef(
    key: uint32(cb.stageOrder shl 16) or uint32(cb.cmdIdx),
    cmdBufferIdx: cb.index,
    cmd: cmdDrawIndexedInstancedIndirect,
    paramsOffset: offset
  )

  add(cb.refs, r)
  inc(cb.cmdIdx)

  cast[ptr sgfx.Buffer](buff)[] = buf
  buff += sizeof(sgfx.Buffer)
  cast[ptr int32](buff)[] = bufferOffset
  buff += sizeof(int32)

proc finishPass() {.cdecl.} =
  let cb = addr(ctx.cmdBuffersFeed[coreApi.jobThreadIndex()])

  assert(bool(cb.runningStage.id), "must invoke `beginStage` before invoking this procedure")
  assert(cb.cmdIdx < uint16.high, "maximum number of graphics calls exceeded")

  let r = CommandBufferRef(
    key: uint32(cb.stageOrder shl 16) or uint32(cb.cmdIdx),
    cmdBufferIdx: cb.index,
    cmd: cmdFinishPass,
    paramsOffset: len(cb.paramsBuffer)
  )

  add(cb.refs, r)
  inc(cb.cmdIdx)

proc appendBuffer(buf: Buffer; data: pointer;
    dataSize: int32): int32 {.cdecl.} =
  var idx = -1
  for i in 0 ..< len(ctx.streamBuffers):
    if ctx.streamBuffers[i].buf.id == buf.id:
      idx = i
      break

  assert(idx != -1, "buffer must be streamed and not destroyed during render")
  let sBuff = addr((ctx.streamBuffers[idx]))
  assert(load(sBuff.offset) + uint32(dataSize) <= uint32(sBuff.size))

  let
    streamOffset = fetchAdd(sBuff.offset, uint32(dataSize))
    cb = addr(ctx.cmdBuffersFeed[coreApi.jobThreadIndex()])

  assert(bool(cb.runningStage.id), "must invoke `beginStage` before invoking this procedure")
  assert(cb.cmdIdx < uint16.high, "maximum number of graphics calls exceeded")

  var
    offset = 0
    buff = initParamsBuff(cb, dataSize + sizeof(int32) * 3 + sizeof(
        sgfx.Buffer), offset)

  let r = CommandBufferRef(
    key: uint32(cb.stageOrder shl 16) or uint32(cb.cmdIdx),
    cmdBufferIdx: cb.index,
    cmd: cmdAppendBuffer,
    paramsOffset: offset
  )

  add(cb.refs, r)
  inc(cb.cmdIdx)

  cast[ptr int32](buff)[] = int32(idx)
  buff += sizeof(int32)
  cast[ptr sgfx.Buffer](buff)[] = buf
  buff += sizeof(sgfx.Buffer)
  cast[ptr uint32](buff)[] = streamOffset
  buff += sizeof(int32)
  cast[ptr int32](buff)[] = dataSize
  buff += sizeof(int32)
  copyMem(buff, data, dataSize)

  setBufferUsedFrame(buf.id, coreApi.frameIndex())

  result = int32(streamOffset)

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

      discard runCommandCallbacks[int(r.cmd)](cast[ptr UncheckedArray[uint8]](
          addr(cb.paramsBuffer[0])), r.paramsOffset)

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
  let
    name = b{"name"}.getStr("")
    semantic = b{"semantic"}.getStr("")
  a.name[0..len(name) - 1] = name
  a.semantic[0..len(semantic) - 1] = semantic 
  a.semanticIndex = int32(b{"semantic_index"}.getInt(0))
  a.vertexFormat = strToShaderVertexFormat(b{"type"}.getStr(""))

proc fromJsonHook(a: var ShaderReflUniformBuffer; b: JsonNode) =
  let name = b{"name"}.getStr("")
  a.name[0..len(name) - 1] = name 
  a.numBytes = int32(b{"block_size"}.getInt(0))
  a.binding = int32(b{"binding"}.getInt(0))
  a.arraySize = int32(b{"array"}.getInt(0))

proc fromJsonHook(a: var ShaderReflTexture; b: JsonNode) =
  let name = b{"name"}.getStr("")
  a.name[0..len(name) - 1] = name
  a.binding = int32(b{"binding"}.getInt(0))
  a.imageType = strToShaderTextureType(b{"dimension"}.getStr(""), b{
      "array"}.getBool(false))

proc fromJsonHook(a: var ShaderReflBuffer; b: JsonNode) =
  let name = b{"name"}.getStr("")
  a.name[0..len(name) - 1] = name
  a.numBytes = int32(b{"block_size"}.getInt(0))
  a.binding = int32(b{"binding"}.getInt(0))
  a.arrayStride = int32(b{"unsized_array_stride"}.getInt(1))

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

    a.profileVersion = int32(b{"profile_version"}.getInt(0))
    a.codeType = if b{"bytecode"}.getBool(false): sctBytecode else: sctSource
    a.flattenUbos = b{"flatten_ubos"}.getBool(false)

    let file = lastPathPart(jStage{"file"}.getStr(""))
    a.sourceFile[0..len(file) - 1] = file

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

  result.info.numInputs = int32(min(len(vsRefl.inputs), maxVertexAttributes))
  for i in 0 ..< result.info.numInputs:
    result.info.inputs[i] = vsRefl.inputs[i]

proc bindShaderToPipeline*(shader: ptr api.Shader; pipDesc: ptr PipelineDesc;
    vl: ptr VertexLayout): ptr PipelineDesc {.cdecl.} =
  assert(vl != nil)
  pipDesc.shader = shader.shd

  var
    index = 0
    attr = addr(vl.attributes[0])

  # zeroMem(addr(pipDesc.layout.attrs), sizeof(VertexAttrDesc) * maxVertexAttributes)

  while (attr.semantic != nil and len(attr.semantic) > 0) and index <
      shader.info.numInputs:
    var found = false
    for i in 0 ..< shader.info.numInputs:
      if attr.semantic == cast[cstring](addr(shader.info.inputs[i].semantic[0])) and
        attr.semanticIndex == shader.info.inputs[i].semanticIndex:
        found = true

        pipDesc.layout.attrs[i].offset = attr.offset
        pipDesc.layout.attrs[i].format = if attr.format !=
            vertexFormatInvalid: attr.format else: shader.info.inputs[i].vertexFormat
        pipDesc.layout.attrs[i].bufferIndex = attr.bufferIndex
        break

    if not found:
      logError("vertex attribute '$#$#' does not exist in actual shader inputs",
          attr.semantic, attr.semanticIndex)
      assert(false)

    attr += 1
    inc(index)

  result = pipDesc

proc getShader(shaderAssetHandle: AssetHandle): ptr api.Shader {.cdecl.} =
  result = cast[ptr api.Shader](assetApi.asset(shaderAssetHandle).p)
  assert(not isNil(result), "shader is not loaded or missing")

proc makePipeline(desc: ptr PipelineDesc): sgfx.Pipeline {.cdecl.} =
  ctx.lastShaderError = false

  result = sgfx.c_makePipeline(desc)

  if ctx.lastShaderError:
    logError("in pipeline: $#", if desc.label != nil: desc.label else: "[NA]")
    ctx.lastShaderError = false

proc makeBuffer(desc: ptr BufferDesc): sgfx.Buffer {.cdecl.} =
  let bufId = sgfx.c_makeBuffer(desc)
  if desc.usage == usageStream:
    var sBuff = StreamBuffer(buf: bufId, size: desc.size)
    store(sBuff.offset, 0'u32)
    add(ctx.streamBuffers, sBuff)
  result = bufId

proc glFamily*(): bool {.cdecl.} =
  let backend = queryBackend()
  result = backend == backendGlcore33 or backend == backendGles2 or backend == backendGles3

proc initShaders() =
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

proc initTextures() =
  var
    whitePixel {.global.} = 0xffffffff'u32
    blackPixel {.global.} = 0xff000000'u32
    imgDesc = ImageDesc(
      width: 1,
      height: 1,
      numMipmaps: 1,
      pixelFormat: pixelFormatRgba8,
      label: "frag_white_texture_1x1"
    )
    textureInfo = TextureInfo(
      imageType: imagetype2d,
      format: pixelFormatRgba8,
      memSizeBytes: int32(sizeof(whitePixel)),
      width: 1,
      height: 1,
      dl: DepthLayers(
        layers: 1
      ),
      mips: 1,
      bpp: 32
    )
  imgDesc.data.subImage[0][0].`addr` = addr(whitePixel)
  imgDesc.data.subImage[0][0].size = sizeof(whitePixel)
  ctx.textureManager.whiteTexture.img = gfxApi.makeImage(addr(imgDesc))
  ctx.textureManager.whiteTexture.info = textureInfo

  imgDesc.label = "frag_black_texture_1x1"
  imgDesc.data.subImage[0][0].`addr` = addr(blackPixel)
  imgDesc.data.subImage[0][0].size = sizeof(blackPixel)
  ctx.textureManager.blackTexture.img = gfxApi.makeImage(addr(imgDesc))
  ctx.textureManager.blackTexture.info = textureInfo

  assetApi.registerAssetType(
    "texture",
    AssetCallbacks(
      onPrepare: onPrepareTexture,
      onLoad: onLoadTexture,
      onFinalize: onFinalizeTexture,
      onReload: onReloadTexture,
      onRelease: onReleaseTexture
    ),
    "TextureLoadParams",
    int32(sizeof(TextureLoadParams)),
    Asset(p: nil),
    Asset(p: nil),
    alfNone
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
  initTextures()

proc shutdown*() =
  deinitLock(ctx.stageLock)

  sgfx.shutdown()

gfxApi = GfxApi(
  staged: GfxDrawApi(
    begin: beginStage,
    finish: finishStage,
    beginDefaultPass: beginDefaultPass,
    beginPass: beginPass,
    applyPipeline: applyPipeline,
    applyBindings: applyBindings,
    applyUniforms: applyUniforms,
    draw: draw,
    dispatch: dispatch,
    dispatchIndirect: dispatchIndirect,
    drawIndexedInstancedIndirect: drawIndexedInstancedIndirect,
    finishPass: finishPass,
    appendBuffer: appendBuffer
  ),
  glFamily: glFamily,
  makeBuffer: makeBuffer,
  makeImage: cMakeImage,
  makeShader: cMakeShader,
  makePipeline: makePipeline,
  makePass: cMakePass,
  allocShader: cAllocShader,
  initShader: cInitShader,
  registerStage: registerStage,
  makeShaderWithData: makeShaderWithData,
  bindShaderToPipeline: bindShaderToPipeline,
  getShader: getShader,
)
