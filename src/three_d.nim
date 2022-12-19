import api

type
  Debug* = object
    gridXYPlaneCam*: proc(spacing, spacingBold, dist: float32; cam: ptr Camera; viewProj: ptr Float4x4f) {.cdecl.}

  ThreeDApi* = object
    debug*: Debug

var threeDApi*: ThreeDApi