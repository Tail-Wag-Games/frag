#version 450

#include "tone_mapping.glsl"

layout (binding = 0, std140) uniform params {
    float u_Gamma;
};

layout (binding = 0) uniform sampler2D   u_FramebufferSampler;

layout(location = 0) out vec2 o_TexCoord;

void main(void)
{
    o_TexCoord  = vec2(gl_VertexIndex & 1, gl_VertexIndex >> 1 & 1);
    gl_Position = vec4(2.0 * o_TexCoord - 1.0, 0.0, 1.0);
}