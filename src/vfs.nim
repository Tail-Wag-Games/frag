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
    requestQueue: ptr SpscQueue
    responseQueue: ptr SpscQueue
    workerSem: Semaphore
    
const
  acRead = AsyncCommand(0)
  acWrite = AsyncCommand(1)

var ctx: VfsState

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
  ctx.requestQueue = create(sizeof(AsyncRequest), 128)
  ctx.responseQueue = create(sizeof(AsyncResponse), 128)

  init(ctx.workerSem)

vfsApi = VfsApi(
  mount: mount,
  readAsync: readAsync
)

proc shutdown*() =
  if ctx.requestQueue != nil:
    destroy(ctx.requestQueue)
  if ctx.responseQueue != nil:
    destroy(ctx.responseQueue)