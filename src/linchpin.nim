import std/cpuinfo,
       sokol/gfx as sgfx, sokol/app as sapp,
       api, asset, fuse, gfx, job, plugin, vfs

type
  CoreContext = object
    frameIndex: int64
    jobCtx: ptr JobContext

    numThreads: int32

var
  ctx: CoreContext

  passAction = PassAction(
    colors: [ ColorAttachmentAction( action: actionClear, value: (1, 0, 0, 0)) ]
  )

proc frameIndex(): int64 {.cdecl.} =
  result = ctx.frameIndex

proc testAndDelJob(j: Job): bool {.cdecl.} =
  assert(ctx.jobCtx != nil)
  result = job.testAndDel(ctx.jobCtx, j)

proc numJobThreads(): int32 {.cdecl.} =
  ctx.numThreads

proc jobThreadIndex(): int32 {.cdecl.} =
  assert(ctx.jobCtx != nil)
  result = jobThreadIndex(ctx.jobCtx)

proc init*(cfg: var Config) =
  var numWorkerThreads = if cfg.numJobThreads >= 0 : cfg.numJobThreads else: int32(countProcessors() - 1)
  numWorkerThreads = max(1, numWorkerThreads)
  ctx.numThreads = numWorkerThreads + 1

  vfs.init()

  ctx.jobCtx = job.createContext(JobContextDesc(
    numThreads: 4,
    maxFibers: 64,
    fiberStackSize: 1024 * 1024
  ))

  asset.init()

  gfx.init()

  plugin.init(cfg.pluginPath)

proc frame*() =
  vfs.update()
  
  plugin.update()

  gfx.executeCommandBuffers()

  inc(ctx.frameIndex)
  
proc shutdown*() =
  plugin.shutdown()
  gfx.shutdown()
  asset.shutdown()
  job.destroyContext(ctx.jobCtx)
  vfs.shutdown()

coreApi = CoreApi(
  frameIndex: frameIndex,
  testAndDelJob: testAndDelJob,
  numJobThreads: numJobThreads,
  jobThreadIndex: jobThreadIndex
)