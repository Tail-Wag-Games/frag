#version 450

layout (binding = 0, std140) uniform vs_params {
    mat4 mvp;
    mat4 model;
    vec2 joint_uv;
    float joint_pixel_width;
};

layout (location = POSITION) in vec4 a_position;
layout (location = NORMAL) in vec3 a_normal;
layout (location = TEXCOORD0) in vec4 a_jindices;
layout (location = TEXCOORD1) in vec4 a_jweights;

layout (binding = 0) uniform sampler2D s_joint_tex;

void skinned_pos_nrm(in vec4 pos, in vec4 nrm, in vec4 skin_weights, in vec4 skin_indices, in vec2 joint_uv, out vec4 skin_pos, out vec4 skin_nrm) {
    skin_pos = vec4(0.0, 0.0, 0.0, 1.0);
    skin_nrm = vec4(0.0, 0.0, 0.0, 0.0);    
    vec4 weights = skin_weights / dot(skin_weights, vec4(1.0));
    vec2 step = vec2(joint_pixel_width, 0.0);
    vec2 uv;
    vec4 xxxx, yyyy, zzzz;
    if (weights.x > 0.0) {
        uv = vec2(joint_uv.x + (3.0 * skin_indices.x)*joint_pixel_width, joint_uv.y);
        xxxx = textureLod(s_joint_tex, uv, 0.0);
        yyyy = textureLod(s_joint_tex, uv + step, 0.0);
        zzzz = textureLod(s_joint_tex, uv + 2.0 * step, 0.0);
        skin_pos.xyz += vec3(dot(pos,xxxx), dot(pos,yyyy), dot(pos,zzzz)) * weights.x;
        skin_nrm.xyz += vec3(dot(nrm,xxxx), dot(nrm,yyyy), dot(nrm,zzzz)) * weights.x;
    }
    if (weights.y > 0.0) {
        uv = vec2(joint_uv.x + (3.0 * skin_indices.y)*joint_pixel_width, joint_uv.y);
        xxxx = textureLod(s_joint_tex, uv, 0.0);
        yyyy = textureLod(s_joint_tex, uv + step, 0.0);
        zzzz = textureLod(s_joint_tex, uv + 2.0 * step, 0.0);
        skin_pos.xyz += vec3(dot(pos,xxxx), dot(pos,yyyy), dot(pos,zzzz)) * weights.y;
        skin_nrm.xyz += vec3(dot(nrm,xxxx), dot(nrm,yyyy), dot(nrm,zzzz)) * weights.y;
    }
    if (weights.z > 0.0) {
        uv = vec2(joint_uv.x + (3.0 * skin_indices.z)*joint_pixel_width, joint_uv.y);
        xxxx = textureLod(s_joint_tex, uv, 0.0);
        yyyy = textureLod(s_joint_tex, uv + step, 0.0);
        zzzz = textureLod(s_joint_tex, uv + 2.0 * step, 0.0);
        skin_pos.xyz += vec3(dot(pos,xxxx), dot(pos,yyyy), dot(pos,zzzz)) * weights.z;
        skin_nrm.xyz += vec3(dot(nrm,xxxx), dot(nrm,yyyy), dot(nrm,zzzz)) * weights.z;
    }
    if (weights.w > 0.0) {
        uv = vec2(joint_uv.x + (3.0 * skin_indices.w)*joint_pixel_width, joint_uv.y);
        xxxx = textureLod(s_joint_tex, uv, 0.0);
        yyyy = textureLod(s_joint_tex, uv + step, 0.0);
        zzzz = textureLod(s_joint_tex, uv + 2.0 * step, 0.0);
        skin_pos.xyz += vec3(dot(pos,xxxx), dot(pos,yyyy), dot(pos,zzzz)) * weights.w;
        skin_nrm.xyz += vec3(dot(nrm,xxxx), dot(nrm,yyyy), dot(nrm,zzzz)) * weights.w;
    }
}

void main()
{
    vec4 pos, nrm;
    skinned_pos_nrm(a_position, vec4(a_normal, 0.0), a_jweights, a_jindices * 255.0, joint_uv, pos, nrm);
    gl_Position = mvp * pos;
}