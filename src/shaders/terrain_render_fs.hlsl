cbuffer params : register(b1)
{
    float _80_u_TargetEdgeLength : packoffset(c0);
    float _80_u_LodFactor : packoffset(c0.y);
    float _80_u_DmapFactor : packoffset(c0.z);
    float _80_u_MinLodVariance : packoffset(c0.w);
};

ByteAddressBuffer u_CbtBuffers[1] : register(t1);
cbuffer PerFrameVariables : register(b0)
{
    row_major float4x4 _140_u_ModelMatrix : packoffset(c0);
    row_major float4x4 _140_u_ModelViewMatrix : packoffset(c4);
    row_major float4x4 _140_u_ViewMatrix : packoffset(c8);
    row_major float4x4 _140_u_CameraMatrix : packoffset(c12);
    row_major float4x4 _140_u_ViewProjectionMatrix : packoffset(c16);
    row_major float4x4 _140_u_ModelViewProjectionMatrix : packoffset(c20);
    float4 _140_u_FrustumPlanes[6] : packoffset(c24);
};

Texture2D<float4> u_DmapSampler : register(t0);
SamplerState _u_DmapSampler_sampler : register(s0);
Texture2D<float4> u_SmapSampler : register(t1);
SamplerState _u_SmapSampler_sampler : register(s1);

static float2 i_TexCoord;
static float4 o_FragColor;
static float3 i_WorldPos;
static float height;
static float4 i_Color;

struct SPIRV_Cross_Input
{
    float2 i_TexCoord : TEXCOORD2;
    float3 i_WorldPos : TEXCOORD3;
    float height : TEXCOORD4;
    float4 i_Color : TEXCOORD5;
};

struct SPIRV_Cross_Output
{
    float4 o_FragColor : SV_Target0;
};

uint2 SPIRV_Cross_textureSize(Texture2D<float4> Tex, uint Level, out uint Param)
{
    uint2 ret;
    Tex.GetDimensions(Level, ret.x, ret.y, Param);
    return ret;
}

void frag_main()
{
    uint _19_dummy_parameter;
    float filterSize = 1.0f / float(int2(SPIRV_Cross_textureSize(u_DmapSampler, uint(0), _19_dummy_parameter)).x);
    float sx0 = u_DmapSampler.SampleLevel(_u_DmapSampler_sampler, i_TexCoord - float2(filterSize, 0.0f), 0.0f).x * 255.0f;
    float sx1 = u_DmapSampler.SampleLevel(_u_DmapSampler_sampler, i_TexCoord + float2(filterSize, 0.0f), 0.0f).x * 255.0f;
    float sy0 = u_DmapSampler.SampleLevel(_u_DmapSampler_sampler, i_TexCoord - float2(0.0f, filterSize), 0.0f).x * 255.0f;
    float sy1 = u_DmapSampler.SampleLevel(_u_DmapSampler_sampler, i_TexCoord + float2(0.0f, filterSize), 0.0f).x * 255.0f;
    float sx = sx1 - sx0;
    float sy = sy1 - sy0;
    float3 n = normalize(float3(float2(-sx, -sy) * (((_80_u_DmapFactor * 0.02999999932944774627685546875f) / filterSize) * 0.5f), 1.0f));
    float3 wi = 0.57735025882720947265625f.xxx;
    float d = (dot(wi, n) * 0.5f) + 0.5f;
    float3 albedo = float3(0.988235294818878173828125f, 0.77254903316497802734375f, 0.588235318660736083984375f);
    float3 shading = albedo * (d / 3.141590118408203125f);
    o_FragColor = float4(shading, 1.0f);
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    i_TexCoord = stage_input.i_TexCoord;
    i_WorldPos = stage_input.i_WorldPos;
    height = stage_input.height;
    i_Color = stage_input.i_Color;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output.o_FragColor = o_FragColor;
    return stage_output;
}
