import std/os, std/private/globs,
       api, fuse

type
  MountPoint = object
    path: string
    alias: string

  VfsState = object
    mounts: seq[MountPoint]

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

vfsApi = VfsApi(
  mount: mount
)