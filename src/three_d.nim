import api, tnt

type
  DebugVertex* = object
    pos*: Vec3f
    normal*: Vec3f
    uv*: Vec2f
    color*: array[4, uint8]

  Debug* = object
    gridXYPlaneCam*: proc(spacing, spacingBold, dist: float32; cam: ptr Camera; viewProj: ptr Mat4) {.cdecl.}

  ThreeDApi* = object
    debug*: Debug

var threeDApi*: ThreeDApi