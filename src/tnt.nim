import std/[fenv, math],
       hmm

export
  hmm,
  math

type
  Rgba* = object
    r*, g*, b*, a*: uint8

  Color* {.union.} = object
    rgba*: Rgba
    element*: uint32

  # 3d Transform
  Tx3d* = object
    pos*: Vec3
    rot*: Mat3

  Box* = object
    tx*: Tx3d
    e*: Vec3

  Ray* = object
    dir*, orig*: Vec3

  Rectangle* = object
    xMin*, yMin*: float32
    xMax*, yMax*: float32

  MinMax* = object
    xMin*, yMin*, zMin*: float32
    xMax*, yMax*, zMax*: float32

  VMinMax* = object
    vMin*: Vec3
    vMax*: Vec3

  AABB* {.union.} = object
    minMax*: MinMax
    vMinMax*: VMinMax
    f*: array[6, float32]
    

let
  White* = Color(rgba: Rgba(r: 255, g: 255, b: 255, a: 255))

proc rectangle(xMin, yMin, xMax, yMax: float32): Rectangle =
  result.xMin = xMin
  result.yMin = yMin
  result.xMax = xMax
  result.yMax = yMax

proc rectwh*(x, y, w, h: float32): Rectangle =
  result = rectangle(x, y, x + w, y + h)

proc log2*(x: int32): int32 =
  var p = nextPowerOfTwo(x)

  while not bool(p and 1):
    p = p shr 1
    inc(result)

proc max3*[T](x, y, z: T): T =
  result = x
  if result < y: result = y
  if result < z: result = z

proc `~=`*(a, b: float): bool = abs(a - b) <= epsilon(float)

proc length*(p: Vec2): float32 = hypot(p.x, p.y)

proc area*(a, b, c: Vec2): float32 =
  (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)

proc dist*(p1: Vec2, p2: Vec2): float32 = subtractVec2(p1, p2).length

proc aabbf*(xMin, yMin, zMin, xMax, yMax, zMax: float32): AABB = 
  result = AABB(minMax: MinMax(xMin: xMin, yMin: yMin, zMin: zMin, xMax: xMax, yMax: yMax, zMax: zMax))

proc aabbv*(vMin, vMax: Vec3): AABB =
  result = AABB(vMinMax: VMinMax(vMin: vMin, vMax: vMax))

proc corner(aabb: ptr AABB; idx: int): Vec3 =
  assert(idx < 8)
  result = vec3(
    if bool(idx and 1): aabb.minMax.xMax else: aabb.minMax.xMin,
    if bool(idx and 4): aabb.minMax.yMax else: aabb.minMax.yMin,
    if bool(idx and 2): aabb.minMax.zMax else: aabb.minMax.zMin
  )

proc corners*(aabb: ptr AABB): array[8, Vec3] =
  for i in 0 ..< 8:
    result[i] = corner(aabb, i)

proc addPoint*(aabb: ptr AABB; pt: Vec3) =
  aabb[] = aabbv(min(aabb.vMinMax.vMin, pt), max(aabb.vMinMax.vMax, pt))

proc normalizePlane*(va, vb, vc: Vec3): Vec3 =
  let
    ba = vb - va
    ca = vc - va
    baca = cross(ca, ba)
  
  result = normalizeVec3(baca)