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
layout (location = TEXCOORD2) out float height;
layout (location = TEXCOORD3) out vec4 o_Color;

// this comes from the book Real-Time 3D Terrain Engines Using C++ And DirectX 
float computeWeight(float value, float minExtent, float maxExtent)
{
	float weight = 0.0;
				
	if(value >= minExtent && value <= maxExtent)
	{
		float range = maxExtent - minExtent;
		
		weight = value - minExtent;
						
		// convert to [0, 1] based on its distance to midpoint of the extents
		weight *= 1.0 / range;
		weight -= 0.5;
		weight *= 2.0;
						
		// square result for non-linear falloff
		weight *= weight;
						
		// invert and bound check
		weight = 1.0 - abs(weight);
		weight = clamp(weight, 0.001, 1.0);
	}
					
	return weight;
}


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

    height = attrib.position.y;

    vec3 light = -normalize( vec3(1.0, -1.0, 0.0) );
    vec4 mapStrength = vec4(1.0, 0.4, 0.28, 0.86);

    vec4 dirtColor = vec4(62.0, 39.0, 49.0, 255.0) / 255.0;
    vec4 dirtData = vec4(0.0, 128.0, 0.0, 0.83);
    vec4 grassColor = vec4(38.0, 92.0, 66.0, 255.0) / 255.0;
    vec4 grassData = vec4(0.0, 128.0, 0.0, 0.66);
    vec4 rockColor = vec4(90.0, 105.0, 136.0, 255.0) / 255.0;
    vec4 rockData = vec4(0.0, 255.0, 0.16, 1.0);
    vec4 snowColor = vec4(1.0, 1.0, 1.0, 1.0);
    vec4 snowData = vec4(128.0, 255.0, 0.0, 0.7);

    vec4 h;
    float texelSize = 1.0f / float(textureSize(u_DmapSampler, 0).x);
    h.x = textureLod(u_DmapSampler, attrib.texCoord + texelSize*vec2( 0,-1), 0).r * 255.0; 
    h.y = textureLod(u_DmapSampler, attrib.texCoord + texelSize*vec2(-1, 0), 0).r * 255.0; 
    h.z = textureLod(u_DmapSampler, attrib.texCoord + texelSize*vec2( 1, 0), 0).r * 255.0; 
    h.w = textureLod(u_DmapSampler, attrib.texCoord + texelSize*vec2( 0, 1), 0).r * 255.0; 
    
    vec3 n; 
    n.z = h.x - h.w; 
    n.x = h.y - h.z; 
    n.y = 2;
    n = normalize(n);

    float l = max( dot( n, light ), 0.0 ) * 0.5 + 0.5;
    float slope = 1.0 - n.y;

    vec4 weights = vec4(0.0, 0.0, 0.0, 0.0);
    weights.x = computeWeight(height, rockData.x, rockData.y) * 
				computeWeight(slope, rockData.z, rockData.w) * mapStrength.z;
	weights.y = computeWeight(height, dirtData.x, dirtData.y) * 
				computeWeight(slope, dirtData.z, dirtData.w) * mapStrength.y;
	weights.z = computeWeight(height, snowData.x, snowData.y) * 
				computeWeight(slope, snowData.z, snowData.w) * mapStrength.w;
	weights.w = computeWeight(height, grassData.x, grassData.y) * 
				computeWeight(slope, grassData.z, grassData.w) * mapStrength.x;
	weights *= 1.0 / (weights.x + weights.y + weights.z + weights.w);
				
	vec4 finalColor = vec4(0.0, 0.0, 0.0, 1.0);
	vec4 tempColor = vec4(0.0, 0.0, 0.0, 1.0);

    finalColor += weights.y * dirtColor;
    finalColor += weights.w * grassColor;
    finalColor += weights.x * rockColor;
    finalColor += weights.z * snowColor;
    
    gl_Position = u_ModelViewProjectionMatrix * attrib.position;
    o_Color = finalColor * l;
    o_TexCoord  = attrib.texCoord;
    o_WorldPos  = (u_ModelMatrix * attrib.position).xyz;
}
