import std/dynlib,
       api, fuse, logging, primer

type
  PluginObject = object
    lib: pointer
    eventHandlerCb: EventHandlerCallback
    mainCb: MainCallback

  PluginData {.union.} = object
    plugin: Plugin
    obj: PluginObject

  PluginHandle = object
    data: PluginData

    info: PluginInfo
    filepath: array[MaxPath, char]

  PluginState = object
    plugins: seq[PluginHandle]
    pluginUpdateOrder: seq[int]

let nativeApis = [
  cast[pointer](coreApi.addr), pluginApi.addr, appApi.addr, gfxApi.addr,
      vfsApi.addr, assetApi.addr, cameraApi.addr
]

var ctx: PluginState

proc getApi*(api: ApiType): pointer {.cdecl.} =
  result = nativeApis[api.int]

proc init*() =
  discard

proc loadAbs*(filepath: cstring; entry: bool) =
  var handle: PluginHandle
  handle.data.plugin.api = addr pluginApi

  var dll: pointer
  if not entry:
    discard
  else:
    dll = getAppModule()
    handle.info.name = appApi.name()

  handle.filepath.copyStr(filepath)

  unloadLib(dll)

  ctx.plugins.add(handle)
  ctx.pluginUpdateOrder.add(ctx.plugins.len() - 1)

proc initPlugins*() =
  block outer:
    for i in 0 ..< ctx.pluginUpdateOrder.len():
      let
        idx = ctx.pluginUpdateOrder[i]
        handle = ctx.plugins[idx].addr

      if not openPlugin(handle.data.plugin.addr, cast[cstring](addr handle.filepath[0])).bool:
        logWarn("failed initialing plugin: $#", handle.filepath)
        break outer

      logDebug("initialized plugin!")

proc update*() =
  block:
    for i in 0 ..< ctx.pluginUpdateOrder.len():
      let handle = ctx.plugins[ctx.pluginUpdateOrder[i]].addr
      assert updatePlugin(handle.data.plugin.addr, true) >= 0

proc shutdown*() =
  block:
    for i in 0 ..< ctx.pluginUpdateOrder.len():
      let handle = ctx.plugins[ctx.pluginUpdateOrder[i]].addr
      closePlugin(handle.data.plugin.addr)

pluginApi = PluginApi(
  getApi: getApi,
)
