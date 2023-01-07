import std / [dynlib, os, parseopt, strformat],
       sokol/app as sapp,
       api, fuse, linchpin, plugin

type
  AppState = object
    cfg: Config

    appFilepath: string
    windowSize: Float2f
    keysPressed: array[MaxKeycodes, bool]

var 
  ctx: AppState

  defaultName: array[64, char]
  defaultTitle: array[64, char]
  defaultPluginPath: array[256, char]
  defaultPlugins: array[MaxPlugins, array[32, char]]

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

proc saveCfgString(cacheStr: openArray[char], str: var cstring) = 
  if str != nil:
    copyMem(addr cacheStr[0], addr str[0], sizeof(str))
  
  str = cast[cstring](addr(cacheStr[0]))

proc windowSize(size: ptr Float2f) {.cdecl.} =
  assert size != nil
  size[] = ctx.windowSize

proc name(): cstring {.cdecl.} =
  result = ctx.cfg.appName

proc init() {.cdecl.} =
  linchpin.init(ctx.cfg)

  var numPlugins = 0'i32
  for i in 0 ..< MaxPlugins:
    if isNil(ctx.cfg.plugins[i]) or not bool(ctx.cfg.plugins[i][0]):
      break

    if not pluginApi.load(ctx.cfg.plugins[i]):
      quit(QuitFailure)
    
    inc(numPlugins)

  plugin.loadAbs(cast[cstring](addr ctx.appFilepath[0]), true, ctx.cfg.plugins, numPlugins)

  plugin.initPlugins()

proc frame() {.cdecl.} =
  linchpin.frame()

proc cleanup() {.cdecl.} =
  linchpin.shutdown()

proc event(e: ptr sapp.Event) {.cdecl.} =
  # assert(sizeof(AppEvent) == sizeof(sapp.Event), "sizeof sapp_event does not match sizeof AppEvent")

  case e.`type`:
  of eventTypeResized:
    ctx.cfg.windowWidth = e.windowWidth
    ctx.cfg.windowHeight = e.windowHeight
    ctx.windowSize = Float2f(x: float32(e.windowWidth), y: float32(e.windowHeight))
    discard
  of eventTypeSuspended:
    discard
  of eventTypeIconified:
    discard
  of eventTypeResumed:
    discard
  of eventTypeRestored:
    discard
  of eventTypeKeyDown:
    ctx.keysPressed[int32(e.keyCode)] = true
  of eventTypeKeyUp:
    ctx.keysPressed[int32(e.keyCode)] = false
  else:
    discard

  broadcastPluginEvent(e)

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

    let 
      (_, sAppFilename, _) = splitFile(appFilepath)
      appFilename = cstring(sAppFilename)
    defaultName[0..high(appFilepath)] = toOpenArray(appFilename, 0, high(appFilepath))
    defaultTitle = defaultName

    var cfg = Config(
      appName: addr defaultName[0],
      appTitle: addr defaultTitle[0]
    )

    appPluginMain(cfg)

    saveCfgString(defaultName, cfg.appName)
    saveCfgString(defaultPluginPath, cfg.pluginPath)
    saveCfgString(defaultTitle, cfg.appTitle)
    for i in 0 ..< MaxPlugins:
      if cfg.plugins[i] != nil and len(cfg.plugins[i]) > 0:
        saveCfgString(defaultPlugins[i], cfg.plugins[i])

    if true:
      unloadLib(lib)
    else:
      setAppModule(lib)

    ctx.cfg = cfg
    ctx.appFilepath = appFilepath
    ctx.windowSize = float2f(cfg.windowWidth.float32, cfg.windowHeight.float32)

    sapp.run(sapp.Desc(
      initCb: init,
      frameCb: frame,
      cleanupCb: cleanup,
      eventCb: event,
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