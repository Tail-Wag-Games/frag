import std/os, std/private/globs,
       api, fuse, io, lockfree, threading

type
  MountPoint = object
    path: string
    alias: string
  
  AsyncCommand = distinct uint32

  AsyncCallback {.union.} = object
    readFn: VfsAsyncReadCallback
    writeFn: VfsAsyncWriteCallback

  AsyncRequest = object
    cmd: AsyncCommand
    flags: VfsFlag
    path: cstring
    writeMem: ptr MemBlock
    callback: AsyncCallback
    userData: pointer

  ResponseCode = distinct uint32

  Mem {.union.} = object
    read: ptr MemBlock
    write: ptr MemBlock

  AsyncResponse = object
    code: ResponseCode
    mem: Mem
    callback: AsyncCallback
    userData: pointer
    writeBytes: int64
    path: cstring

  VfsState = object
    mounts: seq[MountPoint]
    worker: Thread[pointer]
    requestQueue: ptr SpscQueue
    responseQueue: ptr SpscQueue
    workerSem: Semaphore
    quit: bool
    
const
  acRead = AsyncCommand(0)
  acWrite = AsyncCommand(1)

  rcReadFailed = ResponseCode(0)
  rcReadOk = ResponseCode(1)
  rcWriteFailed = ResponseCode(2)
  rcWriteOk = ResponseCode(3)

var ctx: ptr VfsState

proc read(path: cstring; flags: VfsFlag): ptr MemBlock =
  discard

proc worker(userData: pointer) {.thread.} =
  while not ctx.quit:
    var req: AsyncRequest
    if consume(ctx.requestQueue, addr(req)):
      var res = AsyncResponse(
        writeBytes: -1,
        path: req.path,
        userData: req.userData
      )

      case req.cmd:
      of acRead:
        res.callback.readFn = req.callback.readFn
        let mem = read(req.path, req.flags)
      else:
        discard

proc mount*(path, alias: cstring; watch: bool): bool {.cdecl.} =
  block outer:
    let
      sPath = $path
      sAlias = $alias
    
    if dirExists(sPath):
      let mp = MountPoint(
        path: sPath.normalizedPath(),
        alias: sAlias.nativeToUnixPath()
      )
    
      for i in 0 ..< ctx.mounts.len():
        if ctx.mounts[i].path == mp.path:
          result = false
          break outer

      ctx.mounts.add(mp)
      result = true
    else:
      result = false

proc readAsync(path: cstring; flags: VfsFlag; readFn: VfsAsyncReadCallback; userData: pointer) {.cdecl.} =
  var req = AsyncRequest(
    cmd: acRead,
    flags: flags,
    callback: AsyncCallback(
      readFn: readFn
    ),
    userData: userData,
    path: path,
  )

  discard produceAndGrow(ctx.requestQueue, addr(req))
  post(ctx.workerSem, 1)

proc init*() =
  ctx = createShared(VfsState)

  ctx.requestQueue = create(sizeof(AsyncRequest), 128)
  ctx.responseQueue = create(sizeof(AsyncResponse), 128)

  block outer:
    if isNil(ctx.requestQueue) or isNil(ctx.responseQueue):
      break outer
 
  init(ctx.workerSem)
  createThread(ctx.worker, worker, nil)

proc update*() =
  var res: AsyncResponse
  while consume(ctx.responseQueue, addr(res)):
    case res.code:
    of rcReadOk, rcReadFailed:
      res.callback.readFn(res.path, res.mem.read, res.userData)
    of rcWriteOk, rcWriteFailed:
      res.callback.writeFn(res.path, res.writeBytes, res.mem.write, res.userData)
    else:
      discard

proc shutdown*() =
  if running(ctx.worker):
    ctx.quit = true
    post(ctx.workerSem, 1)
    joinThread(ctx.worker)
    destroy(ctx.workerSem)

  if ctx.requestQueue != nil:
    destroy(ctx.requestQueue)
  if ctx.responseQueue != nil:
    destroy(ctx.responseQueue)
  
  freeShared(ctx)

vfsApi = VfsApi(
  mount: mount,
  readAsync: readAsync
)