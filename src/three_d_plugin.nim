import api, three_d

var pluginApi {.fragState.}: ptr PluginApi

proc gridXYPlaneCam(spacing, spacingBold, dist: float32; cam: ptr Camera; viewProj: ptr Float4x4f) {.cdecl.} =
  discard

proc fragPlugin(ctx: ptr Plugin; operation: PluginOperation): int32 {.exportc,
    cdecl, dynlib.} =
  case operation:
  of poStep:
    discard
  of poInit:
    pluginApi = ctx.api

    pluginApi.injectApi("three_d", 0, addr(threeDApi))
  else:
    discard

proc fragPluginInfo(info: ptr PluginInfo) {.cdecl, exportc, dynlib.} =
  info.name[0..31] = toOpenArray("three_d", 0, 31)
  info.desc[0..255] = toOpenArray("3d related functionality", 0, 255)

threeDApi = ThreeDApi(
  debug: Debug(
    gridXYPlaneCam: gridXYPlaneCam
  )
)