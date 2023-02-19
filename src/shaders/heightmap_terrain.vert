#version 450

layout (location = POSITION) in vec3 a_position;
layout (location = TEXCOORD0) in vec2 a_texcoord0;

layout(location = POSITION) out vec3 v_position;
layout (location = TEXCOORD0) out vec2 v_texcoord0;

layout (binding = 0) uniform sampler2D s_heightTexture;

layout (binding=0, std140) uniform uniforms {
    mat4 u_modelViewProj;
};

void main()
{
    v_texcoord0 = a_texcoord0;
    v_position = a_position.xyz;
    // v_position.y = textureLod(s_heightTexture, a_texcoord0, 0).x * 255.0;
    // v_position.z = texture(s_heightTexture, a_texcoord0).x * 255.0;
    
    gl_Position = u_modelViewProj * vec4(v_position.xyz, 1.0);
}