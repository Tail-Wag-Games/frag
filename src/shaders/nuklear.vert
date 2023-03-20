#version 450

layout (location = POSITION) in vec2 a_pos;
layout (location = TEXCOORD0) in vec2 a_uv;
layout (location = COLOR0) in vec4 a_color;

layout (location = COLOR0) out vec4 f_color;
layout (location = TEXCOORD0) out vec2 f_uv;

layout (binding = 0, std140) uniform vs_params {
    vec4 disp_size;
};

void main()
{
    gl_Position = vec4(((a_pos/disp_size.xy)-0.5)*vec2(2.0,-2.0), 0.5, 1.0);
    f_uv = a_uv;
    f_color = a_color;
}