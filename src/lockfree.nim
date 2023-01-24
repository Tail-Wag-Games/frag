import atomics,
       primer

type
  SpscNode = object
    next: ptr SpscNode

  SpscBin = object
    ptrs: ptr ptr SpscNode
    buff: ptr uint8
    next: ptr SpscBin
    iter: int
    reserved: int

  SpscQueue* = object
    ptrs: ptr ptr SpscNode
    buff: ptr uint8
    iter: int
    capacity: int
    stride: int
    buffSize: int

    first: ptr SpscNode
    last: Atomic[uint]
    divider: Atomic[uint]

    growBins: ptr SpscBin

proc destroy*(bin: ptr SpscBin) =
  assert not bin.isNil

  freeShared(bin)

proc destroy*(queue: ptr SpscQueue) =
  if cast[ptr SpscQueue](queue.addr) != nil:
    if queue.growBins != nil:
      var bin = queue.growBins
      while bin != nil:
        let next = bin.next
        destroy(bin)
        bin = next

    queue.iter = 0
    queue.capacity = queue.iter
    freeShared(queue)

proc createBin(itemSize, capacity: int): ptr SpscBin =
  assert capacity mod 16 == 0

  block outer:
    var buff = cast[ptr uint8](allocShared(
      sizeof(SpscBin) + (itemSize + sizeof(pointer) + sizeof(SpscNode)) * capacity
    ))

    if buff.isNil:
      # TODO: Handle OOM
      result = nil
      break outer

    result = cast[ptr SpscBin](buff)
    buff += sizeof(SpscBin)
    result.ptrs = cast[ptr ptr SpscNode](buff)
    buff += sizeof(ptr SpscNode) * capacity
    result.buff = buff
    result.next = nil

    result.iter = capacity

    for i in 0 ..< capacity:
      result.ptrs[capacity - i - 1] =
        cast[ptr SpscNode](result.buff + (sizeof(SpscNode) + itemSize) * i)

proc create*(itemSize, capacity: int): ptr SpscQueue =
  assert itemSize > 0

  let cap = alignMask(capacity, 15).int

  block outer:
    var
      buff = cast[ptr uint8](
        allocShared(sizeof(SpscQueue) + (itemSize + sizeof(pointer) + sizeof(
            SpscNode)) * capacity)
      )

    if buff.isNil:
      # TODO: Handle OOM
      result = nil
      break outer

    result = cast[ptr SpscQueue](buff)
    buff += sizeof(SpscQueue)
    result.ptrs = cast[ptr ptr SpscNode](buff)
    buff += sizeof(ptr SpscNode) * cap
    result.buff = buff

    result.iter = cap
    result.capacity = cap
    result.stride = itemSize
    result.buffSize = (itemSize + sizeof(SpscNode)) * cap

    for i in 0 ..< cap:
      result.ptrs[cap - i - 1] =
        cast[ptr SpscNode](result.buff + (sizeof(SpscNode) + itemSize) * i)

    dec(result.iter)
    let node = result.ptrs[result.iter]
    node.next = nil
    result.first = node
    store(result.last, cast[uint](node))
    store(result.divider, load(result.last))
    result.growBins = nil

proc produce*(queue: ptr SpscQueue; data: pointer): bool =
  var
    node: ptr SpscNode = nil
    nodeBin: ptr SpscBin = nil

  if queue.iter > 0:
    dec(queue.iter)
    node = queue.ptrs[queue.iter]
  else:
    var bin = queue.growBins
    while bin != nil and isNil(node):
      if bin.iter > 0:
        dec(bin.iter)
        node = bin.ptrs[bin.iter]
        nodeBin = bin

      bin = bin.next

  if node != nil:
    copyMem(node + 1, data, queue.stride)
    node.next = nil

    let last = cast[ptr SpscNode](exchange(queue.last, cast[uint](node)))
    last.next = node

    while cast[uint](queue.first) != load(queue.divider, moAcquire):
      let first = queue.first
      queue.first = first.next

      let firstPtr = cast[uint](first)
      if firstPtr >= cast[uint](queue.buff) and firstPtr < cast[uint](
          queue.buff + queue.buffSize):
        assert queue.iter != queue.capacity
        queue.ptrs[queue.iter] = first
        inc(queue.iter)
      else:
        var bin = queue.growBins
        while bin != nil:
          if firstPtr >= cast[uint](bin.buff) and firstPtr < cast[uint](
              bin.buff + queue.buffSize):
            assert bin.iter != queue.capacity
            bin.ptrs[bin.iter] = first
            inc(bin.iter)
            break
          bin = bin.next
        assert bin != nil

    result = true
  else:
    result = false

proc consume*(queue: ptr SpscQueue; data: pointer): bool =
  if queue.divider.load() != queue.last.load():
    let divider = cast[ptr SpscNode](queue.divider)
    assert(divider.next != nil)
    copyMem(data, divider.next + 1, queue.stride)

    store(queue.divider, cast[uint](divider.next), moRelease)
    result = true
  else:
    result = false

proc grow*(queue: ptr SpscQueue): bool =
  let bin = createBin(queue.stride, queue.capacity)
  if bin != nil:
    if queue.growBins != nil:
      var last = queue.growBins
      while last.next != nil: last = last.next
      last.next = bin
    else:
      queue.growBins = bin
    result = true
  else:
    result = false

proc full*(queue: ptr SpscQueue): bool =
  block outer:
    if queue.iter > 0:
      result = false
      break outer
    else:
      var bin = queue.growBins
      while bin != nil:
        if bin.iter > 0:
          result = false
          break
        bin = bin.next

  result = true

template produceAndGrow*(queue, data: untyped): bool =
  if full(queue): discard grow(queue)
  produce(queue, data)
