from math import PI, almostEqual

{.passC: "-D CGLM_STATIC".}
{.passC: "/IC:\\Users\\Zach\\dev\\frag\\thirdparty\\cglm\\include".}
{.passC: "/IC:\\Users\\Zach\\dev\\frag\\thirdparty\\cglm\\src".}
{.compile:"C:\\Users\\Zach\\dev\\frag\\thirdparty\\cglm\\src\\euler.c".}
{.compile:"C:\\Users\\Zach\\dev\\frag\\thirdparty\\cglm\\src\\affine.c".}
{.compile:"C:\\Users\\Zach\\dev\\frag\\thirdparty\\cglm\\src\\io.c".}
{.compile:"C:\\Users\\Zach\\dev\\frag\\thirdparty\\cglm\\src\\quat.c".}
{.compile:"C:\\Users\\Zach\\dev\\frag\\thirdparty\\cglm\\src\\cam.c".}
{.compile:"C:\\Users\\Zach\\dev\\frag\\thirdparty\\cglm\\src\\vec2.c".}
{.compile:"C:\\Users\\Zach\\dev\\frag\\thirdparty\\cglm\\src\\ivec2.c".}
{.compile:"C:\\Users\\Zach\\dev\\frag\\thirdparty\\cglm\\src\\vec3.c".}
{.compile:"C:\\Users\\Zach\\dev\\frag\\thirdparty\\cglm\\src\\ivec3.c".}
{.compile:"C:\\Users\\Zach\\dev\\frag\\thirdparty\\cglm\\src\\vec4.c".}
{.compile:"C:\\Users\\Zach\\dev\\frag\\thirdparty\\cglm\\src\\ivec4.c".}
{.compile:"C:\\Users\\Zach\\dev\\frag\\thirdparty\\cglm\\src\\mat2.c".}
{.compile:"C:\\Users\\Zach\\dev\\frag\\thirdparty\\cglm\\src\\mat3.c".}
{.compile:"C:\\Users\\Zach\\dev\\frag\\thirdparty\\cglm\\src\\mat4.c".}
{.compile:"C:\\Users\\Zach\\dev\\frag\\thirdparty\\cglm\\src\\plane.c".}
{.compile:"C:\\Users\\Zach\\dev\\frag\\thirdparty\\cglm\\src\\frustum.c".}
{.compile:"C:\\Users\\Zach\\dev\\frag\\thirdparty\\cglm\\src\\box.c".}
{.compile:"C:\\Users\\Zach\\dev\\frag\\thirdparty\\cglm\\src\\project.c".}
{.compile:"C:\\Users\\Zach\\dev\\frag\\thirdparty\\cglm\\src\\sphere.c".}
{.compile:"C:\\Users\\Zach\\dev\\frag\\thirdparty\\cglm\\src\\ease.c".}
{.compile:"C:\\Users\\Zach\\dev\\frag\\thirdparty\\cglm\\src\\curve.c".}
{.compile:"C:\\Users\\Zach\\dev\\frag\\thirdparty\\cglm\\src\\bezier.c".}
{.compile:"C:\\Users\\Zach\\dev\\frag\\thirdparty\\cglm\\src\\ray.c".}
{.compile:"C:\\Users\\Zach\\dev\\frag\\thirdparty\\cglm\\src\\affine2d.c".}
{.compile:"C:\\Users\\Zach\\dev\\frag\\thirdparty\\cglm\\src\\clipspace/ortho_lh_no.c".}
{.compile:"C:\\Users\\Zach\\dev\\frag\\thirdparty\\cglm\\src\\clipspace/ortho_lh_zo.c".}
{.compile:"C:\\Users\\Zach\\dev\\frag\\thirdparty\\cglm\\src\\clipspace/ortho_rh_no.c".}
{.compile:"C:\\Users\\Zach\\dev\\frag\\thirdparty\\cglm\\src\\clipspace/ortho_rh_zo.c".}
{.compile:"C:\\Users\\Zach\\dev\\frag\\thirdparty\\cglm\\src\\clipspace/persp_lh_no.c".}
{.compile:"C:\\Users\\Zach\\dev\\frag\\thirdparty\\cglm\\src\\clipspace/persp_lh_zo.c".}
{.compile:"C:\\Users\\Zach\\dev\\frag\\thirdparty\\cglm\\src\\clipspace/persp_rh_no.c".}
{.compile:"C:\\Users\\Zach\\dev\\frag\\thirdparty\\cglm\\src\\clipspace/persp_rh_zo.c".}
{.compile:"C:\\Users\\Zach\\dev\\frag\\thirdparty\\cglm\\src\\clipspace/view_lh_no.c".}
{.compile:"C:\\Users\\Zach\\dev\\frag\\thirdparty\\cglm\\src\\clipspace/view_lh_zo.c".}
{.compile:"C:\\Users\\Zach\\dev\\frag\\thirdparty\\cglm\\src\\clipspace/view_rh_no.c".}
{.compile:"C:\\Users\\Zach\\dev\\frag\\thirdparty\\cglm\\src\\clipspace/view_rh_zo.c".}
{.compile:"C:\\Users\\Zach\\dev\\frag\\thirdparty\\cglm\\src\\clipspace/project_no.c".}
{.compile:"C:\\Users\\Zach\\dev\\frag\\thirdparty\\cglm\\src\\clipspace/project_zo.c".}

type
  RawIVec2 = array[2, int32]
  IVec2* = object
    raw: RawIVec2
  RawVec2 = array[2, float32]
  Vec2* = object
    raw: RawVec2
  RawVec3 = array[3, float32]
  Vec3* = object
    raw: RawVec3
  RawVec4 = array[4, float32]
  Vec4* = object
    raw {.align: 16.}: RawVec4
  RawVersor = RawVec4
  Versor* = object
    raw {.align: 16.}: RawVersor
  RawMat2 = array[2, RawVec2]
  Mat2* = object
    raw  {.align: 16.}: RawMat2
  RawMat4 = array[4, RawVec4]
  Mat4* = object
    raw  {.align: 16.}: RawMat4

  AABB* = array[2, Vec3]
  Frustum* = array[8, Vec4]

const
  Green* = [0'u8, 255'u8, 0'u8, 255'u8]
  Red* = [255'u8, 0'u8, 0'u8, 255'u8]

proc mat4*(fc1, fc2, fc3, fc4: array[4, float32]): Mat4 =
  result.raw = [
    fc1, fc2, fc3, fc4
  ]
proc glmc_mat4_quat(m, dest: ptr float32) {.importc: "glmc_mat4_quat", cdecl.}
proc mat4Quat*(m: Mat4): Versor =
  glmc_mat4_quat(addr(m.raw[0][0]), addr(result.raw[0]))
proc glmc_mat4_mul(m1, m2, dest: ptr float32) {.importc: "glmc_mat4_mul", cdecl.}
proc `*`*(m1, m2: Mat4): Mat4 = 
  glmc_mat4_mul(addr(m1.raw[0][0]), addr(m2.raw[0][0]), addr(result.raw[0][0]))
proc glmc_lookat(eye, center, up: ptr float32; dest: ptr float32) {.importc: "glmc_lookat", cdecl.}
proc lookAt*(eye, center, up: Vec3): Mat4 = 
  glmc_lookat(addr(eye.raw[0]), addr(center.raw[0]), addr(up.raw[0]), addr(result.raw[0][0]))
proc glmc_perspective(fovy, aspect, nearZ, farZ: float32; dest: ptr float32) {.importc: "glmc_perspective", cdecl.}
proc perspective*(fovy, aspect, nearZ, farZ: float32): Mat4 =
  glmc_perspective(fovy, aspect, nearZ, farZ, addr(result.raw[0][0]))

proc glmc_euler_angles(m: ptr float32; result: ptr float32) {.importc: "glmc_euler_angles", cdecl.}
proc eulerAngles*(m: Mat4): Vec3 =
  glmc_euler_angles(addr(m.raw[0][0]), addr(result.raw[0]))

proc `[]`*(m: Mat4; idx: SomeUnsignedInt): RawVec4 =
  result= m.raw[idx]

proc glmc_plane_normalize(plane: ptr float32; dest: ptr float32) {.importc: "glmc_plane_normalize", cdecl.}
proc normalize*(plane: Vec4): Vec4 =
  glmc_plane_normalize(addr(plane.raw[0]), addr(result.raw[0]))

proc glmc_quat_mul(p, q, dest: ptr float32) {.importc: "glmc_quat_mul", cdecl.}
proc `*`*(p, q: Versor): Versor =
  glmc_quat_mul(addr(p.raw[0]), addr(q.raw[0]), addr(result.raw[0]))
proc glmc_quat_identity(dest: ptr float32) {.importc: "glmc_quat_identity", cdecl.}
proc identityQuat*(): Versor = 
  glmc_quat_identity(addr(result.raw[0]))
proc glmc_quat_mat4(q: ptr float32; dest: ptr float32) {.importc: "glmc_quat_mat4", cdecl.}
proc mat4*(q: Versor): Mat4 =
  glmc_quat_mat4(addr(q.raw[0]), addr(result.raw[0][0]))
proc glmc_quat_for(dir, up, dest: ptr float32) {.importc: "glmc_quat_for", cdecl.}
proc quatFor*(dir, up: Vec3): Versor =
  glmc_quat_for(addr(dir.raw[0]), addr(up.raw[0]), addr(result.raw[0]))
proc glmc_quatv(dest: ptr float32; angle: float32; axis: ptr float32) {.importc: "glmc_quatv", cdecl.}
proc quat*(angle: float32; axis: Vec3): Versor =
  glmc_quatv(addr(result.raw[0]), angle, addr(axis.raw[0]))

proc eq*(a, b: float32): bool =
  result = almostEqual(a, b)
proc toRad*(deg: float32): float32 =
  result = deg * PI / 180.0f;

proc iVec2*(x, y: int32): IVec2 =
  result.raw = [x, y]
proc x*(v: IVec2): int32 =
  result = v.raw[0]  
proc y*(v: IVec2): int32 =
  result = v.raw[1]  

proc vec2*(x, y: float32): Vec2 =
  result.raw = [x, y]
proc x*(v: Vec2): float32 =
  result = v.raw[0]  
proc y*(v: Vec2): float32 =
  result = v.raw[1]  

proc vec3*(x, y, z: float32): Vec3 =
  result.raw = [x, y, z]
proc x*(v: Vec3): float32 =
  result = v.raw[0]
proc y*(v: Vec3): float32 =
  result = v.raw[1]
proc z*(v: Vec3): float32 =
  result = v.raw[2]

proc `x=`*(v: var Vec3; f: float32) =
  v.raw[0] = f
proc `y=`*(v: var Vec3; f: float32) =
  v.raw[1] = f
proc `z=`*(v: var Vec3; f: float32) =
  v.raw[2] = f

proc glmc_vec3_add(a, b, dest: ptr float32) {.importc: "glmc_vec3_add", cdecl.}
proc `+`*(a, b: Vec3): Vec3 =
  glmc_vec3_add(addr(a.raw[0]), addr(b.raw[0]), addr(result.raw[0]))
proc `+=`*(lhs: var Vec3; rhs: Vec3) =
  lhs = lhs + rhs
proc glmc_vec3_div(a, b, dest: ptr float32) {.importc: "glmc_vec3_div", cdecl.}
proc `/`*(a, b: Vec3): Vec3 =
  glmc_vec3_div(addr(a.raw[0]), addr(b.raw[0]), addr(result.raw[0]))
proc glmc_vec3_sub(a, b, dest: ptr float32) {.importc: "glmc_vec3_sub", cdecl.}  
proc `-`*(a, b: Vec3): Vec3 =
  glmc_vec3_sub(addr(a.raw[0]), addr(b.raw[0]), addr(result.raw[0]))
proc glmc_vec3_scale(v: ptr float32; s: float32; dest: ptr float32) {.importc: "glmc_vec3_scale", cdecl.}
proc `*`*(v: Vec3; s: float32): Vec3 =
  glmc_vec3_scale(addr(v.raw[0]), s, addr(result.raw[0]))
proc `*`*(s: float32; v: Vec3): Vec3 =
  v * s
proc `[]`*(v: Vec3; idx: SomeUnsignedInt): float32 =
  v.raw[idx]
proc glmc_vec3_cross(a, b, dest: ptr float32) {.importc: "glmc_vec3_cross", cdecl.}
proc cross*(a, b: Vec3): Vec3 =
  glmc_vec3_cross(addr(a.raw[0]), addr(b.raw[0]), addr(result.raw[0]))
proc glmc_vec3_maxv(a, b, dest: ptr float32) {.importc: "glmc_vec3_maxv", cdecl.}
proc max*(a, b: Vec3): Vec3 =
  glmc_vec3_maxv(addr(a.raw[0]), addr(b.raw[0]), addr(result.raw[0]))
proc glmc_vec3_minv(a, b, dest: ptr float32) {.importc: "glmc_vec3_minv", cdecl.}
proc min*(a, b: Vec3): Vec3 =
  glmc_vec3_minv(addr(a.raw[0]), addr(b.raw[0]), addr(result.raw[0]))
proc glmc_vec3_normalize_to(v, dest: ptr float32) {.importc: "glmc_vec3_normalize_to", cdecl.}
proc normalize*(v: Vec3): Vec3 =
  glmc_vec3_normalize_to(addr(v.raw[0]), addr(result.raw[0]))
proc normalize*(va, vb, vc: Vec3): Vec3 =
  let
    ba = vb - va
    ca = vc - va
    baca = cross(ca, ba)

  result = normalize(baca)

proc xyz*(v: RawVec4): Vec3 =
  result = vec3(v[0], v[1], v[2])

proc xyz*(v: Vec4): Vec3 =
  result = v.raw.xyz


proc glmc_vec4(v3: ptr float32; last: float32; dest: ptr float32) {.importc: "glmc_vec4", cdecl.}
proc vec4*(v3: Vec3; last: float32): Vec4 =
  glmc_vec4(addr(v3.raw[0]), last, addr(result.raw[0]))

proc aabb*(xMin, yMin, zMin, xMax, yMax, zMax: float32): AABB =
  result[0].raw = [xMin, yMin, zMin]
  result[1].raw = [xMax, yMax, zMax]

proc xMin*(aabb: AABB): float32 =
  aabb[0][0]
proc yMin*(aabb: AABB): float32 =
  aabb[0][1]
proc zMin*(aabb: AABB): float32 =
  aabb[0][2]

proc xMax*(aabb: AABB): float32 =
  aabb[1][0]
proc yMax*(aabb: AABB): float32 =
  aabb[1][1]
proc zMax*(aabb: AABB): float32 =
  aabb[1][2]

proc addPoint*(aabb: var AABB; pt: Vec3) =
  aabb = [
    min(aabb[0], pt),
    max(aabb[1], pt)
  ]