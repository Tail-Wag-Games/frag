import std/math,
       sse2

type
  Mix4* = enum
    m4X
    m4Y
    m4Z
    m4W

    m4A
    m4B
    m4C
    m4D

  Scalarf* = object
    value: M128

  Matrix4x4f* = object
    xAxis*: Vector4f
    yAxis*: Vector4f
    zAxis*: Vector4f
    wAxis*: Vector4f

  Quatf* = M128

  Quatd* = object
    xy*: M128d
    zw*: M128d

  Vector4f* = M128

  Float2f* = object
    x*: float32
    y*: float32

  Float3f* = object
    x*: float32
    y*: float32
    z*: float32

  Float4f* = object
    x*: float32
    y*: float32
    z*: float32
    w*: float32

  Rectangle* = object
    xmin*, ymin*: float32
    xmax*, ymax*: float32

const
  OneDivTwoPi* = 1.591549430918953357688837633725143620e-01'f32
  TwoPi* = 6.283185307179586476925286766559005768'f32
  HalfPi* = 1.570796326794896619231321691639751442'f32
  PiDivOneEighty* = 0.01745329251994329576923690768489'f32
  Pi* = 3.141592653589793238462643383279502884'f32

template allTrue2Mask4f(inputMask, output) =
  result = (mm_movemask_ps(inputMask) and 0x3) == 0x3

template selectVector4f(mask, ifTrue, ifFalse): untyped =
  mm_or_ps(mm_andnot_ps(mask, ifFalse), mm_and_ps(ifTrue, mask))

when defined vcc:
  proc isMixXyzw*(arg: Mix4): bool {.codegendecl: "__declspec(safebuffers) __forceinline $# $#$#", inline.} =
    result = uint32(arg) <= uint32(m4W)
  
  proc isMixAbcd*(arg: Mix4): bool {.codegendecl: "__declspec(safebuffers) __forceinline $# $#$#", inline.} =
    result = uint32(arg) >= uint32(m4A)

  proc castScalar*(input: Scalarf): float32 {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    result = mm_cvtss_f32(input.value)

  proc setScalar*(xyzw: float32): Scalarf {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    result = Scalarf(value: mm_set_ps1(xyzw))

  proc divScalar*(lhs, rhs: Scalarf): Scalarf {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    result.value = mm_div_ss(lhs.value, rhs.value)

  proc maxScalar*(lhs, rhs: Scalarf): Scalarf {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    result = Scalarf(value: mm_max_ss(lhs.value, rhs.value))

  proc maxScalar*(lhs, rhs: float32): float32 {.codegendecl: "__declspec(safebuffers) __forceinline $# $#$#", inline.} =
    result = mm_cvtss_f32(mm_max_ss(mm_set_ps1(lhs), mm_set_ps1(rhs)))

  proc roundBankersScalar*(input: Scalarf): Scalarf {.codegendecl: "__declspec(safebuffers) __forceinline $# $#$#", inline.} =
    let
      signMask = mm_set_ps(-0.0'f32, -0.0'f32, -0.0'f32, -0.0'f32)
      sign = mm_and_ps(input.value, signMask)
      fractionalLimit = mm_set_ps1(8388608.0'f32)
      truncatingOffset = mm_or_ps(sign, fractionalLimit)
      integerPart = mm_sub_ss(mm_add_ss(input.value, truncatingOffset), truncatingOffset)
      absMask = mm_set_epi32(0x7FFFFFFF'u32, 0x7FFFFFFF'u32, 0x7FFFFFFF'u32, 0x7FFFFFFF'u32)
      absInput = mm_and_ps(input.value, mm_castsi128_ps(absMask))
      isInputLarge = mm_cmpge_ss(absInput, fractionalLimit)

    result = Scalarf(value: mm_or_ps(mm_and_ps(isInputLarge, input.value),
        mm_andnot_ps(isInputLarge, integerPart)))

  proc sinScalar*(angle: Scalarf): Scalarf {.codegendecl: "__declspec(safebuffers) __forceinline $# $#$#", inline.} =
    var quotient = mm_mul_ss(angle.value, mm_set_ps1(OneDivTwoPi))
    quotient = roundBankersScalar(Scalarf(value: quotient)).value
    quotient = mm_mul_ss(quotient, mm_set_ps1(TwoPi))
    var x = mm_sub_ss(angle.value, quotient)

    let 
      signMask = mm_set_ps(-0.0'f32, -0.0'f32, -0.0'f32, -0.0'f32)
      sign = mm_and_ps(x, signMask)
      reference = mm_or_ps(sign, mm_set_ps1(Pi))
      reflection = mm_sub_ss(reference, x)
      absMask = mm_set_epi32(0x7FFFFFFF'u32, 0x7FFFFFFF'u32, 0x7FFFFFFF'u32, 0x7FFFFFFF'u32)
      xAbs = mm_and_ps(x, mm_castsi128_ps(absMask))
      isLessEqualThanHalfPi = mm_cmple_ss(xAbs, mm_set_ps1(HalfPi))

    x = selectVector4f(isLessEqualThanHalfPi, x, reflection)

    let x2 = mm_cvtss_f32(mm_mul_ss(x, x))
    var resVal = (x2 * -2.3828544692960918e-8'f32) + 2.7521557770526783e-6'f32
    resVal = (resVal * x2) - 1.9840782426250314e-4'f32
    resVal = (resVal * x2) + 8.3333303183525942e-3'f32
    resVal = (resVal * x2) - 1.6666666601721269e-1'f32
    resVal = (resVal * x2) + 1.0'f32
    resVal = resVal * mm_cvtss_f32(x)
    result = setScalar(resVal)
  
  proc sinScalar(angle: float32): float32 {.codegendecl: "__declspec(safebuffers) __forceinline $# $#$#", inline.} =
    result = castScalar(sinScalar(setScalar(angle)))

  proc cosScalar*(angle: Scalarf): Scalarf {.codegendecl: "__declspec(safebuffers) __forceinline $# $#$#", inline.} =
    var quotient = mm_mul_ss(angle.value, mm_set_ps1(OneDivTwoPi))
    quotient = roundBankersScalar(Scalarf(value: quotient)).value
    quotient = mm_mul_ss(quotient, mm_set_ps1(TwoPi))
    var x = mm_sub_ss(angle.value, quotient)

    let 
      signMask = mm_set_ps(-0.0'f32, -0.0'f32, -0.0'f32, -0.0'f32)
      sign = mm_and_ps(x, signMask)
      reference = mm_or_ps(sign, mm_set_ps1(Pi))
      reflection = mm_sub_ss(reference, x)
      absMask = mm_set_epi32(0x7FFFFFFF'u32, 0x7FFFFFFF'u32, 0x7FFFFFFF'u32, 0x7FFFFFFF'u32)
      xAbs = mm_and_ps(x, mm_castsi128_ps(absMask))
      isLessEqualThanHalfPi = mm_cmple_ss(xAbs, mm_set_ps1(HalfPi))

    x = selectVector4f(isLessEqualThanHalfPi, x, reflection)

    let x2 = mm_cvtss_f32(mm_mul_ss(x, x))
    var resVal = (x2 * -2.6051615464872668e-7'f32) + 2.4760495088926859e-5'f32
    resVal = (resVal * x2) - 1.3888377661039897e-3'f32
    resVal = (resVal * x2) + 4.1666638865338612e-2'f32
    resVal = (resVal * x2) - 4.9999999508695869e-1'f32
    resVal = (resVal * x2) + 1.0'f32

    let 
      res = mm_set_ps1(resVal)
      cos = mm_or_ps(res, mm_andnot_ps(isLessEqualThanHalfPi, signMask))
    
    result.value = cos
  
  proc cosScalar(angle: float32): float32 {.codegendecl: "__declspec(safebuffers) __forceinline $# $#$#", inline.} =
    result = castScalar(cosScalar(setScalar(angle)))

  proc sinCosScalar*(angle: float32; outSin, outCos: var float32) {.codegendecl: "__declspec(safebuffers) __forceinline $# $#$#", inline.} =
    outSin = sinScalar(angle)
    outCos = cosScalar(angle)
  
  proc tanScalar*(angle: float32): float32 {.codegendecl: "__declspec(safebuffers) __forceinline $# $#$#", inline.} =
    let
      a = setScalar(angle)
      sin = sinScalar(a)
      cos = cosScalar(a)
    
    block outer:
      if castScalar(cos) == 0.0'f32:
        result = copySign(Inf, angle)
        break outer
    
      result = castScalar(divScalar(sin, cos))

  proc sqrtReciprocalScalar(input: Scalarf): Scalarf {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    let
      half = mm_set_ss(0.5'f32)
      inputHalf = mm_mul_ss(input.value, half)
      x0 = mm_rsqrt_ss(input.value)

    var x1 = mm_mul_ss(x0, x0)
    x1 = mm_sub_ss(half, mm_mul_ss(inputHalf, x1))
    x1 = mm_add_ss(mm_mul_ss(x0, x1), x0)

    var x2 = mm_mul_ss(x1, x1)
    x2 = mm_sub_ss(half, mm_mul_ss(inputHalf, x2))
    x2 = mm_add_ss(mm_mul_ss(x1, x2), x1)

    result = Scalarf(value: x2)

  proc sqrtReciprocalScalar(input: float32): float32 {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    result = castScalar(sqrtReciprocalScalar(setScalar(input)))

  proc getVectorX*(input: Vector4f): float32 {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    result = mm_cvtss_f32(input)

  proc getVectorY*(input: Vector4f): float32 {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    result = mm_cvtss_f32(mm_shuffle_ps(input, input, MM_SHUFFLE(1, 1, 1, 1)))

  proc getVectorZ*(input: Vector4f): float32 {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    result = mm_cvtss_f32(mm_shuffle_ps(input, input, MM_SHUFFLE(2, 2, 2, 2)))

  proc setVector*(x, y, z, w: float32): Vector4f {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    result = mm_set_ps(w, z, y, x)

  proc setVector*(x, y, z: float32): Vector4f {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    result = mm_set_ps(0.0'f32, z, y, x)

  proc setVector*(xyzw: float32): Vector4f {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    result = mm_set_ps1(xyzw)

  proc zeroVector*(): Vector4f {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    mm_setzero_ps()
  
  proc mixVector[comp0: static  Mix4, comp1: static Mix4, comp2: static Mix4, comp3: static Mix4](a, b: Vector4f): Vector4f {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    if isMixXyzw(comp0) and isMixXyzw(comp1) and isMixXyzw(comp2) and isMixXyzw(comp3):
      result = mm_shuffle_ps(a, a, MM_SHUFFLE(int32(comp3) mod 4, int32(comp2) mod 4, int32(comp1) mod 4, int32(comp0) mod 4))

    if isMixAbcd(comp0) and isMixAbcd(comp1) and isMixAbcd(comp2) and isMixAbcd(comp3):
      result = mm_shuffle_ps(b, b, MM_SHUFFLE(int32(comp3) mod 4, int32(comp2) mod 4, int32(comp1) mod 4, int32(comp0) mod 4))


  proc dupXVector*(input: Vector4f): Vector4f  {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    mixVector[m4X, m4X, m4X, m4X](input, input)

  proc absVector*(input: Vector4f): Vector4f {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    let absMask = mm_set_epi32(0x7FFFFFFF'u32, 0x7FFFFFFF'u32, 0x7FFFFFFF'u32, 0x7FFFFFFF'u32)
    result = mm_and_ps(input, mm_castsi128_ps(absMask))

  proc subVector*(lhs, rhs: Vector4f): Vector4f {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    result = mm_sub_ps(lhs, rhs)

  proc mulVector(lhs: Vector4f; rhs: Scalarf): Vector4f {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    result = mm_mul_ps(lhs, mm_shuffle_ps(rhs.value, rhs.value, MM_SHUFFLE(0, 0,
        0, 0)))

  proc mulVector(lhs, rhs: Vector4f): Vector4f {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    result = mm_mul_ps(lhs, rhs)

  proc allLessEqualVector3(lhs, rhs: Vector4f): bool {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    let mask = mm_cmple_ps(lhs, rhs)

    allTrue2Mask4f(mask, result)

  proc allNearEqualVector3(lhs, rhs: Vector4f;
      threshold: float32 = 00001'f32): bool {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    result = allLessEqualVector3(absVector(subVector(lhs, rhs)), setVector(threshold))

  proc storeVector3*(output: ptr Float3f;
      input: Vector4f) {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    output.x = getVectorX(input)
    output.y = getVectorY(input)
    output.z = getVectorZ(input)

  proc crossVector3*(lhs, rhs: Vector4f): Vector4f {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    let
      lhsYzx = mm_shuffle_ps(lhs, lhs, MM_SHUFFLE(3, 0, 2, 1))
      rhsYzx = mm_shuffle_ps(rhs, rhs, MM_SHUFFLE(3, 0, 2, 1))
      tmpZxy = mm_sub_ps(mm_mul_ps(lhs, rhsYzx), mm_mul_ps(lhsYzx, rhs))

    result = mm_shuffle_ps(tmpZxy, tmpZxy, MM_SHUFFLE(3, 0, 2, 1))

  proc dotVector3*(lhs, rhs: Vector4f): Scalarf {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    let
      x2y2z2w2 = mm_mul_ps(lhs, rhs)
      y2000 = mm_shuffle_ps(x2y2z2w2, x2y2z2w2, MM_SHUFFLE(0, 0, 0, 1))
      x2y2000 = mm_add_ss(x2y2z2w2, y2000)
      z2000 = mm_shuffle_ps(x2y2z2w2, x2y2z2w2, MM_SHUFFLE(0, 0, 0, 2))

    result.value = mm_add_ss(x2y2000, z2000)

  proc lengthSquaredVector3(input: Vector4f): Scalarf {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    result = dotVector3(input, input)

  proc normVector3*(input: Vector4f): Vector4f {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    let lenSq = lengthSquaredVector3(input)
    result = mulVector(input, sqrtReciprocalScalar(lenSq))

  proc quatToVector(input: Quatf): Vector4f {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    result = input

  proc getQuatW*[T](input: Quatf): T {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    when T is Scalarf:
      result = Scalarf(value: mm_shuffle_ps(input, input, MM_SHUFFLE(3, 3, 3, 3)))
    else:
      result = mm_cvtss_f32(mm_shuffle_ps(input, input, MM_SHUFFLE(3, 3, 3, 3)))

  proc getQuatAxis*(input: Quatf): Vector4f {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    let
      epsilon = 1.0e-8'f32
      epsilonSquared = epsilon * epsilon
      scaleSq = maxScalar(1.0'f32 - getQuatW[float32](input) * getQuatW[
          float32](input), 0.0'f32)

    result = if scaleSq >= epsilonSquared: mulVector(quatToVector(input),
        setVector(sqrtReciprocalScalar(scaleSq))) else: setVector(1.0'f32,
        0.0'f32, 0.0'f32)

  proc storeQuat*(output: ptr Float4f; input: Quatf) {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    mm_storeu_ps(output.x.addr, input)

  proc setQuat*(x, y, z, w: float32): Quatf {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    result = mm_set_ps(w, z, y, x)

  proc identityQuat*(): Quatf {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    result = setQuat(0.0, 0.0, 0.0, 1.0)

  proc quatFromMatrix*(xAxis, yAxis, zAxis: Vector4f): Quatf {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    let zero = zeroVector()
    if allNearEqualVector3(xAxis, zero) or allNearEqualVector3(yAxis, zero) or
        allNearEqualVector3(zAxis, zero):
      result = identityQuat()

  proc setMatrix*(xAxis, yAxis, zAxis, wAxis: Vector4f): Matrix4x4f {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    result.xAxis = xAxis
    result.yAxis = yAxis
    result.zAxis = zAxis
    result.wAxis = wAxis

  proc perspective*(width, height, zNear, zFar: float32; oglNdc: bool): Matrix4x4f {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    let 
      d = zFar - zNear
      aa = if oglNdc: (zFar + zNear) / d else: zFar / d
      bb = if oglNdc: (2.0'f32 * zNear * zFar) / d else: zNear * aa
      col0 = setVector(width, 0.0'f32, 0.0'f32, 0.0'f32)
      col1 = setVector(0.0'f32, height, 0.0'f32, 0.0'f32)
      col2 = setVector(0.0'f32, 0.0'f32, -aa, -bb)
      col3 = setVector(0.0'f32, 0.0'f32, -1.0'f32, 0.0'f32)

    result = setMatrix(col0, col1, col2, col3)

  proc perspectiveFov*(fovAngleY, aspectRatio, nearZ, farZ: float32; oglNdc: bool): Matrix4x4f {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    var sinFov, cosFov: float32
    sinCosScalar(0.5'f32 * fovAngleY, sinFov, cosFov)

    let
      height = cosFov / sinFov
      width = height / aspectRatio
    result = perspective(width, height, nearZ, farZ, oglNdc)

  proc mulMatrix*(lhs, rhs: Matrix4x4f): Matrix4x4f {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    let tmp = mulVector(dupXVector(lhs.xAxis), rhs.xAxis)

else:
  proc setQuat(x, y, z, w: float32): Quatf {.codegendecl: "__attribute__((always_inline)) inline $# $#$#", inline.} =
    result = mm_set_ps(w, z, y, x)

  proc identityQuat*(): Quatf {.codegendecl: "__attribute__((always_inline)) inline $# $#$#", inline.} =
    result = setQuat(0.0, 0.0, 0.0, 1.0)

const
  Float3fZero* = Float3f(x: 0.0'f32, y: 0.0'f32, z: 0.0'f32)
  Float3fUnitX* = Float3f(x: 1.0'f32, y: 0.0'f32, z: 0.0'f32)
  Float3fUnitY* = Float3f(x: 0.0'f32, y: 1.0'f32, z: 0.0'f32)
  Float3fUnitZ* = Float3f(x: 0.0'f32, y: 0.0'f32, z: 1.0'f32)

proc float2f*(x, y: float32): Float2f =
  result.x = x
  result.y = y

proc float3f*(x, y, z: float32): Float3f =
  result.x = x
  result.y = y
  result.z = z

proc rectangle(xmin, ymin, xmax, ymax: float32): Rectangle =
  result.xmin = xmin
  result.ymin = ymin
  result.xmax = xmax
  result.ymax = ymax

proc rectwh*(x, y, w, h: float32): Rectangle =
  result = rectangle(x, y, x + w, y + h)

proc toRad*(deg: float32): float32 {.codegendecl: "__declspec(safebuffers) __forceinline $# $#$#", inline.} =
  result = deg * PiDivOneEighty