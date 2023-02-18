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
  exec "C:\\Users\\Zach\\dev\\frag\\thirdparty\\glslcc\\.build\\src\\Debug\\glslcc.exe -r -l hlsl --cvar=basic -o C:\\Users\\Zach\\dev\\frag\\src\\shaders\\basic.nim --vert=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\basic.vert --frag=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\basic.frag"
  exec "C:\\Users\\Zach\\dev\\frag\\thirdparty\\glslcc\\.build\\src\\Debug\\glslcc.exe -r -l hlsl --cvar=wire -o C:\\Users\\Zach\\dev\\frag\\src\\shaders\\wire.nim --vert=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\wire.vert --frag=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\wire.frag"
  exec "C:\\Users\\Zach\\dev\\frag\\thirdparty\\glslcc\\.build\\src\\Debug\\glslcc.exe -g -r -l hlsl --cvar=terrain -o C:\\Users\\Zach\\dev\\frag\\src\\shaders\\terrain.nim --vert=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\terrain.vert --frag=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\terrain.frag"
  exec "C:\\Users\\Zach\\dev\\frag\\thirdparty\\glslcc\\.build\\src\\Debug\\glslcc.exe -r -l hlsl --sgs -o C:\\Users\\Zach\\dev\\frag\\src\\shaders\\heightmap_terrain.sgs --vert=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\heightmap_terrain.vert --frag=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\heightmap_terrain.frag"
  exec "C:\\Users\\Zach\\dev\\frag\\thirdparty\\glslcc\\.build\\src\\Debug\\glslcc.exe -r -l hlsl --sgs -o C:\\Users\\Zach\\dev\\frag\\src\\shaders\\leb_init.sgs --compute=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\leb_init.comp"
  exec "C:\\Users\\Zach\\dev\\frag\\thirdparty\\glslcc\\.build\\src\\Debug\\glslcc.exe -r -l hlsl --sgs -o C:\\Users\\Zach\\dev\\frag\\src\\shaders\\leb_update.sgs --compute=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\leb_update.comp"
  exec "C:\\Users\\Zach\\dev\\frag\\thirdparty\\glslcc\\.build\\src\\Debug\\glslcc.exe -r -l hlsl --sgs -o C:\\Users\\Zach\\dev\\frag\\src\\shaders\\leb_update_draw.sgs --compute=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\leb_update_draw.comp"
  exec "C:\\Users\\Zach\\dev\\frag\\thirdparty\\glslcc\\.build\\src\\Debug\\glslcc.exe -r -l hlsl --sgs -o C:\\Users\\Zach\\dev\\frag\\src\\shaders\\leb_update_merge.sgs --compute=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\leb_update_merge.comp"
  exec "C:\\Users\\Zach\\dev\\frag\\thirdparty\\glslcc\\.build\\src\\Debug\\glslcc.exe -r -l hlsl --sgs -o C:\\Users\\Zach\\dev\\frag\\src\\shaders\\leb_update_split.sgs --compute=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\leb_update_split.comp"
  exec "C:\\Users\\Zach\\dev\\frag\\thirdparty\\glslcc\\.build\\src\\Debug\\glslcc.exe -r -l hlsl --sgs -o C:\\Users\\Zach\\dev\\frag\\src\\shaders\\cbt_sum_reduction.sgs --compute=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\cbt_sum_reduction.comp"
  exec "C:\\Users\\Zach\\dev\\frag\\thirdparty\\glslcc\\.build\\src\\Debug\\glslcc.exe -r -l hlsl --sgs -o C:\\Users\\Zach\\dev\\frag\\src\\shaders\\cbt_sum_reduction_prepass.sgs --compute=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\cbt_sum_reduction_prepass.comp"
  exec "C:\\Users\\Zach\\dev\\frag\\thirdparty\\glslcc\\.build\\src\\Debug\\glslcc.exe -r -l hlsl -o C:\\Users\\Zach\\dev\\frag\\src\\shaders\\terrain_render.hlsl --vert=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\terrain_render.vert --frag=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\terrain_render.frag"
  exec "C:\\Users\\Zach\\dev\\frag\\thirdparty\\glslcc\\.build\\src\\Debug\\glslcc.exe -r -l hlsl --sgs -o C:\\Users\\Zach\\dev\\frag\\src\\shaders\\terrain_render.sgs --vert=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\terrain_render.vert --frag=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\terrain_render.frag"
  exec "C:\\Users\\Zach\\dev\\frag\\thirdparty\\glslcc\\.build\\src\\Debug\\glslcc.exe -r -l hlsl --cvar=terrainRender -o C:\\Users\\Zach\\dev\\frag\\src\\shaders\\terrain_render.nim --vert=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\terrain_render.vert --frag=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\terrain_render.frag"
  exec "C:\\Users\\Zach\\dev\\frag\\thirdparty\\glslcc\\.build\\src\\Debug\\glslcc.exe -r -l hlsl --cvar=offscreen -o C:\\Users\\Zach\\dev\\frag\\src\\shaders\\offscreen.nim --vert=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\viewer.vert --frag=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\viewer.frag"

task build3dPlugin, "build 3d plugin":
  exec "nim c --debugger:native --threads:on --app:lib --out:three_d.dll .\\src\\three_d_plugin.nim"

task buildTerrainPlugin, "build terrain plugin":
  exec "nim c --debugger:native --threads:on --app:lib --out:terrain.dll .\\src\\terrain_plugin.nim"

task buildPlugins, "build plugins":
  exec "nim build3dPlugin"
  exec "nim buildTerrainPlugin"