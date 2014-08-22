
precision highp float;

attribute vec4 a_cc3Position;
attribute vec2 a_cc3TexCoord0;
attribute vec4 a_cc3BoneWeights;
attribute vec4 a_cc3BoneIndices;
attribute vec3 a_cc3Normal;
attribute vec3 a_cc3Tangent;
attribute vec3 a_cc3Bitangent;

#define MAX_BONES_PER_VERTEX 33

uniform int u_cc3BonesPerVertex;
uniform mat4 u_cc3BoneMatricesGlobal[MAX_BONES_PER_VERTEX];

uniform mat4 u_cc3MatrixModel;
uniform mat4 u_cc3MatrixView;
uniform mat4 u_cc3MatrixProj;

varying vec3 v_position_world;
varying vec2 v_texCoord;

#if defined(USE_LIGHT) || defined(FRESNEL_ENABLED) || defined(BLUE)
varying vec3 v_N;
#if defined(USE_NORMAL_MAP) || defined(BLUE)
varying vec3 v_T;
varying vec3 v_B;
#endif
#endif

vec4 finalPosition_world;

#if defined(USE_LIGHT) || defined(FRESNEL_ENABLED) || defined(BLUE)
vec3 finalNormal_world;
#if defined(USE_NORMAL_MAP) || defined(BLUE)
vec3 finalTangent_world;
#endif
#endif

void vertexToEyeSpace() {
    ivec4 boneIndices = ivec4(a_cc3BoneIndices);
    vec4 boneWeights = a_cc3BoneWeights;
    
    finalPosition_world = vec4(0);
#if defined(USE_LIGHT) || defined(FRESNEL_ENABLED) || defined(BLUE)
    finalNormal_world = vec3(0);
#if defined(USE_NORMAL_MAP) || defined(BLUE)
    finalTangent_world = vec3(0);
#endif
#endif
    
    for (int i = 0; i < u_cc3BonesPerVertex; ++i) {
        // Add position contribution from this bone
        int bIdx = boneIndices[i];
        float bWt = boneWeights[i];
        mat4 transform = u_cc3BoneMatricesGlobal[bIdx];
        finalPosition_world += transform * a_cc3Position * bWt;
#if defined(USE_LIGHT) || defined(FRESNEL_ENABLED) || defined(BLUE)
        finalNormal_world += (transform * vec4(a_cc3Normal, 0)).xyz * bWt;
#if defined(USE_NORMAL_MAP) || defined(BLUE)
        finalTangent_world += (transform * vec4(a_cc3Tangent, 0)).xyz * bWt;
#endif
#endif
    }
}

#extension GL_EXT_draw_instanced: enable

void main() {
    vertexToEyeSpace();
    
    float xOffset = float(gl_InstanceIDEXT / 30) * 0.5;
    float yOffset = float(gl_InstanceIDEXT - (gl_InstanceIDEXT / 30) * 30) * 0.25;
    vec4 offset = vec4(xOffset, yOffset, 0, 0);
    
    gl_Position = u_cc3MatrixProj * ((u_cc3MatrixView * finalPosition_world) + offset);
    
    v_position_world = finalPosition_world.xyz;
    v_texCoord = a_cc3TexCoord0;
    
#if defined(USE_LIGHT) || defined(FRESNEL_ENABLED) || defined(BLUE)
    v_N = normalize(finalNormal_world);
#if defined(USE_NORMAL_MAP) || defined(BLUE)
    float handedness = dot(cross(a_cc3Normal, a_cc3Tangent), a_cc3Bitangent) >= 0.0 ? 1.0 : -1.0;
    v_T = normalize(finalTangent_world);
    v_B = handedness * cross(v_N, v_T);
#endif
#endif
    
}
