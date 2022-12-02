import std/[hashes, locks, tables],
       api, fuse, handle, io, logging

type
  AssetJobState = distinct uint32

  AsyncAssetLoadRequest = object
    pathHash: Hash
    asset: AssetHandle

  AsyncAssetJob = object
    loadData: AssetLoadData
    mem: ptr MemBlock
    assetMgr: ptr AssetManager
    loadParams: AssetLoadParams
    job: Job
    state: AssetJobState
    assetHandle: AssetHandle

  AssetData = object
    handle: Handle
    paramsId: uint32
    resourceId: uint32
    assetManagerId: int32
    refCount: int32
    asset: Asset
    hash: Hash
    tags: uint32
    loadFlags: AssetLoadFlag
    state: AssetState

  AssetResource = object
    path: cstring
    realPath: cstring
    lastModified: uint64
    used: bool

  AssetManager = object
    name: cstring
    callbacks: AssetCallbacks
    nameHash: uint32
    paramsSize: int32
    paramsTypeName: cstring
    failedObj: Asset
    asyncObj: Asset
    paramsBuff: seq[uint8]
    forcedFlags: AssetLoadFlag
    unreg: bool

  AssetContext = object
    assetManagers: Table[cstring, AssetManager]
    loadedAssets: seq[AssetData]
    assetHandles: ptr HandlePool
    assets: Table[Hash, AssetHandle]
    resources: Table[cstring, int]
    loadedResources: seq[AssetResource]
    asyncReqs: seq[AsyncAssetLoadRequest]
    asyncJobList: seq[AsyncAssetJob]
    assetsLock: Lock

const
  ajsSpawn = AssetJobState(0)
  ajsLoadFailed = AssetJobState(1)
  ajsSuccess = AssetJobState(2)

var ctx: AssetContext

proc onReadAsset(path: cstring; mem: ptr MemBlock; userData: pointer) {.cdecl.} =
  discard

proc hashAsset(path: cstring; params: pointer; paramsSize: int): Hash =
  var h: Hash = 0
  h = h !& hash(path)
  if bool(paramsSize):
    h = h !& hash(params)
  result = !$h

proc createNewAsset(path: cstring; params: pointer; asset: Asset; name: cstring; flags: AssetLoadFlag; tags: uint32): AssetHandle =
  if not contains(ctx.assetManagers, name):
    assert false, "asset type must be registered first"
  let assetMgr = addr(ctx.assetManagers[name])

  var resIdx = getOrDefault(ctx.resources, path, -1)
  if resIdx == -1:
    let res = AssetResource(
      used: true,
      path: path,
      realPath: path
    )
    resIdx = len(ctx.loadedResources)
    add(ctx.loadedResources, res)
    ctx.resources[path] = resIdx
  else:
    ctx.loadedResources[resIdx].used = true
  
  let paramsSize = assetMgr.paramsSize
  var paramsId = 0'u32
  if paramsSize > 0:
    paramsId = toId(len(assetMgr.paramsBuff))
    add(assetMgr.paramsBuff, toOpenArray[uint8](cast[ptr UncheckedArray[uint8]](params), 0, paramsSize))
  
  let hnd = newHandleGrowPool(ctx.assetHandles)
  assert bool(hnd)

  let assetData = AssetData(
    handle: hnd,
    paramsId: paramsId,
    resourceId: toId(resIdx),
    refCount: 1,
    asset: asset,
    hash: hashAsset(path, params, paramsSize),
    tags: tags,
    loadFlags: flags,
    state: asZombie
  )

  withLock(ctx.assetsLock):
    let hndIdx = handleIndex(hnd)
    if len(ctx.loadedAssets) >= hndIdx:
      add(ctx.loadedAssets, assetData)
    else:
      ctx.loadedAssets[hndIdx] = assetData

proc registerAssetType(name: cstring; callbacks: AssetCallbacks;
    paramsTypeName: cstring; paramsSize: int32; failedObj, asyncObj: Asset;
    forcedFlags: AssetLoadFlag) {.cdecl.} =
  block outer:
    if contains(ctx.assetManagers, name):
      assert false, "asset manager already regisitered"
      break outer
    
    let assetManager = AssetManager(
      callbacks: callbacks,
      name: name,
      paramsSize: paramsSize,
      paramsTypeName: paramsTypeName,
      failedObj: failedObj,
      asyncObj: asyncObj,
      forcedFlags: forcedFlags
    )

    ctx.assetManagers[name] = assetManager

proc loadHashed(name: cstring; path: cstring; params: pointer;
    flags: AssetLoadFlag; tags: uint32): AssetHandle =
  block outer:
    if isNil(path):
      logWarn("failed loading asset: invalid asset path")
      result.id = 0
      break outer

    assert(coreApi.jobThreadIndex() == 0, "`asset.loadHashed` must be called from main thread")

    var loadFlags = flags
    if bool(flags and alfReload):
      loadFlags = flags or alfWaitOnLoad

    if not contains(ctx.assetManagers, name):
      assert false, "asset type must be registered first"
    let assetMgr = addr(ctx.assetManagers[name])
    loadFlags = loadFlags or assetMgr.forcedFlags

    if assetMgr.paramsSize > 0 and isNil(params):
      logWarn("`params` of type '%s' must be supplied for this asset", assetMgr.paramsTypeName)
      assert(false, "params must not be `nil` for this asset type")
    
    result = cast[AssetHandle](getOrDefault(ctx.assets, hashAsset(path, params, assetMgr.paramsSize), AssetHandle(id: 0)))
    if bool(result.id) and not bool(flags and alfReload):
      inc(ctx.loadedAssets[result.id].refCount)
    else:
      let resourceIdx = getOrDefault(ctx.resources, path, -1)

      var 
        realPath = path
        res: ptr AssetResource = nil
      if resourceIdx != -1:
        res = addr(ctx.loadedResources[resourceIdx])
        realPath = res.realPath
      
      if not bool(flags and alfWaitOnLoad):
        result = createNewAsset(path, params, assetMgr.asyncObj, name, flags, tags)
        let a = addr(ctx.loadedAssets[handleIndex(result.id)])
        a.state = asLoading

        let req = AsyncAssetLoadRequest(
          pathHash: hash(realPath),
          asset: result
        )
        add(ctx.asyncReqs, req)

        vfsApi.readAsync(
          realPath,
          if bool(flags and alfAbsolutePath): vfsfAbsolutePath else: VfsFlag(0),
          onReadAsset,
          nil
        )

proc load(name: cstring; path: cstring; params: pointer; flags: AssetLoadFlag;
    tags: uint32): AssetHandle {.cdecl.} =
  result = loadHashed(name, path, params, flags, tags)

proc init*() =
  initLock(ctx.assetsLock)
  ctx.assetHandles = createHandlePool(AssetPoolSize)

proc update*() =
  for assetJob in ctx.asyncJobList.mitems:
    if coreApi.testAndDelJob(assetJob.job):
      let a = addr(ctx.assets[handleIndex(assetJob.assetHandle.id)])


proc shutdown*() =
  destroyHandlePool(ctx.assetHandles)
  deinitLock(ctx.assetsLock)

assetApi = AssetApi(
  registerAssetType: registerAssetType,
  load: load
)
