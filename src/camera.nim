import api, fuse, tnt

proc init(cam: ptr Camera; fovDeg: float32; viewport: Rectangle; fNear,
    fFar: float32) {.cdecl.} =
  cam.right = vec3(1.0'f32, 0.0'f32, 0.0'f32)
  cam.up = vec3(0.0'f32, 1.0'f32, 0.0'f32)
  cam.forward = vec3(0.0'f32, 0.0'f32, 1.0'f32)
  cam.pos = vec3(0.0'f32, 0.0'f32, 0.0'f32)
  # cam.pos = vec3(3601.0'f32 / 2.0'f32, 3601.0'f32 / 4.0'f32, 0.0'f32)

  cam.quat = quaternion(0.0'f32, 0.0'f32, 0.0'f32, 1.0'f32)
  cam.fov = fovDeg
  cam.fNear = fNear
  cam.fFar = fFar
  cam.viewport = viewport

# proc calcFrustumPointsRange(cam: ptr Camera; frustum: ptr Frustum; fNear,
#     fFar: float32) {.cdecl.} =
#   let
#     fov = toRad(cam.fov)
#     w = cam.viewport.xMax - cam.viewport.xMin
#     h = cam.viewport.yMax - cam.viewport.yMin
#     aspect = w / h

#     xAxis = cam.right
#     yAxis = cam.up
#     zAxis = cam.forward
#     pos = cam.pos

#     nearPlaneH = tan(fov * 0.5'f32) * fNear
#     nearPlaneW = nearPlaneH * aspect

#     farPlaneH = tan(fov * 0.5'f32) * fFar
#     farPlaneW = farPlaneH * aspect

#     centerNear = (zAxis * fNear) + pos
#     centerFar = (zAxis * fFar) + pos

#     xNearScaled = xAxis * nearPlaneW
#     xFarScaled = xAxis * farPlaneW
#     yNearScaled = yAxis * nearPlaneH
#     yFarScaled = yAxis * farPlaneH

#   frustum[0] = vec4(centerNear - (xNearScaled + yNearScaled), 0.0'f32)
#   frustum[1] = vec4(centerNear + (xNearScaled - yNearScaled), 0.0'f32)
#   frustum[2] = vec4(centerNear + (xNearScaled + yNearScaled), 0.0'f32)
#   frustum[3] = vec4(centerNear - (xNearScaled - yNearScaled), 0.0'f32)

#   frustum[4] = vec4(centerFar - (xFarScaled + yFarScaled), 0.0'f32)
#   frustum[5] = vec4(centerFar - (xFarScaled - yFarScaled), 0.0'f32)
#   frustum[6] = vec4(centerFar + (xFarScaled + yFarScaled), 0.0'f32)
#   frustum[7] = vec4(centerFar + (xFarScaled - yFarScaled), 0.0'f32)

proc perspective(cam: ptr Camera; proj: ptr Mat4) {.cdecl.} =
  assert(proj != nil)

  let
    w = cam.viewport.xMax - cam.viewport.xMin
    h = cam.viewport.yMax - cam.viewport.yMin

  proj[] = perspective(cam.fov, w / h, cam.fNear, cam.fFar)

proc view(cam: ptr Camera; view, invView: ptr Mat4) {.cdecl.} =
  assert(view != nil)

  view[] = lookAt(cam.pos, addVec3(cam.pos, cam.forward), cam.up)

  # view[].elements = [
  #   [cam.right.x, cam.up.x, cam.forward.x, 0.0'f32],
  #   [cam.right.y, cam.up.y, cam.forward.y, 0.0'f32],
  #   [cam.right.z, cam.up.z, cam.forward.z, 0.0'f32],
  #   [-dotVec3(cam.right, cam.pos), -dotVec3(cam.up, cam.pos), -dotVec3(cam.forward, cam.pos), 1.0'f32]
  # ]

proc lookAt(cam: ptr Camera; pos, target, up: Vec3) =
  cam.forward = normalizeVec3(subtractVec3(target, pos))
  cam.right = normalizeVec3(cross(cam.forward, up))
  cam.up = cross(cam.right, cam.forward)
  cam.pos = pos

  # var m: Mat4
  # m.elements = [
  #   [cam.right.x, cam.up.x, -cam.forward.x, 0.0'f32],
  #   [cam.right.y, cam.up.y, -cam.forward.y, 0.0'f32],
  #   [cam.right.z, cam.up.z, -cam.forward.z, 0.0'f32],
  #   [0.0'f32, 0.0'f32, 0.0'f32, 1.0'f32]
  # ]
  # var m = lookAt(pos, target, up)

  # cam.quat =  mat4ToQuaternion(m)

proc initFps(fps: ptr FpsCamera; fovDeg: float32; viewport: Rectangle; fNear,
    fFar: float32) {.cdecl.} =
  init(fps.cam.addr, fovDeg, viewport, fnear, fFar)
  fps.pitch = 0
  fps.yaw = fps.pitch

proc lookAtFps(fps: ptr FpsCamera; pos, target, up: Vec3) {.cdecl.} =
  lookAt(fps.cam.addr, pos, target, up)

  # let
  #   sinrCosp = 2 * (fps.cam.quat.w * fps.cam.quat.x + fps.cam.quat.y * fps.cam.quat.z)
  #   cosrCosp = 1 - 2 * (fps.cam.quat.x * fps.cam.quat.x + fps.cam.quat.y * fps.cam.quat.y)

  #   # sinp = 2 * (fps.cam.quat.w * fps.cam.quat.y - fps.cam.quat.z * fps.cam.quat.x)

  #   sinyCosp = 2 * (fps.cam.quat.w * fps.cam.quat.z + fps.cam.quat.x * fps.cam.quat.y)
  #   cosyCosp = 1 - 2 * (fps.cam.quat.y * fps.cam.quat.y + fps.cam.quat.z * fps.cam.quat.z)
  
  # fps.pitch = aTan2F(sinrCosp, cosrCosp)
  # fps.yaw = aTan2F(sinyCosp, cosyCosp)

proc updateRot(cam: ptr Camera) =
  let m = quaternionToMat4(cam.quat)

  cam.right = m[0].xyz
  cam.up = multiplyVec3f(m[1].xyz, -1.0'f32) 
  cam.forward = m[2].xyz
  
proc pitchFps(fps: ptr FpsCamera; pitch: float32) {.cdecl.} =
  fps.pitch -= pitch
  fps.cam.quat = quaternionFromAxisAngle(vec3(0, 0, 1), fps.yaw) * quaternionFromAxisAngle(vec3(1, 0, 0), fps.pitch)
  updateRot(addr(fps.cam))

proc yawFps(fps: ptr FpsCamera; yaw: float32) {.cdecl.} =
  fps.yaw -= yaw
  fps.cam.quat = quaternionFromAxisAngle(vec3(0, 0, 1), fps.yaw) * quaternionFromAxisAngle(vec3(1, 0, 0), fps.pitch)
  updateRot(addr(fps.cam))

proc forwardFps(fps: ptr FpsCamera; forward: float32) {.cdecl.} =
  fps.cam.pos += (fps.cam.forward * forward)

proc strafeFps(fps: ptr FpsCamera; strafe: float32) {.cdecl.} =
  fps.cam.pos += (fps.cam.right * strafe)

cameraApi = CameraApi(
  perspective: perspective,
  view: view,
  # calcFrustumPointsRange: calcFrustumPointsRange,
  initFps: initFps,
  lookAtFps: lookAtFps,
  pitchFps: pitchFps,
  yawFps: yawFps,
  forwardFps: forwardFps,
  strafeFps: strafeFps
)