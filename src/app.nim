import std / [dynlib, os, parseopt, strformat],
       sokol/app as sapp,
       api, fuse, linchpin, plugin

type
  AppState = object
    cfg: Config

    appFilepath: string
    windowSize: Float2f

var 
  ctx: AppState

  defaultName: cstring
  defaultTitle: cstring

when defined(Windows):
  import winim/lean

proc messageBox(msg: string) =
  when defined(Windows):
    MessageBoxA(HWND(0), msg, "frag", MB_OK or MB_ICONERROR)

proc saveCfgString(cacheStr: cstring, str: var cstring) = 
  if str != nil:
    copyMem(addr cacheStr[0], addr str[0], sizeof(str))
    str = cacheStr
  else:
    str = cacheStr

proc windowSize(size: ptr Float2f) {.cdecl.} =
  assert size != nil
  size[] = ctx.windowSize

proc name(): cstring {.cdecl.} =
  result = ctx.cfg.appName

proc init() {.cdecl.} =
  linchpin.init(ctx.cfg)

  plugin.loadAbs(cast[cstring](addr ctx.appFilepath[0]), true)

  plugin.initPlugins()

proc frame() {.cdecl.} =
  linchpin.frame()

proc cleanup() {.cdecl.} =
  linchpin.shutdown()

proc run*() =
  block:
    var appFilepath: string

    for kind, key, val in getopt():
      case kind
      of cmdArgument:
        discard
      of cmdLongOption, cmdShortOption:
        case key
        of "r", "run":
          appFilepath = val
      of cmdEnd: assert(false) # cannot happen

    if appFilepath.len == 0:
      messageBox("must provide the path to an application plugin to run, via the run option (ex: --run=app_plugin.dll )")
      break

    if not fileExists(appFilepath):
      messageBox(&"application plugin does not exist: {appFilepath}")
      break

    let lib = loadLib(appFilepath)
    if lib.isNil:
      messageBox(&"file at path: {appFilepath} is not a valid application plugin")
      break

    let appPluginMain = cast[proc(cfg: ptr Config) {.cdecl.}](lib.symAddr("fragApp"))
    if appPluginMain.isNil:
      messageBox(&"application plugin at path: {appFilepath} does not export a procedure named `fragApp`")
      break

    let (_, appFilename, _) = splitFile(appFilepath)
    defaultName = appFilename.cstring
    defaultTitle = defaultName

    var cfg = Config(
      appName: addr defaultName[0],
      appTitle: addr defaultTitle[0]
    )

    appPluginMain(cfg)

    saveCfgString(defaultName, cfg.appName)
    saveCfgString(defaultTitle, cfg.appTitle)

    if true:
      unloadLib(lib)
    else:
      setAppModule(lib)

    ctx.appFilepath = appFilepath
    ctx.windowSize = float2f(cfg.windowWidth.float32, cfg.windowHeight.float32)

    sapp.run(sapp.Desc(
      initCb: init,
      frameCb: frame,
      cleanupCb: cleanup,
      windowTitle: cfg.appTitle,
      width: cfg.windowWidth,
      height: cfg.windowHeight,
      icon: IconDesc(sokol_default: true)
    ))

appApi = AppApi(
  name: name,
  windowSize: windowSize,
  width: cWidth,
  height: cHeight
)