import std/[hashes, json, jsonutils, os],
       sokol/gfx as sgfx, sokol/glue as sglue,
       api, fuse, logging, io, primer

const
  MaxStages = 1024
  MaxDepth = 64

  StageOrderDepthBits = 6
  StageOrderDepthMask = 0xfc00
  StageOrderIdBits = 10
  StageOrderIdMask = 0x03ff

  CheckerTextureSize = 128

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


type
  StageState = object

  Stage = object
    name: cstring
    nameHash: Hash
    state: StageState
    parent: GfxStage
    child: GfxStage
    next: GfxStage
    prev: GfxStage
    order: uint16
    enabled: bool
    singleEnabled: bool

  GfxState = object
    stages: seq[Stage]

var
  ctx: GfxState

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
    result = vertexFormatInvalid

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
    singleEnabled: true,
    name: name
  )

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
  a.imageType = strToShaderTextureType(b{"dimension"}.getStr(""), b{"array"}.getBool(false))

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

proc parseShaderReflectJson(stageReflJson: cstring; stageReflJsonLen: int): ref ShaderRefl =
  block outer:
    result = new ShaderRefl

    try:
      fromJsonHook(result[], parseJson($stageReflJson))
    except:
      logError("failed parsing shader reflection json")
      break outer

proc makeShaderWithData(vsDataSize: uint32; vsData: ptr UncheckedArray[uint32];
        vsReflSize: uint32; vsReflJson: ptr UncheckedArray[uint32]; fsDataSize: uint32;
        fsData: ptr UncheckedArray[uint32]; fsReflSize: uint32; fsReflJson: ptr UncheckedArray[uint32]): api.Shader {.cdecl.} =
  
  var shaderDesc: ShaderDesc
  discard parseShaderReflectJson(cast[cstring](addr(vsReflJson[0])), int(vsReflSize) - 1)
  result

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

proc init*() =
  sgfx.setup(sgfx.Desc(context: sglue.context()))

  initShaders()

proc shutdown*() =
  sgfx.shutdown()

gfxApi = GfxApi(
  registerStage: registerStage,
  makeShaderWithData: makeShaderWithData,
)
