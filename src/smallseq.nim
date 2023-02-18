# Based on idea of SmallList<T> at
# https://stackoverflow.com/questions/41946007/efficient-and-well-explained-implementation-of-a-quadtree-for-2d-collision-det
#
# Collection of arbitrary elements to be used as a replacement for builtin sequences.
# In contrast to sequences, does not allocate memory on heap until its length exceeds 128 elements.
#
# Denis Olshin, 2021
import tnt

type
  sseq*[T] = object
    size: int
    base: array[128, T]
    extra: seq[T]

{.push inline.}

proc newSSeq*[T](len: Natural = 0): sseq[T] =
  if len > 0:
    result.size = len
    if len > 128:
      when T is SomeNumber:
        result.extra = newSeqUninitialized[T](len.nextPowerOfTwo - 128)
      else:
        result.extra = newSeq[T](len.nextPowerOfTwo - 128)

proc `@@`*[IDX, T](a: sink array[IDX, T]): sseq[T] =
  let len = a.len
  result.size = len
  for i in 0..<min(len, 128):
    result.base[i] = a[i + IDX.low]
  if len > 128:
    when T is SomeNumber:
      result.extra = newSeqUninitialized[T](len.nextPowerOfTwo - 128)
    else:
      result.extra = newSeq[T](len.nextPowerOfTwo - 128)
    for i in 0..<(len - 128):
      result.extra[i] = a[i + IDX.low + 128]

proc `[]`*[T](s: sseq[T], i: Natural): T =
  assert i < s.size, "Out of bounds"
  if i < 128:
    s.base[i]
  else:
    s.extra[i - 128]

proc `[]=`*[T](s: var sseq[T], i: Natural, e: T) =
  assert i < s.size, "Out of bounds"
  if i < 128:
    s.base[i] = e
  else:
    s.extra[i - 128] = e

proc len*(s: sseq): int = s.size
proc add*[T](s: var sseq[T], e: T) =
  if s.size < 128:
    s.base[s.size] = e
  elif s.size == 128:
    when T is SomeNumber:
      s.extra = newSeqUninitialized[T](128)
    else:
      s.extra = newSeq[T](128)
    s.extra[0] = e
  elif (s.size and (s.size - 1)) == 0: # at powers of 2, double the size
    s.extra.setLen((s.size shl 1) - 128)
    s.extra[s.size] = e
  else:
    s.extra[s.size] = e
  s.size += 1

proc setLen*(s: sseq, len: Natural) =
  if len > 128 and len > s.size.nextPowerOfTwo:
    s.extra.setLen(len.nextPowerOfTwo - 128)
  s.size = len
proc `len=`*(s: var sseq, len: Natural) = s.setLen(len)

proc push*[T](s: var sseq[T], e: T) = s.add(e)
proc pop*[T](s: var sseq[T]): T =
  result = s[s.size - 1]
  s.size -= 1

{.pop.}