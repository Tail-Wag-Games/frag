import std/[deques, tables],
       noise,
       tnt

type
  SurfaceKind = distinct uint

  SurfaceParameters = object
    name: string
    density: float32
    porosity: float32

    transports: SurfaceKind
    solubility: float32
    equrate: float32
    friction: float32

    erodes: SurfaceKind
    erosionRate: float32

    cascades: SurfaceKind
    maxDiff: float32
    settling: float32

    abrades: SurfaceKind
    suspension: float32
    abrasion: float32

  SurfaceLayer = object
    surfaceKind: SurfaceKind

    min, bias, scale: float32

    gen: NoiseGenerator
    octaves: int32
    lacunarity, gain, frequency: float32

  Section = object
    next: ptr Section
    prev: ptr Section

    surfaceKind: SurfaceKind
    size: float64
    floor: float64
    saturation: float64

  SectionPool = object
    size: int32
    start: ptr UncheckedArray[Section]
    free: Deque[ptr Section]

  LayerMap* = object
    dim: tuple[x, y: int32]
    pool: SectionPool
    data: ptr UncheckedArray[ptr Section]

    layers: seq[SurfaceLayer]
    heights: seq[uint16]

const
  worldScale = 80
  slice = 2 * worldScale

var soils = @[
  SurfaceParameters(
    name: "Air",
    porosity: 1.0'f32
  ),
  SurfaceParameters(
    name: "Rock",
    solubility: 1.0'f32,
    equRate: 0.1'f32,
    friction: 0.15'f32,
    maxDiff: 0.01'f32,
    settling: 0.1'f32,
  ),
]

var soilMap: Table[string, SurfaceKind] = {
  "Air": SurfaceKind(0),
  "Rock": SurfaceKind(1),
  "Sand": SurfaceKind(2)
}.toTable()

proc `==` *(l, r: SurfaceKind): bool {.borrow.}

proc init(sl: var SurfaceLayer) =
  sl.gen = create()
  sl.gen.kind = nkOpenSimplex2
  sl.gen.fractalKind = fkFBM
  sl.gen.octaves = sl.octaves
  sl.gen.lacunarity = sl.lacunarity
  sl.gen.gain = sl.gain
  sl.gen.frequency = sl.frequency

proc get(sl: var SurfaceLayer; pos: Vec3): float32 =
  result = sl.bias + sl.scale * noise3d(addr(sl.gen), pos.x, pos.y, pos.z)
  if result < sl.min: result = sl.min

proc init(s: ptr Section; size: float64; surfaceKind: SurfaceKind) =
  s.size = size
  s.surfaceKind = surfaceKind

proc reset(s: ptr Section) =
  s.size = 0.0'f64

proc reserve(sp: var SectionPool; n: int32) =
  sp.start = cast[ptr UncheckedArray[Section]](alloc0(sizeof(Section) * n))
  for i in 0 ..< n:
    addFirst(sp.free, addr(sp.start[i]))
  sp.size = n

proc get(sp: var SectionPool; size: float64;
    surfaceKind: SurfaceKind): ptr Section =
  block outer:
    if len(sp.free) == 0:
      result = nil
      break outer

    result = popLast(sp.free)
    init(result, size, surfaceKind)

proc release(sp: var SectionPool; sec: ptr Section) =
  block outer:
    if isNil(sec):
      break outer

    reset(sec)
    addFirst(sp.free, sec)

proc reset(sp: var SectionPool) =
  clear(sp.free)
  for i in 0 ..< sp.size:
    addFirst(sp.free, addr(sp.start[i]))

proc height*(lm: ptr ; pos: tuple[x, y: int32]): float64 =
  block outer:
    if isNil(lm.data[pos.x * lm.dim.y + pos.y]):
      result = 0.0'f64
      break outer

    result = lm.data[pos.x * lm.dim.y + pos.y].floor + lm.data[pos.x * lm.dim.y + pos.y].size

proc add(lm: ptr LayerMap; pos: tuple[x, y: int32]; sec: ptr Section) =
  block outer:
    if isNil(sec):
      break outer
    
    if sec.size <= 0:
      release(lm.pool, sec)
      break outer

    if isNil(lm.data[pos.x * lm.dim.y + pos.y]):
      lm.data[pos.x * lm.dim.y + pos.y] = sec
      break outer

    if lm.data[pos.x * lm.dim.y + pos.y].surfaceKind == sec.surfaceKind:
      lm.data[pos.x * lm.dim.y + pos.y].size += sec.size
      release(lm.pool, sec)
      break outer

    if lm.data[pos.x * lm.dim.y + pos.y].surfaceKind == soilMap["Air"]:
      let top = lm.data[pos.x * lm.dim.y + pos.y]
      lm.data[pos.x * lm.dim.y + pos.y] = top.prev

      add(lm, pos, sec)
      add(lm, pos, top)

      break outer
  
    lm.data[pos.x * lm.dim.y + pos.y].next = sec
    sec.prev = lm.data[pos.x * lm.dim.y + pos.y]
    sec.floor = height(lm, pos)
    lm.data[pos.x * lm.dim.y + pos.y] = sec

#  proc update*(lm: ptr LayerMap; pos: tuple[x, y: int32]) =
#   lm.data[p.x*dim.y+p.y] = 

proc init*(lm: ptr LayerMap; seed: int32; dim: tuple[x, y: int32]) =
  lm.pool.reserve(10000000)
  
  add(lm.layers,
    [SurfaceLayer(
      min: 0.0,
      bias: 0.0,
      scale: 1.0,
      octaves: 1,
      lacunarity: 1.0,
      gain: 0.0,
      frequency: 1.0
    )
    # ,
    #  SurfaceLayer(
    #   min: 0.0,
    #   bias: 0.5,
    #   scale: 0.8,
    #   octaves: 8,
    #   lacunarity: 2.0,
    #   gain: 0.5,
    #   frequency: 1.0
    # )]
    ]
  )

  lm.dim = dim

  reset(lm.pool)
  setLen(lm.heights, lm.dim.x * lm.dim.y)

  if lm.data != nil:
    dealloc(lm.data)
  lm.data = cast[ptr UncheckedArray[ptr Section]](alloc0(sizeof(ptr Section) *
      lm.dim.x * lm.dim.y))

  for i in 0 ..< lm.dim.x:
    for j in 0 ..< lm.dim.y:
      lm.data[i*lm.dim.y+j] = nil

  let maxSeed = 10000
  for l in 0 ..< len(lm.layers):
    let
      f = float32(l) / float32(len(lm.layers))
      z = seed + int32(f * float32(maxSeed))

    init(lm.layers[l])

    for i in 0 ..< lm.dim.x:
      for j in 0 ..< lm.dim.y:
        let h = get(lm.layers[l], divideVec3(vec3(float32(i), float32(j),
            float32(z mod maxSeed)), vec3(float32(dim.x), float32(dim.y), 1.0'f32)))
        add(lm, (i, j),  get(lm.pool, h, lm.layers[l].surfaceKind))

  # for i in 0 ..< lm.dim.x:
  #   for j in 0 ..< lm.dim.y:
  #     update(lm, (i, j))
