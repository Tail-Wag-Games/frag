#version 450

#include "tone_mapping.glsl"

layout (binding = 0, std140) uniform params {
    float u_Gamma;
};

layout (binding = 0) uniform sampler2D   u_FramebufferSampler;

layout(location = 0) in vec2 i_TexCoord;
layout(location = 0) out vec4 o_FragColor;

void main(void)
{
    vec4 color = vec4(0);
    ivec2 P = ivec2(gl_FragCoord.xy);

    color = texelFetch(u_FramebufferSampler, P, 0);

    if (color.a > 0.0) color.rgb/= color.a;

    // make sure fragments store positive values
    if (any(lessThan(color.rgb, vec3(0)))) {
        o_FragColor = vec4(1, 0, 0, 1);
        return;
    }

    // tone map
    color.rgb = HdrToLdr(color.rgb);

    // final color
    o_FragColor = vec4(color.rgb, 1.0);

    // make sure the fragments store real values
    if (any(isnan(color.rgb)))
        o_FragColor = vec4(1, 0, 0, 1);

    //o_FragColor = vec4(i_TexCoord, 0, 1);
}