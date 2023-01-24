cbuffer params : register(b1)
{
    float _23_u_TargetEdgeLength : packoffset(c0);
    float _23_u_LodFactor : packoffset(c0.y);
    float _23_u_DmapFactor : packoffset(c0.z);
    float _23_u_MinLodVariance : packoffset(c0.w);
};

cbuffer PerFrameVariables : register(b0)
{
    row_major float4x4 _65_u_ModelMatrix : packoffset(c0);
    row_major float4x4 _65_u_ModelViewMatrix : packoffset(c4);
    row_major float4x4 _65_u_ViewMatrix : packoffset(c8);
    row_major float4x4 _65_u_CameraMatrix : packoffset(c12);
    row_major float4x4 _65_u_ViewProjectionMatrix : packoffset(c16);
    row_major float4x4 _65_u_ModelViewProjectionMatrix : packoffset(c20);
    float4 _65_u_FrustumPlanes[6] : packoffset(c24);
};

ByteAddressBuffer u_CbtBuffers[1] : register(t1);
Texture2D<float4> u_SmapSampler : register(t1);
SamplerState _u_SmapSampler_sampler : register(s1);
Texture2D<float4> u_DmapSampler : register(t0);
SamplerState _u_DmapSampler_sampler : register(s0);
Texture2D<float4> u_DmapRockSampler : register(t2);
SamplerState _u_DmapRockSampler_sampler : register(s2);
Texture2D<float4> u_SmapRockSampler : register(t3);
SamplerState _u_SmapRockSampler_sampler : register(s3);

static float2 i_TexCoord;
static float4 o_FragColor;
static float3 i_WorldPos;

struct SPIRV_Cross_Input
{
    float2 i_TexCoord : TEXCOORD2;
    float3 i_WorldPos : TEXCOORD3;
};

struct SPIRV_Cross_Output
{
    float4 o_FragColor : SV_Target0;
};

void frag_main()
{
    float2 smap = (u_SmapSampler.Sample(_u_SmapSampler_sampler, i_TexCoord).xy * _23_u_DmapFactor) * 0.02999999932944774627685546875f;
    float3 n = normalize(float3(-smap, 1.0f));
    float3 wi = 0.57735025882720947265625f.xxx;
    float d = (dot(wi, n) * 0.5f) + 0.5f;
    float3 albedo = float3(0.988235294818878173828125f, 0.77254903316497802734375f, 0.588235318660736083984375f);
    float3 camPos = _65_u_CameraMatrix[3].xyz;
    o_FragColor = float4(1.0f, 0.0f, 0.0f, 1.0f);
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    i_TexCoord = stage_input.i_TexCoord;
    i_WorldPos = stage_input.i_WorldPos;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output.o_FragColor = o_FragColor;
    return stage_output;
}
