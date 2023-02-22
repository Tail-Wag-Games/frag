struct cbt_Node
{
    uint id;
    int depth;
};

struct cbt_HeapArgs
{
    uint heapIndexLSB;
    uint heapIndexMSB;
    uint bitOffsetLSB;
    uint bitCountLSB;
    uint bitCountMSB;
};

struct VertexAttribute
{
    float4 position;
    float2 texCoord;
};

ByteAddressBuffer u_CbtBuffers[1] : register(t1);
cbuffer params : register(b1)
{
    float _471_u_TargetEdgeLength : packoffset(c0);
    float _471_u_LodFactor : packoffset(c0.y);
    float _471_u_DmapFactor : packoffset(c0.z);
    float _471_u_MinLodVariance : packoffset(c0.w);
};

cbuffer PerFrameVariables : register(b0)
{
    row_major float4x4 _610_u_ModelMatrix : packoffset(c0);
    row_major float4x4 _610_u_ModelViewMatrix : packoffset(c4);
    row_major float4x4 _610_u_ViewMatrix : packoffset(c8);
    row_major float4x4 _610_u_CameraMatrix : packoffset(c12);
    row_major float4x4 _610_u_ViewProjectionMatrix : packoffset(c16);
    row_major float4x4 _610_u_ModelViewProjectionMatrix : packoffset(c20);
    float4 _610_u_FrustumPlanes[6] : packoffset(c24);
};

Texture2D<float4> u_DmapSampler : register(t0);
SamplerState _u_DmapSampler_sampler : register(s0);

static float4 gl_Position;
static int gl_InstanceIndex;
static float2 i_VertexPos;
static float height;
static float2 o_TexCoord;
static float3 o_WorldPos;

struct SPIRV_Cross_Input
{
    float2 i_VertexPos : POSITION;
    uint gl_InstanceIndex : SV_InstanceID;
};

struct SPIRV_Cross_Output
{
    float2 o_TexCoord : TEXCOORD2;
    float3 o_WorldPos : TEXCOORD3;
    float height : TEXCOORD4;
    float4 gl_Position : SV_Position;
};

cbt_Node cbt_CreateNode(uint id, int depth)
{
    cbt_Node node;
    node.id = id;
    node.depth = depth;
    return node;
}

int cbt_MaxDepth(int cbtID)
{
    return int(firstbitlow(u_CbtBuffers[cbtID].Load(0)));
}

int cbt_NodeBitSize(int cbtID, cbt_Node node)
{
    return (cbt_MaxDepth(cbtID) - node.depth) + 1;
}

uint cbt_NodeBitID(int cbtID, cbt_Node node)
{
    uint tmp1 = 2u << uint(node.depth);
    uint tmp2 = uint((1 + cbt_MaxDepth(cbtID)) - node.depth);
    return tmp1 + (node.id * tmp2);
}

uint cbt_HeapByteSize(uint cbtMaxDepth)
{
    return 1u << (cbtMaxDepth - 1u);
}

uint cbt_HeapUint32Size(uint cbtMaxDepth)
{
    uint param = cbtMaxDepth;
    return cbt_HeapByteSize(param) >> uint(2);
}

cbt_HeapArgs cbt_CreateHeapArgs(int cbtID, cbt_Node node, int _bitCount)
{
    uint alignedBitOffset = cbt_NodeBitID(cbtID, node);
    uint param = uint(cbt_MaxDepth(cbtID));
    uint maxHeapIndex = cbt_HeapUint32Size(param) - 1u;
    uint heapIndexLSB = alignedBitOffset >> 5u;
    uint heapIndexMSB = min((heapIndexLSB + 1u), maxHeapIndex);
    cbt_HeapArgs args;
    args.bitOffsetLSB = alignedBitOffset & 31u;
    args.bitCountLSB = min((32u - args.bitOffsetLSB), uint(_bitCount));
    args.bitCountMSB = uint(_bitCount) - args.bitCountLSB;
    args.heapIndexLSB = heapIndexLSB;
    args.heapIndexMSB = heapIndexMSB;
    return args;
}

uint cbt_BitFieldExtract(uint bitField, uint bitOffset, uint _bitCount)
{
    uint bitMask = ~(4294967295u << _bitCount);
    return (bitField >> bitOffset) & bitMask;
}

uint cbt_HeapReadExplicit(int cbtID, cbt_Node node, int _bitCount)
{
    int param = _bitCount;
    cbt_HeapArgs args = cbt_CreateHeapArgs(cbtID, node, param);
    uint param_1 = u_CbtBuffers[cbtID].Load(args.heapIndexLSB * 4 + 0);
    uint param_2 = args.bitOffsetLSB;
    uint param_3 = args.bitCountLSB;
    uint lsb = cbt_BitFieldExtract(param_1, param_2, param_3);
    uint param_4 = u_CbtBuffers[cbtID].Load(args.heapIndexMSB * 4 + 0);
    uint param_5 = 0u;
    uint param_6 = args.bitCountMSB;
    uint msb = cbt_BitFieldExtract(param_4, param_5, param_6);
    return lsb | (msb << args.bitCountLSB);
}

uint cbt_HeapRead(int cbtID, cbt_Node node)
{
    int param = cbt_NodeBitSize(cbtID, node);
    return cbt_HeapReadExplicit(cbtID, node, param);
}

cbt_Node cbt_LeftChildNode_Fast(cbt_Node node)
{
    uint param = node.id << uint(1);
    int param_1 = node.depth + 1;
    return cbt_CreateNode(param, param_1);
}

cbt_Node cbt_DecodeNode(int cbtID, inout uint nodeID)
{
    uint param = 1u;
    int param_1 = 0;
    cbt_Node node = cbt_CreateNode(param, param_1);
    while (cbt_HeapRead(cbtID, node) > 1u)
    {
        cbt_Node leftChild = cbt_LeftChildNode_Fast(node);
        uint cmp = cbt_HeapRead(cbtID, leftChild);
        uint b = (nodeID < cmp) ? 0u : 1u;
        node = leftChild;
        node.id |= b;
        nodeID -= (cmp * b);
    }
    return node;
}

uint leb_GetBitValue(uint bitField, int bitID)
{
    return (bitField >> uint(bitID)) & 1u;
}

float3x3 leb_SquareMatrix(uint quadBit)
{
    float b = float(quadBit);
    float c = 1.0f - b;
    return transpose(float3x3(float3(c, 0.0f, b), float3(b, c, b), float3(b, 0.0f, c)));
}

float3x3 leb_SplittingMatrix(uint splitBit)
{
    float b = float(splitBit);
    float c = 1.0f - b;
    return transpose(float3x3(float3(c, b, 0.0f), float3(0.5f, 0.0f, 0.5f), float3(0.0f, c, b)));
}

float3x3 leb_WindingMatrix(uint mirrorBit)
{
    float b = float(mirrorBit);
    float c = 1.0f - b;
    return float3x3(float3(c, 0.0f, b), float3(0.0f, 1.0f, 0.0f), float3(b, 0.0f, c));
}

float3x3 leb_DecodeTransformationMatrix_Square(cbt_Node node)
{
    int param = max(0, (node.depth - 1));
    uint param_1 = leb_GetBitValue(node.id, param);
    float3x3 xf = leb_SquareMatrix(param_1);
    int _399 = node.depth - 2;
    for (int bitID = _399; bitID >= 0; bitID--)
    {
        int param_2 = bitID;
        uint param_3 = leb_GetBitValue(node.id, param_2);
        xf = mul(xf, leb_SplittingMatrix(param_3));
    }
    uint param_4 = uint((node.depth ^ 1) & 1);
    return mul(xf, leb_WindingMatrix(param_4));
}

float2x3 leb_DecodeNodeAttributeArray_Square(cbt_Node node, float2x3 data)
{
    return mul(data, leb_DecodeTransformationMatrix_Square(node));
}

void DecodeTriangleVertices(out float4 SPIRV_Cross_return_value[3], cbt_Node node)
{
    float3 xPos = float3(0.0f, 0.0f, 1.0f);
    float3 yPos = float3(1.0f, 0.0f, 0.0f);
    float2x3 pos = leb_DecodeNodeAttributeArray_Square(node, float2x3(float3(xPos), float3(yPos)));
    float4 p1 = float4(pos[0].x, pos[1].x, 0.0f, 1.0f);
    float4 p2 = float4(pos[0].y, pos[1].y, 0.0f, 1.0f);
    float4 p3 = float4(pos[0].z, pos[1].z, 0.0f, 1.0f);
    p1.z = _471_u_DmapFactor * u_DmapSampler.SampleLevel(_u_DmapSampler_sampler, p1.xy, 0.0f).x;
    p2.z = _471_u_DmapFactor * u_DmapSampler.SampleLevel(_u_DmapSampler_sampler, p2.xy, 0.0f).x;
    p3.z = _471_u_DmapFactor * u_DmapSampler.SampleLevel(_u_DmapSampler_sampler, p3.xy, 0.0f).x;
    float4 _507[3] = { p1, p2, p3 };
    SPIRV_Cross_return_value = _507;
}

float2 BarycentricInterpolation(float2 v[3], float2 u)
{
    return (v[1] + ((v[2] - v[1]) * u.x)) + ((v[0] - v[1]) * u.y);
}

VertexAttribute TessellateTriangle(float2 texCoords[3], float2 tessCoord)
{
    float2 param[3] = texCoords;
    float2 param_1 = tessCoord;
    float2 texCoord = BarycentricInterpolation(param, param_1);
    float4 position = float4(texCoord, 0.0f, 1.0f);
    position.z = ((-1.0f) * _471_u_DmapFactor) * u_DmapSampler.SampleLevel(_u_DmapSampler_sampler, texCoord, 0.0f).x;
    VertexAttribute _554 = { position, texCoord };
    return _554;
}

void vert_main()
{
    uint nodeID = uint(gl_InstanceIndex);
    uint param = nodeID;
    cbt_Node _565 = cbt_DecodeNode(0, param);
    cbt_Node node = _565;
    float4 _569[3];
    DecodeTriangleVertices(_569, node);
    float4 triangleVertices[3] = _569;
    float2 _580[3] = { triangleVertices[0].xy, triangleVertices[1].xy, triangleVertices[2].xy };
    float2 triangleTexCoords[3] = _580;
    float2 param_1 = i_VertexPos;
    VertexAttribute attrib = TessellateTriangle(triangleTexCoords, param_1);
    attrib.position.z = round(attrib.position.z * 100.0f) / 100.0f;
    height = -attrib.position.z;
    gl_Position = mul(attrib.position, _610_u_ModelViewProjectionMatrix);
    o_TexCoord = attrib.texCoord;
    o_WorldPos = mul(attrib.position, _610_u_ModelMatrix).xyz;
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    gl_InstanceIndex = int(stage_input.gl_InstanceIndex);
    i_VertexPos = stage_input.i_VertexPos;
    vert_main();
    SPIRV_Cross_Output stage_output;
    stage_output.gl_Position = gl_Position;
    stage_output.height = height;
    stage_output.o_TexCoord = o_TexCoord;
    stage_output.o_WorldPos = o_WorldPos;
    return stage_output;
}
