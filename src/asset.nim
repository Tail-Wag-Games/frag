import std/[hashes, locks, tables],
       api, fuse, handle, io, logging, primer

type
  AssetJobState = distinct uint32

  AsyncAssetLoadRequest = object
    pathHash: Hash
    handle: AssetHandle

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
    assetManagerName: cstring
    refCount: int32
    asset: Asset
    deadAsset: Asset
    hash: Hash
    tags: uint32
    loadFlags: AssetLoadFlag
    state: AssetState

  AssetResource = object
    path: array[MaxPath, char]
    realPath: array[MaxPath, char]
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
    assets: Table[Hash, Handle]
    resources: Table[cstring, int]
    loadedResources: seq[AssetResource]
    asyncReqs: seq[AsyncAssetLoadRequest]
    asyncJobList: seq[ptr AsyncAssetJob]
    assetsLock: Lock

const
  ajsSpawn = AssetJobState(0)
  ajsLoadFailed = AssetJobState(1)
  ajsSuccess = AssetJobState(2)

var ctx: AssetContext

template assetErrMsg(path, realPath, msgPref: untyped) =
  if path != realPath:
    logWarn("$# asset '$# -> $#' failed", msgPref, path, realpath)
  else:
    logWarn("$# asset '$#' failed", msgPref, path)

proc loadJobCallback(start, finish, threadIdx: int32;
    userData: pointer) {.cdecl.} =
  let aJob = cast[ptr AsyncAssetJob](userData)

  aJob.state = if aJob.assetMgr.callbacks.onLoad(
    addr(aJob.loadData),
    addr(aJob.loadParams),
    aJob.mem):
      ajsSuccess
    else:
      ajsLoadFailed

proc findAsyncRequest(path: cstring): int =
  block outer:
    let pathHash = hash(path)
    for i, asyncReq in ctx.asyncReqs:
      if asyncReq.pathHash == pathHash:
        result = i
        break outer

    result = -1

proc onReadAsset(path: cstring; mem: ptr MemBlock;
    userData: pointer) {.cdecl.} =
  block outer:
    let asyncRequestIdx = findAsyncRequest(path)

    if isNil(mem):
      if asyncRequestIdx != -1:
        let
          req = addr(ctx.asyncReqs[asyncRequestIdx])
          hnd = req.handle
          asset = addr(ctx.loadedAssets[handleIndex(hnd.id)])

        assert(bool(asset.resourceId))

        let
          res = addr(ctx.loadedResources[toIndex(asset.resourceId)])
          assetMgr = addr(ctx.assetManagers[asset.assetManagerName])

        assetErrMsg(res.path, res.realPath, "opening")

        asset.state = asFailed
        asset.asset = assetMgr.failedObj

        del(ctx.asyncReqs, asyncRequestIdx)
      break outer
    elif asyncRequestIdx == -1:
      destroyMemBlock(mem)
      break outer

    let
      req = addr(ctx.asyncReqs[asyncRequestIdx])
      hnd = req.handle
      asset = addr(ctx.loadedAssets[handleIndex(hnd.id)])

    assert(bool(asset.resourceId))

    let
      res = addr(ctx.loadedResources[toIndex(asset.resourceId)])
      assetMgr = addr(ctx.assetManagers[asset.assetManagerName])

    var pParams: pointer
    if bool(asset.paramsId):
      pParams = addr(assetMgr.paramsBuff[toIndex(asset.paramsId)])

    var aParams = AssetLoadParams(
      path: cstring($res.path),
      params: pParams,
      tags: asset.tags,
      flags: asset.loadFlags
    )

    let loadData = assetMgr.callbacks.onPrepare(addr(aParams), mem)

    del(ctx.asyncReqs, asyncRequestIdx)
    if not bool(loadData.asset.id):
      assetErrMsg(res.path, res.realPath, "preparing")
      destroyMemBlock(mem)
      break outer

    var buff = cast[ptr UncheckedArray[uint]](alloc(sizeof(AsyncAssetJob) +
        assetMgr.paramsSize + MaxPath))
    if isNil(buff):
      assert(false, "out of memory")
      break outer

    let ajob = cast[ptr AsyncAssetJob](buff)
    buff += sizeof(AsyncAssetJob)
    aParams.path = cast[cstring](buff)
    copyMem(buff, addr(res.path[0]), MaxPath)
    buff += MaxPath

    if pParams != nil:
      assert(cast[uint](buff) mod 8 == 0)
      aParams.params = buff
      copyMem(buff, pParams, assetMgr.paramsSize)

    aJob[] = AsyncAssetJob(
      loadData: loadData,
      mem: mem,
      assetMgr: assetMgr,
      loadParams: aParams,
      assetHandle: hnd
    )

    aJob.job = coreApi.dispatchJob(1, loadJobCallback, aJob, jpHigh, 0)
    add(ctx.asyncJobList, aJob)

proc hashAsset(path: cstring; params: pointer; paramsSize: int): Hash =
  var h: Hash = 0
  h = h !& hash(path)
  if bool(paramsSize):
    h = h !& hash(params)
  result = !$h

proc createNewAsset(path: cstring; params: pointer; asset: Asset; name: cstring;
    flags: AssetLoadFlag; tags: uint32): AssetHandle =
  if not contains(ctx.assetManagers, name):
    assert false, "asset type must be registered first"
  let assetMgr = addr(ctx.assetManagers[name])

  var resIdx = getOrDefault(ctx.resources, path, -1)
  if resIdx == -1:
    var res = AssetResource(used: true)
    copyStr(res.path, path)
    copyStr(res.realPath, path)
    resIdx = len(ctx.loadedResources)
    add(ctx.loadedResources, res)
    ctx.resources[path] = resIdx
  else:
    ctx.loadedResources[resIdx].used = true

  let paramsSize = assetMgr.paramsSize
  var paramsId = 0'u32
  if paramsSize > 0:
    paramsId = toId(len(assetMgr.paramsBuff))
    add(assetMgr.paramsBuff, toOpenArray[uint8](cast[ptr UncheckedArray[uint8]](
        params), 0, paramsSize))

  var handle = newHandleGrowPool(ctx.assetHandles)
  # assert bool(result)

  let assetData = AssetData(
    handle: handle,
    paramsId: paramsId,
    resourceId: toId(resIdx),
    assetManagerName: name,
    refCount: 1,
    asset: asset,
    hash: hashAsset(path, params, paramsSize),
    tags: tags,
    loadFlags: flags,
    state: asZombie
  )

  withLock(ctx.assetsLock):
    let hndIdx = handleIndex(handle)
    if hndIdx >= len(ctx.loadedAssets):
      add(ctx.loadedAssets, assetData)
    else:
      ctx.loadedAssets[hndIdx] = assetData

  ctx.assets[assetData.hash] = handle
  result = cast[AssetHandle](handle)

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

proc addAsset(path: cstring; params: pointer; asset: Asset; name: cstring;
    flags: AssetLoadFlag; tags: uint32;
    overrideAsset: AssetHandle): AssetHandle =
  result = overrideAsset
  if bool(result.id):
    # TODO: reload asset
    assert(bool(flags and alfReload))
  else:
    result = createNewAsset(path, params, asset, name, flags, tags)

proc loadHashed(name: cstring; path: cstring; params: pointer;
    flags: AssetLoadFlag; tags: uint32): AssetHandle =
  block outer:
    if isNil(path):
      logWarn("failed loading asset: invalid asset path")
      result.id = 0
      break outer

    assert(coreApi.jobThreadIndex() == 0, "`asset.loadHashed` must be called from main thread")

    var loadFlags = flags
    if bool(loadFlags and alfReload):
      loadFlags = loadFlags or alfWaitOnLoad

    if not contains(ctx.assetManagers, name):
      assert false, "asset type must be registered first"
    let assetMgr = addr(ctx.assetManagers[name])
    loadFlags = loadFlags or assetMgr.forcedFlags

    if assetMgr.paramsSize > 0 and isNil(params):
      logWarn("`params` of type '$#' must be supplied for this asset",
          assetMgr.paramsTypeName)
      assert(false, "params must not be `nil` for this asset type")

    result = cast[AssetHandle](getOrDefault(ctx.assets, hashAsset(path, params,
        assetMgr.paramsSize), Handle(0)))
    if bool(result.id) and not bool(loadFlags and alfReload):
      inc(ctx.loadedAssets[result.id].refCount)
    else:
      let resourceIdx = getOrDefault(ctx.resources, path, -1)

      var
        realPath = path
        res: ptr AssetResource = nil
      if resourceIdx != -1:
        res = addr(ctx.loadedResources[resourceIdx])
        realPath = cstring($res.realPath)

      if not bool(loadFlags and alfWaitOnLoad):
        result = createNewAsset(path, params, assetMgr.asyncObj, name,
            loadFlags, tags)
        let a = addr(ctx.loadedAssets[handleIndex(result.id)])
        a.state = asLoading

        let req = AsyncAssetLoadRequest(
          pathHash: hash(realPath),
          handle: result
        )
        add(ctx.asyncReqs, req)

        vfsApi.readAsync(
          realPath,
          if bool(loadFlags and alfAbsolutePath): vfsfAbsolutePath else: VfsFlag(
              0),
          onReadAsset,
          nil
        )
      else:
        result = addAsset(path, params, assetMgr.failedObj, name, loadFlags,
            tags, if bool(loadFlags and alfReload): result else: AssetHandle(id: 0))
        
        let mem = vfsApi.read(
          realPath,
          if bool(flags and alfAbsolutePath): vfsfAbsolutePath else: vfsfNone
        )

        if isNil(mem):
          assetErrMsg(path, realPath, "opening")
          break outer
        
        var a = addr(ctx.loadedAssets[handleIndex(result.id)])

        if isNil(res):
          assert(bool(a.resourceId))
          res = addr(ctx.loadedResources[toIndex(a.resourceId)])
        
        var 
          aParams = AssetLoadParams(
            path: path,
            params: params,
            tags: tags,
            flags: flags
          )
          success = false

        let loadData = assetMgr.callbacks.onPrepare(addr(aParams), mem)

        a = addr(ctx.loadedAssets[handleIndex(result.id)])
        if bool(loadData.asset.id):
          if assetMgr.callbacks.onLoad(addr(loadData), addr(aParams), mem):
            assetMgr.callbacks.onFinalize(addr(loadData), addr(aParams), mem)
            success = true
        
        destroyMemBlock(mem)
        if success:
          a.state = asOk
          a.asset = loadData.asset
        else:
          if bool(loadData.asset.id):
            assetMgr.callbacks.onRelease(loadData.asset)
          assetErrMsg(path, realPath, "loading")
          if bool(a.asset.id and not a.deadAsset.id):
            a.state = asFailed
          else:
            a.asset = a.deadAsset
            a.deadAsset = Asset(id: 0)
        
        if bool(flags and alfReload):
          # TODO: asset reloading
          discard

proc load(name: cstring; path: cstring; params: pointer; flags: AssetLoadFlag;
    tags: uint32): AssetHandle {.cdecl.} =
  result = loadHashed(name, path, params, flags, tags)

proc asset(hnd: AssetHandle): Asset {.cdecl.} =
  withLock(ctx.assetsLock):
    result = ctx.loadedAssets[handleIndex(hnd.id)].asset

proc init*() =
  initLock(ctx.assetsLock)
  ctx.assetHandles = createHandlePool(AssetPoolSize)

proc update*() =
  var i = 0
  while i < len(ctx.asyncJobList):
    let aJob = addr(ctx.asyncJobList[i])
    if coreApi.testAndDelJob(aJob.job):
      let a = addr(ctx.loadedAssets[handleIndex(aJob.assetHandle.id)])
      assert(bool(a.resourceId))
      let res = addr(ctx.loadedResources[toIndex(a.resourceId)])

      case aJob.state:
      of ajsSuccess:
        aJob.assetMgr.callbacks.onFinalize(addr(aJob.loadData), addr(
            aJob.loadParams), aJob.mem)
        a.asset = aJob.loadData.asset
        a.state = asOk
      of ajsLoadFailed:
        assetErrMsg(res.path, res.realPath, "loading")
        a.asset = aJob.assetMgr.failedObj
        a.state = asFailed

        if bool(aJob.loadData.asset.id):
          aJob.assetMgr.callbacks.onRelease(aJob.loadData.asset)
      else:
        assert(false, "invalid completed job state")

      assert(not bool(aJob.loadParams.flags and alfReload))

      destroyMemBlock(aJob.mem)

      delete(ctx.asyncJobList, find(ctx.asyncJobList, aJob[]))
      dealloc(aJob)
    else:
      i += 1

proc shutdown*() =
  destroyHandlePool(ctx.assetHandles)
  deinitLock(ctx.assetsLock)

assetApi = AssetApi(
  registerAssetType: registerAssetType,
  load: load,
  asset: asset,
)
