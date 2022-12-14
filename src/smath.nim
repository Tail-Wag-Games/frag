import std/math,
       sse2

type
  Mix4* = enum
    m4X = 0
    m4Y = 1
    m4Z = 2
    m4W = 3

    m4A = 4
    m4B = 5
    m4C = 6
    m4D = 7

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

  Float4x4f* = object
    m* {.align: 16.}: array[4, array[4, float32]]

  Rectangle* = object
    xMin*, yMin*: float32
    xMax*, yMax*: float32

  AABB* = object
    xMin*, yMin*, zMin*: float32
    xMax*, yMax*, zMax*: float32

  Color* = object
    r*: uint8
    g*: uint8
    b*: uint8
    a*: uint8

const
  OneDivTwoPi* = 1.591549430918953357688837633725143620e-01'f32
  TwoPi* = 6.283185307179586476925286766559005768'f32
  HalfPi* = 1.570796326794896619231321691639751442'f32
  PiDivOneEighty* = 0.01745329251994329576923690768489'f32
  Pi* = 3.141592653589793238462643383279502884'f32

  Red* = Color(r: 255, b: 0, g: 0, a: 255)
  Green* = Color(r: 0, b: 0, g: 255, a: 255)


template allTrue2Mask4f(inputMask, output): untyped =
  (mm_movemask_ps(inputMask) and 0x3) == 0x3

template selectVector4f(mask, ifTrue, ifFalse): untyped =
  mm_or_ps(mm_andnot_ps(mask, ifFalse), mm_and_ps(ifTrue, mask))

template mulvAddVector(v0, v1, v2): untyped =
  mm_add_ps(mm_mul_ps(v0, v1), v2)

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

  proc absScalar*(input: float32): float32 {.codegendecl: "__declspec(safebuffers) __forceinline $# $#$#", inline.} =
    let absMask = mm_set_epi32(0x7FFFFFFF'u32, 0x7FFFFFFF'u32, 0x7FFFFFFF'u32, 0x7FFFFFFF'u32)
    result = mm_cvtss_f32(mm_and_ps(mm_set_ps1(input), mm_castsi128_ps(abs_mask)))

  proc ceilScalar*(input: Scalarf): Scalarf {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    let
      absMask = mm_set_epi32(0x7FFFFFFF'u32, 0x7FFFFFFF'u32, 0x7FFFFFFF'u32, 0x7FFFFFFF'u32)
      fractionalLimit = mm_set_ps1(8388608.0'f32)

      absInput = mm_and_ps(input.value, mm_castsi128_ps(absMask))
      isInputLarge = mm_cmpge_ss(absInput, fractionalLimit)

      isNan = mm_cmpneq_ss(input.value, input.value)

      useOriginalInput = mm_or_ps(isInputLarge, isNan)

    var integerPart = mm_cvtepi32_ps(mm_cvtps_epi32(input.value))

    let
      isPositive = mm_cmplt_ss(integerPart, input.value)

      bias = mm_cvtepi32_ps(mm_castps_si128(isPositive))

    integerPart = mm_sub_ss(integerPart, bias)

    result = Scalarf(value: mm_or_ps(mm_and_ps(useOriginalInput, input.value),
        mm_andnot_ps(useOriginalInput, integerPart)))

  proc reciprocalScalar*(input: Scalarf): Scalarf {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    result.value = mm_div_ss(mm_set_ps1(1.0'f32), input.value)

  proc reciprocalScalar*(input: float32): float32 {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    result = castScalar(reciprocalScalar(setScalar(input)))

  proc ceilScalar*(input: float32): float32 {.codegendecl: "__declspec(safebuffers) __forceinline $# $#$#", inline.} =
    result = castScalar(ceilScalar(setScalar(input)))

  proc roundBankersScalar*(input: Scalarf): Scalarf {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
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

  proc sinCosScalar*(angle: float32; outSin,
      outCos: ptr float32) {.codegendecl: "__declspec(safebuffers) __forceinline $# $#$#", inline.} =
    outSin[] = sinScalar(angle)
    outCos[] = cosScalar(angle)

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
  
  proc nearEqualScalar*(lhs, rhs, threshold: float32): bool {.codegendecl: "__declspec(safebuffers) __forceinline $# $#$#", inline.} =
    result = absScalar(lhs - rhs) <= threshold

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

  proc setVector*(f: Float3f): Vector4f {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    result = mm_set_ps(0.0'f32, f.z, f.y, f.x)

  proc setVector*(xyzw: float32): Vector4f {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    result = mm_set_ps1(xyzw)

  proc zeroVector*(): Vector4f {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    mm_setzero_ps()

  proc mixVector[comp0: static Mix4; comp1: static Mix4; comp2: static Mix4;
      comp3: static Mix4](a,
      b: Vector4f): Vector4f {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    if isMixXyzw(comp0) and isMixXyzw(comp1) and isMixXyzw(comp2) and isMixXyzw(comp3):
      result = mm_shuffle_ps(a, a, MM_SHUFFLE(int32(comp3) mod 4, int32(
          comp2) mod 4, int32(comp1) mod 4, int32(comp0) mod 4))

    if isMixAbcd(comp0) and isMixAbcd(comp1) and isMixAbcd(comp2) and isMixAbcd(comp3):
      result = mm_shuffle_ps(b, b, MM_SHUFFLE(int32(comp3) mod 4, int32(
          comp2) mod 4, int32(comp1) mod 4, int32(comp0) mod 4))

    if isMixXyzw(comp0) and isMixXyzw(comp1) and isMixAbcd(comp2) and isMixAbcd(comp3):
      result = mm_shuffle_ps(a, b, MM_SHUFFLE(int32(comp3) mod 4, int32(
          comp2) mod 4, int32(comp1) mod 4, int32(comp0) mod 4))

    if isMixAbcd(comp0) and isMixAbcd(comp1) and isMixXyzw(comp2) and isMixXyzw(comp3):
      result = mm_shuffle_ps(b, a, MM_SHUFFLE(int32(comp3) mod 4, int32(
          comp2) mod 4, int32(comp1) mod 4, int32(comp0) mod 4))

    if comp0 == m4X and comp1 == m4A and comp2 == m4Y and comp3 == m4B:
      result = mm_unpacklo_ps(a, b)

    if comp0 == m4A and comp1 == m4X and comp2 == m4B and comp3 == m4Y:
      result = mm_unpacklo_ps(b, a)

    if comp0 == m4Z and comp1 == m4C and comp2 == m4W and comp3 == m4D:
      result = mm_unpackhi_ps(a, b)

    if comp0 == m4C and comp1 == m4Z and comp2 == m4D and comp3 == m4W:
      result = mm_unpackhi_ps(b, a)

  proc dupXVector*(input: Vector4f): Vector4f {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    mixVector[m4X, m4X, m4X, m4X](input, input)

  proc dupYVector*(input: Vector4f): Vector4f {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    mixVector[m4Y, m4Y, m4Y, m4Y](input, input)

  proc dupZVector*(input: Vector4f): Vector4f {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    mixVector[m4Z, m4Z, m4Z, m4Z](input, input)

  proc absVector*(input: Vector4f): Vector4f {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    let absMask = mm_set_epi32(0x7FFFFFFF'u32, 0x7FFFFFFF'u32, 0x7FFFFFFF'u32, 0x7FFFFFFF'u32)
    result = mm_and_ps(input, mm_castsi128_ps(absMask))

  proc minVector*(lhs, rhs: Vector4f): Vector4f {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    result = mm_min_ps(lhs, rhs)
  
  proc maxVector*(lhs, rhs: Vector4f): Vector4f {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    result = mm_max_ps(lhs, rhs)

  proc subVector*(lhs, rhs: Vector4f): Vector4f {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    result = mm_sub_ps(lhs, rhs)

  proc mulVector*(lhs: Vector4f; rhs: Scalarf): Vector4f {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    result = mm_mul_ps(lhs, mm_shuffle_ps(rhs.value, rhs.value, MM_SHUFFLE(0, 0,
        0, 0)))

  proc mulVector*(lhs, rhs: Vector4f): Vector4f {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    result = mm_mul_ps(lhs, rhs)

  proc mulVector*(lhs: Vector4f; rhs: float32): Vector4f {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    result = mulVector(lhs, setVector(rhs))

  proc mulAddVector*(v0, v1, v2: Vector4f): Vector4f {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    result = mulvAddVector(v0, v1, v2)

  proc addVector*(lhs, rhs: Vector4f): Vector4f{.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    result = mm_add_ps(lhs, rhs)

  proc allLessEqualVector3(lhs, rhs: Vector4f): bool {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    let mask = mm_cmple_ps(lhs, rhs)

    result = allTrue2Mask4f(mask, result)

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

  # proc dotVector3*(lhs, rhs: Vector4f): float32 {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
  #   let
  #     x2y2z2w2 = mm_mul_ps(lhs, rhs)
  #     y2000 = mm_shuffle_ps(x2y2z2w2, x2y2z2w2, MM_SHUFFLE(0, 0, 0, 1))
  #     x2y2000 = mm_add_ss(x2y2z2w2, y2000)
  #     z2000 = mm_shuffle_ps(x2y2z2w2, x2y2z2w2, MM_SHUFFLE(0, 0, 0, 2))
  #     x2y2z2000 = mm_add_ss(x2y2000, z2000)

  #   result = mm_cvtss_f32(x2y2z2000)

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

  proc normQuat*(input: Quatf): Quatf {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    let
      x2y2z2w2 = mm_mul_ps(input, input)
      z2w200 = mm_shuffle_ps(x2y2z2w2, x2y2z2w2, MM_SHUFFLE(0, 0, 3, 2))
      x2z2y2w200 = mm_add_ps(x2y2z2w2, z2w200)
      y2w2000 = mm_shuffle_ps(x2z2y2w200, x2z2y2w200, MM_SHUFFLE(0, 0, 0, 1))
      x2y2z2w2000 = mm_add_ps(x2z2y2w200, y2w2000)

      dot = x2y2z2w2000

      half = mm_set_ss(0.5'f32)
      inputHalfV = mm_mul_ss(dot, half)
      x0 = mm_rsqrt_ss(dot)

    var x1 = mm_mul_ss(x0, x0)
    x1 = mm_sub_ss(half, mm_mul_ss(inputHalfV, x1))
    x1 = mm_add_ss(mm_mul_ss(x0, x1), x0)

    var x2 = mm_mul_ss(x1, x1)
    x2 = mm_sub_ss(half, mm_mul_ss(inputHalfV, x2))
    x2 = mm_add_ss(mm_mul_ss(x1, x2), x1)

    let invLen = mm_shuffle_ps(x2, x2, MM_SHUFFLE(0, 0, 0, 0))

    result = mm_mul_ps(input, invLen)

  proc quatFromMatrix*(xAxis, yAxis, zAxis: Vector4f): Quatf {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    let zero = zeroVector()
    if allNearEqualVector3(xAxis, zero) or allNearEqualVector3(yAxis, zero) or
        allNearEqualVector3(zAxis, zero):
      result = identityQuat()

    let
      xAxisX = getVectorX(xAxis)
      yAxisY = getVectorY(yAxis)
      zAxisZ = getVectorZ(zAxis)

      mtxTrace = xAxisX + yAxisY + zAxisZ
    if mtxTrace > 0.0'f32:
      let
        xAxisY = getVectorY(xAxis)
        xAxisZ = getVectorZ(xAxis)

        yAxisX = getVectorX(yAxis)
        yAxisZ = getVectorZ(yAxis)

        zAxisX = getVectorX(zAxis)
        zAxisY = getVectorY(zAxis)

        invTrace = sqrtReciprocalScalar(mtxTrace + 1.0'f32)
        halfInvTrace = invTrace * 0.5'f32

        x = (yAxisZ - zAxisY) * halfInvTrace
        y = (zAxisX - xAxisZ) * halfInvTrace
        z = (xAxisY - yAxisX) * halfInvTrace
        w = reciprocalScalar(invTrace) * 0.5'f32

      result = normQuat(setQuat(x, y, z, w))
  
  template transposeMatrix4x4f*(inputXyzw0, inputXyzw1, inputXyzw2, inputXyzw3, outputXxxx, outputYyyy, outputZzzz, outputWwww) =
    let 
      x0y0x1y1 = mm_shuffle_ps(inputXyzw0, inputXyzw1, MM_SHUFFLE(1, 0, 1, 0))
      z0w0z1w1 = mm_shuffle_ps(inputXyzw0, inputXyzw1, MM_SHUFFLE(3, 2, 3, 2))
      x2y2x3y3 = mm_shuffle_ps(inputXyzw2, inputXyzw3, MM_SHUFFLE(1, 0, 1, 0))
      z2w2z3w3 = mm_shuffle_ps(inputXyzw2, inputXyzw3, MM_SHUFFLE(3, 2, 3, 2))

    outputXxxx = mm_shuffle_ps(x0y0x1y1, x2y2x3y3, MM_SHUFFLE(2, 0, 2, 0))
    outputYyyy = mm_shuffle_ps(x0y0x1y1, x2y2x3y3, MM_SHUFFLE(3, 1, 3, 1))
    outputZzzz = mm_shuffle_ps(z0w0z1w1, z2w2z3w3, MM_SHUFFLE(2, 0, 2, 0))
    outputWwww = mm_shuffle_ps(z0w0z1w1, z2w2z3w3, MM_SHUFFLE(3, 1, 3, 1))

  proc setMatrix*(xAxis, yAxis, zAxis, wAxis: Vector4f): Matrix4x4f {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    result.xAxis = xAxis
    result.yAxis = yAxis
    result.zAxis = zAxis
    result.wAxis = wAxis
  
  proc transposeMatrix*(input: Matrix4x4f): Matrix4x4f {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    var xAxis, yAxis, zAxis, wAxis: Vector4f

    transposeMatrix4x4f(input.xAxis, input.yAxis, input.zAxis, input.wAxis, xAxis, yAxis, zAxis, wAxis)
    result = Matrix4x4f(xAxis: xAxis, yAxis: yAxis, zAxis: zAxis, wAxis: wAxis)

  proc perspective*(width, height, zNear, zFar: float32;
      oglNdc: bool): Matrix4x4f {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    let
      # d = zFar - zNear
      # aa = if oglNdc: (zFar + zNear) / d else: zFar / d
      # bb = if oglNdc: (2.0'f32 * zNear * zFar) / d else: zNear * aa
      fRange = zFar / (zNear - zFar)

      col0 = setVector(width, 0.0'f32, 0.0'f32, 0.0'f32)
      col1 = setVector(0.0'f32, height, 0.0'f32, 0.0'f32)
      col2 = setVector(0.0'f32, 0.0'f32, fRange, -1.0'f32)
      col3 = setVector(0.0'f32, 0.0'f32, fRange * zNear, 0.0'f32)

    result = setMatrix(col0, col1, col2, col3)

  proc perspectiveFov*(fovAngleY, aspectRatio, nearZ, farZ: float32;
      oglNdc: bool): Matrix4x4f {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    # let
    #   height = 1.0'f32 / tanScalar(fovAngleY * 0.5'f32)
    #   width = height / aspectRatio
    
    var sinFov, cosFov: float32
    sinCosScalar(0.5'f32 * fovAngleY, addr(sinFov), addr(cosFov))

    let
      height = cosFov / sinFov
      width = height / aspectRatio
    
    result = perspective(width, height, nearZ, farZ, oglNdc)



    result = perspective(width, height, nearZ, farZ, oglNdc)

  proc mulMatrix*(lhs, rhs: Matrix4x4f): Matrix4x4f {.codegendecl: "__declspec(safebuffers) __forceinline $# __vectorcall $#$#", inline.} =
    var tmp = mulVector(dupXVector(lhs.xAxis), rhs.xAxis)
    tmp = mulAddVector(dupYVector(lhs.xAxis), rhs.yAxis, tmp)
    tmp = mulAddVector(dupZVector(lhs.xAxis), rhs.zAxis, tmp)

    let xAxis = tmp
    tmp = mulVector(dupXVector(lhs.yAxis), rhs.xAxis)
    tmp = mulAddVector(dupYVector(lhs.yAxis), rhs.yAxis, tmp)
    tmp = mulAddVector(dupZVector(lhs.yAxis), rhs.zAxis, tmp)

    let yAxis = tmp
    tmp = mulVector(dupXVector(lhs.zAxis), rhs.xAxis)
    tmp = mulAddVector(dupYVector(lhs.zAxis), rhs.yAxis, tmp)
    tmp = mulAddVector(dupZVector(lhs.zAxis), rhs.zAxis, tmp)

    let zAxis = tmp
    tmp = mulVector(dupXVector(lhs.wAxis), rhs.xAxis)
    tmp = mulAddVector(dupYVector(lhs.wAxis), rhs.yAxis, tmp)
    tmp = mulAddVector(dupZVector(lhs.wAxis), rhs.zAxis, tmp)

    let wAxis = addVector(rhs.wAxis, tmp)
    result = Matrix4x4f(
      xAxis: xAxis,
      yAxis: yAxis,
      zAxis: zAxis,
      wAxis: wAxis
    )

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

proc rectangle(xMin, yMin, xMax, yMax: float32): Rectangle =
  result.xMin = xMin
  result.yMin = yMin
  result.xMax = xMax
  result.yMax = yMax

proc rectwh*(x, y, w, h: float32): Rectangle =
  result = rectangle(x, y, x + w, y + h)

proc emptyAABB*(): AABB =
  result.xMin = float32.high
  result.yMin = float32.high
  result.zMin = float32.high
  result.xMax = -float32.high
  result.yMax = -float32.high
  result.zMax = -float32.high

proc aabbv*(vMin, vMax: Float3f): AABB =
  result.xMin = vMin.x
  result.yMin = vMin.y
  result.zMin = vMin.z
  
  result.xMax = vMax.x
  result.yMax = vMax.y
  result.zMax = vMax.z

proc aabbf*(xMin, yMin, zMin, xMax, yMax, zMax: float32): AABB =
  result.xMin = xMin
  result.yMin = yMin
  result.zMin = zMin
  
  result.xMax = xMax
  result.yMax = yMax
  result.zMax = zMax

proc addPoint*(aabb: ptr AABB; pt: Float3f) =
  var vMin, vMax: Float3f
  storeVector3(addr(vMin), minVector(setVector(aabb.xMin, aabb.yMin, aabb.zMin),
      setVector(pt.x, pt.y, pt.z)))
  storeVector3(addr(vMax), maxVector(setVector(aabb.xMax, aabb.yMax, aabb.zMax),
      setVector(pt.x, pt.y, pt.z)))
  
  aabb[] = aabbv(vMin, vMax)

proc normPlane*(va, vb, vc: Float3f; output: ptr Float3f) {.codegendecl: "__declspec(safebuffers) __forceinline $# $#$#", inline.} =
  let
    v4va = setVector(va.x, va.y, va.z)
    ba = subVector(setVector(vb), v4va)
    ca = subVector(setVector(vc), v4va)
    baca = crossVector3(ca, ba)

  storeVector3(output, normVector3(baca))

proc normPlane*(va, vb, vc: Float3f): Vector4f {.codegendecl: "__declspec(safebuffers) __forceinline $# $#$#", inline.} =
  let
    v4va = setVector(va.x, va.y, va.z)
    ba = subVector(setVector(vb), v4va)
    ca = subVector(setVector(vc), v4va)
    baca = crossVector3(ca, ba)

  normVector3(baca)

proc toRad*(deg: float32): float32 {.codegendecl: "__declspec(safebuffers) __forceinline $# $#$#", inline.} =
  result = deg * PiDivOneEighty
