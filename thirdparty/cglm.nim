from math import PI, almostEqual

{.passC: "-D CGLM_STATIC".}


when defined(windows):
  {.passC: "-D CGLM_FORCE_DEPTH_ZERO_TO_ONE".}
  {.passC: "-D CGLM_FORCE_LEFT_HANDED".}

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
  RawVec2i = array[2, int32]
  Vec2i* = object
    raw: RawVec2i
  RawVec2f = array[2, float32]
  Vec2f* = object
    raw: RawVec2f

  RawVec3i = array[3, int32]
  Vec3i* = object
    raw: RawVec3i
  RawVec3f = array[3, float32]
  Vec3f* = object
    raw: RawVec3f
  Vec3*[T] = object
    raw: array[3, T]
  RawVec4f = array[4, float32]
  Vec4f* = object
    raw {.align: 16.}: RawVec4f
  RawVersor = RawVec4f
  Versor* = object
    raw {.align: 16.}: RawVersor
  RawMat2 = array[2, RawVec2f]
  Mat2* = object
    raw  {.align: 16.}: RawMat2
  RawMat4 = array[4, RawVec4f]
  Mat4* = object
    raw*  {.align: 16.}: RawMat4

  AABBf* = array[2, Vec3f]
  AABBi* = array[2, Vec3i]
  AABB*[T] = array[2, Vec3[T]]

  Frustum* = array[8, Vec4f]
  Ray* = object
    origin*: Vec3f
    direction*: Vec3f

const
  Green* = [0'u8, 255'u8, 0'u8, 255'u8]
  Red* = [255'u8, 0'u8, 0'u8, 255'u8]

proc glmc_mat4_identity(mat: ptr float32) {.importc: "glmc_mat4_identity", cdecl.}
proc identity*(): Mat4 =
  glmc_mat4_identity(addr(result.raw[0][0]))
proc mat4*(fc1, fc2, fc3, fc4: array[4, float32]): Mat4 =
  result.raw = [
    fc1, fc2, fc3, fc4
  ]
proc glmc_mat4_inv(mat, dest: ptr float32) {.importc: "glmc_mat4_inv", cdecl.}
proc inverse*(m: Mat4): Mat4 =
  glmc_mat4_inv(addr(m.raw[0][0]), addr(result.raw[0][0]))
proc glmc_rotate_make(m: ptr float32; angle: float32; axis: ptr float32) {.importc: "glmc_rotate_make", cdecl.}
proc rotate*(axis: Vec3f; angle: float32): Mat4 =
  glmc_rotate_make(addr(result.raw[0][0]), angle, addr(axis.raw[0]))
proc glmc_scale_make(m, v: ptr float32) {.importc: "glmc_scale_make", cdecl.}
proc scale*(v: Vec3f): Mat4 =
  glmc_scale_make(addr(result.raw[0][0]), addr(v.raw[0]))
proc glmc_translate_make(m, v: ptr float32) {.importc: "glmc_translate_make", cdecl.}
proc translate*(v: Vec3f): Mat4 =
  glmc_translate_make(addr(result.raw[0][0]), addr(v.raw[0]))
proc glmc_translate_to(m, v, dest: ptr float32) {.importc: "glmc_translate_to", cdecl.}
proc translateTo*(m: Mat4; v: Vec3f): Mat4 =
  glmc_translate_to(addr(m.raw[0][0]), addr(v.raw[0]), addr(result.raw[0][0]))
proc glmc_mat4_transpose_to*(m, dest: ptr float32) {.importc: "glmc_mat4_transpose_to", cdecl.}
proc transpose*(m: Mat4): Mat4 =
  glmc_mat4_transpose_to(addr(m.raw[0][0]), addr(result.raw[0][0]))
proc glmc_mat4_quat(m, dest: ptr float32) {.importc: "glmc_mat4_quat", cdecl.}
proc mat4Quat*(m: Mat4): Versor =
  glmc_mat4_quat(addr(m.raw[0][0]), addr(result.raw[0]))
proc glmc_mat4_mul(m1, m2, dest: ptr float32) {.importc: "glmc_mat4_mul", cdecl.}
proc `*`*(m1, m2: Mat4): Mat4 = 
  glmc_mat4_mul(addr(m1.raw[0][0]), addr(m2.raw[0][0]), addr(result.raw[0][0]))
proc glmc_mat4_mulv(m, v, dest: ptr float32) {.importc: "glmc_mat4_mulv", cdecl.}
proc `*`*(m: Mat4; v: Vec4f): Vec4f =
  glmc_mat4_mulv(addr(m.raw[0][0]), addr(v.raw[0]), addr(result.raw[0]))
proc glmc_mat4_mulv3(m, v: ptr float32; last: float32; dest: ptr float32) {.importc: "glmc_mat4_mulv3", cdecl.}
proc `*`*(m: Mat4; v: Vec3f; last: float32 = 0.0'f32): Vec3f =
  glmc_mat4_mulv3(addr(m.raw[0][0]), addr(v.raw[0]), last, addr(result.raw[0]))
proc `*`*(v: Vec3f; m: Mat4; last: float32 = 0.0'f32): Vec3f =
  glmc_mat4_mulv3(addr(m.raw[0][0]), addr(v.raw[0]), last, addr(result.raw[0]))

proc glmc_lookat(eye, center, up: ptr float32; dest: ptr float32) {.importc: "glmc_lookat", cdecl.}
proc lookAt*(eye, center, up: Vec3f): Mat4 = 
  glmc_lookat(addr(eye.raw[0]), addr(center.raw[0]), addr(up.raw[0]), addr(result.raw[0][0]))
proc glmc_perspective(fovy, aspect, nearZ, farZ: float32; dest: ptr float32) {.importc: "glmc_perspective", cdecl.}
proc perspective*(fovy, aspect, nearZ, farZ: float32): Mat4 =
  glmc_perspective(fovy, aspect, nearZ, farZ, addr(result.raw[0][0]))

proc glmc_euler_angles(m: ptr float32; result: ptr float32) {.importc: "glmc_euler_angles", cdecl.}
proc eulerAngles*(m: Mat4): Vec3f =
  glmc_euler_angles(addr(m.raw[0][0]), addr(result.raw[0]))
proc glmc_euler(angles: ptr float32; dest: ptr float32) {.importc: "glmc_euler", cdecl.}
proc euler*(angles: Vec3f): Mat4 =
  glmc_euler(addr(angles.raw[0]), addr(result.raw[0][0]))

proc `[]`*(m: Mat4; idx: SomeUnsignedInt): RawVec4f =
  result= m.raw[idx]
proc `[]`*(m: var Mat4; idx: SomeUnsignedInt): var RawVec4f =
  result= m.raw[idx]

proc `[]=`*(v1: var Mat4; idx: SomeUnsignedInt; v2: RawVec4f) =
  v1.raw[idx] = v2

proc glmc_plane_normalize(plane: ptr float32; dest: ptr float32) {.importc: "glmc_plane_normalize", cdecl.}
proc normalize*(plane: Vec4f): Vec4f =
  glmc_plane_normalize(addr(plane.raw[0]), addr(result.raw[0]))

proc glmc_quat_look(eye, ori, dest: ptr float32) {.importc: "glmc_quat_look".}
proc quatLookAt*(eye: Vec3f; ori: Versor): Mat4 =
  glmc_quat_look(addr(eye.raw[0]), addr(ori.raw[0]), addr(result.raw[0][0]))
proc glmc_quat_rotatev(src: ptr float32; to, dest: ptr float32) {.importc: "glmc_quat_rotatev", cdecl.}
proc quatRotateV*(src: Versor; to: Vec3f): Vec3f =
  glmc_quat_rotatev(addr(src.raw[0]), addr(to.raw[0]), addr(result.raw[0])) 
proc glmc_quat_mul(p, q, dest: ptr float32) {.importc: "glmc_quat_mul", cdecl.}
proc `*`*(p, q: Versor): Versor =
  glmc_quat_mul(addr(p.raw[0]), addr(q.raw[0]), addr(result.raw[0]))
proc glmc_quat_identity(dest: ptr float32) {.importc: "glmc_quat_identity", cdecl.}
proc identityQuat*(): Versor = 
  glmc_quat_identity(addr(result.raw[0]))
proc glmc_quat_init(q: ptr float32; x, y, z, w: float32) {.importc: "glmc_quat_init".}
proc quat*(x, y, z, w: float32): Versor =
  glmc_quat_init(addr(result.raw[0]), x, y, z, w)
proc glmc_quat_mat4(q: ptr float32; dest: ptr float32) {.importc: "glmc_quat_mat4", cdecl.}
proc mat4*(q: Versor): Mat4 =
  glmc_quat_mat4(addr(q.raw[0]), addr(result.raw[0][0]))
proc glmc_quat_for(dir, up, dest: ptr float32) {.importc: "glmc_quat_for", cdecl.}
proc quatFor*(dir, up: Vec3f): Versor =
  glmc_quat_for(addr(dir.raw[0]), addr(up.raw[0]), addr(result.raw[0]))
proc glmc_quat_forp(frm, to, up, dest: ptr float32) {.importc: "glmc_quat_forp", cdecl.}
proc quatForp*(frm, to, up: Vec3f): Versor =
  glmc_quat_forp(addr(frm.raw[0]), addr(to.raw[0]), addr(up.raw[0]), addr(result.raw[0]))
proc glmc_quatv(dest: ptr float32; angle: float32; axis: ptr float32) {.importc: "glmc_quatv", cdecl.}
proc quat*(angle: float32; axis: Vec3f): Versor =
  glmc_quatv(addr(result.raw[0]), angle, addr(axis.raw[0]))
proc glmc_quat_inv(quat, dest: ptr float32) {.importc: "glmc_quat_inv", cdecl.}
proc inverse*(v: Versor): Versor =
  glmc_quat_inv(addr(v.raw[0]), addr(result.raw[0]))
proc glmc_quat_conjugate(q, dest: ptr float32) {.importc: "glmc_quat_conjugate", cdecl.}
proc conjugate*(v: Versor): Versor =
  glmc_quat_conjugate(addr(v.raw[0]), addr(result.raw[0]))
proc glmc_quat_normalize_to(quat, dest: ptr float32 ) {.importc: "glmc_quat_normalize_to", cdecl.}
proc normalize*(v: Versor): Versor =
  glmc_quat_normalize_to(addr(v.raw[0]), addr(result.raw[0]))

proc x*(v: Versor): float32 =
  v.raw[0]
proc x*(v: var Versor): var float32 =
  v.raw[0]
proc `x=`*(v: var Versor; f: float32) =
  v.raw[0] = f
proc y*(v: Versor): float32 =
  v.raw[1]
proc y*(v: var Versor): var float32 =
  v.raw[1]
proc `y=`*(v: var Versor; f: float32) =
  v.raw[1] = f
proc z*(v: Versor): float32 =
  v.raw[2]
proc z*(v: var Versor): var float32 =
  v.raw[2]
proc w*(v: Versor): float32 =
  v.raw[3]
proc w*(v: var Versor): var float32 =
  v.raw[3]

proc eq*(a, b: float32): bool =
  result = almostEqual(a, b)
proc toRad*(deg: float32): float32 =
  result = deg * PI / 180.0f;

proc vec2*(x, y: int32): Vec2i =
  result.raw = [x, y]
proc x*(v: Vec2i): int32 =
  result = v.raw[0]  
proc y*(v: Vec2i): int32 =
  result = v.raw[1]  

proc vec2*(x, y: float32): Vec2f =
  result.raw = [x, y]
proc x*(v: Vec2f): float32 =
  result = v.raw[0]  
proc y*(v: Vec2f): float32 =
  result = v.raw[1]

proc `x=`*(v: var Vec2f; f: float32) =
  v.raw[0] = f
proc `y=`*(v: var Vec2f; f: float32) =
  v.raw[1] = f

proc glmc_vec2_divs(a: ptr float32; s: float32; dest: ptr float32) {.importc: "glmc_vec2_divs", cdecl.}
proc `/`*(a: Vec2f; s: float32): Vec2f =
  glmc_vec2_divs(addr(a.raw[0]), s, addr(result.raw[0]))

proc vec3*(x, y, z: float32): Vec3f =
  result.raw = [x, y, z]
proc vec3*(xyz: float32): Vec3f =
  result = vec3(xyz, xyz, xyz)

proc x*(v: Vec3f): float32 =
  result = v.raw[0]
proc y*(v: Vec3f): float32 =
  result = v.raw[1]
proc z*(v: Vec3f): float32 =
  result = v.raw[2]

proc `x=`*(v: var Vec3f; f: float32) =
  v.raw[0] = f
proc `y=`*(v: var Vec3f; f: float32) =
  v.raw[1] = f
proc `z=`*(v: var Vec3f; f: float32) =
  v.raw[2] = f

proc glmc_vec3_copy(a, dest: ptr float32) {.importc: "glmc_vec3_copy", cdecl.}
proc copy*(a, dest: Vec3f) =
  glmc_vec3_copy(addr(a.raw[0]), addr(dest.raw[0]))
proc glmc_vec3_add(a, b, dest: ptr float32) {.importc: "glmc_vec3_add", cdecl.}
proc `+`*(a, b: Vec3f): Vec3f =
  glmc_vec3_add(addr(a.raw[0]), addr(b.raw[0]), addr(result.raw[0]))
proc `+=`*(lhs: var Vec3f; rhs: Vec3f) =
  lhs = lhs + rhs
proc glmc_vec3_div(a, b, dest: ptr float32) {.importc: "glmc_vec3_div", cdecl.}
proc `/`*(a, b: Vec3f): Vec3f =
  glmc_vec3_div(addr(a.raw[0]), addr(b.raw[0]), addr(result.raw[0]))
proc glmc_vec3_divs(a: ptr float32; s: float32; dest: ptr float32) {.importc: "glmc_vec3_divs", cdecl.}
proc `/`*(a: Vec3f; s: float32): Vec3f =
  glmc_vec3_divs(addr(a.raw[0]), s, addr(result.raw[0]))
proc glmc_vec3_sub(a, b, dest: ptr float32) {.importc: "glmc_vec3_sub", cdecl.}  
proc `-`*(a, b: Vec3f): Vec3f =
  glmc_vec3_sub(addr(a.raw[0]), addr(b.raw[0]), addr(result.raw[0]))
proc glmc_vec3_scale(v: ptr float32; s: float32; dest: ptr float32) {.importc: "glmc_vec3_scale", cdecl.}
proc `*`*(v: Vec3f; s: float32): Vec3f =
  glmc_vec3_scale(addr(v.raw[0]), s, addr(result.raw[0]))
proc `*`*(s: float32; v: Vec3f): Vec3f =
  v * s
proc `[]`*(v: Vec3f; idx: SomeUnsignedInt): float32 =
  v.raw[idx]
proc glmc_vec3_cross(a, b, dest: ptr float32) {.importc: "glmc_vec3_cross", cdecl.}
proc cross*(a, b: Vec3f): Vec3f =
  glmc_vec3_cross(addr(a.raw[0]), addr(b.raw[0]), addr(result.raw[0]))
proc glmc_vec3_maxv(a, b, dest: ptr float32) {.importc: "glmc_vec3_maxv", cdecl.}
proc max*(a, b: Vec3f): Vec3f =
  glmc_vec3_maxv(addr(a.raw[0]), addr(b.raw[0]), addr(result.raw[0]))
proc glmc_vec3_minv(a, b, dest: ptr float32) {.importc: "glmc_vec3_minv", cdecl.}
proc min*(a, b: Vec3f): Vec3f =
  glmc_vec3_minv(addr(a.raw[0]), addr(b.raw[0]), addr(result.raw[0]))
proc glmc_vec3_dot(a, b: ptr float32): float32 {.importc: "glmc_vec3_dot".}
proc dot*(a, b: Vec3f): float32 =
  result = glmc_vec3_dot(addr(a.raw[0]), addr(b.raw[0]))
proc glmc_vec3_normalize(v: ptr float32) {.importc: "glmc_vec3_normalize", cdecl.}
proc normalize*(v: Vec3f) =
  glmc_vec3_normalize(addr(v.raw[0]))
proc glmc_vec3_normalize_to(v, dest: ptr float32) {.importc: "glmc_vec3_normalize_to", cdecl.}
proc normalizeTo*(v: Vec3f): Vec3f =
  glmc_vec3_normalize_to(addr(v.raw[0]), addr(result.raw[0]))
proc normalize*(va, vb, vc: Vec3f): Vec3f =
  let
    ba = vb - va
    ca = vc - va
    baca = cross(ca, ba)

  result = normalizeTo(baca)
proc lengthSquared*(v: Vec3f): float32 =
  result = (v.x * v.x) + (v.y * v.y) + (v.z * v.z)

proc xyz*(v: RawVec4f): Vec3f =
  result = vec3(v[0], v[1], v[2])

proc xyz*(v: Vec4f): Vec3f =
  result = v.raw.xyz

proc x*(v: Vec4f): float32 =
  result = v.raw[0]
proc y*(v: Vec4f): float32 =
  result = v.raw[1]
proc z*(v: Vec4f): float32 =
  result = v.raw[2]
proc w*(v: Vec4f): float32 =
  result = v.raw[3]

proc `x=`*(v: var Vec4f; f: float32) =
  v.raw[0] = f
proc `y=`*(v: var Vec4f; f: float32) =
  v.raw[1] = f
proc `z=`*(v: var Vec4f; f: float32) =
  v.raw[2] = f
proc `w=`*(v: var Vec4f; f: float32) =
  v.raw[3] = f

proc glmc_vec4(v3: ptr float32; last: float32; dest: ptr float32) {.importc: "glmc_vec4", cdecl.}
proc vec4*(v3: Vec3f; last: float32): Vec4f =
  glmc_vec4(addr(v3.raw[0]), last, addr(result.raw[0]))
proc glmc_vec4_normalize_to(v, dest: ptr float32) {.importc: "glmc_vec4_normalize_to", cdecl.}
proc normalizeTo*(v: Vec4f): Vec4f =
  glmc_vec4_normalize_to(addr(v.raw[0]), addr(result.raw[0]))
proc glmc_vec4_scale(v: ptr float32; s: float32; dest: ptr float32) {.importc: "glmc_vec4_scale", cdecl.}
proc `*`*(v: Vec4f; s: float32): Vec4f =
  glmc_vec4_scale(addr(v.raw[0]), s, addr(result.raw[0]))
proc `*`*(v: RawVec4f; s: float32): RawVec4f =
  glmc_vec4_scale(addr(v[0]), s, addr(result[0]))
proc `*`*(s: float32; v: RawVec4f): RawVec4f =
  v * s
proc `*`*(s: float32; v: Vec4f): Vec4f =
  v * s

proc aabb*(xMin, yMin, zMin, xMax, yMax, zMax: float32): AABBf =
  result[0].raw = [xMin, yMin, zMin]
  result[1].raw = [xMax, yMax, zMax]

proc aabb*(min, max: Vec3f): AABBf =
  result[0] = min
  result[1] = max

proc `==`*(a, b: AABBf): bool =
  result = a == b

const emptyAABB* = aabb(float32.high, float32.high, float32.high, float32.high, float32.high, float32.high)

proc min*(aabb: AABBf): Vec3f =
  result = aabb[0]
proc max*(aabb: AABBf): Vec3f =
  result = aabb[1]

proc xMin*(aabb: AABBf): float32 =
  aabb[0][0]
proc yMin*(aabb: AABBf): float32 =
  aabb[0][1]
proc zMin*(aabb: AABBf): float32 =
  aabb[0][2]

proc xMax*(aabb: AABBf): float32 =
  aabb[1][0]
proc yMax*(aabb: AABBf): float32 =
  aabb[1][1]
proc zMax*(aabb: AABBf): float32 =
  aabb[1][2]

proc width*(aabb: AABBf): float32 =
  result = aabb.xMax - aabb.xMin

proc addPoint*(aabb: var AABBf; pt: Vec3f) =
  aabb = [
    min(aabb[0], pt),
    max(aabb[1], pt)
  ]

proc intersects*(aabb: AABBf; ray: Ray; distance: var float32): bool =
  block outer:
    var 
      d = 0.0'f32
      maxVal = float32.high

    normalize(ray.direction)

    if abs(ray.direction.x) < 0.0000001'f32:
      if ray.origin.x < aabb.xMin or ray.origin.y > aabb.xMax:
        distance = 0.0'f32
        result = false
        break outer
    else:
      let inv = 1.0'f32 / ray.origin.x
      
      var
        min = (aabb.xMin - ray.origin.x) * inv
        max = (aabb.xMax - ray.origin.x) * inv
      
      if min > max:
        var tmp = min
        min = max
        max = tmp
      
      d = max(min, d)
      maxVal = min(max, maxVal)

      if d > maxVal:
        distance = 0.0'f32
        result = false
        break outer
    
    if abs(ray.direction.y) < 0.0000001'f32:
      if ray.origin.y < aabb.yMin or ray.origin.y > aabb.yMax:
        distance = 0.0'f32
        result = false
        break outer
    else:
      let inv = 1.0'f32 / ray.direction.y

      var
        min = (aabb.yMin - ray.origin.y) * inv
        max = (aabb.yMax - ray.origin.y) * inv
      
      if min > max:
        var tmp = min
        min = max
        max = tmp

      d = max(min, d)
      maxVal = min(max, maxVal)

      if d > maxVal:
        distance = 0.0'f32
        result = false
        break outer
    
    if abs(ray.direction.z) < 0.0000001'f32:
      if ray.origin.z < aabb.zMin or ray.origin.z > aabb.zMax:
        distance = 0.0'f32
        result = false
        break outer
    else:
      let inv = 1.0'f32 / ray.direction.z

      var
        min = (aabb.zMin - ray.origin.z) * inv
        max = (aabb.zMax - ray.origin.z) * inv
      
      if min > max:
        var tmp = min
        min = max
        max = tmp

      d = max(min, d)
      maxVal = min(max, maxVal)

      if d > maxVal:
        distance = 0.0'f32
        result = false
        break outer
    
    distance = d
  
  result = true
