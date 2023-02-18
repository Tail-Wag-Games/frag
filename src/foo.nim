type
  Vec2*[T] {.exportc.} = object
    x*, y*: T

proc windowSize*[T](size: ptr Vec2[T]) {.cdecl, exportc: "window_size".} =
  size.x = T(1)
  size.y = T(2)