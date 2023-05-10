{.link: "ozz.lib".}

import sokol/gfx as sgfx

type
  CreateVBufCb* = proc(p: ptr UncheckedArray[Vertex]; numVerts: uint) {.cdecl.}
  CreateIBufCb* = proc(p: ptr UncheckedArray[uint16]; numIndices: uint) {.cdecl.}

  Instance* = pointer

  Vertex* = object
    position*: array[3, float32]
    normal*: uint32
    jointIndices*: uint32
    jointWeights*: uint32
  
  Desc* = object
    maxPaletteJoints*: int32
    maxInstances*: int32
  
proc setup*(desc: ptr Desc) {.importc: "ozz_setup", cdecl.}
proc shutdown*() {.importc: "ozz_shutdown", cdecl.}
proc jointTexture*(): Image {.importc: "ozz_joint_texture", cdecl.}
proc jointUploadBuffer*(): ptr UncheckedArray[float32] {.importc: "ozz_joint_upload_buffer", cdecl.}
proc jointTexturePitch*(): int32 {.importc: "ozz_joint_texture_pitch", cdecl.}
proc jointTextureWidth*(): int32 {.importc: "ozz_joint_texture_width", cdecl.}
proc jointTextureHeight*(): int32 {.importc: "ozz_joint_texture_height", cdecl.}
proc jointTextureU*(ozz: ptr Instance): float32 {.importc: "ozz_joint_texture_u", cdecl.}
proc jointTextureV*(ozz: ptr Instance): float32 {.importc: "ozz_joint_texture_v", cdecl.}
proc createInstance*(idx: int32): ptr Instance {.importc: "ozz_create_instance", cdecl.}
proc destroyInstance*(ozz: ptr Instance) {.importc: "ozz_destroy_instance", cdecl.}
proc vertexBuffer*(ozz: ptr Instance): Buffer {.importc: "ozz_vertex_buffer", cdecl.}
proc indexBuffer*(ozz: ptr Instance): Buffer {.importc: "ozz_index_buffer", cdecl.}
proc allLoaded*(ozz: ptr Instance): bool {.importc: "ozz_all_loaded", cdecl.}
proc loadFailed*(ozz: ptr Instance): bool {.importc: "ozz_load_failed", cdecl.}
proc loadSkeleton*(ozz: ptr Instance; data: pointer; numBytes: uint) {.importc: "ozz_load_skeleton", cdecl.}
proc loadAnimation*(ozz: ptr Instance; data: pointer; numBytes: uint) {.importc: "ozz_load_animation", cdecl.}
proc loadMesh*(ozz: ptr Instance; data: pointer; numBytes: uint; createVBufCb: CreateVBufCb; createIBufCb: CreateIBufCb) {.importc: "ozz_load_mesh", cdecl.}
proc setLoadFailed*(ozz: ptr Instance) {.importc: "ozz_set_load_failed", cdecl.}
proc updateInstance*(ozz: ptr Instance; seconds: float64) {.importc: "ozz_update_instance", cdecl.}
proc updateJointTexture*() {.importc: "ozz_update_joint_texture", cdecl.}
proc joinTexturePixelWidth*(): float32 {.importc: "ozz_joint_texture_pixel_width", cdecl.}
proc joinTextureU*(ozz: ptr Instance): float32 {.importc: "ozz_joint_texture_u", cdecl.}
proc joinTextureV*(ozz: ptr Instance): float32 {.importc: "ozz_joint_texture_v", cdecl.}
proc numTriangleIndices*(ozz: ptr Instance): int32 {.importc: "ozz_num_triangle_indices", cdecl.}
