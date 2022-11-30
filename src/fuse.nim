import api

var
  coreApi*: CoreApi
  pluginApi*: PluginApi
  appApi*: AppApi
  gfxApi*: GfxApi
  vfsApi*: VfsApi
  assetApi*: AssetApi
  cameraApi*: CameraApi

  appModuleHandle: pointer

proc setAppModule*(handle: pointer) =
  appModuleHandle = handle

proc getAppModule*(): pointer =
  appModuleHandle