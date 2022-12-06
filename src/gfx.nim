import std/hashes,
       sokol/gfx as sgfx, sokol/glue as sglue,
       api, fuse, io, primer

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

proc onPrepareShader(params: ptr AssetLoadParams;
        mem: ptr MemBlock): AssetLoadData {.cdecl.} =
  block:
    let shader = cast[ptr api.Shader](alloc0(sizeof(api.Shader)))
    if isNil(shader):
      result.asset = Asset(id: 0)
      break

    let info = addr(shader.info)

    var reader: MemReader
    initMemReader(addr(reader), mem.data, mem.size)

    var sgs: uint32
    readVar(addr(reader), sgs)
    if sgs != SgsChunkCC:
      assert false, "invalid sgs file"
      result.asset = Asset(id: 0)
      break

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

proc parseShaderReflectJson(stageReflJson: cstring; stageReflJsonLen: int): ptr ShaderRefl =
  discard

proc makeShaderWithData(vsDataSize: uint32; vsData: openArray[uint32];
        vsReflSize: uint32; vsReflJson: openArray[uint32]; fsDataSize: uint32;
        fsData: openArray[uint32]; fsReflSize: uint32; fsReflJson: openArray[uint32]): api.Shader {.cdecl.} =
  
  var shaderDesc: ShaderDesc
  let vsRefl = parseShaderReflectJson(cast[cstring](vsReflJson), int(vsReflSize - 1)) 

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
