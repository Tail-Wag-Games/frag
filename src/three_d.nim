import api, tnt

type
  DebugVertex* = object
    pos*: Vec3
    normal*: Vec3
    uv*: Vec2
    color*: tnt.Color
  
  DebugMapType* = distinct int32

  DebugGeometry* = object
    verts*: ptr UncheckedArray[DebugVertex]
    indices*: ptr UncheckedArray[uint16]
    numVerts*: int32
    numIndices*: int32

  Debug* = object
    gridXYPlaneCam*: proc(spacing, spacingBold, dist: float32; cam: ptr Camera; viewProj: ptr Mat4) {.cdecl.}
    drawBox*: proc(box: ptr Box; viewProjMat: ptr Mat4; mapType: DebugMapType; tint: Color) {.cdecl.}
    drawBoxes*: proc(boxes: ptr Box; numBoxes: int32; viewProjMat: ptr Mat4; mapType: DebugMapType; tints: ptr Color) {.cdecl.}

  ThreeDApi* = object
    debug*: Debug

const
  dmtWhite* = DebugMapType(0)
  dmtChecker* = DebugMapType(1)

var threeDApi*: ThreeDApi