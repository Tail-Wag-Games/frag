import std/deques,
       sokol/app as sapp, sokol/gfx as sgfx,
       api, logging, noise, pool, terrain, tnt

type
  TerrainState = object
    splitShader: sgfx.Shader

var
  n {.fragState.}: NoiseState
  pluginApi {.fragState.}: ptr PluginApi

proc init() =
  discard

proc fragPluginEventHandler(e: ptr sapp.Event) {.cdecl, exportc, dynlib.} =
  discard

proc fragPlugin(plugin: ptr Plugin; operation: PluginOperation): int32 {.exportc,
    cdecl, dynlib.} =
  case operation:
  of poStep:
    discard
  of poInit:
    pluginApi = plugin.api

    init()

    pluginApi.injectApi("three_d", 0, addr(terrainApi))
  else:
    discard

proc fragPluginInfo(info: ptr PluginInfo) {.cdecl, exportc, dynlib.} =
  info.name[0..31] = toOpenArray("terrain", 0, 31)
  info.desc[0..255] = toOpenArray("heightmap generation and terrain rendering related functionality", 0, 255)

terrainApi = TerrainApi(
)
