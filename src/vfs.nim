import std/os, std/private/globs,
       api, fuse, io

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

  VfsState = object
    mounts: seq[MountPoint]

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

vfsApi = VfsApi(
  mount: mount,
  readAsync: readAsync
)