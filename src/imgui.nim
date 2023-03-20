import nuklear

type
  ImguiApi* = object
    begin*: proc(title: cstring; bounds: nk_rect; flags: nk_flags): bool {.cdecl.}
    finish*: proc() {.cdecl.}

    layoutRow*: proc(fmt: nk_layout_format; height: float32; cols: int32; ratio: ptr float32) {.cdecl.}
    layoutRowDynamic*: proc(height: float32; cols: int32) {.cdecl.}
    spacing*: proc(cols: int32) {.cdecl.}

    label*: proc(str: cstring; alignment: nk_flags) {.cdecl.}

    buttonLabel*: proc(str: cstring): bool {.cdecl.}
    buttonText*: proc(str: cstring; len: int32): bool {.cdecl.}

    render*: proc() {.cdecl.}

var imguiApi*: ImguiApi
