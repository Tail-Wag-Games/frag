import primer

type
  Page = object
    ptrs: ptr UncheckedArray[pointer]
    buff*: ptr uint8
    next: ptr Page
    iter: int

  Pool* = object
    itemSize: int
    capacity: int
    pages*: ptr Page

proc poolPageCreate(pool: ptr Pool): ptr Page =
  let
    cap = pool.capacity
    itemSize = pool.itemSize

  var buff = cast[ptr uint8]( 
    allocAligned(
      sizeof(Page) + (itemSize + sizeof(pointer)) * cap,
      16
    )
  )

  result = cast[ptr Page](buff)
  buff += sizeof(Page)
  result.iter = cap
  result.ptrs = cast[ptr UncheckedArray[pointer]](buff)
  buff += sizeof(pointer) * cap
  result.buff = buff
  result.next = nil
  for i in 0 ..< cap:
    result.ptrs[cap - i - 1] = result.buff + i * itemSize

proc poolCreate*(itemSize, capacity: int): ptr Pool =
  let cap = int32(alignMask(capacity, 15))

  var buff = cast[ptr uint8](
    allocAligned(
      sizeof(Pool) + sizeof(Page) + (itemSize + sizeof(pointer)) * cap,
      16
    )
  )

  result = cast[ptr Pool](buff)
  buff += sizeof(Pool)
  result.itemSize = itemSize
  result.capacity = cap
  result.pages = cast[ptr Page](buff)
  buff += sizeof(Page)

  var page = cast[ptr Page](result.pages)
  page.iter = cap
  page.ptrs = cast[ptr UncheckedArray[pointer]](buff)
  buff += sizeof(pointer) * cap
  page.buff = buff
  page.next = nil
  for i in 0 ..< cap:
    page.ptrs[cap - i - 1] = page.buff + i * itemSize

proc poolDestroy*(pool: ptr Pool) =
  var page = pool.pages.next
  while page != nil:
    let next = page.next
    freeAligned(page)
    page = next
  pool.capacity = 0
  pool.pages.iter = 0
  pool.pages.next = nil
  freeAligned(pool)

proc poolNew*(pool: ptr Pool): pointer =
  var page = pool.pages
  while page.iter == 0 and page.next != nil:
    page = page.next

  if page.iter > 0:
    dec(page.iter)
    return page.ptrs[page.iter]

proc poolGrow(pool: ptr Pool): bool =
  let page = poolPageCreate(pool)
  if page != nil:
    var last = pool.pages
    while last.next != nil:
      last = last.next
    last.next = page
    result = true

proc poolFull(pool: ptr Pool): bool =
  var page = pool.pages
  while page != nil:
    if page.iter > 0:
      return false
    page = page.next
  result = true

proc poolFullN*(pool: ptr Pool, n: int): bool =
  var page = pool.pages
  while page != nil:
    if (page.iter - n) >= 0:
      return false
    page = page.next
  result = true

proc poolDel*(pool: ptr Pool, p: pointer) =
  let uptr = cast[uint](p)
  var page = pool.pages

  while page != nil:
    if uptr >= cast[uint](page.buff) and
       uptr < cast[uint](page.buff + pool.capacity * pool.itemSize):
      page.ptrs[page.iter] = p
      inc(page.iter)
      return

    page = page.next
  

template poolNewAndGrow*(pool: ptr Pool): untyped =
  if poolFull(pool):
    discard poolGrow(pool)

  poolNew(pool)
