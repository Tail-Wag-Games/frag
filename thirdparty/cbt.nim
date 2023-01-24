{.passC: "/IC:\\Users\\Zach\\dev\\frag\\thirdparty".}
{.compile: "C:\\Users\\Zach\\dev\\frag\\thirdparty\\cbt.c".}

type
  Node* = object
    id {.bitsize: 58.}: uint64
    depth {.bitsize: 6.}: uint64
  Tree* = object
    heap: ptr UncheckedArray[uint64]

proc node*(id, depth: uint64): Node =
  result.id = id
  result.depth = depth

proc createAtDepth*(maxDepth, depth: int64): ptr Tree {.importc: "cbt_CreateAtDepth".}
proc heapByteSize*(tree: ptr Tree): int64 {.importc: "cbt_HeapByteSize".}
proc getHeap*(tree: ptr Tree): ptr UncheckedArray[char] {.importc: "cbt_GetHeap".}