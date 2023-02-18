import api, fuse, tnt

proc init(cam: ptr Camera; fovDeg: float32; viewport: Rectangle; fNear,
    fFar: float32) {.cdecl.} =
  cam.right = vec3(1.0'f32, 0.0'f32, 0.0'f32)
  cam.up = vec3(0.0'f32, 1.0'f32, 0.0'f32)
  cam.forward = vec3(0.0'f32, 0.0'f32, -1.0'f32)
  cam.pos = vec3(0.0'f32, 0.0'f32, 0.0'f32)

  cam.quat = identityQuat()
  cam.fov = fovDeg
  cam.fNear = fNear
  cam.fFar = fFar
  cam.viewport = viewport

proc calcFrustumPointsRange(cam: ptr Camera; frustum: ptr Frustum; fNear,
    fFar: float32) {.cdecl.} =
  let
    fov = toRad(cam.fov)
    w = cam.viewport.xMax - cam.viewport.xMin
    h = cam.viewport.yMax - cam.viewport.yMin
    aspect = w / h

    xAxis = cam.right
    yAxis = cam.up
    zAxis = cam.forward
    pos = cam.pos

    nearPlaneH = tan(fov * 0.5'f32) * fNear
    nearPlaneW = nearPlaneH * aspect

    farPlaneH = tan(fov * 0.5'f32) * fFar
    farPlaneW = farPlaneH * aspect

    centerNear = (zAxis * fNear) + pos
    centerFar = (zAxis * fFar) + pos

    xNearScaled = xAxis * nearPlaneW
    xFarScaled = xAxis * farPlaneW
    yNearScaled = yAxis * nearPlaneH
    yFarScaled = yAxis * farPlaneH

  frustum[0] = vec4(centerNear - (xNearScaled + yNearScaled), 0.0'f32)
  frustum[1] = vec4(centerNear + (xNearScaled - yNearScaled), 0.0'f32)
  frustum[2] = vec4(centerNear + (xNearScaled + yNearScaled), 0.0'f32)
  frustum[3] = vec4(centerNear - (xNearScaled - yNearScaled), 0.0'f32)

  frustum[4] = vec4(centerFar - (xFarScaled + yFarScaled), 0.0'f32)
  frustum[5] = vec4(centerFar - (xFarScaled - yFarScaled), 0.0'f32)
  frustum[6] = vec4(centerFar + (xFarScaled + yFarScaled), 0.0'f32)
  frustum[7] = vec4(centerFar + (xFarScaled - yFarScaled), 0.0'f32)

proc perspective(cam: ptr Camera; proj: ptr Mat4) {.cdecl.} =
  assert(proj != nil)

  let
    w = cam.viewport.xMax - cam.viewport.xMin
    h = cam.viewport.yMax - cam.viewport.yMin

  proj[] = perspective(toRad(cam.fov), w / h, cam.fNear, cam.fFar)

proc view(cam: ptr Camera; view: ptr Mat4) {.cdecl.} =
  assert(view != nil)

  view[] = mat4(
    [cam.right.x, cam.up.x, cam.forward.x, 0.0'f32],
    [cam.right.y, cam.up.y, cam.forward.y, 0.0'f32],
    [cam.right.z, cam.up.z, cam.forward.z, 0.0'f32],
    [-dot(cam.right, cam.pos), -dot(cam.up, cam.pos), -dot(cam.forward, cam.pos), 1.0'f32]
  )

proc lookAt(cam: ptr Camera; pos, target, up: Vec3f) =
  cam.forward = normalizeTo(pos - target)
  cam.right = normalizeTo(cross(up, cam.forward))
  cam.up = cross(cam.forward, cam.right)
  cam.pos = pos

  # var m =  mat4(
  #   [cam.right.x, cam.up.x, cam.forward.x, 0.0'f32],
  #   [cam.right.y, cam.up.y, cam.forward.y, 0.0'f32],
  #   [cam.right.z, cam.up.z, cam.forward.z, 0.0'f32],
  #   [0.0'f32, 0.0'f32, 0.0'f32, 1.0'f32]
  # )
  var m = lookAt(cam.pos, cam.pos + cam.forward, cam.up)

  cam.quat = mat4Quat(m)

proc initFps(fps: ptr FpsCamera; fovDeg: float32; viewport: Rectangle; fNear,
    fFar: float32) {.cdecl.} =
  init(fps.cam.addr, fovDeg, viewport, fnear, fFar)
  fps.pitch = 0
  fps.yaw = fps.pitch

proc updateRot(cam: ptr Camera) =
  let m = mat4(cam.quat)

  # cam.right = m[0].xyz
  # cam.up = -1.0'f32 * m[1].xyz
  # cam.forward = m[2].xyz
  cam.right = normalizeTo(quatRotateV(cam.quat, vec3(1.0'f32, 0.0'f32, 0.0'f32)))
  cam.up = -1.0'f32 * normalizeTo(quatRotateV(cam.quat, vec3(0.0'f32, 1.0'f32, 0'f32)))
  cam.forward = normalizeTo(quatRotateV(cam.quat, vec3(0.0'f32, 0'f32, -1.0'f32)))

proc lookAtFps(fps: ptr FpsCamera; pos, target, up: Vec3f) {.cdecl.} =
  lookAt(fps.cam.addr, pos, target, up)

  let angles = eulerAngles(mat4(fps.cam.quat))  
  fps.pitch = angles.x
  fps.yaw = angles.y
  
proc pitchFps(fps: ptr FpsCamera; pitch: float32) {.cdecl.} =
  fps.pitch -= pitch
  let
    qPitch = quat(fps.pitch, vec3(1.0'f32, 0.0'f32, 0.0'f32))
    qYaw = quat(fps.yaw, vec3(0.0'f32, 1.0'f32, 0.0'f32))
  fps.cam.quat = qPitch * qYaw
  updateRot(addr(fps.cam))

proc yawFps(fps: ptr FpsCamera; yaw: float32) {.cdecl.} =
  fps.yaw -= yaw
  let
    qPitch = quat(fps.pitch, vec3(1.0'f32, 0.0'f32, 0.0'f32))
    qYaw = quat(fps.yaw, vec3(0.0'f32, 1.0'f32, 0.0'f32))
  fps.cam.quat = qPitch * qYaw
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
