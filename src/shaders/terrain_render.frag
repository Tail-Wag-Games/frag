#version 450

layout(std430, binding = 1) readonly buffer cbt_Buffer {
    uint heap[];
} u_CbtBuffers[1];

layout (binding = 0) uniform sampler2D u_DmapSampler;
layout (binding = 1) uniform sampler2D u_SmapSampler;

// #include "bruneton_atmosphere.glsl"
#include "frustum_culling.glsl"
#include "cbt_readonly.glsl"
#include "leb.glsl"
#include "terrain_common.glsl"

layout(location = TEXCOORD0) in vec2 i_TexCoord;
layout(location = TEXCOORD1) in vec3 i_WorldPos;

layout(location = SV_Target0) out vec4 o_FragColor;

void main()
{
    float filterSize = 1.0f / float(textureSize(u_DmapSampler, 0).x);// sqrt(dot(dFdx(texCoord), dFdy(texCoord)));
    float sx0 = textureLod(u_DmapSampler, i_TexCoord - vec2(filterSize, 0.0), 0.0).r;
    float sx1 = textureLod(u_DmapSampler, i_TexCoord + vec2(filterSize, 0.0), 0.0).r;
    float sy0 = textureLod(u_DmapSampler, i_TexCoord - vec2(0.0, filterSize), 0.0).r;
    float sy1 = textureLod(u_DmapSampler, i_TexCoord + vec2(0.0, filterSize), 0.0).r;
    float sx = sx1 - sx0;
    float sy = sy1 - sy0;

    vec3 n = normalize(vec3(u_DmapFactor * 0.03 / filterSize * 0.5f * vec2(-sx, -sy), 1));


    vec3 wi = normalize(vec3(1, 1, 1));
    float d = dot(wi, n) * 0.5 + 0.5;
    vec3 albedo = vec3(252, 197, 150) / 255.0f;

    vec3 shading = (d / 3.14159) * albedo;

    o_FragColor = vec4(shading * 0.5, 1);
    // o_FragColor = vec4(1, 0, 0, 1);
}