import api, fuse, tnt

proc init(cam: ptr Camera; fovDeg: float32; viewport: Rectangle; fNear,
    fFar: float32) {.cdecl.} =
  cam.right = vec3(1.0'f32, 0.0'f32, 0.0'f32)
  cam.up = vec3(0.0'f32, 0.0'f32, 1.0'f32)
  cam.forward = vec3(0.0'f32, 1.0'f32, 0.0'f32)
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

  view[] = lookAt(cam.pos, cam.pos + cam.forward, cam.up)

proc lookAt(cam: ptr Camera; pos, target, up: Vec3) =
  cam.forward = normalize(target - pos)
  cam.right = normalize(cross(cam.forward, up))
  cam.up = cross(cam.right, cam.forward)
  cam.pos = pos

  let m = mat4(
    [cam.right.x, cam.right.y, cam.right.z, 0.0'f32],
    [-cam.up.x, -cam.up.y, -cam.up.z, 0.0'f32],
    [cam.forward.x, cam.forward.y, cam.forward.z, 0.0'f32],
    [0.0'f32, 0.0'f32, 0.0'f32, 1.0'f32]
  )

  cam.quat = quatFor(cam.forward, cam.up)

proc initFps(fps: ptr FpsCamera; fovDeg: float32; viewport: Rectangle; fNear,
    fFar: float32) {.cdecl.} =
  init(fps.cam.addr, fovDeg, viewport, fnear, fFar)
  fps.pitch = 0
  fps.yaw = fps.pitch

proc lookAtFps(fps: ptr FpsCamera; pos, target, up: Vec3) {.cdecl.} =
  lookAt(fps.cam.addr, pos, target, up)

  let angles = eulerAngles(mat4(fps.cam.quat))  
  fps.pitch = angles.x
  fps.yaw = angles.z

proc updateRot(cam: ptr Camera) =
  let m = mat4(cam.quat)

  cam.right = m[0].xyz
  cam.up = m[1].xyz
  cam.forward = -1.0 * m[2].xyz
  
proc pitchFps(fps: ptr FpsCamera; pitch: float32) {.cdecl.} =
  fps.pitch -= pitch
  fps.cam.quat = quat(fps.yaw, vec3(0, 0, 1)) * quat(fps.pitch, vec3(1, 0, 0))
  updateRot(addr(fps.cam))

proc yawFps(fps: ptr FpsCamera; yaw: float32) {.cdecl.} =
  fps.yaw -= yaw
  fps.cam.quat = quat(fps.yaw, vec3(0, 0, 1)) * quat(fps.pitch, vec3(1, 0, 0))
  updateRot(addr(fps.cam))

proc forwardFps(fps: ptr FpsCamera; forward: float32) {.cdecl.} =
  fps.cam.pos += (fps.cam.forward * forward)

proc strafeFps(fps: ptr FpsCamera; strafe: float32) {.cdecl.} =
  fps.cam.pos += (fps.cam.right * strafe)

cameraApi = CameraApi(
  perspective: perspective,
  view: view,
  calcFrustumPointsRange: calcFrustumPointsRange,
  initFps: initFps,
  lookAtFps: lookAtFps,
  pitchFps: pitchFps,
  yawFps: yawFps,
  forwardFps: forwardFps,
  strafeFps: strafeFps
)
