import std / [os, strutils]

switch("gc", "arc")
switch("define", "useMalloc")

let
  thirdPartyPath = projectDir() / ".." / "thirdparty"
  mimallocPath = thirdPartyPath / "mimalloc"
  mimallocStatic = "mimallocStatic=\"" & (mimallocPath / "src" / "static.c") & '"'
  mimallocIncludePath = "mimallocIncludePath=\"" & (mimallocPath / "include") & '"'

switch("define", mimallocStatic)
switch("define", mimallocIncludePath)

switch("define", "host")
switch("define", "debug")
switch("define", "nimArcDebug")

switch("path", thirdPartyPath)
switch("path", thirdPartyPath / "winim")
switch("path", thirdPartyPath / "sokol-nim" / "src")
switch("path", thirdPartyPath / "laser")

patchFile("stdlib", "malloc", "alloc")

when defined Windows:
  switch("cc", "vcc")