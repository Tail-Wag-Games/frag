import api, input,
       sokol/app as sapp

var
  pluginApi {.fragState.}: ptr PluginApi

proc fragPlugin(plugin: ptr Plugin; operation: PluginOperation): int32 {.exportc,
    cdecl, dynlib.} =
  case operation:
  of poStep:
    discard
  of poInit:
    pluginApi = plugin.api

    pluginApi.injectApi("input", 0, addr(inputApi))
  else:
    discard

proc fragPluginEventHandler(e: ptr sapp.Event) {.cdecl, exportc, dynlib.} =
  discard

proc fragPluginInfo(info: ptr PluginInfo) {.cdecl, exportc, dynlib.} =
  info.name[0..31] = toOpenArray("input", 0, 31)
  info.desc[0..255] = toOpenArray("Input related functionality", 0, 255)

inputApi = InputApi(
)
