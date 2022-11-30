# when defined(windows):
#   when defined(vcc):
#     proc rdtsc(): uint64 {.importc: "__rdtsc", header: "<intrin.h>".}
# when defined(macosx):
#     proc mach_absolute_time(): uint64 {.importc, header: "<mach/mach.h>".}

# # https://github.com/google/benchmark/blob/v1.1.0/src/cycleclock.h
# proc cycleClock*(): uint64 =
#   when defined(windows):
#     result = rdtsc()
#   when defined(macosx):
#     result = mach_absolute_time()
