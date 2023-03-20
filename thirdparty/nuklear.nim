const
  NK_BUFFER_DEFAULT_INITIAL_SIZE = 4 * 1024

  nk_false* = 0
  nk_true* = 1

type
  nk_char* = char
  nk_uchar* = char
  nk_byte* = char
  nk_short* = int16
  nk_ushort* = uint16
  nk_int* = int32
  nk_uint* = uint32
  nk_size* = uint64
  nk_ptr* = uint64
  nk_bool* = cint
  nk_hash* = nk_uint
  nk_flags* = nk_uint
  nk_rune* = nk_uint
  dummy_array0* = array[if (sizeof((nk_short)) == 2): 1 else: -1, char]
  dummy_array1* = array[if (sizeof((nk_ushort)) == 2): 1 else: -1, char]
  dummy_array2* = array[if (sizeof((nk_uint)) == 4): 1 else: -1, char]
  dummy_array3* = array[if (sizeof((nk_int)) == 4): 1 else: -1, char]
  dummy_array4* = array[if (sizeof((nk_byte)) == 1): 1 else: -1, char]
  dummy_array5* = array[if (sizeof((nk_flags)) >= 4): 1 else: -1, char]
  dummy_array6* = array[if (sizeof((nk_rune)) >= 4): 1 else: -1, char]
  dummy_array7* = array[if (sizeof((nk_size)) >= sizeof(pointer)): 1 else: -1, char]
  dummy_array8* = array[if (sizeof((nk_ptr)) >= sizeof(pointer)): 1 else: -1, char]
  dummy_array9* = array[if (sizeof((nk_bool)) >= 2): 1 else: -1, char]

  nk_color* {.bycopy.} = object
    r*: nk_byte
    g*: nk_byte
    b*: nk_byte
    a*: nk_byte

  nk_colorf* {.bycopy.} = object
    r*: cfloat
    g*: cfloat
    b*: cfloat
    a*: cfloat

  nk_vec2* {.bycopy.} = object
    x*: cfloat
    y*: cfloat

  nk_vec2i* {.bycopy.} = object
    x*: cshort
    y*: cshort

  nk_rect* {.bycopy.} = object
    x*: cfloat
    y*: cfloat
    w*: cfloat
    h*: cfloat

  nk_recti* {.bycopy.} = object
    x*: cshort
    y*: cshort
    w*: cshort
    h*: cshort

  nk_glyph* = array[4, char]
  nk_handle* {.bycopy, union.} = object
    `ptr`*: pointer
    id*: cint

  nk_image* {.bycopy.} = object
    handle*: nk_handle
    w*: nk_ushort
    h*: nk_ushort
    region*: array[4, nk_ushort]

  nk_nine_slice* {.bycopy.} = object
    img*: nk_image
    l*: nk_ushort
    t*: nk_ushort
    r*: nk_ushort
    b*: nk_ushort

  nk_cursor* {.bycopy.} = object
    img*: nk_image
    size*: nk_vec2
    offset*: nk_vec2

  nk_scroll* {.bycopy.} = object
    x*: nk_uint
    y*: nk_uint

  nk_heading* {.size: sizeof(int32).} = enum
    NK_UP, NK_RIGHT, NK_DOWN, NK_LEFT

  nk_button_behavior* {.size: sizeof(int32).} = enum
    NK_BUTTON_DEFAULT, NK_BUTTON_REPEATER

  nk_modify* {.size: sizeof(int32).} = enum
    NK_FIXED = nk_false, NK_MODIFIABLE = nk_true

  nk_orientation* {.size: sizeof(int32).} = enum
    NK_VERTICAL, NK_HORIZONTAL

  nk_collapse_states* {.size: sizeof(int32).} = enum
    NK_MINIMIZED = nk_false, NK_MAXIMIZED = nk_true

  nk_show_states* {.size: sizeof(int32).} = enum
    NK_HIDDEN = nk_false, NK_SHOWN = nk_true

  nk_chart_type* {.size: sizeof(int32).} = enum
    NK_CHART_LINES, NK_CHART_COLUMN, NK_CHART_MAX

  nk_chart_event* {.size: sizeof(int32).} = enum
    NK_CHART_HOVERING = 0x01, NK_CHART_CLICKED = 0x02

  nk_color_format* {.size: sizeof(int32).} = enum
    NK_RGB, NK_RGBA

  nk_popup_type* {.size: sizeof(int32).} = enum
    NK_POPUP_STATIC, NK_POPUP_DYNAMIC

  nk_layout_format* {.size: sizeof(int32).} = enum
    NK_DYNAMIC, NK_STATIC

  nk_tree_type* {.size: sizeof(int32).} = enum
    NK_TREE_NODE, NK_TREE_TAB

  nk_plugin_alloc* = proc (a1: nk_handle; old: pointer; a3: nk_size): pointer {.cdecl.}
  nk_plugin_free* = proc (a1: nk_handle; old: pointer) {.cdecl.}
  nk_plugin_filter* = proc (a1: ptr nk_text_edit; unicode: nk_rune): nk_bool {.cdecl.}
  nk_plugin_paste* = proc (a1: nk_handle; a2: ptr nk_text_edit) {.cdecl.}
  nk_plugin_copy* = proc (a1: nk_handle; a2: cstring; len: cint) {.cdecl.}
  nk_allocator* {.bycopy.} = object
    userdata*: nk_handle
    alloc*: nk_plugin_alloc
    free*: nk_plugin_free

  nk_symbol_type* {.size: sizeof(int32).} = enum
    NK_SYMBOL_NONE, NK_SYMBOL_X, NK_SYMBOL_UNDERSCORE, NK_SYMBOL_CIRCLE_SOLID,
    NK_SYMBOL_CIRCLE_OUTLINE, NK_SYMBOL_RECT_SOLID, NK_SYMBOL_RECT_OUTLINE,
    NK_SYMBOL_TRIANGLE_UP, NK_SYMBOL_TRIANGLE_DOWN, NK_SYMBOL_TRIANGLE_LEFT,
    NK_SYMBOL_TRIANGLE_RIGHT, NK_SYMBOL_PLUS, NK_SYMBOL_MINUS, NK_SYMBOL_MAX

  nk_keys* {.size: sizeof(int32).} = enum
    NK_KEY_NONE, NK_KEY_SHIFT, NK_KEY_CTRL, NK_KEY_DEL, NK_KEY_ENTER, NK_KEY_TAB,
    NK_KEY_BACKSPACE, NK_KEY_COPY, NK_KEY_CUT, NK_KEY_PASTE, NK_KEY_UP, NK_KEY_DOWN,
    NK_KEY_LEFT, NK_KEY_RIGHT, NK_KEY_TEXT_INSERT_MODE, NK_KEY_TEXT_REPLACE_MODE,
    NK_KEY_TEXT_RESET_MODE, NK_KEY_TEXT_LINE_START, NK_KEY_TEXT_LINE_END,
    NK_KEY_TEXT_START, NK_KEY_TEXT_END, NK_KEY_TEXT_UNDO, NK_KEY_TEXT_REDO,
    NK_KEY_TEXT_SELECT_ALL, NK_KEY_TEXT_WORD_LEFT, NK_KEY_TEXT_WORD_RIGHT,
    NK_KEY_SCROLL_START, NK_KEY_SCROLL_END, NK_KEY_SCROLL_DOWN, NK_KEY_SCROLL_UP,
    NK_KEY_MAX

  nk_buttons* {.size: sizeof(int32).} = enum
    NK_BUTTON_LEFT, NK_BUTTON_MIDDLE, NK_BUTTON_RIGHT, NK_BUTTON_DOUBLE,
    NK_BUTTON_MAX

  nk_anti_aliasing* {.size: sizeof(int32).} = enum
    NK_ANTI_ALIASING_OFF, NK_ANTI_ALIASING_ON

  nk_convert_result* {.size: sizeof(int32).} = enum
    NK_CONVERT_SUCCESS = 0, NK_CONVERT_INVALID_PARAM = 1,
    NK_CONVERT_COMMAND_BUFFER_FULL = (1 shl (1)),
    NK_CONVERT_VERTEX_BUFFER_FULL = (1 shl (2)),
    NK_CONVERT_ELEMENT_BUFFER_FULL = (1 shl (3))

  nk_draw_vertex_layout_attribute* {.size: sizeof(int32).} = enum
    NK_VERTEX_POSITION,
    NK_VERTEX_COLOR,
    NK_VERTEX_TEXCOORD,
    NK_VERTEX_ATTRIBUTE_COUNT

  nk_draw_vertex_layout_format* {.size: sizeof(int32).} = enum
    NK_FORMAT_SCHAR,
    NK_FORMAT_SSHORT,
    NK_FORMAT_SINT,
    NK_FORMAT_UCHAR,
    NK_FORMAT_USHORT,
    NK_FORMAT_UINT,
    NK_FORMAT_FLOAT,
    NK_FORMAT_DOUBLE,

    NK_FORMAT_COLOR_BEGIN,
    NK_FORMAT_R16G15B16,
    NK_FORMAT_R32G32B32,

    NK_FORMAT_R8G8B8A8,
    NK_FORMAT_B8G8R8A8,
    NK_FORMAT_R16G15B16A16,
    NK_FORMAT_R32G32B32A32,
    NK_FORMAT_R32G32B32A32_FLOAT,
    NK_FORMAT_R32G32B32A32_DOUBLE,

    NK_FORMAT_RGB32,
    NK_FORMAT_RGBA32,
    NK_FORMAT_COUNT

  nk_draw_null_texture* {.bycopy.} = object
    texture*: nk_handle
    uv*: nk_vec2

  nk_draw_vertex_layout_element* {.bycopy.} = object
    attribute*: nk_draw_vertex_layout_attribute
    format*: nk_draw_vertex_layout_format
    offset*: nk_size

  nk_draw_command* {.bycopy.} = object
    elem_count*: uint32
    clip_rect*: nk_rect
    texture*: nk_handle

  nk_convert_config* {.bycopy.} = object
    global_alpha*: cfloat
    line_AA*: nk_anti_aliasing
    shape_AA*: nk_anti_aliasing
    circle_segment_count*: cuint
    arc_segment_count*: cuint
    curve_segment_count*: cuint
    tex_null*: nk_draw_null_texture
    vertex_layout*: ptr nk_draw_vertex_layout_element
    vertex_size*: nk_size
    vertex_alignment*: nk_size

  nk_panel_flags* {.size: sizeof(int32).} = enum
    NK_WINDOW_BORDER = (1 shl (0)), NK_WINDOW_MOVABLE = (1 shl (1)),
    NK_WINDOW_SCALABLE = (1 shl (2)), NK_WINDOW_CLOSABLE = (1 shl (3)),
    NK_WINDOW_MINIMIZABLE = (1 shl (4)), NK_WINDOW_NO_SCROLLBAR = (1 shl (5)),
    NK_WINDOW_TITLE = (1 shl (6)), NK_WINDOW_SCROLL_AUTO_HIDE = (1 shl (7)),
    NK_WINDOW_BACKGROUND = (1 shl (8)), NK_WINDOW_SCALE_LEFT = (1 shl (9)),
    NK_WINDOW_NO_INPUT = (1 shl (10))

  nk_list_view* {.bycopy.} = object
    begin*: cint
    `end`*: cint
    count*: cint
    total_height*: cint
    ctx*: ptr nk_context
    scroll_pointer*: ptr nk_uint
    scroll_value*: nk_uint

  nk_widget_layout_states* {.size: sizeof(int32).} = enum
    NK_WIDGET_INVALID, NK_WIDGET_VALID, NK_WIDGET_ROM

  nk_widget_states* {.size: sizeof(int32).} = enum
    NK_WIDGET_STATE_MODIFIED = (1 shl (1)), NK_WIDGET_STATE_INACTIVE = (1 shl (2)),
    NK_WIDGET_STATE_ENTERED = (1 shl (3)), NK_WIDGET_STATE_HOVER = (1 shl (4)),
    NK_WIDGET_STATE_ACTIVED = (1 shl (5)), NK_WIDGET_STATE_LEFT = (1 shl (6))

  nk_text_align* {.size: sizeof(int32).} = enum
    NK_TEXT_ALIGN_LEFT = 0x01, NK_TEXT_ALIGN_CENTERED = 0x02,
    NK_TEXT_ALIGN_RIGHT = 0x04, NK_TEXT_ALIGN_TOP = 0x08, NK_TEXT_ALIGN_MIDDLE = 0x10,
    NK_TEXT_ALIGN_BOTTOM = 0x20

  nk_text_alignment* {.size: sizeof(int32).} = enum
    NK_TEXT_LEFT = NK_TEXT_ALIGN_MIDDLE.ord or NK_TEXT_ALIGN_LEFT.ord,
    NK_TEXT_CENTERED = NK_TEXT_ALIGN_MIDDLE.ord or NK_TEXT_ALIGN_CENTERED.ord,
    NK_TEXT_RIGHT = NK_TEXT_ALIGN_MIDDLE.ord or NK_TEXT_ALIGN_RIGHT.ord

  nk_edit_flags* {.size: sizeof(int32).} = enum
    NK_EDIT_DEFAULT = 0, NK_EDIT_READ_ONLY = (1 shl (0)),
    NK_EDIT_AUTO_SELECT = (1 shl (1)), NK_EDIT_SIG_ENTER = (1 shl (2)),
    NK_EDIT_ALLOW_TAB = (1 shl (3)), NK_EDIT_NO_CURSOR = (1 shl (4)),
    NK_EDIT_SELECTABLE = (1 shl (5)), NK_EDIT_CLIPBOARD = (1 shl (6)),
    NK_EDIT_CTRL_ENTER_NEWLINE = (1 shl (7)),
    NK_EDIT_NO_HORIZONTAL_SCROLL = (1 shl (8)),
    NK_EDIT_ALWAYS_INSERT_MODE = (1 shl (9)), NK_EDIT_MULTILINE = (1 shl (10)),
    NK_EDIT_GOTO_END_ON_ACTIVATE = (1 shl (11))

  nk_edit_types* {.size: sizeof(int32).} = enum
    NK_EDIT_SIMPLE = NK_EDIT_ALWAYS_INSERT_MODE,
    NK_EDIT_FIELD = NK_EDIT_SIMPLE.ord or NK_EDIT_SELECTABLE.ord or NK_EDIT_CLIPBOARD.ord, NK_EDIT_BOX = NK_EDIT_ALWAYS_INSERT_MODE.ord or
        NK_EDIT_SELECTABLE.ord or NK_EDIT_MULTILINE.ord or NK_EDIT_ALLOW_TAB.ord or
        NK_EDIT_CLIPBOARD.ord

  nk_edit_events* {.size: sizeof(int32).} = enum
    NK_EDIT_ACTIVE = (1 shl (0)), NK_EDIT_INACTIVE = (1 shl (1)),
    NK_EDIT_ACTIVATED = (1 shl (2)), NK_EDIT_DEACTIVATED = (1 shl (3)),
    NK_EDIT_COMMITED = (1 shl (4))

  nk_style_colors* {.size: sizeof(int32).} = enum
    NK_COLOR_TEXT, NK_COLOR_WINDOW, NK_COLOR_HEADER, NK_COLOR_BORDER,
    NK_COLOR_BUTTON, NK_COLOR_BUTTON_HOVER, NK_COLOR_BUTTON_ACTIVE,
    NK_COLOR_TOGGLE, NK_COLOR_TOGGLE_HOVER, NK_COLOR_TOGGLE_CURSOR,
    NK_COLOR_SELECT, NK_COLOR_SELECT_ACTIVE, NK_COLOR_SLIDER,
    NK_COLOR_SLIDER_CURSOR, NK_COLOR_SLIDER_CURSOR_HOVER,
    NK_COLOR_SLIDER_CURSOR_ACTIVE, NK_COLOR_PROPERTY, NK_COLOR_EDIT,
    NK_COLOR_EDIT_CURSOR, NK_COLOR_COMBO, NK_COLOR_CHART, NK_COLOR_CHART_COLOR,
    NK_COLOR_CHART_COLOR_HIGHLIGHT, NK_COLOR_SCROLLBAR, NK_COLOR_SCROLLBAR_CURSOR,
    NK_COLOR_SCROLLBAR_CURSOR_HOVER, NK_COLOR_SCROLLBAR_CURSOR_ACTIVE,
    NK_COLOR_TAB_HEADER, NK_COLOR_COUNT

  nk_style_cursor* {.size: sizeof(int32).} = enum
    NK_CURSOR_ARROW, NK_CURSOR_TEXT, NK_CURSOR_MOVE, NK_CURSOR_RESIZE_VERTICAL,
    NK_CURSOR_RESIZE_HORIZONTAL, NK_CURSOR_RESIZE_TOP_LEFT_DOWN_RIGHT,
    NK_CURSOR_RESIZE_TOP_RIGHT_DOWN_LEFT, NK_CURSOR_COUNT

  nk_user_font_glyph* {.bycopy.} = object
    uv*: array[2, nk_vec2]
    offset*: nk_vec2
    width*, height*: float32
    xadvance*: float32

  nk_text_width_f* = proc (a1: nk_handle; h: cfloat; a3: cstring; len: cint): cfloat
  nk_query_font_glyph_f* = proc (handle: nk_handle; font_height: cfloat;
                              glyph: ptr nk_user_font_glyph; codepoint: nk_rune;
                              next_codepoint: nk_rune)
  
  nk_user_font* {.bycopy.} = object
    userdata*: nk_handle
    height*: cfloat
    width*: nk_text_width_f
    query*: nk_query_font_glyph_f
    texture*: nk_handle

  nk_font_coord_type* {.size: sizeof(int32).} = enum
    NK_COORD_UV
    NK_COORD_PIXEL
  
  nk_baked_font* {.bycopy.} = object
    height*: float32
    ascent*, descent*: float32
    glyph_offset*: nk_rune
    glyph_count*: nk_rune
    ranges*: ptr nk_rune
  
  nk_font_config* {.bycopy.} = object
    next*: ptr nk_font_config
    ttf_blob*: pointer
    ttf_size*: nk_size
    ttf_data_owned_by_atlas*: char
    merge_mode*: char
    pixel_snap*: char
    oversample_v*, oversample_h*: char
    padding*: array[3, char]

    size*: float32
    coord_type*: nk_font_coord_type
    spacing*: nk_vec2
    `range`*: ptr nk_rune
    font*: ptr nk_baked_font
    fallback_glyph*: nk_rune
    n*: ptr nk_font_config
    p*: ptr nk_font_config

  nk_font_glyph* {.bycopy.} = object
    codepoint*: nk_rune
    xadvance*: float32
    x0*, y0*, x1*, y1*, w*, h*: float32
    u0*, v0*, u1*, v1*: float32
  
  nk_font* {.bycopy.} = object
    next*: ptr nk_font
    handle*: nk_user_font
    info*: nk_baked_font
    scale*: float32
    glyphs*: ptr nk_font_glyph
    fallback*: ptr nk_font_glyph
    fallback_codepoint*: nk_rune
    texture*: nk_handle
    config*: ptr nk_font_config
  
  nk_font_atlas_format* {.size: sizeof(int32).} = enum 
    NK_FONT_ATLAS_ALPHA8
    NK_FONT_ATLAS_RGBA32
  
  nk_font_atlas* {.bycopy.} = object
    pixel*: pointer
    tex_width*: int32
    tex_height*: int32

    permanent*: nk_allocator
    temporary*: nk_allocator

    custom*: nk_recti
    cursors*: array[NK_CURSOR_COUNT, nk_cursor]

    glyph_count*: int32
    glyphs*: ptr nk_font_glyph
    default_font*: ptr nk_font
    fonts*: ptr nk_font
    config*: ptr nk_font_config
    font_num*: int32

  nk_memory_status* {.bycopy.} = object
    memory*: pointer
    `type`*: cuint
    size*: nk_size
    allocated*: nk_size
    needed*: nk_size
    calls*: nk_size

  nk_allocation_type* {.size: sizeof(int32).} = enum
    NK_BUFFER_FIXED, NK_BUFFER_DYNAMIC

  nk_buffer_allocation_type* {.size: sizeof(int32).} = enum
    NK_BUFFER_FRONT, NK_BUFFER_BACK, NK_BUFFER_MAX

  nk_buffer_marker* {.bycopy.} = object
    active*: nk_bool
    offset*: nk_size

  nk_memory* {.bycopy.} = object
    `ptr`*: pointer
    size*: nk_size

  nk_buffer* {.bycopy.} = object
    marker*: array[NK_BUFFER_MAX, nk_buffer_marker]
    pool*: nk_allocator
    `type`*: nk_allocation_type
    memory*: nk_memory
    grow_factor*: cfloat
    allocated*: nk_size
    needed*: nk_size
    calls*: nk_size
    size*: nk_size

  nk_str* {.bycopy.} = object
    buffer*: nk_buffer
    len*: cint

  nk_clipboard* {.bycopy.} = object
    userdata*: nk_handle
    paste*: nk_plugin_paste
    copy*: nk_plugin_copy

  nk_text_undo_record* {.bycopy.} = object
    where*: cint
    insert_length*: cshort
    delete_length*: cshort
    char_storage*: cshort

  nk_text_undo_state* {.bycopy.} = object
    undo_rec*: array[99, nk_text_undo_record]
    undo_char*: array[999, nk_rune]
    undo_point*: cshort
    redo_point*: cshort
    undo_char_point*: cshort
    redo_char_point*: cshort

  nk_text_edit_type* {.size: sizeof(int32).} = enum
    NK_TEXT_EDIT_SINGLE_LINE, NK_TEXT_EDIT_MULTI_LINE

  nk_text_edit_mode* {.size: sizeof(int32).} = enum
    NK_TEXT_EDIT_MODE_VIEW, NK_TEXT_EDIT_MODE_INSERT, NK_TEXT_EDIT_MODE_REPLACE

  nk_text_edit* {.bycopy.} = object
    clip*: nk_clipboard
    string*: nk_str
    filter*: nk_plugin_filter
    scrollbar*: nk_vec2
    cursor*: cint
    select_start*: cint
    select_end*: cint
    mode*: char
    cursor_at_end_of_line*: char
    initialized*: char
    has_preferred_x*: char
    single_line*: char
    active*: char
    padding1*: char
    preferred_x*: cfloat
    undo*: nk_text_undo_state

  nk_command_type* {.size: sizeof(int32).} = enum
    NK_COMMAND_NOP, NK_COMMAND_SCISSOR, NK_COMMAND_LINE, NK_COMMAND_CURVE,
    NK_COMMAND_RECT, NK_COMMAND_RECT_FILLED, NK_COMMAND_RECT_MULTI_COLOR,
    NK_COMMAND_CIRCLE, NK_COMMAND_CIRCLE_FILLED, NK_COMMAND_ARC,
    NK_COMMAND_ARC_FILLED, NK_COMMAND_TRIANGLE, NK_COMMAND_TRIANGLE_FILLED,
    NK_COMMAND_POLYGON, NK_COMMAND_POLYGON_FILLED, NK_COMMAND_POLYLINE,
    NK_COMMAND_TEXT, NK_COMMAND_IMAGE, NK_COMMAND_CUSTOM

  nk_command* {.bycopy.} = object
    `type`*: nk_command_type
    next*: nk_size

  nk_command_scissor* {.bycopy.} = object
    header*: nk_command
    x*: cshort
    y*: cshort
    w*: cushort
    h*: cushort

  nk_command_line* {.bycopy.} = object
    header*: nk_command
    line_thickness*: cushort
    begin*: nk_vec2i
    `end`*: nk_vec2i
    color*: nk_color

  nk_command_curve* {.bycopy.} = object
    header*: nk_command
    line_thickness*: cushort
    begin*: nk_vec2i
    `end`*: nk_vec2i
    ctrl*: array[2, nk_vec2i]
    color*: nk_color

  nk_command_rect* {.bycopy.} = object
    header*: nk_command
    rounding*: cushort
    line_thickness*: cushort
    x*: cshort
    y*: cshort
    w*: cushort
    h*: cushort
    color*: nk_color

  nk_command_rect_filled* {.bycopy.} = object
    header*: nk_command
    rounding*: cushort
    x*: cshort
    y*: cshort
    w*: cushort
    h*: cushort
    color*: nk_color

  nk_command_rect_multi_color* {.bycopy.} = object
    header*: nk_command
    x*: cshort
    y*: cshort
    w*: cushort
    h*: cushort
    left*: nk_color
    top*: nk_color
    bottom*: nk_color
    right*: nk_color

  nk_command_triangle* {.bycopy.} = object
    header*: nk_command
    line_thickness*: cushort
    a*: nk_vec2i
    b*: nk_vec2i
    c*: nk_vec2i
    color*: nk_color

  nk_command_triangle_filled* {.bycopy.} = object
    header*: nk_command
    a*: nk_vec2i
    b*: nk_vec2i
    c*: nk_vec2i
    color*: nk_color

  nk_command_circle* {.bycopy.} = object
    header*: nk_command
    x*: cshort
    y*: cshort
    line_thickness*: cushort
    w*: cushort
    h*: cushort
    color*: nk_color

  nk_command_circle_filled* {.bycopy.} = object
    header*: nk_command
    x*: cshort
    y*: cshort
    w*: cushort
    h*: cushort
    color*: nk_color

  nk_command_arc* {.bycopy.} = object
    header*: nk_command
    cx*: cshort
    cy*: cshort
    r*: cushort
    line_thickness*: cushort
    a*: array[2, cfloat]
    color*: nk_color

  nk_command_arc_filled* {.bycopy.} = object
    header*: nk_command
    cx*: cshort
    cy*: cshort
    r*: cushort
    a*: array[2, cfloat]
    color*: nk_color

  nk_command_polygon* {.bycopy.} = object
    header*: nk_command
    color*: nk_color
    line_thickness*: cushort
    point_count*: cushort
    points*: array[1, nk_vec2i]

  nk_command_polygon_filled* {.bycopy.} = object
    header*: nk_command
    color*: nk_color
    point_count*: cushort
    points*: array[1, nk_vec2i]

  nk_command_polyline* {.bycopy.} = object
    header*: nk_command
    color*: nk_color
    line_thickness*: cushort
    point_count*: cushort
    points*: array[1, nk_vec2i]

  nk_command_image* {.bycopy.} = object
    header*: nk_command
    x*: cshort
    y*: cshort
    w*: cushort
    h*: cushort
    img*: nk_image
    col*: nk_color

  nk_command_custom_callback* = proc (canvas: pointer; x: cshort; y: cshort; w: cushort;
                                   h: cushort; callback_data: nk_handle)
  nk_command_custom* {.bycopy.} = object
    header*: nk_command
    x*: cshort
    y*: cshort
    w*: cushort
    h*: cushort
    callback_data*: nk_handle
    callback*: nk_command_custom_callback

  nk_command_text* {.bycopy.} = object
    header*: nk_command
    font*: ptr nk_user_font
    background*: nk_color
    foreground*: nk_color
    x*: cshort
    y*: cshort
    w*: cushort
    h*: cushort
    height*: cfloat
    length*: cint
    string*: array[1, char]

  nk_command_clipping* {.size: sizeof(int32).} = enum
    NK_CLIPPING_OFF = nk_false, NK_CLIPPING_ON = nk_true

  nk_command_buffer* {.bycopy.} = object
    base*: ptr nk_buffer
    clip*: nk_rect
    use_clipping*: cint
    userdata*: nk_handle
    begin*: nk_size
    `end`*: nk_size
    last*: nk_size

  nk_mouse_button* {.bycopy.} = object
    down*: nk_bool
    clicked*: cuint
    clicked_pos*: nk_vec2

  nk_mouse* {.bycopy.} = object
    buttons*: array[NK_BUTTON_MAX, nk_mouse_button]
    pos*: nk_vec2
    prev*: nk_vec2
    delta*: nk_vec2
    scroll_delta*: nk_vec2
    grab*: char
    grabbed*: char
    ungrab*: char

  nk_key* {.bycopy.} = object
    down*: nk_bool
    clicked*: cuint

  nk_keyboard* {.bycopy.} = object
    keys*: array[NK_KEY_MAX, nk_key]
    text*: array[16, char]
    text_len*: cint

  nk_input* {.bycopy.} = object
    keyboard*: nk_keyboard
    mouse*: nk_mouse

  nk_style_item_type* {.size: sizeof(int32).} = enum
    NK_STYLE_ITEM_COLOR, NK_STYLE_ITEM_IMAGE, NK_STYLE_ITEM_NINE_SLICE

  nk_style_item_data* {.bycopy, union.} = object
    color*: nk_color
    image*: nk_image
    slice*: nk_nine_slice

  nk_style_item* {.bycopy.} = object
    `type`*: nk_style_item_type
    data*: nk_style_item_data

  nk_style_text* {.bycopy.} = object
    color*: nk_color
    padding*: nk_vec2

  nk_style_button* {.bycopy.} = object
    normal*: nk_style_item
    hover*: nk_style_item
    active*: nk_style_item
    border_color*: nk_color
    text_background*: nk_color
    text_normal*: nk_color
    text_hover*: nk_color
    text_active*: nk_color
    text_alignment*: nk_flags
    border*: cfloat
    rounding*: cfloat
    padding*: nk_vec2
    image_padding*: nk_vec2
    touch_padding*: nk_vec2
    userdata*: nk_handle
    draw_begin*: proc (a1: ptr nk_command_buffer; userdata: nk_handle)
    draw_end*: proc (a1: ptr nk_command_buffer; userdata: nk_handle)

  nk_style_toggle* {.bycopy.} = object
    normal*: nk_style_item
    hover*: nk_style_item
    active*: nk_style_item
    border_color*: nk_color
    cursor_normal*: nk_style_item
    cursor_hover*: nk_style_item
    text_normal*: nk_color
    text_hover*: nk_color
    text_active*: nk_color
    text_background*: nk_color
    text_alignment*: nk_flags
    padding*: nk_vec2
    touch_padding*: nk_vec2
    spacing*: cfloat
    border*: cfloat
    userdata*: nk_handle
    draw_begin*: proc (a1: ptr nk_command_buffer; a2: nk_handle)
    draw_end*: proc (a1: ptr nk_command_buffer; a2: nk_handle)

  nk_style_selectable* {.bycopy.} = object
    normal*: nk_style_item
    hover*: nk_style_item
    pressed*: nk_style_item
    normal_active*: nk_style_item
    hover_active*: nk_style_item
    pressed_active*: nk_style_item
    text_normal*: nk_color
    text_hover*: nk_color
    text_pressed*: nk_color
    text_normal_active*: nk_color
    text_hover_active*: nk_color
    text_pressed_active*: nk_color
    text_background*: nk_color
    text_alignment*: nk_flags
    rounding*: cfloat
    padding*: nk_vec2
    touch_padding*: nk_vec2
    image_padding*: nk_vec2
    userdata*: nk_handle
    draw_begin*: proc (a1: ptr nk_command_buffer; a2: nk_handle)
    draw_end*: proc (a1: ptr nk_command_buffer; a2: nk_handle)

  nk_style_slider* {.bycopy.} = object
    normal*: nk_style_item
    hover*: nk_style_item
    active*: nk_style_item
    border_color*: nk_color
    bar_normal*: nk_color
    bar_hover*: nk_color
    bar_active*: nk_color
    bar_filled*: nk_color
    cursor_normal*: nk_style_item
    cursor_hover*: nk_style_item
    cursor_active*: nk_style_item
    border*: cfloat
    rounding*: cfloat
    bar_height*: cfloat
    padding*: nk_vec2
    spacing*: nk_vec2
    cursor_size*: nk_vec2
    show_buttons*: cint
    inc_button*: nk_style_button
    dec_button*: nk_style_button
    inc_symbol*: nk_symbol_type
    dec_symbol*: nk_symbol_type
    userdata*: nk_handle
    draw_begin*: proc (a1: ptr nk_command_buffer; a2: nk_handle)
    draw_end*: proc (a1: ptr nk_command_buffer; a2: nk_handle)

  nk_style_progress* {.bycopy.} = object
    normal*: nk_style_item
    hover*: nk_style_item
    active*: nk_style_item
    border_color*: nk_color
    cursor_normal*: nk_style_item
    cursor_hover*: nk_style_item
    cursor_active*: nk_style_item
    cursor_border_color*: nk_color
    rounding*: cfloat
    border*: cfloat
    cursor_border*: cfloat
    cursor_rounding*: cfloat
    padding*: nk_vec2
    userdata*: nk_handle
    draw_begin*: proc (a1: ptr nk_command_buffer; a2: nk_handle)
    draw_end*: proc (a1: ptr nk_command_buffer; a2: nk_handle)

  nk_style_scrollbar* {.bycopy.} = object
    normal*: nk_style_item
    hover*: nk_style_item
    active*: nk_style_item
    border_color*: nk_color
    cursor_normal*: nk_style_item
    cursor_hover*: nk_style_item
    cursor_active*: nk_style_item
    cursor_border_color*: nk_color
    border*: cfloat
    rounding*: cfloat
    border_cursor*: cfloat
    rounding_cursor*: cfloat
    padding*: nk_vec2
    show_buttons*: cint
    inc_button*: nk_style_button
    dec_button*: nk_style_button
    inc_symbol*: nk_symbol_type
    dec_symbol*: nk_symbol_type
    userdata*: nk_handle
    draw_begin*: proc (a1: ptr nk_command_buffer; a2: nk_handle)
    draw_end*: proc (a1: ptr nk_command_buffer; a2: nk_handle)

  nk_style_edit* {.bycopy.} = object
    normal*: nk_style_item
    hover*: nk_style_item
    active*: nk_style_item
    border_color*: nk_color
    scrollbar*: nk_style_scrollbar
    cursor_normal*: nk_color
    cursor_hover*: nk_color
    cursor_text_normal*: nk_color
    cursor_text_hover*: nk_color
    text_normal*: nk_color
    text_hover*: nk_color
    text_active*: nk_color
    selected_normal*: nk_color
    selected_hover*: nk_color
    selected_text_normal*: nk_color
    selected_text_hover*: nk_color
    border*: cfloat
    rounding*: cfloat
    cursor_size*: cfloat
    scrollbar_size*: nk_vec2
    padding*: nk_vec2
    row_padding*: cfloat

  nk_style_property* {.bycopy.} = object
    normal*: nk_style_item
    hover*: nk_style_item
    active*: nk_style_item
    border_color*: nk_color
    label_normal*: nk_color
    label_hover*: nk_color
    label_active*: nk_color
    sym_left*: nk_symbol_type
    sym_right*: nk_symbol_type
    border*: cfloat
    rounding*: cfloat
    padding*: nk_vec2
    edit*: nk_style_edit
    inc_button*: nk_style_button
    dec_button*: nk_style_button
    userdata*: nk_handle
    draw_begin*: proc (a1: ptr nk_command_buffer; a2: nk_handle)
    draw_end*: proc (a1: ptr nk_command_buffer; a2: nk_handle)

  nk_style_chart* {.bycopy.} = object
    background*: nk_style_item
    border_color*: nk_color
    selected_color*: nk_color
    color*: nk_color
    border*: cfloat
    rounding*: cfloat
    padding*: nk_vec2

  nk_style_combo* {.bycopy.} = object
    normal*: nk_style_item
    hover*: nk_style_item
    active*: nk_style_item
    border_color*: nk_color
    label_normal*: nk_color
    label_hover*: nk_color
    label_active*: nk_color
    symbol_normal*: nk_color
    symbol_hover*: nk_color
    symbol_active*: nk_color
    button*: nk_style_button
    sym_normal*: nk_symbol_type
    sym_hover*: nk_symbol_type
    sym_active*: nk_symbol_type
    border*: cfloat
    rounding*: cfloat
    content_padding*: nk_vec2
    button_padding*: nk_vec2
    spacing*: nk_vec2

  nk_style_tab* {.bycopy.} = object
    background*: nk_style_item
    border_color*: nk_color
    text*: nk_color
    tab_maximize_button*: nk_style_button
    tab_minimize_button*: nk_style_button
    node_maximize_button*: nk_style_button
    node_minimize_button*: nk_style_button
    sym_minimize*: nk_symbol_type
    sym_maximize*: nk_symbol_type
    border*: cfloat
    rounding*: cfloat
    indent*: cfloat
    padding*: nk_vec2
    spacing*: nk_vec2

  nk_style_header_align* {.size: sizeof(int32).} = enum
    NK_HEADER_LEFT, NK_HEADER_RIGHT

  nk_style_window_header* {.bycopy.} = object
    normal*: nk_style_item
    hover*: nk_style_item
    active*: nk_style_item
    close_button*: nk_style_button
    minimize_button*: nk_style_button
    close_symbol*: nk_symbol_type
    minimize_symbol*: nk_symbol_type
    maximize_symbol*: nk_symbol_type
    label_normal*: nk_color
    label_hover*: nk_color
    label_active*: nk_color
    align*: nk_style_header_align
    padding*: nk_vec2
    label_padding*: nk_vec2
    spacing*: nk_vec2

  nk_style_window* {.bycopy.} = object
    header*: nk_style_window_header
    fixed_background*: nk_style_item
    background*: nk_color
    border_color*: nk_color
    popup_border_color*: nk_color
    combo_border_color*: nk_color
    contextual_border_color*: nk_color
    menu_border_color*: nk_color
    group_border_color*: nk_color
    tooltip_border_color*: nk_color
    scaler*: nk_style_item
    border*: cfloat
    combo_border*: cfloat
    contextual_border*: cfloat
    menu_border*: cfloat
    group_border*: cfloat
    tooltip_border*: cfloat
    popup_border*: cfloat
    min_row_height_padding*: cfloat
    rounding*: cfloat
    spacing*: nk_vec2
    scrollbar_size*: nk_vec2
    min_size*: nk_vec2
    padding*: nk_vec2
    group_padding*: nk_vec2
    popup_padding*: nk_vec2
    combo_padding*: nk_vec2
    contextual_padding*: nk_vec2
    menu_padding*: nk_vec2
    tooltip_padding*: nk_vec2

  nk_style* {.bycopy.} = object
    font*: ptr nk_user_font
    cursors*: array[NK_CURSOR_COUNT, ptr nk_cursor]
    cursor_active*: ptr nk_cursor
    cursor_last*: ptr nk_cursor
    cursor_visible*: cint
    text*: nk_style_text
    button*: nk_style_button
    contextual_button*: nk_style_button
    menu_button*: nk_style_button
    option*: nk_style_toggle
    checkbox*: nk_style_toggle
    selectable*: nk_style_selectable
    slider*: nk_style_slider
    progress*: nk_style_progress
    property*: nk_style_property
    edit*: nk_style_edit
    chart*: nk_style_chart
    scrollh*: nk_style_scrollbar
    scrollv*: nk_style_scrollbar
    tab*: nk_style_tab
    combo*: nk_style_combo
    window*: nk_style_window

  nk_panel_type* {.size: sizeof(int32).} = enum
    NK_PANEL_NONE = 0, NK_PANEL_WINDOW = (1 shl (0)), NK_PANEL_GROUP = (1 shl (1)),
    NK_PANEL_POPUP = (1 shl (2)), NK_PANEL_CONTEXTUAL = (1 shl (4)),
    NK_PANEL_COMBO = (1 shl (5)), NK_PANEL_MENU = (1 shl (6)),
    NK_PANEL_TOOLTIP = (1 shl (7))

  nk_panel_set* {.size: sizeof(int32).} = enum
    NK_PANEL_SET_NONBLOCK = NK_PANEL_CONTEXTUAL.ord or NK_PANEL_COMBO.ord or NK_PANEL_MENU.ord or
        NK_PANEL_TOOLTIP.ord,
    NK_PANEL_SET_POPUP = NK_PANEL_SET_NONBLOCK.ord or NK_PANEL_POPUP.ord,
    NK_PANEL_SET_SUB = NK_PANEL_SET_POPUP.ord or NK_PANEL_GROUP.ord

  nk_chart_slot* {.bycopy.} = object
    `type`*: nk_chart_type
    color*: nk_color
    highlight*: nk_color
    min*: cfloat
    max*: cfloat
    range*: cfloat
    count*: cint
    last*: nk_vec2
    index*: cint

  nk_chart* {.bycopy.} = object
    slot*: cint
    x*: cfloat
    y*: cfloat
    w*: cfloat
    h*: cfloat
    slots*: array[4, nk_chart_slot]

  nk_panel_row_layout_type* {.size: sizeof(int32).} = enum
    NK_LAYOUT_DYNAMIC_FIXED = 0, NK_LAYOUT_DYNAMIC_ROW, NK_LAYOUT_DYNAMIC_FREE,
    NK_LAYOUT_DYNAMIC, NK_LAYOUT_STATIC_FIXED, NK_LAYOUT_STATIC_ROW,
    NK_LAYOUT_STATIC_FREE, NK_LAYOUT_STATIC, NK_LAYOUT_TEMPLATE, NK_LAYOUT_COUNT

  nk_row_layout* {.bycopy.} = object
    `type`*: nk_panel_row_layout_type
    index*: cint
    height*: cfloat
    min_height*: cfloat
    columns*: cint
    ratio*: ptr cfloat
    item_width*: cfloat
    item_height*: cfloat
    item_offset*: cfloat
    filled*: cfloat
    item*: nk_rect
    tree_depth*: cint
    templates*: array[16, cfloat]

  nk_popup_buffer* {.bycopy.} = object
    begin*: nk_size
    parent*: nk_size
    last*: nk_size
    `end`*: nk_size
    active*: nk_bool

  nk_menu_state* {.bycopy.} = object
    x*: cfloat
    y*: cfloat
    w*: cfloat
    h*: cfloat
    offset*: nk_scroll

  nk_panel* {.bycopy.} = object
    `type`*: nk_panel_type
    flags*: nk_flags
    bounds*: nk_rect
    offset_x*: ptr nk_uint
    offset_y*: ptr nk_uint
    at_x*: cfloat
    at_y*: cfloat
    max_x*: cfloat
    footer_height*: cfloat
    header_height*: cfloat
    border*: cfloat
    has_scrolling*: cuint
    clip*: nk_rect
    menu*: nk_menu_state
    row*: nk_row_layout
    chart*: nk_chart
    buffer*: ptr nk_command_buffer
    parent*: ptr nk_panel

  nk_window_flags* {.size: sizeof(int32).} = enum
    NK_WINDOW_PRIVATE = (1 shl (11)), NK_WINDOW_ROM = (1 shl (12)),
    NK_WINDOW_NOT_INTERACTIVE = NK_WINDOW_ROM.ord or NK_WINDOW_NO_INPUT.ord,
    NK_WINDOW_HIDDEN = (1 shl (13)), NK_WINDOW_CLOSED = (1 shl (14)),
    NK_WINDOW_MINIMIZED = (1 shl (15)), NK_WINDOW_REMOVE_ROM = (1 shl (16))

  nk_popup_state* {.bycopy.} = object
    win*: ptr nk_window
    `type`*: nk_panel_type
    buf*: nk_popup_buffer
    name*: nk_hash
    active*: nk_bool
    combo_count*: cuint
    con_count*: cuint
    con_old*: cuint
    active_con*: cuint
    header*: nk_rect

  nk_edit_state* {.bycopy.} = object
    name*: nk_hash
    seq*: cuint
    old*: cuint
    active*: cint
    prev*: cint
    cursor*: cint
    sel_start*: cint
    sel_end*: cint
    scrollbar*: nk_scroll
    mode*: char
    single_line*: char

  nk_property_state* {.bycopy.} = object
    active*: cint
    prev*: cint
    buffer*: array[64, char]
    length*: cint
    cursor*: cint
    select_start*: cint
    select_end*: cint
    name*: nk_hash
    seq*: cuint
    old*: cuint
    state*: cint

  nk_window* {.bycopy.} = object
    seq*: cuint
    name*: nk_hash
    name_string*: array[64, char]
    flags*: nk_flags
    bounds*: nk_rect
    scrollbar*: nk_scroll
    buffer*: nk_command_buffer
    layout*: ptr nk_panel
    scrollbar_hiding_timer*: cfloat
    property*: nk_property_state
    popup*: nk_popup_state
    edit*: nk_edit_state
    scrolled*: cuint
    tables*: ptr nk_table
    table_count*: cuint
    next*: ptr nk_window
    prev*: ptr nk_window
    parent*: ptr nk_window

  nk_config_stack_style_item_element* {.bycopy.} = object
    address*: ptr nk_style_item
    old_value*: nk_style_item

  nk_config_stack_float_element* {.bycopy.} = object
    address*: ptr cfloat
    old_value*: cfloat

  nk_config_stack_vec2_element* {.bycopy.} = object
    address*: ptr nk_vec2
    old_value*: nk_vec2

  nk_config_stack_flags_element* {.bycopy.} = object
    address*: ptr nk_flags
    old_value*: nk_flags

  nk_config_stack_color_element* {.bycopy.} = object
    address*: ptr nk_color
    old_value*: nk_color

  nk_config_stack_user_font_element* {.bycopy.} = object
    address*: ptr ptr nk_user_font
    old_value*: ptr nk_user_font

  nk_config_stack_button_behavior_element* {.bycopy.} = object
    address*: ptr nk_button_behavior
    old_value*: nk_button_behavior

  nk_config_stack_style_item* {.bycopy.} = object
    head*: cint
    elements*: array[16, nk_config_stack_style_item_element]

  nk_config_stack_float* {.bycopy.} = object
    head*: cint
    elements*: array[32, nk_config_stack_float_element]

  nk_config_stack_vec2* {.bycopy.} = object
    head*: cint
    elements*: array[16, nk_config_stack_vec2_element]

  nk_config_stack_flags* {.bycopy.} = object
    head*: cint
    elements*: array[32, nk_config_stack_flags_element]

  nk_config_stack_color* {.bycopy.} = object
    head*: cint
    elements*: array[32, nk_config_stack_color_element]

  nk_config_stack_user_font* {.bycopy.} = object
    head*: cint
    elements*: array[8, nk_config_stack_user_font_element]

  nk_config_stack_button_behavior* {.bycopy.} = object
    head*: cint
    elements*: array[8, nk_config_stack_button_behavior_element]

  nk_configuration_stacks* {.bycopy.} = object
    style_items*: nk_config_stack_style_item
    floats*: nk_config_stack_float
    vectors*: nk_config_stack_vec2
    flags*: nk_config_stack_flags
    colors*: nk_config_stack_color
    fonts*: nk_config_stack_user_font
    button_behaviors*: nk_config_stack_button_behavior

  nk_table* {.bycopy.} = object
    seq*: cuint
    size*: cuint
    keys*: array[((((if (sizeof(nk_window)) < (sizeof(nk_panel)): (sizeof(nk_panel)) else: (
        sizeof(nk_window))) div sizeof((nk_uint)))) div 2), nk_hash]
    values*: array[((((if (sizeof(nk_window)) < (sizeof(nk_panel)): (sizeof(nk_panel)) else: (
        sizeof(nk_window))) div sizeof((nk_uint)))) div 2), nk_uint]
    next*: ptr nk_table
    prev*: ptr nk_table

  nk_page_data* {.bycopy, union.} = object
    tbl*: nk_table
    pan*: nk_panel
    win*: nk_window

  nk_page_element* {.bycopy.} = object
    data*: nk_page_data
    next*: ptr nk_page_element
    prev*: ptr nk_page_element

  nk_page* {.bycopy.} = object
    size*: cuint
    next*: ptr nk_page
    win*: array[1, nk_page_element]

  nk_pool* {.bycopy.} = object
    alloc*: nk_allocator
    `type`*: nk_allocation_type
    page_count*: cuint
    pages*: ptr nk_page
    freelist*: ptr nk_page_element
    capacity*: cuint
    size*: nk_size
    cap*: nk_size
  
  nk_draw_list* {.bycopy.} = object
    clip_rect*: nk_rect
    circle_vtx*: array[12, nk_vec2]
    config*: nk_convert_config
    buffer*: ptr nk_buffer
    vertices*: ptr nk_buffer
    elements*: ptr nk_buffer
    element_count*: uint32
    vertex_count*: uint32
    cmd_count*: uint32
    cmd_offset*: nk_size
    path_count*: uint32
    path_offset*: uint32
    line_AA*: nk_anti_aliasing
    shape_AA*: nk_anti_aliasing

  nk_context* {.bycopy.} = object
    input*: nk_input
    style*: nk_style
    memory*: nk_buffer
    clip*: nk_clipboard
    last_widget_state*: nk_flags
    button_behavior*: nk_button_behavior
    stacks*: nk_configuration_stacks
    delta_time_seconds*: cfloat
    draw_list*: nk_draw_list
    text_edit*: nk_text_edit
    overlay*: nk_command_buffer
    build*: cint
    use_pool*: cint
    pool*: nk_pool
    begin*: ptr nk_window
    `end`*: ptr nk_window
    active*: ptr nk_window
    current*: ptr nk_window
    freelist*: ptr nk_page_element
    count*: cuint
    seq*: cuint

const
  NK_WINDOW_DYNAMIC* = NK_WINDOW_PRIVATE

  NK_FORMAT_R8G8B8* = NK_FORMAT_COLOR_BEGIN
  NK_FORMAT_COLOR_END* = NK_FORMAT_RGBA32

  NK_WIDGET_STATE_ACTIVE* = NK_WIDGET_STATE_ACTIVED.ord or
        NK_WIDGET_STATE_MODIFIED.ord
  
  NK_WIDGET_STATE_HOVERED* = NK_WIDGET_STATE_HOVER.ord or
        NK_WIDGET_STATE_MODIFIED.ord
  
  NK_EDIT_EDITOR* = NK_EDIT_SELECTABLE.ord or
        NK_EDIT_MULTILINE.ord or NK_EDIT_ALLOW_TAB.ord or NK_EDIT_CLIPBOARD.ord

proc nk_malloc(unused: nk_handle; old: pointer; size: nk_size): pointer {.cdecl.} =
  result = allocShared(size)

proc nk_mfree(unused: nk_handle; p: pointer) {.cdecl.} =
  deallocShared(p)

proc nk_style_item_color*(a1: nk_color): nk_style_item {.cdecl, importc.}
proc nk_style_item_image*(img: nk_image): nk_style_item {.cdecl, importc.}
proc nk_style_item_nine_slice*(slice: nk_nine_slice): nk_style_item {.cdecl, importc.}
proc nk_style_item_hide*(): nk_style_item {.cdecl, importc.}
proc nk_init_fixed*(a1: ptr nk_context; memory: pointer; size: nk_size; a4: ptr nk_user_font): nk_bool {.cdecl, importc.}
proc nk_init*(a1: ptr nk_context; a2: ptr nk_allocator; a3: ptr nk_user_font): nk_bool {.cdecl, importc.}
proc nk_init_default*(ctx: ptr nk_context; font: ptr nk_user_font): nk_bool {.cdecl, importc.}
  # var alloc: nk_allocator
  # alloc.userdata.`ptr` = nil
  # alloc.alloc = nk_malloc
  # alloc.free = nk_mfree
  # result = nk_init(ctx, addr(alloc), font)
proc nk_init_custom*(a1: ptr nk_context; cmds: ptr nk_buffer; pool: ptr nk_buffer; a4: ptr nk_user_font): nk_bool {.cdecl, importc.}
proc nk_clear*(a1: ptr nk_context) {.cdecl, importc.}
proc nk_free*(a1: ptr nk_context) {.cdecl, importc.}
proc nk_input_begin*(a1: ptr nk_context) {.cdecl, importc.}
proc nk_input_motion*(a1: ptr nk_context; x: cint; y: cint) {.cdecl, importc.}
proc nk_input_key*(a1: ptr nk_context; a2: nk_keys; down: nk_bool) {.cdecl, importc.}
proc nk_input_button*(a1: ptr nk_context; a2: nk_buttons; x: cint; y: cint; down: nk_bool) {.cdecl, importc.}
proc nk_input_scroll*(a1: ptr nk_context; val: nk_vec2) {.cdecl, importc.}
proc nk_input_char*(a1: ptr nk_context; a2: char) {.cdecl, importc.}
proc nk_input_glyph*(a1: ptr nk_context; a2: nk_glyph) {.cdecl, importc.}
proc nk_input_unicode*(a1: ptr nk_context; a2: nk_rune) {.cdecl, importc.}
proc nk_input_end*(a1: ptr nk_context) {.cdecl, importc.}
#  proc nk__begin*(a1: ptr nk_context): ptr nk_command {.cdecl, importc.}
#  proc nk__next*(a1: ptr nk_context; a2: ptr nk_command): ptr nk_command 
proc nk_begin*(ctx: ptr nk_context; title: cstring; bounds: nk_rect; flags: nk_flags): nk_bool {.cdecl, importc.}
proc nk_begin_titled*(ctx: ptr nk_context; name: cstring; title: cstring; bounds: nk_rect; flags: nk_flags): nk_bool {.cdecl, importc.}
proc nk_end*(ctx: ptr nk_context) {.cdecl, importc.}
proc nk_window_find*(ctx: ptr nk_context; name: cstring): ptr nk_window {.cdecl, importc.}
proc nk_window_get_bounds*(ctx: ptr nk_context): nk_rect {.cdecl, importc.}
proc nk_window_get_position*(ctx: ptr nk_context): nk_vec2 {.cdecl, importc.}
proc nk_window_get_size*(a1: ptr nk_context): nk_vec2 {.cdecl, importc.}
proc nk_window_get_width*(a1: ptr nk_context): cfloat {.cdecl, importc.}
proc nk_window_get_height*(a1: ptr nk_context): cfloat {.cdecl, importc.}
proc nk_window_get_panel*(a1: ptr nk_context): ptr nk_panel {.cdecl, importc.}
proc nk_window_get_content_region*(a1: ptr nk_context): nk_rect {.cdecl, importc.}
proc nk_window_get_content_region_min*(a1: ptr nk_context): nk_vec2 {.cdecl, importc.}
proc nk_window_get_content_region_max*(a1: ptr nk_context): nk_vec2 {.cdecl, importc.}
proc nk_window_get_content_region_size*(a1: ptr nk_context): nk_vec2 {.cdecl, importc.}
proc nk_window_get_canvas*(a1: ptr nk_context): ptr nk_command_buffer {.cdecl, importc.}
proc nk_window_get_scroll*(a1: ptr nk_context; offset_x: ptr nk_uint; offset_y: ptr nk_uint) {.cdecl, importc.}
proc nk_window_has_focus*(a1: ptr nk_context): nk_bool {.cdecl, importc.}
proc nk_window_is_hovered*(a1: ptr nk_context): nk_bool {.cdecl, importc.}
proc nk_window_is_collapsed*(ctx: ptr nk_context; name: cstring): nk_bool {.cdecl, importc.}
proc nk_window_is_closed*(a1: ptr nk_context; a2: cstring): nk_bool {.cdecl, importc.}
proc nk_window_is_hidden*(a1: ptr nk_context; a2: cstring): nk_bool {.cdecl, importc.}
proc nk_window_is_active*(a1: ptr nk_context; a2: cstring): nk_bool {.cdecl, importc.}
proc nk_window_is_any_hovered*(a1: ptr nk_context): nk_bool {.cdecl, importc.}
proc nk_item_is_any_active*(a1: ptr nk_context): nk_bool {.cdecl, importc.}
proc nk_window_set_bounds*(a1: ptr nk_context; name: cstring; bounds: nk_rect) {.cdecl, importc.}
proc nk_window_set_position*(a1: ptr nk_context; name: cstring; pos: nk_vec2) {.cdecl, importc.}
proc nk_window_set_size*(a1: ptr nk_context; name: cstring; a3: nk_vec2) {.cdecl, importc.}
proc nk_window_set_focus*(a1: ptr nk_context; name: cstring) {.cdecl, importc.}
proc nk_window_set_scroll*(a1: ptr nk_context; offset_x: nk_uint; offset_y: nk_uint) {.cdecl, importc.}
proc nk_window_close*(ctx: ptr nk_context; name: cstring) {.cdecl, importc.}
proc nk_window_collapse*(a1: ptr nk_context; name: cstring; state: nk_collapse_states) {.cdecl, importc.}
proc nk_window_collapse_if*(a1: ptr nk_context; name: cstring; a3: nk_collapse_states; cond: cint) {.cdecl, importc.}
proc nk_window_show*(a1: ptr nk_context; name: cstring; a3: nk_show_states) {.cdecl, importc.}
proc nk_window_show_if*(a1: ptr nk_context; name: cstring; a3: nk_show_states; cond: cint) {.cdecl, importc.}
proc nk_layout_set_min_row_height*(a1: ptr nk_context; height: cfloat) {.cdecl, importc.}
proc nk_layout_reset_min_row_height*(a1: ptr nk_context) {.cdecl, importc.}
proc nk_layout_widget_bounds*(a1: ptr nk_context): nk_rect {.cdecl, importc.}
proc nk_layout_ratio_from_pixel*(a1: ptr nk_context; pixel_width: cfloat): cfloat {.cdecl, importc.}
proc nk_layout_row_dynamic*(ctx: ptr nk_context; height: cfloat; cols: cint) {.cdecl, importc.}
proc nk_layout_row_static*(ctx: ptr nk_context; height: cfloat; item_width: cint; cols: cint) {.cdecl, importc.}
proc nk_layout_row_begin*(ctx: ptr nk_context; fmt: nk_layout_format; row_height: cfloat; cols: cint) {.cdecl, importc.}
proc nk_layout_row_push*(a1: ptr nk_context; value: cfloat) {.cdecl, importc.}
proc nk_layout_row_end*(a1: ptr nk_context) {.cdecl, importc.}
proc nk_layout_row*(a1: ptr nk_context; a2: nk_layout_format; height: cfloat; cols: cint; ratio: ptr cfloat) {.cdecl, importc.}
proc nk_layout_row_template_begin*(a1: ptr nk_context; row_height: cfloat) {.cdecl, importc.}
proc nk_layout_row_template_push_dynamic*(a1: ptr nk_context) {.cdecl, importc.}
proc nk_layout_row_template_push_variable*(a1: ptr nk_context; min_width: cfloat) {.cdecl, importc.}
proc nk_layout_row_template_push_static*(a1: ptr nk_context; width: cfloat) {.cdecl, importc.}
proc nk_layout_row_template_end*(a1: ptr nk_context) {.cdecl, importc.}
proc nk_layout_space_begin*(a1: ptr nk_context; a2: nk_layout_format; height: cfloat; widget_count: cint) {.cdecl, importc.}
proc nk_layout_space_push*(a1: ptr nk_context; bounds: nk_rect) {.cdecl, importc.}
proc nk_layout_space_end*(a1: ptr nk_context) {.cdecl, importc.}
proc nk_layout_space_bounds*(a1: ptr nk_context): nk_rect {.cdecl, importc.}
proc nk_layout_space_to_screen*(a1: ptr nk_context; a2: nk_vec2): nk_vec2 {.cdecl, importc.}
proc nk_layout_space_to_local*(a1: ptr nk_context; a2: nk_vec2): nk_vec2 {.cdecl, importc.}
proc nk_layout_space_rect_to_screen*(a1: ptr nk_context; a2: nk_rect): nk_rect {.cdecl, importc.}
proc nk_layout_space_rect_to_local*(a1: ptr nk_context; a2: nk_rect): nk_rect {.cdecl, importc.}
proc nk_spacer*(a1: ptr nk_context) {.cdecl, importc.}
proc nk_group_begin*(a1: ptr nk_context; title: cstring; a3: nk_flags): nk_bool {.cdecl, importc.}
proc nk_group_begin_titled*(a1: ptr nk_context; name: cstring; title: cstring; a4: nk_flags): nk_bool {.cdecl, importc.}
proc nk_group_end*(a1: ptr nk_context) {.cdecl, importc.}
proc nk_group_scrolled_offset_begin*(a1: ptr nk_context; x_offset: ptr nk_uint; y_offset: ptr nk_uint; title: cstring; flags: nk_flags): nk_bool {.cdecl, importc.}
proc nk_group_scrolled_begin*(a1: ptr nk_context; off: ptr nk_scroll; title: cstring; a4: nk_flags): nk_bool {.cdecl, importc.}
proc nk_group_scrolled_end*(a1: ptr nk_context) {.cdecl, importc.}
proc nk_group_get_scroll*(a1: ptr nk_context; id: cstring; x_offset: ptr nk_uint; y_offset: ptr nk_uint) {.cdecl, importc.}
proc nk_group_set_scroll*(a1: ptr nk_context; id: cstring; x_offset: nk_uint; y_offset: nk_uint) {.cdecl, importc.}
proc nk_tree_push_hashed*(a1: ptr nk_context; a2: nk_tree_type; title: cstring; initial_state: nk_collapse_states; hash: cstring; len: cint; seed: cint): nk_bool {.cdecl, importc.}
proc nk_tree_image_push_hashed*(a1: ptr nk_context; a2: nk_tree_type; a3: nk_image; title: cstring; initial_state: nk_collapse_states; hash: cstring; len: cint; seed: cint): nk_bool {.cdecl, importc.}
proc nk_tree_pop*(a1: ptr nk_context) {.cdecl, importc.}
proc nk_tree_state_push*(a1: ptr nk_context; a2: nk_tree_type; title: cstring; state: ptr nk_collapse_states): nk_bool {.cdecl, importc.}
proc nk_tree_state_image_push*(a1: ptr nk_context; a2: nk_tree_type; a3: nk_image; title: cstring; state: ptr nk_collapse_states): nk_bool {.cdecl, importc.}
proc nk_tree_state_pop*(a1: ptr nk_context) {.cdecl, importc.}
proc nk_tree_element_push_hashed*(a1: ptr nk_context; a2: nk_tree_type; title: cstring; initial_state: nk_collapse_states; selected: ptr nk_bool; hash: cstring; len: cint; seed: cint): nk_bool {.cdecl, importc.}
proc nk_tree_element_image_push_hashed*(a1: ptr nk_context; a2: nk_tree_type; a3: nk_image; title: cstring; initial_state: nk_collapse_states; selected: ptr nk_bool; hash: cstring; len: cint; seed: cint): nk_bool {.cdecl, importc.}
proc nk_tree_element_pop*(a1: ptr nk_context) {.cdecl, importc.}
proc nk_widget*(a1: ptr nk_rect; a2: ptr nk_context): nk_widget_layout_states {.cdecl, importc.}
proc nk_widget_fitting*(a1: ptr nk_rect; a2: ptr nk_context; a3: nk_vec2): nk_widget_layout_states {.cdecl, importc.}
proc nk_widget_bounds*(a1: ptr nk_context): nk_rect {.cdecl, importc.}
proc nk_widget_position*(a1: ptr nk_context): nk_vec2 {.cdecl, importc.}
proc nk_widget_size*(a1: ptr nk_context): nk_vec2 {.cdecl, importc.}
proc nk_widget_width*(a1: ptr nk_context): cfloat {.cdecl, importc.}
proc nk_widget_height*(a1: ptr nk_context): cfloat {.cdecl, importc.}
proc nk_widget_is_hovered*(a1: ptr nk_context): nk_bool {.cdecl, importc.}
proc nk_widget_is_mouse_clicked*(a1: ptr nk_context; a2: nk_buttons): nk_bool {.cdecl, importc.}
proc nk_widget_has_mouse_click_down*(a1: ptr nk_context; a2: nk_buttons; down: nk_bool): nk_bool {.cdecl, importc.}
proc nk_spacing*(a1: ptr nk_context; cols: cint) {.cdecl, importc.}
proc nk_list_view_begin*(a1: ptr nk_context; `out`: ptr nk_list_view; id: cstring; a4: nk_flags; row_height: cint; row_count: cint): nk_bool {.cdecl, importc.}
proc nk_list_view_end*(a1: ptr nk_list_view) {.cdecl, importc.}
proc nk_text*(a1: ptr nk_context; a2: cstring; a3: cint; a4: nk_flags) {.cdecl, importc.}
proc nk_text_colored*(a1: ptr nk_context; a2: cstring; a3: cint; a4: nk_flags; a5: nk_color) {.cdecl, importc.}
proc nk_text_wrap*(a1: ptr nk_context; a2: cstring; a3: cint) {.cdecl, importc.}
proc nk_text_wrap_colored*(a1: ptr nk_context; a2: cstring; a3: cint; a4: nk_color) {.cdecl, importc.}
proc nk_label*(a1: ptr nk_context; a2: cstring; align: nk_flags) {.cdecl, importc.}
proc nk_label_colored*(a1: ptr nk_context; a2: cstring; align: nk_flags; a4: nk_color) {.cdecl, importc.}
proc nk_label_wrap*(a1: ptr nk_context; a2: cstring) {.cdecl, importc.}
proc nk_label_colored_wrap*(a1: ptr nk_context; a2: cstring; a3: nk_color) {.cdecl, importc.}
proc nk_img_init*(a1: ptr nk_context; a2: nk_image) {.cdecl, importc: "nk_image".}
proc nk_image_color*(a1: ptr nk_context; a2: nk_image; a3: nk_color) {.cdecl, importc.}
proc nk_button_text*(a1: ptr nk_context; title: cstring; len: cint): nk_bool {.cdecl, importc.}
proc nk_button_label*(a1: ptr nk_context; title: cstring): nk_bool {.cdecl, importc.}
proc nk_button_color*(a1: ptr nk_context; a2: nk_color): nk_bool {.cdecl, importc.}
proc nk_button_symbol*(a1: ptr nk_context; a2: nk_symbol_type): nk_bool {.cdecl, importc.}
proc nk_button_image*(a1: ptr nk_context; img: nk_image): nk_bool {.cdecl, importc.}
proc nk_button_symbol_label*(a1: ptr nk_context; a2: nk_symbol_type; a3: cstring; text_alignment: nk_flags): nk_bool {.cdecl, importc.}
proc nk_button_symbol_text*(a1: ptr nk_context; a2: nk_symbol_type; a3: cstring; a4: cint; alignment: nk_flags): nk_bool {.cdecl, importc.}
proc nk_button_image_label*(a1: ptr nk_context; img: nk_image; a3: cstring; text_alignment: nk_flags): nk_bool {.cdecl, importc.}
proc nk_button_image_text*(a1: ptr nk_context; img: nk_image; a3: cstring; a4: cint; alignment: nk_flags): nk_bool {.cdecl, importc.}
proc nk_button_text_styled*(a1: ptr nk_context; a2: ptr nk_style_button; title: cstring; len: cint): nk_bool {.cdecl, importc.}
proc nk_button_label_styled*(a1: ptr nk_context; a2: ptr nk_style_button; title: cstring): nk_bool {.cdecl, importc.}
proc nk_button_symbol_styled*(a1: ptr nk_context; a2: ptr nk_style_button; a3: nk_symbol_type): nk_bool {.cdecl, importc.}
proc nk_button_image_styled*(a1: ptr nk_context; a2: ptr nk_style_button; img: nk_image): nk_bool {.cdecl, importc.}
proc nk_button_symbol_text_styled*(a1: ptr nk_context; a2: ptr nk_style_button; a3: nk_symbol_type; a4: cstring; a5: cint; alignment: nk_flags): nk_bool {.cdecl, importc.}
proc nk_button_symbol_label_styled*(ctx: ptr nk_context; style: ptr nk_style_button; symbol: nk_symbol_type; title: cstring; align: nk_flags): nk_bool {.cdecl, importc.}
proc nk_button_image_label_styled*(a1: ptr nk_context; a2: ptr nk_style_button; img: nk_image; a4: cstring; text_alignment: nk_flags): nk_bool {.cdecl, importc.}
proc nk_button_image_text_styled*(a1: ptr nk_context; a2: ptr nk_style_button; img: nk_image; a4: cstring; a5: cint; alignment: nk_flags): nk_bool {.cdecl, importc.}
proc nk_button_set_behavior*(a1: ptr nk_context; a2: nk_button_behavior) {.cdecl, importc.}
proc nk_button_push_behavior*(a1: ptr nk_context; a2: nk_button_behavior): nk_bool {.cdecl, importc.}
proc nk_button_pop_behavior*(a1: ptr nk_context): nk_bool {.cdecl, importc.}
proc nk_check_label*(a1: ptr nk_context; a2: cstring; active: nk_bool): nk_bool {.cdecl, importc.}
proc nk_check_text*(a1: ptr nk_context; a2: cstring; a3: cint; active: nk_bool): nk_bool {.cdecl, importc.}
proc nk_check_flags_label*(a1: ptr nk_context; a2: cstring; flags: cuint; value: cuint): cuint {.cdecl, importc.}
proc nk_check_flags_text*(a1: ptr nk_context; a2: cstring; a3: cint; flags: cuint; value: cuint): cuint {.cdecl, importc.}
proc nk_checkbox_label*(a1: ptr nk_context; a2: cstring; active: ptr nk_bool): nk_bool {.cdecl, importc.}
proc nk_checkbox_text*(a1: ptr nk_context; a2: cstring; a3: cint; active: ptr nk_bool): nk_bool {.cdecl, importc.}
proc nk_checkbox_flags_label*(a1: ptr nk_context; a2: cstring; flags: ptr cuint; value: cuint): nk_bool {.cdecl, importc.}
proc nk_checkbox_flags_text*(a1: ptr nk_context; a2: cstring; a3: cint; flags: ptr cuint; value: cuint): nk_bool {.cdecl, importc.}
proc nk_radio_label*(a1: ptr nk_context; a2: cstring; active: ptr nk_bool): nk_bool {.cdecl, importc.}
proc nk_radio_text*(a1: ptr nk_context; a2: cstring; a3: cint; active: ptr nk_bool): nk_bool {.cdecl, importc.}
proc nk_option_label*(a1: ptr nk_context; a2: cstring; active: nk_bool): nk_bool {.cdecl, importc.}
proc nk_option_text*(a1: ptr nk_context; a2: cstring; a3: cint; active: nk_bool): nk_bool {.cdecl, importc.}
proc nk_selectable_label*(a1: ptr nk_context; a2: cstring; align: nk_flags; value: ptr nk_bool): nk_bool {.cdecl, importc.}
proc nk_selectable_text*(a1: ptr nk_context; a2: cstring; a3: cint; align: nk_flags; value: ptr nk_bool): nk_bool {.cdecl, importc.}
proc nk_selectable_image_label*(a1: ptr nk_context; a2: nk_image; a3: cstring; align: nk_flags; value: ptr nk_bool): nk_bool {.cdecl, importc.}
proc nk_selectable_image_text*(a1: ptr nk_context; a2: nk_image; a3: cstring; a4: cint; align: nk_flags; value: ptr nk_bool): nk_bool {.cdecl, importc.}
proc nk_selectable_symbol_label*(a1: ptr nk_context; a2: nk_symbol_type; a3: cstring; align: nk_flags; value: ptr nk_bool): nk_bool {.cdecl, importc.}
proc nk_selectable_symbol_text*(a1: ptr nk_context; a2: nk_symbol_type; a3: cstring; a4: cint; align: nk_flags; value: ptr nk_bool): nk_bool {.cdecl, importc.}
proc nk_select_label*(a1: ptr nk_context; a2: cstring; align: nk_flags; value: nk_bool): nk_bool {.cdecl, importc.}
proc nk_select_text*(a1: ptr nk_context; a2: cstring; a3: cint; align: nk_flags; value: nk_bool): nk_bool {.cdecl, importc.}
proc nk_select_image_label*(a1: ptr nk_context; a2: nk_image; a3: cstring; align: nk_flags; value: nk_bool): nk_bool {.cdecl, importc.}
proc nk_select_image_text*(a1: ptr nk_context; a2: nk_image; a3: cstring; a4: cint; align: nk_flags; value: nk_bool): nk_bool {.cdecl, importc.}
proc nk_select_symbol_label*(a1: ptr nk_context; a2: nk_symbol_type; a3: cstring; align: nk_flags; value: nk_bool): nk_bool {.cdecl, importc.}
proc nk_select_symbol_text*(a1: ptr nk_context; a2: nk_symbol_type; a3: cstring; a4: cint; align: nk_flags; value: nk_bool): nk_bool {.cdecl, importc.}
proc nk_slide_float*(a1: ptr nk_context; min: cfloat; val: cfloat; max: cfloat; step: cfloat): cfloat {.cdecl, importc.}
proc nk_slide_int*(a1: ptr nk_context; min: cint; val: cint; max: cint; step: cint): cint {.cdecl, importc.}
proc nk_slider_float*(a1: ptr nk_context; min: cfloat; val: ptr cfloat; max: cfloat; step: cfloat): nk_bool {.cdecl, importc.}
proc nk_slider_int*(a1: ptr nk_context; min: cint; val: ptr cint; max: cint; step: cint): nk_bool {.cdecl, importc.}
proc nk_progress*(a1: ptr nk_context; cur: ptr nk_size; max: nk_size; modifyable: nk_bool): nk_bool {.cdecl, importc.}
proc nk_prog*(a1: ptr nk_context; cur: nk_size; max: nk_size; modifyable: nk_bool): nk_size {.cdecl, importc.}
proc nk_color_picker*(a1: ptr nk_context; a2: nk_colorf; a3: nk_color_format): nk_colorf {.cdecl, importc.}
proc nk_color_pick*(a1: ptr nk_context; a2: ptr nk_colorf; a3: nk_color_format): nk_bool {.cdecl, importc.}
proc nk_property_int*(a1: ptr nk_context; name: cstring; min: cint; val: ptr cint; max: cint; step: cint; inc_per_pixel: cfloat) {.cdecl, importc.}
proc nk_property_float*(a1: ptr nk_context; name: cstring; min: cfloat; val: ptr cfloat; max: cfloat; step: cfloat; inc_per_pixel: cfloat) {.cdecl, importc.}
proc nk_property_double*(a1: ptr nk_context; name: cstring; min: cdouble; val: ptr cdouble; max: cdouble; step: cdouble; inc_per_pixel: cfloat) {.cdecl, importc.}
proc nk_propertyi*(a1: ptr nk_context; name: cstring; min: cint; val: cint; max: cint; step: cint; inc_per_pixel: cfloat): cint {.cdecl, importc.}
proc nk_propertyf*(a1: ptr nk_context; name: cstring; min: cfloat; val: cfloat; max: cfloat; step: cfloat; inc_per_pixel: cfloat): cfloat {.cdecl, importc.}
proc nk_propertyd*(a1: ptr nk_context; name: cstring; min: cdouble; val: cdouble; max: cdouble; step: cdouble; inc_per_pixel: cfloat): cdouble {.cdecl, importc.}
proc nk_edit_string*(a1: ptr nk_context; a2: nk_flags; buffer: cstring; len: ptr cint; max: cint; a6: nk_plugin_filter): nk_flags {.cdecl, importc.}
proc nk_edit_string_zero_terminated*(a1: ptr nk_context; a2: nk_flags; buffer: cstring; max: cint; a5: nk_plugin_filter): nk_flags {.cdecl, importc.}
proc nk_edit_buffer*(a1: ptr nk_context; a2: nk_flags; a3: ptr nk_text_edit; a4: nk_plugin_filter): nk_flags {.cdecl, importc.}
proc nk_edit_focus*(a1: ptr nk_context; flags: nk_flags) {.cdecl, importc.}
proc nk_edit_unfocus*(a1: ptr nk_context) {.cdecl, importc.}
proc nk_chart_begin*(a1: ptr nk_context; a2: nk_chart_type; num: cint; min: cfloat; max: cfloat): nk_bool {.cdecl, importc.}
proc nk_chart_begin_colored*(a1: ptr nk_context; a2: nk_chart_type; a3: nk_color; active: nk_color; num: cint; min: cfloat; max: cfloat): nk_bool {.cdecl, importc.}
proc nk_chart_add_slot*(ctx: ptr nk_context; a2: nk_chart_type; count: cint; min_value: cfloat; max_value: cfloat) {.cdecl, importc.}
proc nk_chart_add_slot_colored*(ctx: ptr nk_context; a2: nk_chart_type; a3: nk_color; active: nk_color; count: cint; min_value: cfloat; max_value: cfloat) {.cdecl, importc.}
proc nk_chart_push*(a1: ptr nk_context; a2: cfloat): nk_flags {.cdecl, importc.}
proc nk_chart_push_slot*(a1: ptr nk_context; a2: cfloat; a3: cint): nk_flags {.cdecl, importc.}
proc nk_chart_end*(a1: ptr nk_context) {.cdecl, importc.}
proc nk_plot*(a1: ptr nk_context; a2: nk_chart_type; values: ptr cfloat; count: cint; offset: cint) {.cdecl, importc.}
proc nk_plot_function*(a1: ptr nk_context; a2: nk_chart_type; userdata: pointer; value_getter: proc (user: pointer; index: cint): cfloat; count: cint; offset: cint) {.cdecl, importc.}
proc nk_popup_begin*(a1: ptr nk_context; a2: nk_popup_type; a3: cstring; a4: nk_flags; bounds: nk_rect): nk_bool {.cdecl, importc.}
proc nk_popup_close*(a1: ptr nk_context) {.cdecl, importc.}
proc nk_popup_end*(a1: ptr nk_context) {.cdecl, importc.}
proc nk_popup_get_scroll*(a1: ptr nk_context; offset_x: ptr nk_uint; offset_y: ptr nk_uint) {.cdecl, importc.}
proc nk_popup_set_scroll*(a1: ptr nk_context; offset_x: nk_uint; offset_y: nk_uint) {.cdecl, importc.}
proc nk_combo*(a1: ptr nk_context; items: cstringArray; count: cint; selected: cint; item_height: cint; size: nk_vec2): cint {.cdecl, importc.}
proc nk_combo_separator*(a1: ptr nk_context; items_separated_by_separator: cstring; separator: cint; selected: cint; count: cint; item_height: cint; size: nk_vec2): cint {.cdecl, importc.}
proc nk_combo_string*(a1: ptr nk_context; items_separated_by_zeros: cstring; selected: cint; count: cint; item_height: cint; size: nk_vec2): cint {.cdecl, importc.}
proc nk_combo_callback*(a1: ptr nk_context; item_getter: proc (a1: pointer; a2: cint; a3: cstringArray); userdata: pointer; selected: cint; count: cint; item_height: cint; size: nk_vec2): cint {.cdecl, importc.}
proc nk_combobox*(a1: ptr nk_context; items: cstringArray; count: cint; selected: ptr cint; item_height: cint; size: nk_vec2) {.cdecl, importc.}
proc nk_combobox_string*(a1: ptr nk_context; items_separated_by_zeros: cstring; selected: ptr cint; count: cint; item_height: cint; size: nk_vec2) {.cdecl, importc.}
proc nk_combobox_separator*(a1: ptr nk_context; items_separated_by_separator: cstring; separator: cint; selected: ptr cint; count: cint; item_height: cint; size: nk_vec2) {.cdecl, importc.}
proc nk_combobox_callback*(a1: ptr nk_context; item_getter: proc (a1: pointer; a2: cint; a3: cstringArray); a3: pointer; selected: ptr cint; count: cint; item_height: cint; size: nk_vec2) {.cdecl, importc.}
proc nk_combo_begin_text*(a1: ptr nk_context; selected: cstring; a3: cint; size: nk_vec2): nk_bool {.cdecl, importc.}
proc nk_combo_begin_label*(a1: ptr nk_context; selected: cstring; size: nk_vec2): nk_bool {.cdecl, importc.}
proc nk_combo_begin_color*(a1: ptr nk_context; color: nk_color; size: nk_vec2): nk_bool {.cdecl, importc.}
proc nk_combo_begin_symbol*(a1: ptr nk_context; a2: nk_symbol_type; size: nk_vec2): nk_bool {.cdecl, importc.}
proc nk_combo_begin_symbol_label*(a1: ptr nk_context; selected: cstring; a3: nk_symbol_type; size: nk_vec2): nk_bool {.cdecl, importc.}
proc nk_combo_begin_symbol_text*(a1: ptr nk_context; selected: cstring; a3: cint; a4: nk_symbol_type; size: nk_vec2): nk_bool {.cdecl, importc.}
proc nk_combo_begin_image*(a1: ptr nk_context; img: nk_image; size: nk_vec2): nk_bool {.cdecl, importc.}
proc nk_combo_begin_image_label*(a1: ptr nk_context; selected: cstring; a3: nk_image; size: nk_vec2): nk_bool {.cdecl, importc.}
proc nk_combo_begin_image_text*(a1: ptr nk_context; selected: cstring; a3: cint; a4: nk_image; size: nk_vec2): nk_bool {.cdecl, importc.}
proc nk_combo_item_label*(a1: ptr nk_context; a2: cstring; alignment: nk_flags): nk_bool {.cdecl, importc.}
proc nk_combo_item_text*(a1: ptr nk_context; a2: cstring; a3: cint; alignment: nk_flags): nk_bool {.cdecl, importc.}
proc nk_combo_item_image_label*(a1: ptr nk_context; a2: nk_image; a3: cstring; alignment: nk_flags): nk_bool {.cdecl, importc.}
proc nk_combo_item_image_text*(a1: ptr nk_context; a2: nk_image; a3: cstring; a4: cint; alignment: nk_flags): nk_bool {.cdecl, importc.}
proc nk_combo_item_symbol_label*(a1: ptr nk_context; a2: nk_symbol_type; a3: cstring; alignment: nk_flags): nk_bool {.cdecl, importc.}
proc nk_combo_item_symbol_text*(a1: ptr nk_context; a2: nk_symbol_type; a3: cstring; a4: cint; alignment: nk_flags): nk_bool {.cdecl, importc.}
proc nk_combo_close*(a1: ptr nk_context) {.cdecl, importc.}
proc nk_combo_end*(a1: ptr nk_context) {.cdecl, importc.}
proc nk_contextual_begin*(a1: ptr nk_context; a2: nk_flags; a3: nk_vec2; trigger_bounds: nk_rect): nk_bool {.cdecl, importc.}
proc nk_contextual_item_text*(a1: ptr nk_context; a2: cstring; a3: cint; align: nk_flags): nk_bool {.cdecl, importc.}
proc nk_contextual_item_label*(a1: ptr nk_context; a2: cstring; align: nk_flags): nk_bool {.cdecl, importc.}
proc nk_contextual_item_image_label*(a1: ptr nk_context; a2: nk_image; a3: cstring; alignment: nk_flags): nk_bool {.cdecl, importc.}
proc nk_contextual_item_image_text*(a1: ptr nk_context; a2: nk_image; a3: cstring; len: cint; alignment: nk_flags): nk_bool {.cdecl, importc.}
proc nk_contextual_item_symbol_label*(a1: ptr nk_context; a2: nk_symbol_type; a3: cstring; alignment: nk_flags): nk_bool {.cdecl, importc.}
proc nk_contextual_item_symbol_text*(a1: ptr nk_context; a2: nk_symbol_type; a3: cstring; a4: cint; alignment: nk_flags): nk_bool {.cdecl, importc.}
proc nk_contextual_close*(a1: ptr nk_context) {.cdecl, importc.}
proc nk_contextual_end*(a1: ptr nk_context) {.cdecl, importc.}
proc nk_tooltip*(a1: ptr nk_context; a2: cstring) {.cdecl, importc.}
proc nk_tooltip_begin*(a1: ptr nk_context; width: cfloat): nk_bool {.cdecl, importc.}
proc nk_tooltip_end*(a1: ptr nk_context) {.cdecl, importc.}
proc nk_menubar_begin*(a1: ptr nk_context) {.cdecl, importc.}
proc nk_menubar_end*(a1: ptr nk_context) {.cdecl, importc.}
proc nk_menu_begin_text*(a1: ptr nk_context; title: cstring; title_len: cint; align: nk_flags; size: nk_vec2): nk_bool {.cdecl, importc.}
proc nk_menu_begin_label*(a1: ptr nk_context; a2: cstring; align: nk_flags; size: nk_vec2): nk_bool {.cdecl, importc.}
proc nk_menu_begin_image*(a1: ptr nk_context; a2: cstring; a3: nk_image; size: nk_vec2): nk_bool {.cdecl, importc.}
proc nk_menu_begin_image_text*(a1: ptr nk_context; a2: cstring; a3: cint; align: nk_flags; a5: nk_image; size: nk_vec2): nk_bool {.cdecl, importc.}
proc nk_menu_begin_image_label*(a1: ptr nk_context; a2: cstring; align: nk_flags; a4: nk_image; size: nk_vec2): nk_bool {.cdecl, importc.}
proc nk_menu_begin_symbol*(a1: ptr nk_context; a2: cstring; a3: nk_symbol_type; size: nk_vec2): nk_bool {.cdecl, importc.}
proc nk_menu_begin_symbol_text*(a1: ptr nk_context; a2: cstring; a3: cint; align: nk_flags; a5: nk_symbol_type; size: nk_vec2): nk_bool {.cdecl, importc.}
proc nk_menu_begin_symbol_label*(a1: ptr nk_context; a2: cstring; align: nk_flags; a4: nk_symbol_type; size: nk_vec2): nk_bool {.cdecl, importc.}
proc nk_menu_item_text*(a1: ptr nk_context; a2: cstring; a3: cint; align: nk_flags): nk_bool {.cdecl, importc.}
proc nk_menu_item_label*(a1: ptr nk_context; a2: cstring; alignment: nk_flags): nk_bool {.cdecl, importc.}
proc nk_menu_item_image_label*(a1: ptr nk_context; a2: nk_image; a3: cstring; alignment: nk_flags): nk_bool {.cdecl, importc.}
proc nk_menu_item_image_text*(a1: ptr nk_context; a2: nk_image; a3: cstring; len: cint; alignment: nk_flags): nk_bool {.cdecl, importc.}
proc nk_menu_item_symbol_text*(a1: ptr nk_context; a2: nk_symbol_type; a3: cstring; a4: cint; alignment: nk_flags): nk_bool {.cdecl, importc.}
proc nk_menu_item_symbol_label*(a1: ptr nk_context; a2: nk_symbol_type; a3: cstring; alignment: nk_flags): nk_bool {.cdecl, importc.}
proc nk_menu_close*(a1: ptr nk_context) {.cdecl, importc.}
proc nk_menu_end*(a1: ptr nk_context) {.cdecl, importc.}
proc nk_style_default*(a1: ptr nk_context) {.cdecl, importc.}
proc nk_style_from_table*(a1: ptr nk_context; a2: ptr nk_color) {.cdecl, importc.}
proc nk_style_load_cursor*(a1: ptr nk_context; a2: nk_style_cursor; a3: ptr nk_cursor) {.cdecl, importc.}
proc nk_style_load_all_cursors*(a1: ptr nk_context; a2: ptr nk_cursor) {.cdecl, importc.}
proc nk_style_get_color_by_name*(a1: nk_style_colors): cstring {.cdecl, importc.}
proc nk_style_set_font*(a1: ptr nk_context; a2: ptr nk_user_font) {.cdecl, importc.}
proc nk_style_set_cursor*(a1: ptr nk_context; a2: nk_style_cursor): nk_bool {.cdecl, importc.}
proc nk_style_show_cursor*(a1: ptr nk_context) {.cdecl, importc.}
proc nk_style_hide_cursor*(a1: ptr nk_context) {.cdecl, importc.}
proc nk_style_push_font*(a1: ptr nk_context; a2: ptr nk_user_font): nk_bool {.cdecl, importc.}
proc nk_style_push_float*(a1: ptr nk_context; a2: ptr cfloat; a3: cfloat): nk_bool {.cdecl, importc.}
proc nk_style_push_vec2*(a1: ptr nk_context; a2: ptr nk_vec2; a3: nk_vec2): nk_bool {.cdecl, importc.}
proc nk_style_push_style_item*(a1: ptr nk_context; a2: ptr nk_style_item; a3: nk_style_item): nk_bool {.cdecl, importc.}
proc nk_style_push_flags*(a1: ptr nk_context; a2: ptr nk_flags; a3: nk_flags): nk_bool {.cdecl, importc.}
proc nk_style_push_color*(a1: ptr nk_context; a2: ptr nk_color; a3: nk_color): nk_bool {.cdecl, importc.}
proc nk_style_pop_font*(a1: ptr nk_context): nk_bool {.cdecl, importc.}
proc nk_style_pop_float*(a1: ptr nk_context): nk_bool {.cdecl, importc.}
proc nk_style_pop_vec2*(a1: ptr nk_context): nk_bool {.cdecl, importc.}
proc nk_style_pop_style_item*(a1: ptr nk_context): nk_bool {.cdecl, importc.}
proc nk_style_pop_flags*(a1: ptr nk_context): nk_bool {.cdecl, importc.}
proc nk_style_pop_color*(a1: ptr nk_context): nk_bool {.cdecl, importc.}
proc nk_rgb*(r: cint; g: cint; b: cint): nk_color {.cdecl, importc.}
proc nk_rgb_iv*(rgb: ptr cint): nk_color {.cdecl, importc.}
proc nk_rgb_bv*(rgb: ptr nk_byte): nk_color {.cdecl, importc.}
proc nk_rgb_f*(r: cfloat; g: cfloat; b: cfloat): nk_color {.cdecl, importc.}
proc nk_rgb_fv*(rgb: ptr cfloat): nk_color {.cdecl, importc.}
proc nk_rgb_cf*(c: nk_colorf): nk_color {.cdecl, importc.}
proc nk_rgb_hex*(rgb: cstring): nk_color {.cdecl, importc.}
proc nk_rgba*(r: cint; g: cint; b: cint; a: cint): nk_color {.cdecl, importc.}
proc nk_rgba_u32*(a1: nk_uint): nk_color {.cdecl, importc.}
proc nk_rgba_iv*(rgba: ptr cint): nk_color {.cdecl, importc.}
proc nk_rgba_bv*(rgba: ptr nk_byte): nk_color {.cdecl, importc.}
proc nk_rgba_f*(r: cfloat; g: cfloat; b: cfloat; a: cfloat): nk_color {.cdecl, importc.}
proc nk_rgba_fv*(rgba: ptr cfloat): nk_color {.cdecl, importc.}
proc nk_rgba_cf*(c: nk_colorf): nk_color {.cdecl, importc.}
proc nk_rgba_hex*(rgb: cstring): nk_color {.cdecl, importc.}
proc nk_hsva_colorf*(h: cfloat; s: cfloat; v: cfloat; a: cfloat): nk_colorf {.cdecl, importc.}
proc nk_hsva_colorfv*(c: ptr cfloat): nk_colorf {.cdecl, importc.}
proc nk_colorf_hsva_f*(out_h: ptr cfloat; out_s: ptr cfloat; out_v: ptr cfloat; out_a: ptr cfloat; `in`: nk_colorf) {.cdecl, importc.}
proc nk_colorf_hsva_fv*(hsva: ptr cfloat; `in`: nk_colorf) {.cdecl, importc.}
proc nk_hsv*(h: cint; s: cint; v: cint): nk_color {.cdecl, importc.}
proc nk_hsv_iv*(hsv: ptr cint): nk_color {.cdecl, importc.}
proc nk_hsv_bv*(hsv: ptr nk_byte): nk_color {.cdecl, importc.}
proc nk_hsv_f*(h: cfloat; s: cfloat; v: cfloat): nk_color {.cdecl, importc.}
proc nk_hsv_fv*(hsv: ptr cfloat): nk_color {.cdecl, importc.}
proc nk_hsva*(h: cint; s: cint; v: cint; a: cint): nk_color {.cdecl, importc.}
proc nk_hsva_iv*(hsva: ptr cint): nk_color {.cdecl, importc.}
proc nk_hsva_bv*(hsva: ptr nk_byte): nk_color {.cdecl, importc.}
proc nk_hsva_f*(h: cfloat; s: cfloat; v: cfloat; a: cfloat): nk_color {.cdecl, importc.}
proc nk_hsva_fv*(hsva: ptr cfloat): nk_color {.cdecl, importc.}
proc nk_color_f_init*(r: ptr cfloat; g: ptr cfloat; b: ptr cfloat; a: ptr cfloat; a5: nk_color) {.cdecl, importc: "nk_color_f".}
proc nk_color_fv*(rgba_out: ptr cfloat; a2: nk_color) {.cdecl, importc.}
proc nk_color_cf*(a1: nk_color): nk_colorf {.cdecl, importc.}
proc nk_color_d*(r: ptr cdouble; g: ptr cdouble; b: ptr cdouble; a: ptr cdouble; a5: nk_color) {.cdecl, importc.}
proc nk_color_dv*(rgba_out: ptr cdouble; a2: nk_color) {.cdecl, importc.}
proc nk_color_u32*(a1: nk_color): nk_uint {.cdecl, importc.}
proc nk_color_hex_rgba*(output: cstring; a2: nk_color) {.cdecl, importc.}
proc nk_color_hex_rgb*(output: cstring; a2: nk_color) {.cdecl, importc.}
proc nk_color_hsv_i*(out_h: ptr cint; out_s: ptr cint; out_v: ptr cint; a4: nk_color) {.cdecl, importc.}
proc nk_color_hsv_b*(out_h: ptr nk_byte; out_s: ptr nk_byte; out_v: ptr nk_byte; a4: nk_color) {.cdecl, importc.}
proc nk_color_hsv_iv*(hsv_out: ptr cint; a2: nk_color) {.cdecl, importc.}
proc nk_color_hsv_bv*(hsv_out: ptr nk_byte; a2: nk_color) {.cdecl, importc.}
proc nk_color_hsv_f*(out_h: ptr cfloat; out_s: ptr cfloat; out_v: ptr cfloat; a4: nk_color) {.cdecl, importc.}
proc nk_color_hsv_fv*(hsv_out: ptr cfloat; a2: nk_color) {.cdecl, importc.}
proc nk_color_hsva_i*(h: ptr cint; s: ptr cint; v: ptr cint; a: ptr cint; a5: nk_color) {.cdecl, importc.}
proc nk_color_hsva_b*(h: ptr nk_byte; s: ptr nk_byte; v: ptr nk_byte; a: ptr nk_byte; a5: nk_color) {.cdecl, importc.}
proc nk_color_hsva_iv*(hsva_out: ptr cint; a2: nk_color) {.cdecl, importc.}
proc nk_color_hsva_bv*(hsva_out: ptr nk_byte; a2: nk_color) {.cdecl, importc.}
proc nk_color_hsva_f*(out_h: ptr cfloat; out_s: ptr cfloat; out_v: ptr cfloat; out_a: ptr cfloat; a5: nk_color) {.cdecl, importc.}
proc nk_color_hsva_fv*(hsva_out: ptr cfloat; a2: nk_color) {.cdecl, importc.}
proc nk_handle_ptr*(a1: pointer): nk_handle {.cdecl, importc.}
proc nk_handle_id*(a1: cint): nk_handle {.cdecl, importc.}
proc nk_image_handle*(a1: nk_handle): nk_image {.cdecl, importc.}
proc nk_image_ptr*(a1: pointer): nk_image {.cdecl, importc.}
proc nk_image_id*(a1: cint): nk_image {.cdecl, importc.}
proc nk_image_is_subimage*(img: ptr nk_image): nk_bool {.cdecl, importc.}
proc nk_subimage_ptr*(a1: pointer; w: nk_ushort; h: nk_ushort; sub_region: nk_rect): nk_image {.cdecl, importc.}
proc nk_subimage_id*(a1: cint; w: nk_ushort; h: nk_ushort; sub_region: nk_rect): nk_image {.cdecl, importc.}
proc nk_subimage_handle*(a1: nk_handle; w: nk_ushort; h: nk_ushort; sub_region: nk_rect): nk_image {.cdecl, importc.}
proc nk_nine_slice_handle*(a1: nk_handle; l: nk_ushort; t: nk_ushort; r: nk_ushort; b: nk_ushort): nk_nine_slice {.cdecl, importc.}
proc nk_nine_slice_ptr*(a1: pointer; l: nk_ushort; t: nk_ushort; r: nk_ushort; b: nk_ushort): nk_nine_slice {.cdecl, importc.}
proc nk_nine_slice_id*(a1: cint; l: nk_ushort; t: nk_ushort; r: nk_ushort; b: nk_ushort): nk_nine_slice {.cdecl, importc.}
proc nk_nine_slice_is_sub9slice*(img: ptr nk_nine_slice): cint {.cdecl, importc.}
proc nk_sub9slice_ptr*(a1: pointer; w: nk_ushort; h: nk_ushort; sub_region: nk_rect; l: nk_ushort; t: nk_ushort; r: nk_ushort; b: nk_ushort): nk_nine_slice {.cdecl, importc.}
proc nk_sub9slice_id*(a1: cint; w: nk_ushort; h: nk_ushort; sub_region: nk_rect; l: nk_ushort; t: nk_ushort; r: nk_ushort; b: nk_ushort): nk_nine_slice {.cdecl, importc.}
proc nk_sub9slice_handle*(a1: nk_handle; w: nk_ushort; h: nk_ushort; sub_region: nk_rect; l: nk_ushort; t: nk_ushort; r: nk_ushort; b: nk_ushort): nk_nine_slice {.cdecl, importc.}
proc nk_murmur_hash*(key: pointer; len: cint; seed: nk_hash): nk_hash {.cdecl, importc.}
proc nk_triangle_from_direction*(result: ptr nk_vec2; r: nk_rect; pad_x: cfloat; pad_y: cfloat; a5: nk_heading) {.cdecl, importc.}
proc nk_vec2_init*(x: cfloat; y: cfloat): nk_vec2 {.cdecl, importc: "nk_vec2".}
proc nk_vec2i_init*(x: cint; y: cint): nk_vec2 {.cdecl, importc: "nk_vec2i".}
proc nk_vec2v*(xy: ptr cfloat): nk_vec2 {.cdecl, importc.}
proc nk_vec2iv*(xy: ptr cint): nk_vec2 {.cdecl, importc.}
proc nk_get_null_rect*(): nk_rect {.cdecl, importc.}
proc nk_rect_init*(x: cfloat; y: cfloat; w: cfloat; h: cfloat): nk_rect {.cdecl, importc: "nk_rect".}
proc nk_recti_init*(x: cint; y: cint; w: cint; h: cint): nk_rect {.cdecl, importc:  "nk_recti".}
proc nk_recta*(pos: nk_vec2; size: nk_vec2): nk_rect {.cdecl, importc.}
proc nk_rectv*(xywh: ptr cfloat): nk_rect {.cdecl, importc.}
proc nk_rectiv*(xywh: ptr cint): nk_rect {.cdecl, importc.}
proc nk_rect_pos*(a1: nk_rect): nk_vec2 {.cdecl, importc.}
proc nk_rect_size*(a1: nk_rect): nk_vec2 {.cdecl, importc.}
proc nk_strlen*(str: cstring): cint {.cdecl, importc.}
proc nk_stricmp*(s1: cstring; s2: cstring): cint {.cdecl, importc.}
proc nk_stricmpn*(s1: cstring; s2: cstring; n: cint): cint {.cdecl, importc.}
proc nk_strtoi*(str: cstring; endptr: cstringArray): cint {.cdecl, importc.}
proc nk_strtof*(str: cstring; endptr: cstringArray): cfloat {.cdecl, importc.}
proc nk_strtod*(str: cstring; endptr: cstringArray): cdouble {.cdecl, importc.}
proc nk_strfilter*(text: cstring; regexp: cstring): cint {.cdecl, importc.}
proc nk_strmatch_fuzzy_string*(str: cstring; pattern: cstring; out_score: ptr cint): cint {.cdecl, importc.}
proc nk_strmatch_fuzzy_text*(txt: cstring; txt_len: cint; pattern: cstring; out_score: ptr cint): cint {.cdecl, importc.}
proc nk_utf_decode*(a1: cstring; a2: ptr nk_rune; a3: cint): cint {.cdecl, importc.}
proc nk_utf_encode*(a1: nk_rune; a2: cstring; a3: cint): cint {.cdecl, importc.}
proc nk_utf_len*(a1: cstring; byte_len: cint): cint {.cdecl, importc.}
proc nk_utf_at*(buffer: cstring; length: cint; index: cint; unicode: ptr nk_rune; len: ptr cint): cstring {.cdecl, importc.}
proc nk_font_atlas_init_default*(atlas: ptr nk_font_atlas) {.cdecl, importc.}
# proc nk_font_atlas_init_default*(atlas: ptr nk_font_atlas) =
#   block outer:
#     assert(atlas != nil)
#     if isNil(atlas): break outer
#     zeroMem(atlas, sizeof(atlas[]))
#     atlas.temporary.userdata.`ptr` = nil
#     atlas.temporary.alloc = nk_malloc
#     atlas.temporary.free = nk_mfree
#     atlas.permanent.userdata.`ptr` = nil
#     atlas.permanent.alloc = nk_malloc
#     atlas.permanent.free = nk_mfree

proc nk_font_atlas_begin*(a1: ptr nk_font_atlas) {.cdecl, importc.}
proc nk_font_atlas_bake*(atlas: ptr nk_font_atlas; width, height: ptr int32; fmt: nk_font_atlas_format): pointer {.cdecl, importc.}
proc nk_font_atlas_end*(atlas: ptr nk_font_atlas; texture: nk_handle; tex_null: ptr nk_draw_null_texture) {.cdecl, importc.}
proc nk_font_atlas_cleanup*(atlas: ptr nk_font_atlas) {.cdecl, importc.}


proc nk_buffer_init*(a1: ptr nk_buffer; a2: ptr nk_allocator; size: nk_size) {.cdecl, importc.}
proc nk_buffer_init_default*(buffer: ptr nk_buffer) {.cdecl, importc.}
# proc nk_buffer_init_default*(buffer: ptr nk_buffer) =
#   var alloc: nk_allocator
#   alloc.userdata.`ptr` = nil
#   alloc.alloc = nk_malloc
#   alloc.free = nk_mfree
#   nk_buffer_init(buffer, addr(alloc), NK_BUFFER_DEFAULT_INITIAL_SIZE)
proc nk_buffer_init_fixed*(a1: ptr nk_buffer; memory: pointer; size: nk_size) {.cdecl, importc.}
proc nk_buffer_info*(a1: ptr nk_memory_status; a2: ptr nk_buffer) {.cdecl, importc.}
proc nk_buffer_push*(a1: ptr nk_buffer; `type`: nk_buffer_allocation_type; memory: pointer; size: nk_size; align: nk_size) {.cdecl, importc.}
proc nk_buffer_mark*(a1: ptr nk_buffer; `type`: nk_buffer_allocation_type) {.cdecl, importc.}
proc nk_buffer_reset*(a1: ptr nk_buffer; `type`: nk_buffer_allocation_type) {.cdecl, importc.}
proc nk_buffer_clear*(a1: ptr nk_buffer) {.cdecl, importc.}
proc nk_buffer_free*(a1: ptr nk_buffer) {.cdecl, importc.}
proc nk_buffer_memory*(a1: ptr nk_buffer): pointer {.cdecl, importc.}
proc nk_buffer_memory_const*(a1: ptr nk_buffer): pointer {.cdecl, importc.}
proc nk_buffer_total*(a1: ptr nk_buffer): nk_size {.cdecl, importc.}
proc nk_str_init*(a1: ptr nk_str; a2: ptr nk_allocator; size: nk_size) {.cdecl, importc.}
proc nk_str_init_fixed*(a1: ptr nk_str; memory: pointer; size: nk_size) {.cdecl, importc.}
proc nk_str_clear*(a1: ptr nk_str) {.cdecl, importc.}
proc nk_str_free*(a1: ptr nk_str) {.cdecl, importc.}
proc nk_str_append_text_char*(a1: ptr nk_str; a2: cstring; a3: cint): cint {.cdecl, importc.}
proc nk_str_append_str_char*(a1: ptr nk_str; a2: cstring): cint {.cdecl, importc.}
proc nk_str_append_text_utf8*(a1: ptr nk_str; a2: cstring; a3: cint): cint {.cdecl, importc.}
proc nk_str_append_str_utf8*(a1: ptr nk_str; a2: cstring): cint {.cdecl, importc.}
proc nk_str_append_text_runes*(a1: ptr nk_str; a2: ptr nk_rune; a3: cint): cint {.cdecl, importc.}
proc nk_str_append_str_runes*(a1: ptr nk_str; a2: ptr nk_rune): cint {.cdecl, importc.}
proc nk_str_insert_at_char*(a1: ptr nk_str; pos: cint; a3: cstring; a4: cint): cint {.cdecl, importc.}
proc nk_str_insert_at_rune*(a1: ptr nk_str; pos: cint; a3: cstring; a4: cint): cint {.cdecl, importc.}
proc nk_str_insert_text_char*(a1: ptr nk_str; pos: cint; a3: cstring; a4: cint): cint {.cdecl, importc.}
proc nk_str_insert_str_char*(a1: ptr nk_str; pos: cint; a3: cstring): cint {.cdecl, importc.}
proc nk_str_insert_text_utf8*(a1: ptr nk_str; pos: cint; a3: cstring; a4: cint): cint {.cdecl, importc.}
proc nk_str_insert_str_utf8*(a1: ptr nk_str; pos: cint; a3: cstring): cint {.cdecl, importc.}
proc nk_str_insert_text_runes*(a1: ptr nk_str; pos: cint; a3: ptr nk_rune; a4: cint): cint {.cdecl, importc.}
proc nk_str_insert_str_runes*(a1: ptr nk_str; pos: cint; a3: ptr nk_rune): cint {.cdecl, importc.}
proc nk_str_remove_chars*(a1: ptr nk_str; len: cint) {.cdecl, importc.}
proc nk_str_remove_runes*(str: ptr nk_str; len: cint) {.cdecl, importc.}
proc nk_str_delete_chars*(a1: ptr nk_str; pos: cint; len: cint) {.cdecl, importc.}
proc nk_str_delete_runes*(a1: ptr nk_str; pos: cint; len: cint) {.cdecl, importc.}
proc nk_str_at_char*(a1: ptr nk_str; pos: cint): cstring {.cdecl, importc.}
proc nk_str_at_rune*(a1: ptr nk_str; pos: cint; unicode: ptr nk_rune; len: ptr cint): cstring {.cdecl, importc.}
proc nk_str_rune_at*(a1: ptr nk_str; pos: cint): nk_rune {.cdecl, importc.}
proc nk_str_at_char_const*(a1: ptr nk_str; pos: cint): cstring {.cdecl, importc.}
proc nk_str_at_const*(a1: ptr nk_str; pos: cint; unicode: ptr nk_rune; len: ptr cint): cstring {.cdecl, importc.}
proc nk_str_get*(a1: ptr nk_str): cstring {.cdecl, importc.}
proc nk_str_get_const*(a1: ptr nk_str): cstring {.cdecl, importc.}
proc nk_str_len*(a1: ptr nk_str): cint {.cdecl, importc.}
proc nk_str_len_char*(a1: ptr nk_str): cint {.cdecl, importc.}
proc nk_filter_default*(a1: ptr nk_text_edit; unicode: nk_rune): nk_bool {.cdecl, importc.}
proc nk_filter_ascii*(a1: ptr nk_text_edit; unicode: nk_rune): nk_bool {.cdecl, importc.}
proc nk_filter_float*(a1: ptr nk_text_edit; unicode: nk_rune): nk_bool {.cdecl, importc.}
proc nk_filter_decimal*(a1: ptr nk_text_edit; unicode: nk_rune): nk_bool {.cdecl, importc.}
proc nk_filter_hex*(a1: ptr nk_text_edit; unicode: nk_rune): nk_bool {.cdecl, importc.}
proc nk_filter_oct*(a1: ptr nk_text_edit; unicode: nk_rune): nk_bool {.cdecl, importc.}
proc nk_filter_binary*(a1: ptr nk_text_edit; unicode: nk_rune): nk_bool {.cdecl, importc.}
proc nk_textedit_init*(a1: ptr nk_text_edit; a2: ptr nk_allocator; size: nk_size) {.cdecl, importc.}
proc nk_textedit_init_fixed*(a1: ptr nk_text_edit; memory: pointer; size: nk_size) {.cdecl, importc.}
proc nk_textedit_free*(a1: ptr nk_text_edit) {.cdecl, importc.}
proc nk_textedit_text*(a1: ptr nk_text_edit; a2: cstring; total_len: cint) {.cdecl, importc.}
proc nk_textedit_delete*(a1: ptr nk_text_edit; where: cint; len: cint) {.cdecl, importc.}
proc nk_textedit_delete_selection*(a1: ptr nk_text_edit) {.cdecl, importc.}
proc nk_textedit_select_all*(a1: ptr nk_text_edit) {.cdecl, importc.}
proc nk_textedit_cut*(a1: ptr nk_text_edit): nk_bool {.cdecl, importc.}
proc nk_textedit_paste*(a1: ptr nk_text_edit; a2: cstring; len: cint): nk_bool {.cdecl, importc.}
proc nk_textedit_undo*(a1: ptr nk_text_edit) {.cdecl, importc.}
proc nk_textedit_redo*(a1: ptr nk_text_edit) {.cdecl, importc.}
proc nk_stroke_line*(b: ptr nk_command_buffer; x0: cfloat; y0: cfloat; x1: cfloat; y1: cfloat; line_thickness: cfloat; a7: nk_color) {.cdecl, importc.}
proc nk_stroke_curve*(a1: ptr nk_command_buffer; a2: cfloat; a3: cfloat; a4: cfloat; a5: cfloat; a6: cfloat; a7: cfloat; a8: cfloat; a9: cfloat; line_thickness: cfloat; a11: nk_color) {.cdecl, importc.}
proc nk_stroke_rect*(a1: ptr nk_command_buffer; a2: nk_rect; rounding: cfloat; line_thickness: cfloat; a5: nk_color) {.cdecl, importc.}
proc nk_stroke_circle*(a1: ptr nk_command_buffer; a2: nk_rect; line_thickness: cfloat; a4: nk_color) {.cdecl, importc.}
proc nk_stroke_arc*(a1: ptr nk_command_buffer; cx: cfloat; cy: cfloat; radius: cfloat; a_min: cfloat; a_max: cfloat; line_thickness: cfloat; a8: nk_color) {.cdecl, importc.}
proc nk_stroke_triangle*(a1: ptr nk_command_buffer; a2: cfloat; a3: cfloat; a4: cfloat; a5: cfloat; a6: cfloat; a7: cfloat; line_thichness: cfloat; a9: nk_color) {.cdecl, importc.}
proc nk_stroke_polyline*(a1: ptr nk_command_buffer; points: ptr cfloat; point_count: cint; line_thickness: cfloat; col: nk_color) {.cdecl, importc.}
proc nk_stroke_polygon*(a1: ptr nk_command_buffer; a2: ptr cfloat; point_count: cint; line_thickness: cfloat; a5: nk_color) {.cdecl, importc.}
proc nk_fill_rect*(a1: ptr nk_command_buffer; a2: nk_rect; rounding: cfloat; a4: nk_color) {.cdecl, importc.}
proc nk_fill_rect_multi_color*(a1: ptr nk_command_buffer; a2: nk_rect; left: nk_color; top: nk_color; right: nk_color; bottom: nk_color) {.cdecl, importc.}
proc nk_fill_circle*(a1: ptr nk_command_buffer; a2: nk_rect; a3: nk_color) {.cdecl, importc.}
proc nk_fill_arc*(a1: ptr nk_command_buffer; cx: cfloat; cy: cfloat; radius: cfloat; a_min: cfloat; a_max: cfloat; a7: nk_color) {.cdecl, importc.}
proc nk_fill_triangle*(a1: ptr nk_command_buffer; x0: cfloat; y0: cfloat; x1: cfloat; y1: cfloat; x2: cfloat; y2: cfloat; a8: nk_color) {.cdecl, importc.}
proc nk_fill_polygon*(a1: ptr nk_command_buffer; a2: ptr cfloat; point_count: cint; a4: nk_color) {.cdecl, importc.}
proc nk_draw_image*(a1: ptr nk_command_buffer; a2: nk_rect; a3: ptr nk_image; a4: nk_color) {.cdecl, importc.}
proc nk_draw_nine_slice*(a1: ptr nk_command_buffer; a2: nk_rect; a3: ptr nk_nine_slice; a4: nk_color) {.cdecl, importc.}
proc nk_draw_text*(a1: ptr nk_command_buffer; a2: nk_rect; text: cstring; len: cint; a5: ptr nk_user_font; a6: nk_color; a7: nk_color) {.cdecl, importc.}
proc nk_push_scissor*(a1: ptr nk_command_buffer; a2: nk_rect) {.cdecl, importc.}
proc nk_push_custom*(a1: ptr nk_command_buffer; a2: nk_rect; a3: nk_command_custom_callback; usr: nk_handle) {.cdecl, importc.}
proc nk_input_has_mouse_click*(a1: ptr nk_input; a2: nk_buttons): nk_bool {.cdecl, importc.}
proc nk_input_has_mouse_click_in_rect*(a1: ptr nk_input; a2: nk_buttons; a3: nk_rect): nk_bool {.cdecl, importc.}
proc nk_input_has_mouse_click_in_button_rect*(a1: ptr nk_input; a2: nk_buttons; a3: nk_rect): nk_bool {.cdecl, importc.}
proc nk_input_has_mouse_click_down_in_rect*(a1: ptr nk_input; a2: nk_buttons; a3: nk_rect; down: nk_bool): nk_bool {.cdecl, importc.}
proc nk_input_is_mouse_click_in_rect*(a1: ptr nk_input; a2: nk_buttons; a3: nk_rect): nk_bool {.cdecl, importc.}
proc nk_input_is_mouse_click_down_in_rect*(i: ptr nk_input; id: nk_buttons; b: nk_rect; down: nk_bool): nk_bool {.cdecl, importc.}
proc nk_input_any_mouse_click_in_rect*(a1: ptr nk_input; a2: nk_rect): nk_bool {.cdecl, importc.}
proc nk_input_is_mouse_prev_hovering_rect*(a1: ptr nk_input; a2: nk_rect): nk_bool {.cdecl, importc.}
proc nk_input_is_mouse_hovering_rect*(a1: ptr nk_input; a2: nk_rect): nk_bool {.cdecl, importc.}
proc nk_input_mouse_clicked*(a1: ptr nk_input; a2: nk_buttons; a3: nk_rect): nk_bool {.cdecl, importc.}
proc nk_input_is_mouse_down*(a1: ptr nk_input; a2: nk_buttons): nk_bool {.cdecl, importc.}
proc nk_input_is_mouse_pressed*(a1: ptr nk_input; a2: nk_buttons): nk_bool {.cdecl, importc.}
proc nk_input_is_mouse_released*(a1: ptr nk_input; a2: nk_buttons): nk_bool {.cdecl, importc.}
proc nk_input_is_key_pressed*(a1: ptr nk_input; a2: nk_keys): nk_bool {.cdecl, importc.}
proc nk_input_is_key_released*(a1: ptr nk_input; a2: nk_keys): nk_bool {.cdecl, importc.}
proc nk_input_is_key_down*(a1: ptr nk_input; a2: nk_keys): nk_bool {.cdecl, importc.}
proc nk_convert*(ctx: ptr nk_context; cmds, vertices, elements: ptr nk_buffer; config: ptr nk_convert_config): nk_flags {.cdecl, importc.}
proc nk_draw_begin*(ctx: ptr nk_context; buffer: ptr nk_buffer): ptr nk_draw_command {.cdecl, importc: "nk__draw_begin".}
proc nk_draw_next*(cmd: ptr nk_draw_command; buffer: ptr nk_buffer; ctx: ptr nk_context): ptr nk_draw_command {.cdecl, importc: "nk__draw_next".}
proc nk_draw_end*(ctx: ptr nk_context; buffer: ptr nk_buffer): ptr nk_draw_command {.cdecl, importc: "nk__draw_end".}

{.passC: "/IC:\\Users\\Zach\\dev\\frag\\thirdparty\\Nuklear".}
{.compile:"nuklear.c".}