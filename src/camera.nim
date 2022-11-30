import api, fuse

proc init(cam: ptr Camera; fovDeg: float32; viewport: Rectangle; fnear, ffar: float32) {.cdecl.} =
  cam.right = Float3fUnitX
  cam.up = Float3fUnitZ
  cam.forward = Float3fUnitY
  cam.pos = Float3fZero

  storeQuat(cam.quat.addr, identityQuat())
  cam.fov = fovDeg
  cam.fnear = fnear
  cam.ffar = ffar
  cam.viewport = viewport

proc lookAt(cam: ptr Camera; pos, target, up: Float3f) =
  storeVector3(cam.forward.addr, normVector3(subVector(setVector(target.x, target.y, target.z), setVector(pos.x, pos.y, pos.z))))
  storeVector3(cam.right.addr, crossVector3(setVector(cam.forward.x, cam.forward.y, cam.forward.z), setVector(up.x, up.y, up.z)))
  storeVector3(cam.up.addr, crossVector3(setVector(cam.forward.x, cam.forward.y, cam.forward.z), setVector(up.x, up.y, up.z)))
  cam.pos = pos

  let m = setMatrix(
    setVector(cam.right.x, cam.right.y, cam.right.z, 0.0'f32),
    setVector(-cam.up.x, -cam.up.y, -cam.up.z, 0.0'f32),
    setVector(cam.forward.x, cam.forward.y, cam.forward.z, 0.0'f32),
    setVector(0.0'f32, 0.0'f32, 0.0'f32, 1.0'f32)
  )
  storeQuat(cam.quat.addr, quat_from_matrix(m.xAxis, m.yAxis, m.zAxis))

proc initFps(cam: ptr FpsCamera; fovDeg: float32; viewport: Rectangle; fnear, ffar: float32) {.cdecl.} =
  init(cam.cam.addr, fovDeg, viewport, fnear, ffar)
  cam.pitch = 0
  cam.yaw = cam.pitch

proc lookAtFps(cam: ptr FpsCamera; pos, target, up: Float3f) {.cdecl.} =
  lookAt(cam.cam.addr, pos, target, up)

  let euler = getQuatAxis(setQuat(cam.cam.quat.x, cam.cam.quat.y, cam.cam.quat.z, cam.cam.quat.w))
  cam.pitch = getVectorX(euler)
  cam.yaw = getVectorZ(euler)

cameraApi = CameraApi(
  initFps: initFps,
  lookAtFps: lookAtFps
)