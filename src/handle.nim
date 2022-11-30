import primer

type
  Handle* = distinct uint32

  HandlePool* = object
    count: int32
    capacity: int32
    dense: ptr UncheckedArray[Handle]
    sparse: ptr int32

const
  HandleGenBits = 14

  InvalidHandle* = Handle(0'u32)

  HandleIndexMask = (1 shl (32 - HandleGenBits)) - 1
  HandleGenMask = (1 shl HandleGenBits) - 1
  HandleGenShift = (32 - HandleGenBits)

template handleIndex*(h: untyped): untyped =
  int(uint32(h) and HandleIndexMask)

template handleGen(h: untyped): untyped = int32((uint32(h) shr HandleGenShift) and HandleGenMask)
template handleMake(g, idx: untyped): untyped =
  Handle(((uint32(g) and HandleGenMask) shl HandleGenShift) or (uint32(idx) and HandleIndexMask))

proc handleResetPool(pool: ptr HandlePool) =
  pool.count = 0
  let dense = pool.dense
  for i in 0 ..< pool.capacity:
    dense[i] = handleMake(0, i)

proc createHandlePool*(capacity: int32): ptr HandlePool =
  assert(capacity < int32(high(int16)), "requested handle pool capacity is too high")

  let maxSz = alignMask(capacity, 15)

  var buff = cast[ptr uint8](allocShared(sizeof(HandlePool) + (sizeof(Handle) + sizeof(int32)) * maxSz.int32))

  if isNil(buff):
    return nil

  let pool = cast[ptr HandlePool](buff)
  buff += sizeof(HandlePool)
  pool.dense = cast[ptr UncheckedArray[Handle]](buff)
  buff += sizeof(Handle) * maxSz.int32
  pool.sparse = cast[ptr int32](buff)
  pool.capacity = capacity
  handleResetPool(pool)
  result = pool

proc destroyHandlePool*(pool: ptr HandlePool) =
  if pool != nil:
    deallocShared(pool)

proc handleGrowPool*(ppool: ptr ptr HandlePool): bool =
  let 
    pool = ppool[]
    newCap = pool.capacity shl 1
    newPool = createHandlePool(newCap)
  
  if isNil(newPool):
    return false

  newPool.count= pool.count
  copyMem(addr(newPool.dense[0]), addr(pool.dense[0]), sizeof(Handle) * pool.capacity)
  copyMem(newPool.sparse, pool.sparse, sizeof(int32) * pool.capacity)

  destroyHandlePool(pool)
  ppool[] = newPool

  result = true

proc newHandle*(pool: ptr HandlePool): Handle =
  if pool.count < pool.capacity:
    let idx = pool.count
    inc(pool.count)

    let handle = pool.dense[idx]
    
    var gen = handleGen(handle)
    
    let iidx = handleIndex(handle)
    
    inc(gen)
    
    let newHandle = handleMake(gen, iidx)

    pool.dense[idx] = newHandle
    pool.sparse[iidx] = idx
    return newHandle
  else:
    assert(false, "handle pool is full")
  
  result = InvalidHandle

proc handleFull(pool: ptr HandlePool): bool =
  result = pool.count == pool.capacity

template newHandleGrowPool*(pool: untyped): untyped =
  if handleFull(pool):
    discard handleGrowPool(addr(pool))

  newHandle(pool)