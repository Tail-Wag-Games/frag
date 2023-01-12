import std/math,
       cglm

export 
  cglm,
  math

type
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