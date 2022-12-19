task build, "build frag executable":
  exec "cl /c /I.\\thirdparty\\cr /Fo.\\thirdparty\\cr.o .\\thirdparty\\cr.cpp"
  exec "lib /out:.\\thirdparty\\cr.lib C:\\Users\\Zach\\dev\\frag\\thirdparty\\cr.o"

  when defined(macosx):
    exec "cc -O0 -ffunction-sections -fdata-sections -g -m64 -fPIC  -DBOOST_CONTEXT_EXPORT= -I./src/fragpkg/asm -o ./src/fragpkg/asm/make_combined_all_macho_gas.S.o -c ./src/fragpkg/asm/make_combined_all_macho_gas.S"
    exec "cc -O0 -ffunction-sections -fdata-sections -g -m64 -fPIC  -DBOOST_CONTEXT_EXPORT= -I./src/fragpkg/asm -o ./src/fragpkg/asm/jump_combined_all_macho_gas.S.o -c ./src/fragpkg/asm/jump_combined_all_macho_gas.S"
    exec "cc -O0 -ffunction-sections -fdata-sections -g -m64 -fPIC  -DBOOST_CONTEXT_EXPORT= -I./src/fragpkg/asm -o ./src/fragpkg/asm/ontop_combined_all_macho_gas.S.o -c ./src/fragpkg/asm/ontop_combined_all_macho_gas.S"
  elif defined(windows):
    exec "\"C:\\Program Files\\Microsoft Visual Studio\\2022\\Community\\VC\\Tools\\MSVC\\14.30.30705\\bin\\Hostx64\\x64\\ml64.exe\" /nologo /c /Fo./src/asm/make_x86_64_ms_pe_masm.obj /Zd /Zi /I./src/asm /DBOOST_CONTEXT_EXPORT= ./src/asm/make_x86_64_ms_pe_masm.asm"
    exec "\"C:\\Program Files\\Microsoft Visual Studio\\2022\\Community\\VC\\Tools\\MSVC\\14.30.30705\\bin\\Hostx64\\x64\\ml64.exe\" /nologo /c /Fo./src/asm/jump_x86_64_ms_pe_masm.obj /Zd /Zi /I./src/asm /DBOOST_CONTEXT_EXPORT= ./src/asm/jump_x86_64_ms_pe_masm.asm"
    exec "\"C:\\Program Files\\Microsoft Visual Studio\\2022\\Community\\VC\\Tools\\MSVC\\14.30.30705\\bin\\Hostx64\\x64\\ml64.exe\" /nologo /c /Fo./src/asm/ontop_x86_64_ms_pe_masm.obj /Zd /Zi /I./src/asm /DBOOST_CONTEXT_EXPORT= ./src/asm/ontop_x86_64_ms_pe_masm.asm"

  else:
    echo "platform not supported"

task debugBuild, "build frag executable with debug symbols":
  exec "cl /DDEBUG /c /Zi /I.\\thirdparty\\cr /Fd.\\thirdparty\\cr.pdb /Fo.\\thirdparty\\crd.o .\\thirdparty\\cr.cpp"
  exec "lib /out:.\\thirdparty\\crd.lib C:\\Users\\Zach\\dev\\frag\\thirdparty\\crd.o"

task compileShaders, "compile shaders":
  exec "C:\\Users\\Zach\\dev\\frag\\thirdparty\\glslcc\\.build\\src\\Debug\\glslcc.exe -r -l hlsl --cvar=basic -o C:\\Users\\Zach\\dev\\frag\\src\\basic.nim --vert=C:\\Users\\Zach\\dev\\frag\\src\\basic.vert --frag=C:\\Users\\Zach\\dev\\frag\\src\\basic.frag"

task build3dPlugin, "build 3d plugin":
  exec "nim c --debugger:native --threads:on --app:lib --out:three_d.dll .\\src\\three_d_plugin.nim"