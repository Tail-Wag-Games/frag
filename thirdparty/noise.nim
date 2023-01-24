{.compile: "C:\\Users\\Zach\\dev\\frag\\thirdparty\\FastNoiseLite\\C\\FastNoiseLite.c".}

type
  NoiseKind* = distinct int32
  RotationKind* = distinct int32
  FractalKind* = distinct int32
  CellularDistanceFunc* = distinct int32
  CellularReturnKind* = distinct int32
  DomainWarpKind* = distinct int32

  NoiseState* = object

proc create*(): NoiseState {.importc: "fnlCreateState", cdecl.}
proc get2dNoise*(s: ptr NoiseState; x, y: float32): float32 {.importc: "fnlGetNoise2D", cdecl.}
proc get3dNoise*(s: ptr NoiseState; x, y, z: float32): float32 {.importc: "fnlGetNoise2D", cdecl.}