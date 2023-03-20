import nuklear, sokol/app as sapp, sokol/gfx as sgfx,
       api, imgui, shaders/nuklear as nkshd, tnt

type
  ImguiVertex = object
    pos: array[2, float32]
    uv: array[2, float32]
    col: array[4, uint8]

  ImguiShaderUniforms = object
    dispSize: array[2, float32]
    pad8: array[8, uint8]

  ImguiContext = object
    nkCtx: nk_context
    atlas: nk_font_atlas
    vertexBufferSize: int
    indexBufferSize: int
    uniforms: ImguiShaderUniforms
    passAction: sgfx.PassAction
    shader: sgfx.Shader
    pip: sgfx.Pipeline
    bindings: sgfx.Bindings
    fontTex: sgfx.Image
    stage: GfxStage
    mousePos: array[2, int32]
    mouseDidMove: bool
    btnDown: array[ord(NK_BUTTON_MAX), bool]
    btnUp: array[ord(NK_BUTTON_MAX), bool]


var
  ctx {.fragState.}: ImguiContext

  pluginApi {.fragState.}: ptr PluginApi
  appApi {.fragState.}: ptr AppApi
  gfxApi {.fragState.}: ptr GfxApi

  imguiVertexLayout: VertexLayout
  cmds, verts, idx: nk_buffer

proc begin(title: cstring; bounds: nk_rect; flags: nk_flags): bool {.cdecl.} =
  result = bool(nk_begin(addr(ctx.nkCtx), title, bounds, flags))

proc finish() {.cdecl.} = 
  nk_end(addr(ctx.nkCtx))

proc layoutRow(fmt: nk_layout_format; height: float32; cols: int32; ratio: ptr float32) {.cdecl.} =
  nk_layout_row(addr(ctx.nkCtx), fmt, height, cols, ratio)

proc layoutRowDynamic(height: float32; cols: int32) {.cdecl.} =
  nk_layout_row_dynamic(addr(ctx.nkCtx), height, cols)

proc spacing(cols: int32) {.cdecl.} =
  nk_spacing(addr(ctx.nkCtx), cols)

proc label(str: cstring; alignment: nk_flags) {.cdecl.} =
  nk_label(addr(ctx.nkCtx), str, alignment)

proc buttonLabel(str: cstring): bool {.cdecl.} =
  result = bool(nk_button_label(addr(ctx.nkCtx), str))

proc buttonText(str: cstring; len: int32): bool {.cdecl.} =
  result = bool(nk_button_text(addr(ctx.nkCtx), str, len))

proc render() {.cdecl.} =
  if gfxApi.imm.begin(ctx.stage):
    gfxApi.imm.beginDefaultPass(
      addr(ctx.passAction), appApi.width(), appApi.height()
    )
    
    var vLayout {.global.} = [
      nk_draw_vertex_layout_element(attribute: NK_VERTEX_POSITION, format: NK_FORMAT_FLOAT, offset: nk_size(offsetOf(ImguiVertex, pos))),
      nk_draw_vertex_layout_element(attribute: NK_VERTEX_TEXCOORD, format: NK_FORMAT_FLOAT, offset: nk_size(offsetOf(ImguiVertex, uv))),
      nk_draw_vertex_layout_element(attribute: NK_VERTEX_COLOR, format: NK_FORMAT_R8G8B8A8, offset: nk_size(offsetOf(ImguiVertex, col))),
      nk_draw_vertex_layout_element(attribute: NK_VERTEX_ATTRIBUTE_COUNT, format: NK_FORMAT_COUNT, offset: 0)
    ]

    var cfg = nk_convert_config(
      shape_AA: NK_ANTI_ALIASING_ON,
      line_AA: NK_ANTI_ALIASING_ON,
      vertex_layout: addr(vLayout[0]),
      vertex_size: nk_size(sizeof(ImguiVertex)),
      vertex_alignment: 4,
      circle_segment_count: 22,
      curve_segment_count: 22,
      arc_segment_count: 22,
      global_alpha: 1.0'f32
    )

    ctx.uniforms.dispSize[0] = float32(appApi.width())
    ctx.uniforms.dispSize[1] = float32(appApi.height())

    nk_buffer_init_default(addr(cmds))
    nk_buffer_init_default(addr(verts))
    nk_buffer_init_default(addr(idx))
    discard nk_convert(addr(ctx.nkCtx), addr(cmds), addr(verts), addr(idx), addr(cfg))

    let
      vertexBufferOverflow = int(nk_buffer_total(addr(verts))) > ctx.vertexBufferSize
      indexBufferOverflow = int(nk_buffer_total(addr(idx))) > ctx.indexBufferSize

    assert(not vertexBufferOverflow and not indexBufferOverflow)
    if not vertexBufferOverflow and not indexBufferOverflow:
      let
        dpiScale = appApi.dpiScale()
        fbWidth = int32(ctx.uniforms.dispSize[0] * dpiScale)
        fbHeight = int32(ctx.uniforms.dispSize[1] * dpiScale)

      gfxApi.imm.applyViewport(0, 0, fbWidth, fbHeight, true)
      gfxApi.imm.applyScissorRect(0, 0, fbWidth, fbHeight, true)
      gfxApi.imm.applyPipeline(ctx.pip)
      gfxApi.imm.applyUniforms(shaderStageVs, 0'i32, addr(ctx.uniforms), int32(sizeof(ctx.uniforms)))
    
      var data: sgfx.Range
      data.size = int(nk_buffer_total(addr(verts)))
      data.`addr` = nk_buffer_memory_const(addr(verts))
      gfxApi.imm.updateBuffer(ctx.bindings.vertexBuffers[0], addr(data))
      
      data.size = int(nk_buffer_total(addr(idx)))
      data.`addr` = nk_buffer_memory_const(addr(idx))
      gfxApi.imm.updateBuffer(ctx.bindings.indexBuffer, addr(data))

      var 
        cmd = nk_draw_begin(addr(ctx.nkCtx), addr(cmds))
        idxOffset = 0'i32
      
      while cmd != nil:
        if cmd.elem_count > 0:
          if cmd.texture.id != 0:
            ctx.bindings.fsImages[0] = sgfx.Image(id: uint32(cmd.texture.id))
          else:
            ctx.bindings.fsImages[0] = ctx.fontTex
          
          ctx.bindings.vertexBufferOffsets[0] = 0
          ctx.bindings.indexBufferOffset = idxOffset
          gfxApi.imm.applyBindings(addr(ctx.bindings))
          gfxApi.imm.applyScissorRect(
            int32(cmd.clip_rect.x * dpiScale),
            int32(cmd.clip_rect.y * dpiScale),
            int32(cmd.clip_rect.w * dpiScale),
            int32(cmd.clip_rect.h * dpiScale),
            true
          )
          gfxApi.imm.draw(0, int32(cmd.elem_count), 1'i32)
          idxOffset += int32(cmd.elem_count) * int32(sizeof(uint16))
        cmd = nk_draw_next(cmd, addr(cmds), addr(ctx.nkCtx))
      gfxApi.imm.applyScissorRect(0, 0, fbWidth, fbHeight, true)

    nk_buffer_free(addr(cmds))
    nk_buffer_free(addr(verts))
    nk_buffer_free(addr(idx))

    gfxApi.imm.finishPass()
    gfxApi.imm.finish()

proc init() =
  let initRes = nk_init_default(addr(ctx.nkCtx), nil)
  assert(1 == initRes)

  var passAction: PassAction
  passAction.colors[0].action = actionLoad
  passAction.depth.action = actionDontCare
  passAction.stencil.action = actionDontCare

  imguiVertexLayout.attributes[0].semantic = "POSITION"
  imguiVertexLayout.attributes[1].semantic = "TEXCOORD"
  imguiVertexLayout.attributes[2].semantic = "COLOR"

  imguiVertexLayout.attributes[0].offset = int32(offsetOf(ImguiVertex, pos))
  imguiVertexLayout.attributes[1].offset = int32(offsetOf(ImguiVertex, uv))
  imguiVertexLayout.attributes[2].offset = int32(offsetOf(ImguiVertex, col))

  imguiVertexLayout.attributes[2].format = vertexFormatUbyte4n

  ctx.vertexBufferSize = sizeof(ImguiVertex) * 65536
  var desc = BufferDesc(
    `type`: bufferTypeVertexBuffer,
    usage: usageStream,
    size: ctx.vertexBufferSize,
    label: "imgui_vbuff"
  )
  ctx.bindings.vertexBuffers[0] = gfxApi.makeBuffer(addr(desc))

  ctx.indexBufferSize = sizeof(uint16) * 3 * 65536
  desc.`type` = bufferTypeIndexBuffer
  desc.size = ctx.indexBufferSize
  desc.label = "imgui_ibuff"
  ctx.bindings.indexBuffer = gfxApi.makeBuffer(addr(desc))

  nk_font_atlas_init_default(addr(ctx.atlas))
  nk_font_atlas_begin(addr(ctx.atlas))
  var fontWidth, fontHeight: int32
  let pixels = nk_font_atlas_bake(addr(ctx.atlas), addr(fontWidth), addr(fontHeight), NK_FONT_ATLAS_RGBA32)
  assert(fontWidth > 0 and fontHeight > 0)
  
  var imgDesc = sgfx.ImageDesc(
    width: fontWidth,
    height: fontHeight,
    pixelFormat: pixelFormatRgba8,
    wrapU: wrapClampToEdge,
    wrapV: wrapClampToEdge,
    minFilter: filterLinear,
    magFIlter: filterLinear,
    label: "sokol-nuklear-font"
  )
  imgDesc.data.subimage[0][0].`addr` = pixels
  imgDesc.data.subimage[0][0].size = fontWidth * fontHeight * sizeof(uint32)
  ctx.fontTex = gfxApi.makeImage(addr(imgDesc))
  nk_font_atlas_end(addr(ctx.atlas), nk_handle_id(int32(ctx.fontTex.id)), nil)
  nk_font_atlas_cleanup(addr(ctx.atlas))
  if ctx.atlas.default_font != nil:
    nk_style_set_font(addr(ctx.nkCtx), addr(ctx.atlas.default_font.handle))

  var shader = gfxApi.makeShaderWithData(
    nuklear_vs_size, cast[ptr UncheckedArray[uint32]](addr(nuklear_vs_data[0])), nuklear_vs_refl_size, cast[ptr UncheckedArray[uint32]](addr(nuklear_vs_refl_data[0])),
    nuklear_fs_size, cast[ptr UncheckedArray[uint32]](addr(nuklear_fs_data[0])), nuklear_fs_refl_size, cast[ptr UncheckedArray[uint32]](addr(nuklear_fs_refl_data[0]))
  )
  ctx.shader = shader.shd 

  var pipDesc = PipelineDesc(
    shader: ctx.shader,
    indexType: indexTypeUint16,
    label: "imgui"
  )
  pipDesc.layout.buffers[0].stride = int32(sizeof(ImguiVertex))
  pipDesc.colors[0].writeMask = colorMaskRgb
  pipDesc.colors[0].blend.enabled = true
  pipDesc.colors[0].blend.src_factor_rgb = blendFactorSrcAlpha
  pipDesc.colors[0].blend.dst_factor_rgb = blendFactorOneMinusSrcAlpha

  ctx.pip = gfxApi.makePipeline(
    gfxApi.bindShaderToPipeline(addr(shader), addr(pipDesc), addr(imguiVertexLayout))
  )

  ctx.stage = gfxApi.registerStage("imgui", GfxStage(id: 0))

proc frame() =
  nk_input_begin(addr(ctx.nkCtx))
  if ctx.mouseDidMove:
    nk_input_motion(addr(ctx.nkCtx), ctx.mousePos[0], ctx.mousePos[1])
    ctx.mouseDidMove = false
  for i in 0 ..< len(ctx.btnDown):
    if ctx.btnDown[i]:
      ctx.btnDown[i] = false
      nk_input_button(addr(ctx.nkCtx), nk_buttons(i), ctx.mousePos[0], ctx.mousePos[1], 1)
    elif ctx.btnUp[i]:
      ctx.btnUp[i] = false
      nk_input_button(addr(ctx.nkCtx), nk_buttons(i), ctx.mousePos[0], ctx.mousePos[1], 0)

  nk_clear(addr(ctx.nkCtx))
  
proc fragPluginEventHandler(e: ptr sapp.Event) {.cdecl, exportc, dynlib.} =
  case e.`type`:
  of eventTypeSuspended:
    discard
  of eventTypeRestored:
    discard
  of eventTypeMouseDown:
    ctx.mousePos[0] = int32(e.mouseX)
    ctx.mousePos[1] = int32(e.mouseY)
    case e.mouseButton:
    of mouseButtonLeft:
      ctx.btnDown[ord(NK_BUTTON_LEFT)] = true
    of mouseButtonRight:
      ctx.btnDown[ord(NK_BUTTON_RIGHT)] = true
    of mouseButtonMiddle:
      ctx.btnDown[ord(NK_BUTTON_MIDDLE)] = true
    else:
      discard
  of eventTypeMouseUp:
    ctx.mousePos[0] = int32(e.mouseX)
    ctx.mousePos[1] = int32(e.mouseY)
    case e.mouseButton:
    of mouseButtonLeft:
      ctx.btnUp[ord(NK_BUTTON_LEFT)] = true
    of mouseButtonRight:
      ctx.btnUp[ord(NK_BUTTON_RIGHT)] = true
    of mouseButtonMiddle:
      ctx.btnUp[ord(NK_BUTTON_MIDDLE)] = true
    else:
      discard
  of eventTypeMouseLeave:
    discard
  of eventTypeMouseMove:
    ctx.mousePos[0] = int32(e.mouseX)
    ctx.mousePos[1] = int32(e.mouseY)
    ctx.mouseDidMove = true
  else:
    discard

proc fragPlugin(plugin: ptr Plugin; operation: PluginOperation): int32 {.exportc,
    cdecl, dynlib.} =
  case operation:
  of poStep:
    frame()
  of poInit:
    pluginApi = plugin.api

    appApi = cast[ptr AppApi](pluginApi.getApi(atApp))
    gfxApi = cast[ptr GfxApi](pluginApi.getApi(atGfx))

    init()

    pluginApi.injectApi("imgui", 0, addr(imguiApi))
  else:
    discard

proc fragPluginInfo(info: ptr PluginInfo) {.cdecl, exportc, dynlib.} =
  info.name[0..31] = toOpenArray("imgui", 0, 31)
  info.desc[0..255] = toOpenArray("immediate mode graphical user interface plugin", 0, 255)

imguiApi = ImguiApi(
  begin: begin,
  finish: finish,
  layoutRow: layoutRow,
  layoutRowDynamic: layoutRowDynamic,
  spacing: spacing,
  label: label,
  buttonLabel: buttonLabel,
  buttonText: buttonText,
  render: render,
)
