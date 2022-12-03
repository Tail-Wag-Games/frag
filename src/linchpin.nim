import sokol/gfx as sgfx, sokol/app as sapp,
       api, asset, fuse, gfx, job, plugin, vfs

type
  CoreContext = object
    jobCtx: ptr JobContext

var
  ctx: CoreContext

  passAction = PassAction(
    colors: [ ColorAttachmentAction( action: actionClear, value: (1, 0, 0, 0)) ]
  )

proc testAndDelJob(j: Job): bool {.cdecl.} =
  assert(ctx.jobCtx != nil)
  result = job.testAndDel(ctx.jobCtx, j)

proc jobThreadIndex(): int32 {.cdecl.} =
  assert(ctx.jobCtx != nil)
  result = jobThreadIndex(ctx.jobCtx)

proc init*(cfg: var Config) =
  vfs.init()

  ctx.jobCtx = job.createContext(JobContextDesc(
    numThreads: 4,
    maxFibers: 64,
    fiberStackSize: 1024 * 1024
  ))

  asset.init()

  gfx.init()

  plugin.init()

proc frame*() =
  vfs.update()
  
  plugin.update()
  
  var g = passAction.colors[0].value.g + 0.01
  passAction.colors[0].value.g = if g > 1.0: 0.0 else: g
  beginDefaultPass(passAction, sapp.width(), sapp.height())
  endPass()
  commit()

proc shutdown*() =
  plugin.shutdown()
  gfx.shutdown()
  asset.shutdown()
  job.destroyContext(ctx.jobCtx)
  vfs.shutdown()

coreApi = CoreApi(
  testAndDelJob: testAndDelJob,
  jobThreadIndex: jobThreadIndex
)