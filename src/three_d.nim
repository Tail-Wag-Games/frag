import api

type
  DebugVertex* = object
    pos*: Float3f
    normal*: Float3f
    uv*: Float2f
    color*: Color

  Debug* = object
    gridXYPlaneCam*: proc(spacing, spacingBold, dist: float32; cam: ptr Camera; viewProj: ptr Float4x4f) {.cdecl.}

  ThreeDApi* = object
    debug*: Debug

var threeDApi*: ThreeDApi