import times

template alignMask*(value, mask: untyped): untyped =
  (((value.uint) + (mask.uint)) and ((not 0'u) and (not(mask.uint))))

proc alignPtr*(p: pointer; extra: uint; alignment: uint32): pointer =
  type
    AnonUn {.union.} = object
      p: pointer
      address: uint
  
  var un: AnonUn
  un.p = p
  
  let 
    unaligned = un.address + extra
    mask = alignment - 1
    aligned = alignMask(unaligned, mask)
  un.address = aligned
  return un.p

proc isPowerOfTwo*(n: int): bool {.inline.} =
  (n and (n - 1)) == 0

func roundNextMultipleOf*(x: Natural, n: Natural): int {.inline.} =
  assert isPowerOfTwo(n)
  result = (x + n - 1) and not(n - 1)

# proc allocAligned*(size: int; alignment: static Natural): pointer {.inline.} =
#   static:
#     assert isPowerOfTwo(alignment)

#   let requiredMem = roundNextMultipleOf(size, alignment)
#   result = mi_malloc_aligned(csize_t(requiredMem), csize_t(alignment))

# proc allocAligned*(size: int; alignment: Natural): pointer {.inline.} =
#   assert isPowerOfTwo(alignment)

#   let requiredMem = roundNextMultipleOf(size, alignment)
#   result = mi_malloc_aligned(csize_t(requiredMem), csize_t(alignment))

# proc freeAligned*(p: pointer) {.inline.} =
#   mi_free(p)

template makeFourCC*(a, b, c, d: untyped): untyped =
  (uint32(a) or (uint32(b) shl 8'u32) or (uint32(c) shl 16'u32) or (uint32(d) shl 24'u32))

iterator countup*(a, b, step: float32): float32 =
  var res = a
  while res <= b:
    yield res
    res += step

proc copyStr*[N: static int](dst: var array[N, char]; src: cstring): ptr char {.discardable.} =
  let
    len = src.len()
    max = N - 1
    num = if len < max: len else: max
  
  if num > 0:
    copyMem(addr dst[0], addr src[0], num)
  dst[num] = '\0'

  result = addr dst[num]

proc copyStr*(dst: var cstring; src: var openArray[char]): ptr char {.discardable.} =
  let
    len = src.len()
    max = len(dst) - 1
    num = if len < max: len else: max
  
  if num > 0:
    copyMem(addr dst[0], addr src[0], num)
  dst[num] = '\0'

  result = addr dst[num]

proc copyStr*[N](dst: var array[N, char]; src: string): ptr char {.discardable.} =
  dst.copyStr(addr src[0])

proc copyStr*[N, M: static int](dst: var array[N, char]; src: array[M, char]): ptr char {.discardable.} =
  dst.copyStr(addr src[0])

proc strcmp*(chararray: openarray[char], str: string): bool =
  for i in 0..<chararray.len:
    if chararray[i] == 0.char:
      return i == str.len
    elif chararray[i] != str[i]:
      return false
  return false

## :Author: Kaushal Modi
## :License: MIT
##
## Introduction
## ============
## This module implements basic Pointer Arithmetic functions.
##
## Source
## ======
## `Repo link <https://github.com/kaushalmodi/ptr_math>`_
##
## The code in this module is mostly from `this code snippet <https://forum.nim-lang.org/t/1188#7366>`_ on Nim Forum.
import std / [macros, decls]
export decls

runnableExamples:
  var
    a: array[0 .. 3, int]
    p = addr(a[0])        # p is pointing to a[0]

  for i, _ in a:
    a[i] += i

  p += 1                  # p is now pointing to a[1]
  p[] = 100               # p[] is accessing the contents of a[1]
  doAssert a[1] == 100

  p[0] = 200              # .. so does p[0]
  doAssert a[1] == 200

  p[1] -= 2               # p[1] is accessing the contents of a[2]
  doAssert a[2] == 0

  p[2] += 50              # p[2] is accessing the contents of a[3]
  doAssert a[3] == 53

  p += 2                  # p is now pointing to a[3]
  p[-1] += 77             # p[-1] is accessing the contents of a[2]
  doAssert a[2] == 77

  doAssert a == [0, 200, 77, 53]
##

proc `+`*[T; S: SomeInteger](p: ptr T, offset: S): ptr T =
  ## Increments pointer `p` by `offset` that jumps memory in increments of
  ## the size of `T`.
  runnableExamples:
    type
      MyObject = object
        i: int
        f: float
        b: bool
    var
      a = [MyObject(i: 100, f: 2.3, b: true),
           MyObject(i: 300, f: 4.5, b: false),
           MyObject(i: 500, f: 6.7, b: true)]
      p = addr(a[0])
      p2 = p + 2

    doAssert p2[0].i == 500
    doAssert p2[-1].f == 4.5
  ##
  return cast[ptr T](cast[uint](p) + uint(int(offset) * sizeof(T)))
  #                                      `+%` treats x and y inputs as unsigned
  # and adds them: https://nim-lang.github.io/Nim/system.html#%2B%25%2Cint%2Cint

proc `+`*[S: SomeInteger](p: pointer, offset: S): pointer =
  ## Increments pointer `p` by `offset` that jumps memory in increments of
  ## single bytes.
  runnableExamples:
    type
      MyObject = object
        i: int
        f: float
        b: bool
    var
      a = [MyObject(i: 100, f: 2.3, b: true),
           MyObject(i: 300, f: 4.5, b: false),
           MyObject(i: 500, f: 6.7, b: true)]
      p = cast[pointer](addr(a[0]))
      p2 = p + (2*sizeof(MyObject))

    doAssert cast[ptr MyObject](p2)[0].i == 500-
    doAssert cast[ptr MyObject](p2)[-1].f == 4.5
  ##
  return cast[pointer](cast[uint](p) + uint(offset))

proc `-`*[T; S: SomeInteger](p: ptr T, offset: S): ptr T =
  ## Decrements pointer `p` by `offset` that jumps memory in increments of
  ## the size of `T`.
  runnableExamples:
    type
      MyObject = object
        i: int
        f: float
        b: bool
    var
      a = [MyObject(i: 100, f: 2.3, b: true),
           MyObject(i: 300, f: 4.5, b: false),
           MyObject(i: 500, f: 6.7, b: true)]
      p = addr(a[2])
      p1 = p - 1
    doAssert p1[0].i == 300
    doAssert p1[-1].b == true
    doAssert p1[1].f == 6.7
  ##
  return cast[ptr T](cast[uint](p) - uint(int(offset) * sizeof(T)))

proc `-`*[T](p1: ptr T, p2: ptr T): uint =
  return (cast[uint](p1) - (cast[uint](p2)))

proc `+`*[T](p1: ptr T, p2: ptr T): uint =
  return (cast[uint](p1) + (cast[uint](p2)))

proc `-`*[S: SomeInteger](p: pointer, offset: S): pointer =
  ## Decrements pointer `p` by `offset` that jumps memory in increments of
  ## single bytes.
  runnableExamples:
    type
      MyObject = object
        i: int
        f: float
        b: bool
    var
      a = [MyObject(i: 100, f: 2.3, b: true),
           MyObject(i: 300, f: 4.5, b: false),
           MyObject(i: 500, f: 6.7, b: true)]
      p = cast[pointer](addr(a[2]))
      p1 = p - (1*sizeof(MyObject))
    doAssert cast[ptr MyObject](p1)[0].i == 300
    doAssert cast[ptr MyObject](p1)[-1].b == true
    doAssert cast[ptr MyObject](p1)[1].f == 6.7
  ##
  return cast[pointer](cast[uint](p) - uint(offset))

proc `+=`*[T; S: SomeInteger](p: var ptr T, offset: S) =
  ## Increments pointer `p` *in place* by `offset` that jumps memory
  ## in increments of the size of `T`.
  runnableExamples:
    type
      MyObject = object
        i: int
        f: float
        b: bool
    var
      a = [MyObject(i: 100, f: 2.3, b: true),
           MyObject(i: 300, f: 4.5, b: false),
           MyObject(i: 500, f: 6.7, b: true)]
      p = addr(a[0])

    p += 1
    doAssert p[].i == 300
  ##
  p = p + offset

proc `+=`*[S: SomeInteger](p: var pointer, offset: S) =
  ## Increments pointer `p` *in place* by `offset` that jumps memory
  ## in increments of single bytes.
  runnableExamples:
    type
      MyObject = object
        i: int
        f: float
        b: bool
    var
      a = [MyObject(i: 100, f: 2.3, b: true),
           MyObject(i: 300, f: 4.5, b: false),
           MyObject(i: 500, f: 6.7, b: true)]
      p = cast[pointer](addr(a[0]))

    p += (1*sizeof(MyObject))
    doAssert cast[ptr MyObject](p)[].i == 300
  ##
  p = p + offset

proc `-=`*[T; S: SomeInteger](p: var ptr T, offset: S) =
  ## Decrements pointer `p` *in place* by `offset` that jumps memory
  ## in increments of the size of `T`.
  runnableExamples:
    type
      MyObject = object
        i: int
        f: float
        b: bool
    var
      a = [MyObject(i: 100, f: 2.3, b: true),
           MyObject(i: 300, f: 4.5, b: false),
           MyObject(i: 500, f: 6.7, b: true)]
      p = addr(a[2])

    p -= 2
    doAssert p[].f == 2.3
  ##
  p = p - offset

proc `-=`*[S: SomeInteger](p: var pointer, offset: S) =
  ## Decrements pointer `p` *in place* by `offset` that jumps memory
  ## in increments of single bytes.
  runnableExamples:
    type
      MyObject = object
        i: int
        f: float
        b: bool
    var
      a = [MyObject(i: 100, f: 2.3, b: true),
           MyObject(i: 300, f: 4.5, b: false),
           MyObject(i: 500, f: 6.7, b: true)]
      p = cast[pointer](addr(a[2]))

    p -= (2*sizeof(MyObject))
    doAssert cast[ptr MyObject](p)[].f == 2.3
  ##
  p = p - offset

proc `[]=`*[T; S: SomeInteger](p: ptr T, offset: S, val: T) =
  ## Assigns the value at memory location pointed by `p[offset]`.
  runnableExamples:
    var
      a = [1.3, -9.5, 100.0]
      p = addr(a[1])

    p[0] = 123.456
    doAssert a[1] == 123.456
  ##
  (p + offset)[] = val

proc `[]`*[T; S: SomeInteger](p: ptr T, offset: S): var T =
  ## Retrieves the value from `p[offset]`.
  runnableExamples:
    var
      a = [1, 3, 5, 7]
      p = addr(a[0])

    doAssert p[] == a[0]
    doAssert p[0] == a[0]
    doAssert p[2] == a[2]
  ##
  return (p + offset)[]


iterator items*[T](start: ptr T, stopBefore: ptr T): lent T =
  ## Iterates over contiguous `ptr T`s, from `start` excluding `stopBefore`. Yields immutable `T`.
  runnableExamples:
    var
      a = [1, 3, 5, 7]
      p = addr(a[0])
      e = p + a.len
      sum = 0
    for i in items(p, e):
      sum += i
    doAssert(sum == 16)
  ##
  var p = start
  while p != stopBefore:
    yield p[] 
    p += 1

iterator mitems*[T](start: ptr T, stopBefore: ptr T): var T =
  ## Iterates over contiguous `ptr T`s, from `start` excluding `stopBefore`. Yields mutable `T`.
  runnableExamples:
    var
      a = [1, 3, 5, 7]
      p = addr(a[0])
      e = p + a.len
      sum = 0
    for i in mitems(p, e):
      inc i
    for i in items(p, e):
      sum += i
    doAssert(sum == 20)
  ##
  var p = start
  while p != stopBefore:
    yield p[] 
    p += 1

iterator items*[T](uarray: UncheckedArray[T] | ptr T, len: SomeInteger): lent T =
  ## Iterates over `UncheckedArray[T]` or `ptr T` array with length. Yields immutable `T`.
  runnableExamples:
    let
      l = 4
      a = cast[ptr UncheckedArray[int]](alloc0(sizeof(int) * l))
      b = [1, 3, 5, 7]

    copyMem(a, b[0].unsafeAddr, sizeof(int) * l) 
    var i = 0
    for val in items(a[], l):
      doAssert(val == b[i])
      inc i

    let
      p = cast[ptr int](a)
    i = 0
    for val in items(p, l):
      doAssert(val == b[i])
      inc i
    dealloc(a)
  ##
  for i in 0..<len:
    yield uarray[i]

# As of 1.6.0 mitems and mpairs for var UncheckedArray[t] and ptr T cannot be combined
# like their immutable versions. https://forum.nim-lang.org/t/8557#55560

iterator mitems*[T](uarray: var UncheckedArray[T], len: SomeInteger): var T =
  ## Iterates over `var UncheckedArray[T]` with length. Yields mutable `T`.
  runnableExamples:
    var a = cast[ptr UncheckedArray[int]](alloc0(sizeof(int) * 4))
    for i in mitems(a[], 4):
      inc i
    doAssert(a[0] == 1)
    dealloc(a)
  ##
  for i in 0..<len:
    yield uarray[i]

iterator mitems*[T](p: ptr T, len: SomeInteger): var T =
  ## Iterates over `ptr T` with length. Yields mutable `T`.
  runnableExamples:
    var a = cast[ptr int](alloc0(sizeof(int) * 4))
    for i in mitems(a, 4):
      inc i
    doAssert(a[0] == 1)
    dealloc(a)
  ##
  for i in 0..<len:
    yield p[i]

iterator pairs*[T; S:SomeInteger](uarray: UncheckedArray[T] | ptr T, len: S): (S, lent T) =
  ## Iterates over `UncheckedArray[T]` or `ptr T` array with length. Yields immutable `(index, uarray[index])`.
  runnableExamples:
    let
      l = 4
      a = [1, 3, 5, 7]
      b = cast[ptr UncheckedArray[int]](alloc0(sizeof(int) * l))
      c = cast[ptr int](alloc0(sizeof(int) * l))

    copyMem(b, a[0].unsafeAddr, sizeof(int) * l) 
    copyMem(c, a[0].unsafeAddr, sizeof(int) * l) 

    for i, val in pairs(b[], l):
      doAssert(a[i] == val)

    for i, val in pairs(c, l):
      doAssert(a[i] == val)
    dealloc(b)
    dealloc(c)
  ##
  for i in S(0)..<len:
    yield (i, uarray[i])


iterator mpairs*[T; S: SomeInteger](uarray: var UncheckedArray[T], len: S): (S, var T) =
  ## Iterates over `var UncheckedArray[T]` with length. Yields `(index, uarray[index])` with mutable `T`.
  runnableExamples:
    let
      l = 4
      a = [1, 3, 5, 7]
      b = cast[ptr UncheckedArray[int]](alloc0(sizeof(int) * l))

    copyMem(b, a[0].unsafeAddr, sizeof(int) * l) 

    for i, val in mpairs(b[], l):
      inc val
      doAssert(a[i] + 1 == val)

    dealloc(b)
  ##
  for i in S(0)..<len:
    yield (i, uarray[i])

iterator mpairs*[T; S: SomeInteger](p: ptr T, len: S): (S, var T) =
  ## Iterates over `ptr T` array with length. Yields `(index, p[index])` with mutable `T`.
  runnableExamples:
    let
      l = 4
      a = [1, 3, 5, 7]
      b = cast[ptr int](alloc0(sizeof(int) * l))

    copyMem(b, a[0].unsafeAddr, sizeof(int) * l) 

    for i, val in mpairs(b, l):
      inc val
      doAssert(a[i] + 1 == val)
    dealloc(b)
  ##
  for i in S(0)..<len:
    yield (i, p[i])

macro rows*(x: ForLoopStmt) =
  ## This for loop macro, iterates over `UncheckedArray[untyped]` or `ptr untyped` array arguments, with a length. 
  ## It "yields" `(index, src1[index], src2[index], ...)`.
  ##
  runnableExamples:
    var 
      l = 3
      a = [100, 300, 500]
      b = ['a', 'e', 'i']
      c = [1.1, 2.2, 3.3]
      pa = a[0].addr
      pb = b[0].addr
      pc = cast[ptr UncheckedArray[float]](c[0].addr)

    var tuples:seq[(int, int, char, float)]
    for i, ta, tb, tc in rows(pa, pb, pc[], l):
      tuples.add (i, ta, tb, tc)

    doAssert(tuples[^1][0] == l-1)
    doAssert(tuples[^1][3] == 3.3)
  ##
  # Warning: This does not use iterators, so we don't get type information with ForLoopStmt.
  #   But, that allows us to mix `UncheckedArray[untyped]` and `ptr untyped` in the sources.
  let 
    internalCounter = genSym(nskVar, "counter") # prevents shenanigans with counter in loopBody
    counter = x[0]
    indices = x[1 ..< ^2]
    sources = x[^2][1 ..< ^1] # ptr T or UncheckedArray[T]
    length = x[^2][^1]
    loopBody = x[^1]

  var oVarSec = nnkVarSection.newTree()
  # length could be signed or unsigned, the counter should match its type
  oVarSec.add nnkIdentDefs.newTree(internalCounter, nnkCall.newTree(ident"typeof", length), newLit(0))

  var pvars:seq[NimNode]
  for i, source in pairs(sources):
    pvars.add genSym(nskVar, "p" & $i)
    oVarSec.add nnkIdentDefs.newTree(pvars[^1], newEmptyNode(), 
      nnkDotExpr.newTree(nnkBracketExpr.newTree(source, newLit(0)), ident"addr")) # source[0].addr

  var cond = infix(internalCounter, "<", length)

  var whileStmtList = nnkStmtList.newTree
  # counter is var, rest are let
  whileStmtList.add nnkVarSection.newTree(nnkIdentDefs.newTree(counter, newEmptyNode(), internalCounter))
  for i, index in pairs(indices):
    whileStmtList.add nnkLetSection.newTree(nnkIdentDefs.newTree(index, newEmptyNode(), nnkBracketExpr.newTree(pvars[i])))

  # Enables: sugar.collect(), increment the counter and pointers before the loopBody.
  whileStmtList.add newCall(ident"inc", internalCounter)
  for pv in pvars:
    whileStmtList.add infix(pv, "+=", newLit(1))
  whileStmtList.add loopBody

  result = quote do:
    block:
      `oVarSec`
      while `cond`:
        `whileStmtList`

macro mrows*(x: ForLoopStmt) =
  ## This for loop macro, iterates over `UncheckedArray[untyped]` or `ptr untyped` array arguments, with a length.
  ## It "yields" `(index, src1[index], src2[index], ...)` where the indexed values are mutable.
  runnableExamples:
    import std / sugar
    var 
      l = 3
      a = [100, 300, 500]
      b = ['a', 'e', 'i']
      c = [1.1, 2.2, 3.3]
      pa = a[0].addr
      pb = b[0].addr
      pc = cast[ptr UncheckedArray[float]](c[0].addr)

    var tuples:seq[(int, int, char, float)]
    for i, ta, tb, tc in mrows(pa, pb, pc[], l):
      inc ta
      tuples.add (i, ta, tb, tc)

    doAssert(tuples[^1][0] == l-1)
    doAssert(tuples[^1][3] == 3.3)
    doAssert(tuples[0][1] == 101)
  ##
  # Warning: This does not use iterators, so we don't get type information with ForLoopStmt.
  #   But, that allows us to mix `var UncheckedArray[untyped]` and `ptr untyped` in the sources.
  let 
    internalCounter = genSym(nskVar, "counter") # prevents shenanigans with counter in loopBody
    counter = x[0]
    indices = x[1 ..< ^2]
    sources = x[^2][1 ..< ^1] # ptr T or UncheckedArray[T]
    length = x[^2][^1]
    loopBody = x[^1]

  var oVarSec = nnkVarSection.newTree()
  # length could be signed or unsigned, the counter should match its type
  oVarSec.add nnkIdentDefs.newTree(internalCounter, nnkCall.newTree(ident"typeof", length), newLit(0))

  var pvars:seq[NimNode]
  for i, source in pairs(sources):
    pvars.add genSym(nskVar, "p" & $i)
    oVarSec.add nnkIdentDefs.newTree(pvars[^1], newEmptyNode(), 
      nnkDotExpr.newTree(nnkBracketExpr.newTree(source, newLit(0)), ident"addr")) # source[0].addr

  var cond = infix(internalCounter, "<", length)

  var whileStmtList = nnkStmtList.newTree()
  whileStmtList.add nnkVarSection.newTree(nnkIdentDefs.newTree(counter, newEmptyNode(), internalCounter))

  for i, index in pairs(indices):
    # A separate VarSection is need for each index using .byaddr. pragma, 
    #   or the compiler will complain .byaddr. is an invalid pragma.
    whileStmtList.add nnkVarSection.newTree(
      nnkIdentDefs.newTree(
        nnkPragmaExpr.newTree(index, nnkPragma.newTree(ident"byaddr")), 
        newEmptyNode(), 
        nnkBracketExpr.newTree(pvars[i])))

  # Enables sugar.collect(), increment the counter and pointers before the loopBody.
  whileStmtList.add newCall(ident"inc", internalCounter)
  for pv in pvars:
    whileStmtList.add infix(pv, "+=", newLit(1))
  whileStmtList.add loopBody

  result = quote do:
    block:
      `oVarSec`
      while `cond`:
        `whileStmtList`

#
#
## TimSort is a sorting algorithm based on Insertion Sort and Merge Sort.
## Used in Java’s Arrays.sort() as well as Python’s sorted() and sort().
## First sort small pieces using Insertion Sort, then merges the pieces using
## a merge of merge sort.
##
##

import std/algorithm
export SortOrder

const RUN: int = 32

const onlySafeCode = true

template `<-`(a, b) =
  when defined(gcDestructors):
    a = move b
  elif onlySafeCode:
    shallowCopy(a, b)
  else:
    copyMem(addr(a), addr(b), sizeof(T))

proc insertionSort[T](myRun: var openArray[T], left: int, right: int,
    cmp: proc (x, y: T): int {.closure.}, order: SortOrder) =

  var
    j: int
    temp: T

  template comparison(body: untyped) =
    for i in left + 1..right:
      temp = myRun[i]
      j = i - 1
      while j >= left and body:
        swap(myRun[j+1], myRun[j])
        dec j

  if cmp == system.cmp[T]:
    # Dont use system.cmp because it is slower
    case order:
      of Ascending: comparison myRun[j] > temp
      of Descending: comparison myRun[j] < temp
  else:
    # use custom cmp()
    case order:
      of Ascending: comparison cmp(myRun[j], temp) == 1
      of Descending: comparison cmp(myRun[j], temp) == -1

proc insertionSortIndex[T](myRun: var openArray[T], left: int, right: int,
    cmp: proc (x, y: T): int {.closure.}, order: SortOrder,
    idx: var seq[int]) =

  var
    j: int
    temp: T
    #temp2: int

  template comparison(body: untyped) =
    for i in left + 1..right:
      temp = myRun[i]
      #temp2 = idx[i]
      j = i - 1
      while j >= left and body:
        swap(myRun[j+1], myRun[j])
        swap(idx[j+1], idx[j])
        dec j

  if cmp == system.cmp[T]:
    # Dont use system.cmp because it is slower
    case order:
      of Ascending: comparison myRun[j] > temp
      of Descending: comparison myRun[j] < temp
  else:
    # use custom cmp()
    case order:
      of Ascending: comparison cmp(myRun[j], temp) == 1
      of Descending: comparison cmp(myRun[j], temp) == -1

proc merge[T](a, b: var openArray[T], lo, m, hi: int,
              cmp: proc (x, y: T): int {.closure.},
                  order: SortOrder) {.effectsOf: cmp.} =
  # Optimization: If max(left) <= min(right) there is nothing to do!
  if cmp(a[m], a[m+1]) * order <= 0: return
  var j = lo
  # copy a[j..m] into b:
  assert j <= m

  var bb = 0
  while j <= m:
    b[bb] <- a[j]
    inc(bb)
    inc(j)
  var i = 0
  var k = lo

  # copy proper element back:
  template comparison(body: untyped) =
    while k < j and j <= hi:
      if body:
        a[k] <- b[i]
        inc(i)
      else:
        a[k] <- a[j]
        inc(j)
      inc(k)

  if cmp == system.cmp[T]:
    # Dont use system.cmp because it is slower
    case order:
      of Ascending: comparison b[i] <= a[j]
      of Descending: comparison b[i] >= a[j]
  else:
    # use custom cmp()
    comparison cmp(b[i], a[j]) * order <= 0
  # copy rest of b:
  while k < j:
    a[k] <- b[i]
    inc(k)
    inc(i)

proc mergeIndex[T](a, b: var openArray[T], bidx: var seq[int], lo, m, hi: int,
                  cmp: proc (x, y: T): int {.closure.},
                  order: SortOrder, idx: var seq[int]) {.effectsOf: cmp.} =

  # Optimization: If max(left) <= min(right) there is nothing to do!
  if cmp(a[m], a[m+1]) * order <= 0: return
  var j = lo
  # copy a[j..m] into b:
  assert j <= m

  var bb = 0
  while j <= m:
    b[bb] <- a[j]
    bidx[bb] <- idx[j]
    inc(bb)
    inc(j)
  var i = 0
  var k = lo

  # copy proper element back:
  template comparison(body: untyped) =
    while k < j and j <= hi:
      if body:
        a[k] <- b[i]
        idx[k] <- bidx[i]
        inc(i)
      else:
        a[k] <- a[j]
        idx[k] <- idx[j]
        inc(j)
      inc(k)

  if cmp == system.cmp[T]:
    # Dont use system.cmp because it is slower
    case order:
      of Ascending: comparison b[i] <= a[j]
      of Descending: comparison b[i] >= a[j]
  else:
    # use custom cmp()
    comparison cmp(b[i], a[j]) * order <= 0
  # copy rest of b:
  while k < j:
    a[k] <- b[i]
    idx[k] <- bidx[i]
    inc(k)
    inc(i)

proc timSort*[T](arr: var openArray[T], cmp: proc (x,
    y: T): int {.closure.}, order = SortOrder.Ascending) {.effectsOf: cmp.} =
  ## Stable Sort, in-place based on the default python algorithm.
  ## Accepts sequence and array containers
  runnableExamples:
    var arr1 = @["bannana", "Apple", "cat"]
    arr1.timSort
    assert arr1 == ["Apple", "bannana", "cat"]
    var arr2 = @[-2, 7, 15, -14, 0, 15, 0, 7, -7, -4, -13, 5, 8, -14, 12]
    arr2.timSort
    assert arr2 == [-14, -14, -13, -7, -4, -2, 0, 0, 5, 7, 7, 8, 12, 15, 15]

  let n = arr.len
  var b = newSeq[T](n)
  for i in countup(0, n - 1, RUN):
    insertionSort(arr, i, min(i + RUN - 1, n-1), cmp, order)

  var size: int = RUN
  while size < n:
    for left in countup(0, n-1, 2*size):
      var
        mid = left + size - 1
        right = min(left + 2 * size - 1, n - 1)
      if mid < right:
        merge(arr, b, left, mid, right, cmp, order)
    size *= 2

proc timSort*[T](arr: var openArray[T], order = SortOrder.Ascending) =
  timSort[T](arr, system.cmp[T], order)

func timSort*[T](arr: var seq[seq[T]], cmp: proc (x, y: T): int {.closure.},
    order: SortOrder, sortIndex: varargs[int]) {.effectsOf: cmp.} =
  ## Stable Sort, based on timSort.
  ## Accepts sequence containers
  ## Sorts based on column criteria
  runnableExamples:
    var arr3 = @[@[2, 2, 2, 2, 1, 1, 1, 1, 3, 3, 3, 3], @[4, 3, 2, 1, 2, 3, 4,
        1, 5, 6, 7, 8], @[8, 7, 6, 5, 4, 3, 2, 1, 9, 10, 11, 12]]
    timSort(arr3, @[0, 1])
    check arr3 == @[@[1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3], @[1, 2, 3, 4, 1, 2,
        3, 4, 5, 6, 7, 8], @[1, 4, 3, 2, 5, 6, 7, 8, 9, 10, 11, 12]]
    var arr4 = @[@[2, 2, 2, 2, 1, 1, 1, 1, 3, 3, 3, 3], @[4, 3, 2, 1, 2, 3, 4,
        1, 5, 6, 7, 8], @[8, 7, 6, 5, 4, 3, 2, 1, 9, 10, 11, 12]]
    arr4.timSort(0, 1)
    check arr4 == @[@[1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3], @[1, 2, 3, 4, 1, 2,
        3, 4, 5, 6, 7, 8], @[1, 4, 3, 2, 5, 6, 7, 8, 9, 10, 11, 12]]


  let n = arr[0].len
  var 
    input = arr
    idx = newSeq[int](n)
    b = newSeq[T](n)
    bidx = newSeq[int](n)
  for i in 0..<arr[0].len:
    idx[i] = i

  for col in countdown(sortIndex.len - 1, 0, 1):
    for i in countup(0, n - 1, RUN):
      insertionSortIndex(arr[sortIndex[col]], i, min(i + RUN - 1, n-1), cmp,
          order, idx)

    var size: int = RUN
    while size < n:
      for left in countup(0, n-1, 2*size):
        var
          mid = left + size - 1
          right = min(left + 2 * size - 1, n - 1)
        if mid < right:
          mergeIndex(arr[sortIndex[col]], b, bidx, left, mid, right, cmp,
              order, idx)
      size *= 2

    #use idx[] to rebuild data
    for column in 0..<arr.len:
      if sortIndex[col] == column: continue
      for index, row in idx:
        arr[column][index] = input[column][row]

proc timSort*[T](arr: var seq[seq[T]], sortIndex: varargs[int] = [0]) =
  timSort[T](arr, system.cmp[T], Ascending, sortIndex)