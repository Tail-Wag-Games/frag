import cbt

{.passC: "/IC:\\Users\\Zach\\dev\\frag\\thirdparty".}
{.compile: "C:\\Users\\Zach\\dev\\frag\\thirdparty\\leb.c".}

proc decodeNodeAttributeArray*(node: Node; attributeArraySize: int64; attributeArray: openArray[array[3, float32]]) {.importc: "leb_DecodeNodeAttributeArray".}