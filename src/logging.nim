import std/[strformat, strutils, terminal],
       winim/lean

type
  LogLevel* = enum
    llError
    llWarning
    llInfo
    llVerbose
    llDebug

  LogEntry* = object
    kind*: LogLevel
    channels*: uint32
    text*: string
    sourceFile*: string
    line*: int

  LogCtx = object
    logLevel: LogLevel

const
  logEntryKinds = [
    "FRAG ERROR: ",
    "FRAG WARNING: ",
    "FRAG INFO: ",
    "FRAG VERBOSE: ",
    "FRAG DEBUG: "
  ]

var ctx: LogCtx

template logInfo*(msg: string, args: varargs[string, `$`]) =
  let iinfo = instantiationInfo()
  printInfo(0, iinfo.filename, iinfo.line, msg, args)

template logDebug*(msg: string, args: varargs[string, `$`]) =
  let iinfo = instantiationInfo()
  printDebug(0, iinfo.filename, iinfo.line, msg, args)

template logVerbose*(msg: string, args: varargs[string, `$`]) =
  let iinfo = instantiationInfo()
  printVerbose(0, iinfo.filename, iinfo.line, msg, args)

template logError*(msg: string, args: varargs[string, `$`]) =
  let iinfo = instantiationInfo()
  printError(0, iinfo.filename, iinfo.line, msg, args)

template logWarn*(msg: string, args: varargs[string, `$`]) =
  let iinfo = instantiationInfo()
  printWarning(0, iinfo.filename, iinfo.line, msg, args)

proc logTerminalBackend(entry: LogEntry) =
  var msg: string

  case entry.kind
  of llInfo:
    styledEcho fgGreen, logEntryKinds[ord(entry.kind)], entry.text
  of llVerbose:
    styledEcho fgBlue, logEntryKinds[ord(entry.kind)], entry.text
  of llDebug:
    styledEcho fgCyan, logEntryKinds[ord(entry.kind)], entry.text
  of llWarning:
    styledEcho fgYellow, logEntryKinds[ord(entry.kind)], entry.text
  of llError:
    styledEcho fgRed, logEntryKinds[ord(entry.kind)], entry.text

proc logDebuggerBackend(entry: LogEntry) =
  when defined(vcc):
    OutputDebugStringA(fmt"{entry.sourceFile}({entry.line}): {logEntryKinds[ord(entry.kind)]}{entry.text}")

proc dispatchLogEntry(entry: LogEntry) =
  logTerminalBackend(entry)
  logDebuggerBackend(entry)

proc printInfo*(channels: uint32; sourceFile: string; line: int; fmt: string; args: varargs[string]) =
  block:
    if ctx.logLevel < llInfo:
      break
    
    dispatchLogEntry(
      LogEntry(
        kind: llInfo,
        channels: channels,
        text: format(fmt, args),
        sourceFile: sourceFile,
        line: line
      )
    )

proc printDebug*(channels: uint32; sourceFile: string; line: int; fmt: string; args: varargs[string]) =
  block:
    if ctx.logLevel < llDebug:
      break
    
    dispatchLogEntry(
      LogEntry(
        kind: llDebug,
        channels: channels,
        text: format(fmt, args),
        sourceFile: sourceFile,
        line: line
      )
    )

proc printVerbose*(channels: uint32; sourceFile: string; line: int; fmt: string; args: varargs[string]) =
  block:
    if ctx.logLevel < llVerbose:
      break
    
    dispatchLogEntry(
      LogEntry(
        kind: llVerbose,
        channels: channels,
        text: format(fmt, args),
        sourceFile: sourceFile,
        line: line
      )
    )

proc printError*(channels: uint32; sourceFile: string; line: int; fmt: string; args: varargs[string]) =
  block:
    if ctx.logLevel < llError:
      break
    
    dispatchLogEntry(
      LogEntry(
        kind: llError,
        channels: channels,
        text: format(fmt, args),
        sourceFile: sourceFile,
        line: line
      )
    )

proc printWarning*(channels: uint32; sourceFile: string; line: int; fmt: string; args: varargs[string]) =
  block:
    if ctx.logLevel < llWarning:
      break
    
    dispatchLogEntry(
      LogEntry(
        kind: llWarning,
        channels: channels,
        text: format(fmt, args),
        sourceFile: sourceFile,
        line: line
      )
    )
  
proc setLogLevel*(ll: LogLevel) =
  ctx.logLevel = ll

ctx.logLevel = llDebug