import api, fuse

proc init(cam: ptr Camera; fovDeg: float32; viewport: Rectangle; fnear,
    ffar: float32) {.cdecl.} =
  cam.right = Float3fUnitX
  cam.up = Float3fUnitZ
  cam.forward = Float3fUnitY
  cam.pos = Float3fZero

  storeQuat(cam.quat.addr, identityQuat())
  cam.fov = fovDeg
  cam.fnear = fnear
  cam.ffar = ffar
  cam.viewport = viewport

proc perspective(cam: ptr Camera; proj: ptr Matrix4x4f) {.cdecl.} =
  assert(proj != nil)

  let
    w = cam.viewport.xMax - cam.viewport.xMin
    h = cam.viewport.yMax - cam.viewport.yMin

  proj[] = perspectiveFov(toRad(cam.fov), w / h, cam.fnear, cam.ffar,
      gfxApi.glFamily())

proc view(cam: ptr Camera; view: ptr Matrix4x4f) {.cdecl.} =
  assert(view != nil)

  let
    zAxis = cam.forward
    xAxis = cam.right
    yAxis = cam.up
    col0 = setVector(xAxis.x, xAxis.y, xAxis.z, -castScalar(dotVector3(
        setVector(xAxis.x, xAxis.y, xAxis.z), setVector(cam.pos.x, cam.pos.y, cam.pos.z))))
    col1 = setVector(yAxis.x, yAxis.y, yAxis.z, -castScalar(dotVector3(
        setVector(yAxis.x, yAxis.y, yAxis.z), setVector(cam.pos.x, cam.pos.y, cam.pos.z))))
    col2 = setVector(-zAxis.x, -zAxis.y, -zAxis.z, -castScalar(dotVector3(
        setVector(zAxis.x, zAxis.y, zAxis.z), setVector(cam.pos.x, cam.pos.y, cam.pos.z))))
    col3 = setVector(0.0'f32, 0.0'f32, 0.0'f32, 1.0'f32)
  
  view[] = setMatrix(col0, col1, col2, col3)

proc lookAt(cam: ptr Camera; pos, target, up: Float3f) =
  storeVector3(cam.forward.addr, normVector3(subVector(setVector(target.x,
      target.y, target.z), setVector(pos.x, pos.y, pos.z))))
  storeVector3(cam.right.addr, crossVector3(setVector(cam.forward.x,
      cam.forward.y, cam.forward.z), setVector(up.x, up.y, up.z)))
  storeVector3(cam.up.addr, crossVector3(setVector(cam.forward.x, cam.forward.y,
      cam.forward.z), setVector(up.x, up.y, up.z)))
  cam.pos = pos

  let m = setMatrix(
    setVector(cam.right.x, cam.right.y, cam.right.z, 0.0'f32),
    setVector(-cam.up.x, -cam.up.y, -cam.up.z, 0.0'f32),
    setVector(cam.forward.x, cam.forward.y, cam.forward.z, 0.0'f32),
    setVector(0.0'f32, 0.0'f32, 0.0'f32, 1.0'f32)
  )
  storeQuat(cam.quat.addr, quat_from_matrix(m.xAxis, m.yAxis, m.zAxis))

proc initFps(cam: ptr FpsCamera; fovDeg: float32; viewport: Rectangle; fnear,
    ffar: float32) {.cdecl.} =
  init(cam.cam.addr, fovDeg, viewport, fnear, ffar)
  cam.pitch = 0
  cam.yaw = cam.pitch

proc lookAtFps(cam: ptr FpsCamera; pos, target, up: Float3f) {.cdecl.} =
  lookAt(cam.cam.addr, pos, target, up)

  let euler = getQuatAxis(setQuat(cam.cam.quat.x, cam.cam.quat.y,
      cam.cam.quat.z, cam.cam.quat.w))
  cam.pitch = getVectorX(euler)
  cam.yaw = getVectorZ(euler)

cameraApi = CameraApi(
  perspective: perspective,
  view: view,
  initFps: initFps,
  lookAtFps: lookAtFps
)
