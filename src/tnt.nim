import std/math,
       hmm

export 
  hmm,
  math

type
  Ray* = object
    dir*, orig*: Vec3

  Rectangle* = object
    xMin*, yMin*: float32
    xMax*, yMax*: float32

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
