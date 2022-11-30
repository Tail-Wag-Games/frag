import cpuinfo, std/[atomics, locks]

when defined(windows):
  import winim/lean
else:
  import posix

type
  MachPort = distinct uint32

  SpinWait* = object
    count: int

  # SpinLock* = object
  #   state: AtomicFlag

  SpinLock* = Atomic[int]

  Semaphore* = object
    cond: Cond
    lock: Lock
    count: int

const
  LockPrespin = 1023
  LockMaxTime* = 300

  # LockMaxTime* = 300
  # MaxSpinCount = 10

let
  allowBusyWaiting = countProcessors() > 1

when defined(macosx):
  proc pthreadMachThreadNp(t: Pthread): MachPort {.cdecl, importc:"pthread_mach_thread_np", header:"pthread.h".}
elif defined(windows) and defined(vcc):
  proc switchToThread(): bool {.cdecl, importc:"SwitchToThread", header:"Processthreadsapi.h".}
  proc rdtsc(): int64 {.cdecl, importc: "__rdtsc", header: "<intrin.h>".}

proc threadTid*(): uint32 =
  when defined(windows):
    result = uint32(GetCurrentThreadId())
  else:
    result = uint32(cast[MachPort](pthreadMachThreadNp(pthreadSelf())))

proc unlock*(lock: var SpinLock) =
  let prev = exchange(lock, 0)
  assert(prev == 1)

proc tryLock*(lock: var SpinLock): bool = 
  result = load(lock) == 0 and exchange(lock, 1) == 0

proc lock*(lock: var SpinLock) =
  var counter = 0
  while not tryLock(lock):
    inc(counter)
    if (counter and LockPrespin) == 0:
      discard switchToThread()
    else:
      let prev = rdtsc()
      cpuRelax()
      while (rdtsc() - prev) < LockMaxTime:
        cpuRelax()

template withLock*(t, x: untyped) =
  lock(t)
  x
  unlock(t)

# proc isNextSpinYield*(self: SpinWait): bool {.inline.} =
#   return self.count >= MaxSpinCount or not allowBusyWaiting

# proc spinOnce*(self: var SpinWait) {.inline.} =
#   if self.isNextSpinYield:
#     cpuRelax()
#   inc(self.count)

# proc enter*(self: var SpinLock): bool {.inline.} =
#   var wait: SpinWait
#   while self.state.testAndSet(moAcquire):
#     wait.spinOnce()
#   return true

# proc exit*(self: var SpinLock) {.inline.} =
#   self.state.clear(moRelease)

# template withLock*(self: var SpinLock; body: untyped): untyped =
#   let isLockTaken = self.enter()
#   try:
#     body
#   finally:
#     if isLockTaken:
#       self.exit()

proc init*(s: var Semaphore) =
  initLock(s.lock)
  initCond(s.cond)
  s.count = 0

proc `=destroy`*(s: var Semaphore) =
  deinitCond(s.cond)
  deinitLock(s.lock)
  s.count = 0

proc wait*(s: var Semaphore) =
  acquire(s.lock)
  while s.count <= 0:
    wait(s.cond, s.lock)
  dec s.count
  release(s.lock)

proc signal*(s: var Semaphore) =
  withLock s.lock:
    inc s.count
    signal s.cond

proc post*(s: var Semaphore; count: int) =
  for i in 0 ..< count:
    signal(s)
