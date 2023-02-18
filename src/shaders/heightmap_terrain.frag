#version 450

layout (location = POSITION) in vec3 v_position;
layout (location = TEXCOORD0) in vec2 v_texcoord0;

layout (location = SV_Target0) out vec4 frag_color;

void main()
{
    frag_color = vec4(v_texcoord0.x, v_texcoord0.y, v_position.y / 50.0, 1.0);
}