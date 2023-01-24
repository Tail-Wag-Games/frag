#version 450

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
    // slope
    vec2 smap = texture(u_SmapSampler, i_TexCoord).rg * u_DmapFactor * 0.03;
    vec3 n = normalize(vec3(-smap, 1));

    vec3 wi = normalize(vec3(1, 1, 1));
    float d = dot(wi, n) * 0.5 + 0.5;
    vec3 albedo = vec3(252, 197, 150) / 255.0f;
    vec3 camPos = u_CameraMatrix[3].xyz;
    /*vec3 extinction;
    vec3 inscatter = inScattering(camPos.zxy + earthPos,
                                  i_WorldPos.zxy + earthPos,
                                  wi.zxy,
                                  extinction);

    vec3 shading = (d / 3.14159) * albedo;

    o_FragColor = vec4(shading * extinction + inscatter * 0.5, 1);*/
    o_FragColor = vec4(1, 0, 0, 1);
}