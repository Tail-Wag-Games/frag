# Based on idea of FreeList<T> at
# https://stackoverflow.com/questions/41946007/efficient-and-well-explained-implementation-of-a-quadtree-for-2d-collision-det
#
# Denis Olshin, 2021

import std/[ropes, strformat]

type
  FreeElement[T] = object
    val: T
    nextFree: int

  fseq*[T] = object
    len: int
    firstFree: int
    data: seq[FreeElement[T]]

{.push inline.}

proc `$`*[T](s: fseq[T]): string =
  var r = rope(&"fseq[len: {s.len}, firstFree: {s.firstFree}, data: [")
  var first = true
  for e in s.data:
    if not first:
      r.add(", ")
    first = false
    if e.nextFree == -1:
      r.add($e.val)
    else:
      r.add(&"->{e.nextFree}")
  r.add("]")
  return $r

proc newFSeq*[T](len: Natural = 0): fseq[T] =
  result.data = newSeq[FreeElement[T]](len)
  for i in 0..<len:
    result.data[i].nextFree = -2
  result.len = len
  result.firstFree = -1

proc isFree(el: FreeElement): bool {.inline.} = el.nextFree != -2
proc isFree*(s: fseq, i: Natural): bool = s.data[i].isFree

proc `[]`*[T](s: fseq[T], i: Natural): T =
  assert not s.isFree(i), "Access to deleted element"
  s.data[i].val

proc `[]=`*[T](s: var fseq[T], i: Natural, e: T) =
  assert not s.isFree(i), "Access to deleted element"
  s.data[i].val = e

proc len*(s: fseq): int = s.len
proc add*[T](s: var fseq[T], e: T): int {.discardable.} =
  if s.firstFree == -1:
    s.data.add(FreeElement[T](val: e, nextFree: -2))
    result = s.len
  else:
    result = s.firstFree
    s.firstFree = s.data[result].nextFree
    s.data[result].val = e
    s.data[result].nextFree = -2
  s.len += 1

proc del*[T](s: var fseq[T], i: int): T {.discardable.} =
  if s.isFree(i):
    return
  s.data[i].nextFree = s.firstFree
  s.firstFree = i
  s.len -= 1

proc push*[T](s: var fseq[T], e: T) = s.add(e)
proc pop*[T](s: var fseq[T]): T = s.del(s.len - 1)

proc items*[T](s: fseq[T]): seq[T] =
  result = newSeq[T](s.len)
  var i = 0
  for item in s.data:
    if not item.isFree:
      result[i] = item.val
      i += 1

iterator items*[T](s: fseq[T]): T =
  for item in s.data:
    if not item.isFree:
      yield item.val

{.pop.}

when isMainModule:
  let prev = getOccupiedMem() + 48
  #echo getOccupiedMem()
  #let x = 1
  #var y: seq[int]
  var z = newFSeq[int]()
  z.add(1)
  #z.extra.add(1)
  #z
  echo "mem: ", getOccupiedMem() - prev
  echo sizeof(z)
  #echo sizeof(z)
  echo GC_getStatistics()