#version 450

layout (location = POSITION) in vec3 v_position;
layout (location = TEXCOORD0) in vec2 v_texcoord0;
layout (location = TEXCOORD1) in float height;

layout (binding = 0) uniform sampler2D s_heightTexture;

layout (location = SV_Target0) out vec4 frag_color;

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

    vec4 texel = texture(s_heightTexture, v_texcoord0) * 2.0 - 1.0;


    float filterSize = 1.0f / float(textureSize(s_heightTexture, 0).x);// sqrt(dot(dFdx(texCoord), dFdy(texCoord)));
    float sx0 = textureLod(s_heightTexture, v_texcoord0 + vec2(0.0, -filterSize), 0.0).r * 65535.0;
    float sx1 = textureLod(s_heightTexture, v_texcoord0 + vec2(-filterSize, 0.0), 0.0).r * 65535.0;
    float sy0 = textureLod(s_heightTexture, v_texcoord0 + vec2(filterSize, 0.0), 0.0).r * 65535.0;
    float sy1 = textureLod(s_heightTexture, v_texcoord0 + vec2(0.0, filterSize), 0.0).r * 65535.0;
    // float sx = sx1 - sx0;
    // float sy = sy1 - sy0;

    // vec3 n = normalize(vec3(1.0f * 0.03 / filterSize * 0.5f * vec2(sx, sy), -1));
    vec3 n = normalize(vec3(sx1 - sy0, 2, sx0 - sy1));
    
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

    // dirt
	// tempColor = tpweights.z * texture2D(tex1, triTexCoords.xy*5.0);
	// tempColor += tpweights.x * texture2D(tex1, triTexCoords.yz*5.0);
	// tempColor += tpweights.y * texture2D(tex1, triTexCoords.xz*5.0);
	finalColor += weights.y * dirtColor;

	// grass
	// tempColor = tpweights.z * texture2D(tex2, triTexCoords.xy*5.0);
	// tempColor += tpweights.x * texture2D(tex2, triTexCoords.yz*5.0);
	// tempColor += tpweights.y * texture2D(tex2, triTexCoords.xz*5.0);
	finalColor += weights.w * grassColor;
	
	// rock
	// tempColor = tpweights.z * texture2D(tex3, triTexCoords.xy*5.0);
	// tempColor += tpweights.x * texture2D(tex3, triTexCoords.yz*5.0);
	// tempColor += tpweights.y * texture2D(tex3, triTexCoords.xz*5.0);
	finalColor += weights.x * rockColor;
	
	// snow
	// tempColor = tpweights.z * texture2D(tex4, triTexCoords.xy*5.0);
	// tempColor += tpweights.x * texture2D(tex4, triTexCoords.yz*5.0);
	// tempColor += tpweights.y * texture2D(tex4, triTexCoords.xz*5.0);
	finalColor += weights.z * snowColor;


    // vec3 wi = normalize(vec3(1, 1, 1));
    // float d = dot(wi, n) * 0.5 + 0.5;
    // vec3 albedo = vec3(252, 197, 150) / 255.0f;
    //vec3 shading = (d / 3.14159) * albedo;

    // frag_color = vec4(shading, 1);
    frag_color = finalColor * l;



    // frag_color = vec4(v_texcoord0.x, v_texcoord0.y, v_position.y / 50.0, 1.0);
}