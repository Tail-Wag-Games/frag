cbuffer params : register(b1)
{
    float _165_u_TargetEdgeLength : packoffset(c0);
    float _165_u_LodFactor : packoffset(c0.y);
    float _165_u_DmapFactor : packoffset(c0.z);
    float _165_u_MinLodVariance : packoffset(c0.w);
};

ByteAddressBuffer u_CbtBuffers[1] : register(t1);
cbuffer PerFrameVariables : register(b0)
{
    row_major float4x4 _350_u_ModelMatrix : packoffset(c0);
    row_major float4x4 _350_u_ModelViewMatrix : packoffset(c4);
    row_major float4x4 _350_u_ViewMatrix : packoffset(c8);
    row_major float4x4 _350_u_CameraMatrix : packoffset(c12);
    row_major float4x4 _350_u_ViewProjectionMatrix : packoffset(c16);
    row_major float4x4 _350_u_ModelViewProjectionMatrix : packoffset(c20);
    float4 _350_u_FrustumPlanes[6] : packoffset(c24);
};

Texture2D<float4> u_DmapSampler : register(t0);
SamplerState _u_DmapSampler_sampler : register(s0);
Texture2D<float4> u_SmapSampler : register(t1);
SamplerState _u_SmapSampler_sampler : register(s1);

static float2 i_TexCoord;
static float height;
static float4 o_FragColor;
static float3 i_WorldPos;

struct SPIRV_Cross_Input
{
    float2 i_TexCoord : TEXCOORD2;
    float3 i_WorldPos : TEXCOORD3;
    float height : TEXCOORD4;
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

float computeWeight(float value, float minExtent, float maxExtent)
{
    float weight = 0.0f;
    if ((value >= minExtent) && (value <= maxExtent))
    {
        float range = maxExtent - minExtent;
        weight = value - minExtent;
        weight *= (1.0f / range);
        weight -= 0.5f;
        weight *= 2.0f;
        weight *= weight;
        weight = 1.0f - abs(weight);
        weight = clamp(weight, 0.001000000047497451305389404296875f, 1.0f);
    }
    return weight;
}

void frag_main()
{
    float3 light = float3(-0.707106769084930419921875f, 0.707106769084930419921875f, -0.0f);
    float4 mapStrength = float4(1.0f, 0.4000000059604644775390625f, 0.2800000011920928955078125f, 0.86000001430511474609375f);
    float4 dirtColor = float4(0.24313725531101226806640625f, 0.15294118225574493408203125f, 0.19215686619281768798828125f, 1.0f);
    float4 dirtData = float4(0.0f, 34132.0f, 0.0f, 0.829999983310699462890625f);
    float4 grassColor = float4(0.14901961386203765869140625f, 0.3607843220233917236328125f, 0.2588235437870025634765625f, 1.0f);
    float4 grassData = float4(0.0f, 32767.0f, 0.0f, 0.660000026226043701171875f);
    float4 rockColor = float4(0.3529411852359771728515625f, 0.4117647111415863037109375f, 0.533333361148834228515625f, 1.0f);
    float4 rockData = float4(0.0f, 65535.0f, 0.1599999964237213134765625f, 1.0f);
    float4 snowColor = 1.0f.xxxx;
    float4 snowData = float4(30246.0f, 65535.0f, 0.0f, 0.699999988079071044921875f);
    uint _113_dummy_parameter;
    float filterSize = 1.0f / float(int2(SPIRV_Cross_textureSize(u_DmapSampler, uint(0), _113_dummy_parameter)).x);
    float sx0 = u_DmapSampler.SampleLevel(_u_DmapSampler_sampler, i_TexCoord - float2(filterSize, 0.0f), 0.0f).x;
    float sx1 = u_DmapSampler.SampleLevel(_u_DmapSampler_sampler, i_TexCoord + float2(filterSize, 0.0f), 0.0f).x;
    float sy0 = u_DmapSampler.SampleLevel(_u_DmapSampler_sampler, i_TexCoord - float2(0.0f, filterSize), 0.0f).x;
    float sy1 = u_DmapSampler.SampleLevel(_u_DmapSampler_sampler, i_TexCoord + float2(0.0f, filterSize), 0.0f).x;
    float sx = sx1 - sx0;
    float sy = sy1 - sy0;
    float3 n = normalize(float3(float2(-sx, -sy) * ((_165_u_DmapFactor / filterSize) * 0.5f), 1.0f));
    float l = (max(dot(n, light), 0.0f) * 0.5f) + 0.5f;
    float slope = 1.0f - n.z;
    float4 weights = 0.0f.xxxx;
    float param = height;
    float param_1 = rockData.x;
    float param_2 = rockData.y;
    float param_3 = slope;
    float param_4 = rockData.z;
    float param_5 = rockData.w;
    weights.x = (computeWeight(param, param_1, param_2) * computeWeight(param_3, param_4, param_5)) * mapStrength.z;
    float param_6 = height;
    float param_7 = dirtData.x;
    float param_8 = dirtData.y;
    float param_9 = slope;
    float param_10 = dirtData.z;
    float param_11 = dirtData.w;
    weights.y = (computeWeight(param_6, param_7, param_8) * computeWeight(param_9, param_10, param_11)) * mapStrength.y;
    float param_12 = height;
    float param_13 = snowData.x;
    float param_14 = snowData.y;
    float param_15 = slope;
    float param_16 = snowData.z;
    float param_17 = snowData.w;
    weights.z = (computeWeight(param_12, param_13, param_14) * computeWeight(param_15, param_16, param_17)) * mapStrength.w;
    float param_18 = height;
    float param_19 = grassData.x;
    float param_20 = grassData.y;
    float param_21 = slope;
    float param_22 = grassData.z;
    float param_23 = grassData.w;
    weights.w = (computeWeight(param_18, param_19, param_20) * computeWeight(param_21, param_22, param_23)) * mapStrength.x;
    weights *= (1.0f / (((weights.x + weights.y) + weights.z) + weights.w));
    float4 finalColor = float4(0.0f, 0.0f, 0.0f, 1.0f);
    float4 tempColor = float4(0.0f, 0.0f, 0.0f, 1.0f);
    finalColor += (dirtColor * weights.y);
    finalColor += (grassColor * weights.w);
    finalColor += (rockColor * weights.x);
    finalColor += (snowColor * weights.z);
    o_FragColor = finalColor * l;
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    i_TexCoord = stage_input.i_TexCoord;
    height = stage_input.height;
    i_WorldPos = stage_input.i_WorldPos;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output.o_FragColor = o_FragColor;
    return stage_output;
}
