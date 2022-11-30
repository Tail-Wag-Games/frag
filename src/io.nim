type
  MemBlock* = object
    data*: pointer
    size*: int64
    startOffset*: int64
    align*: int32
    refCount*: uint32

  MemReader* = object
    data: ptr UncheckedArray[uint8]
    pos: int64
    top: int64

template truncateData() =
  assert(false, "truncated data")

template readVar*(r, v: untyped) =
  discard readMem(r, addr(v), sizeof(v))

proc readMem*(reader: ptr MemReader; data: pointer; size: int64): int64 =
  let remaining = reader.top - reader.pos

  result = size
  if result > remaining:
    result = remaining
    truncateData()
  copyMem(data, addr(reader.data[reader.pos]), result)
  reader.pos += result

proc initMemReader*(reader: ptr MemReader; data: pointer; size: int64) =
  assert(data != nil)
  assert(size > 0)

  reader.data = cast[ptr UncheckedArray[uint8]](data)
  reader.top = size
  reader.pos = 0