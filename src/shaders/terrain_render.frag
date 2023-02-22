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
layout (location = TEXCOORD2) in float height;

layout(location = SV_Target0) out vec4 o_FragColor;

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
    vec3 light = -normalize( vec3(1.0, -1.0, 0.0) );
    vec4 mapStrength = vec4(1.0, 0.4, 0.28, 0.86);

    vec4 dirtColor = vec4(62.0, 39.0, 49.0, 255.0) / 255.0;
    vec4 dirtData = vec4(0.0, 34132.0, 0.0, 0.83);
    vec4 grassColor = vec4(38.0, 92.0, 66.0, 255.0) / 255.0;
    vec4 grassData = vec4(0.0, 32767.0, 0.0, 0.66);
    vec4 rockColor = vec4(90.0, 105.0, 136.0, 255.0) / 255.0;
    vec4 rockData = vec4(0.0, 65535.0, 0.16, 1.0);
    vec4 snowColor = vec4(1.0, 1.0, 1.0, 1.0);
    vec4 snowData = vec4(30246.0, 65535.0, 0.0, 0.7);

    float filterSize = 1.0f / float(textureSize(u_DmapSampler, 0).x);// sqrt(dot(dFdx(i_TexCoord), dFdy(i_TexCoord)));
    float sx0 = textureLod(u_DmapSampler, i_TexCoord - vec2(filterSize, 0.0), 0.0).r;
    float sx1 = textureLod(u_DmapSampler, i_TexCoord + vec2(filterSize, 0.0), 0.0).r;
    float sy0 = textureLod(u_DmapSampler, i_TexCoord - vec2(0.0, filterSize), 0.0).r;
    float sy1 = textureLod(u_DmapSampler, i_TexCoord + vec2(0.0, filterSize), 0.0).r;
    float sx = sx1 - sx0;
    float sy = sy1 - sy0;

    vec3 n = normalize(vec3(u_DmapFactor / filterSize * 0.5f * vec2(-sx, -sy), 1));

    float l = max( dot( n, light ), 0.0 ) * 0.5 + 0.5;
    float slope = 1.0 - n.z;

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

    o_FragColor = finalColor * l;
    // o_FragColor = vec4(abs(n), 1);
}