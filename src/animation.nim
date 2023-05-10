import tnt

type
  AnimationApi* = object
    draw*: proc(mvp: ptr Mat4) {.cdecl.}

var animationApi*: AnimationApi
