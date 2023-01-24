when defined(amd64):
  type
    AtomicPtr* = distinct uint64

type  
  MemoryOrder* = distinct int32

const
  moRelaxed* = MemoryOrder(0)
  moConsume* = MemoryOrder(1)
  moAcquire* = MemoryOrder(2)
  moRelease* = MemoryOrder(3)
  moAcqRel* = MemoryOrder(4)
  moSeqCst* = MemoryOrder(5)

proc exchange64*(a: ptr AtomicPtr; b: uint64): uint64 {.importc: "fe_atomic_exchange64".}