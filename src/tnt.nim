import std/[fenv, math],
       hmm

export 
  hmm,
  math

type
  Region2* = concept e
    bbox(e) is BBox2
    inside(Vec2, e) is bool
    dist(Vec2, e) is float32
    distSq(Vec2, e) is float32

  Ray* = object
    dir*, orig*: Vec3

  Rectangle* = object
    xMin*, yMin*: float32
    xMax*, yMax*: float32
  
  BBox2* = object
    min*, max*: Vec2

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

proc bbox*(min, max: Vec2): BBox2 = BBox2(min: min, max: max)