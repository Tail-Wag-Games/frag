{.compile: "C:\\Users\\Zach\\dev\\frag\\thirdparty\\FastNoiseLite\\C\\FastNoiseLite.c".}

type
  NoiseKind* = distinct int32
  RotationKind3d* = distinct int32
  FractalKind* = distinct int32
  CellularDistanceFunc* = distinct int32
  CellularReturnKind* = distinct int32
  DomainWarpKind* = distinct int32

  NoiseGenerator* = object
    seed*: int32
    frequency*: float32
    kind*: NoiseKind
    rotationKind3d*: RotationKind3d
    fractalKind*: FractalKind
    octaves*: int32
    lacunarity*: float32
    gain*: float32
    weightedStrength*: float32
    pingPongStrength*: float32
    cellularDistanceFunc*: CellularDistanceFunc
    cellularReturnKind*: CellularReturnKind
    cellularJitterMod*: float32
    domainWarpKind*: DomainWarpKind
    domainWarpAmp*: float32

const
  nkOpenSimplex2* = NoiseKind(0)
  nkOpenSimplex2s* = NoiseKind(1)
  nkCellular* = NoiseKind(2)
  nkPerlin* = NoiseKind(3)
  nkValueCubic* = NoiseKind(4)
  nkValue* = NoiseKind(5)

  rk3dNone* = RotationKind3d(0)
  rk3dImproveXYPlanes* = RotationKind3d(1)
  rk3dImproveXZPlanes* = RotationKind3d(2)

  fkNone* = FractalKind(0)
  fkFBM* = FractalKind(0)
  fkRidged* = FractalKind(0)
  fkPingPong* = FractalKind(0)
  fkDomainWarpProgressive* = FractalKind(0)
  fkDomainWarpIndependent* = FractalKind(0)

proc create*(): NoiseGenerator {.importc: "fnlCreateState", cdecl.}
proc noise2d*(s: ptr NoiseGenerator; x, y: float32): float32 {.importc: "fnlGetNoise2D", cdecl.}
proc noise3d*(s: ptr NoiseGenerator; x, y, z: float32): float32 {.importc: "fnlGetNoise3D", cdecl.}