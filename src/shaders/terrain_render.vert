#version 450

layout(std430, binding = 1) readonly buffer cbt_Buffer {
    uint heap[];
} u_CbtBuffers[1];

layout (binding = 0) uniform sampler2D u_DmapSampler;

#include "frustum_culling.glsl"
#include "cbt_readonly.glsl"
#include "leb.glsl"
#include "terrain_common.glsl"

layout(location = POSITION) in vec2 i_VertexPos;

layout(location = TEXCOORD0) out vec2 o_TexCoord;
layout(location = TEXCOORD1) out vec3 o_WorldPos;

void main()
{
    const int cbtID = 0;
    uint nodeID = gl_InstanceIndex;
    cbt_Node node = cbt_DecodeNode(cbtID, nodeID);
    vec4 triangleVertices[3] = DecodeTriangleVertices(node);
    vec2 triangleTexCoords[3] = vec2[3](
        triangleVertices[0].xy,
        triangleVertices[1].xy,
        triangleVertices[2].xy
    );

    // compute final vertex attributes
    VertexAttribute attrib = TessellateTriangle(
        triangleTexCoords,
        i_VertexPos
    );

    gl_Position = u_ModelViewProjectionMatrix * attrib.position;
    o_TexCoord  = attrib.texCoord;
    o_WorldPos  = (u_ModelMatrix * attrib.position).xyz;
}
