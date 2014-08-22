//#define NO_DIFFUSE_TEXTURE
//#define LIGHTMAP_ENABLED
//#define ALPHA_TEST
//#define USE_NORMAL_MAP
//#define USE_LIGHT
//#define SPECULAR_ENABLED
//#define FRESNEL_ENABLED
//#define FRESNEL_PULSE_ENABLED
//#define DRAW_IN_GRAYSCALE

#define M_PI 3.1415926535897932384626433832795
#define M_GRAYSCALE vec3(0.2126, 0.7152, 0.0722)

precision highp float;

// uniforms
uniform vec4 u_cc3MaterialDiffuseColor;
uniform vec4 u_cc3MaterialSpecularColor; // this is actually the color of the fresnel reflection

uniform sampler2D s_cc3Texture2Ds[2];

uniform samplerCube u_irradianceMap;
uniform samplerCube u_reflectionMap;

uniform vec4 u_cc3LightPositionGlobal;
uniform vec4 u_cc3LightDiffuseColor;
uniform vec4 u_cc3LightSpecularColor;
uniform vec3 u_cc3CameraPositionGlobal;
uniform vec2 u_cc3SceneTime;

#if defined(RED_GLOW)
uniform float blend_intensity;
#endif

// varyings
varying vec3 v_position_world;

#if defined(USE_LIGHT) || defined(FRESNEL_ENABLED)
varying vec3 v_N;
#if defined(USE_NORMAL_MAP)
varying vec3 v_T;
varying vec3 v_B;
#endif
#endif

#if defined(FRESNEL_ENABLED) && defined(FRESNEL_PULSE_ENABLED)
uniform float pulseFrequency;
#endif

varying vec2 v_texCoord;

#ifdef LIGHTMAP_ENABLED
varying vec2 v_lightMapCoord;
#endif

// code
void main() {
#ifdef NO_DIFFUSE_TEXTURE
    vec4 textureColor = vec4(1.0);
#else
    vec4 textureColor = texture2D(s_cc3Texture2Ds[0], v_texCoord);
#endif
    vec4 diffuseColor = u_cc3MaterialDiffuseColor * textureColor;
    
    // alpha test
#ifdef ALPHA_TEST
    if (textureColor.a < 0.1) {
        discard;
    }
#endif
    
    gl_FragColor = diffuseColor;
    
    // normal
#if defined(USE_LIGHT) || defined(FRESNEL_ENABLED)
#ifdef USE_NORMAL_MAP
    vec3 normal = texture2D(s_cc3Texture2Ds[1], v_texCoord).rgb;
    vec3 normal_t = normal * 2.0 - 1.0;
    vec3 N = normalize(mat3(v_T, v_B, v_N) * normal_t);
#else
    vec3 N = v_N;
#endif
#endif
    
#if (defined(USE_LIGHT) && defined(SPECULAR_ENABLED)) || defined(FRESNEL_ENABLED)
    vec3 V = normalize(u_cc3CameraPositionGlobal - v_position_world);
#endif
    
#ifdef LIGHTMAP_ENABLED // for static objects
    
    vec4 lightMapTexel = texture2D(s_cc3Texture2Ds[1], v_lightMapCoord);
    gl_FragColor = gl_FragColor * lightMapTexel;
    
#elif defined(USE_LIGHT) // for dynamic objects
    
    gl_FragColor.a = u_cc3MaterialDiffuseColor.a;
    
    gl_FragColor = gl_FragColor * mix(vec4(1.0), textureCube(u_irradianceMap, N), textureColor.a);
    
#ifdef SPECULAR_ENABLED
    vec3 R = reflect(-V, N);
    float specularLevel = texture2D(s_cc3Texture2Ds[1], v_texCoord).a;
    vec4 specularColor = u_cc3MaterialSpecularColor * specularLevel * textureCube(u_reflectionMap, R);
    // add specular
    gl_FragColor.rgb = gl_FragColor.rgb + specularColor.rgb;
#endif
    
#endif
    
#ifdef FRESNEL_ENABLED
    float nDotVInv = 1.0 - max(0.0, dot(N, V));
    float fresnelLevel = nDotVInv;
#ifdef FRESNEL_PULSE_ENABLED
    float timeMultiplier = (cos(u_cc3SceneTime[0] * 2.0 * M_PI * pulseFrequency) + 1.0) * 0.5;
    fresnelLevel *= 2.0 * timeMultiplier;
#endif
    float fresnelLerp = fresnelLevel * u_cc3MaterialSpecularColor.a;
    vec4 fresnelColor = fresnelLerp * (u_cc3MaterialSpecularColor - gl_FragColor);
    // add fresnel
    gl_FragColor.rgb = gl_FragColor.rgb + fresnelColor.rgb * gl_FragColor.a;
#endif
    
#if defined(DRAW_IN_GRAYSCALE)
    float color = dot(gl_FragColor.rgb, M_GRAYSCALE);
    gl_FragColor = vec4(color, color, color, gl_FragColor.a);
#endif
    
#if defined(RED_GLOW)
    vec4 blendColor = vec4(0.0, 0.0, 0.0, 0.0);
    
    vec4 yellow = vec4(1.0, 1.0, 0.0, 1.0);
    vec4 orange = vec4(1.0, 0.5, 0.0, 1.0);
    vec4 red = vec4(1.0, 0.0, 0.0, 1.0);
    
    float intensity = max(max(gl_FragColor.r, gl_FragColor.g), gl_FragColor.b);
    blendColor = vec4(0.0, 0.0, 0.0, 0.0);
    if (intensity > 0.66) {
        blendColor += (intensity - 0.66) * yellow;
        blendColor += 0.66 * orange;
    } else if (intensity > 0.33) {
        blendColor += (intensity + 0.16 - 0.33) * orange;
        blendColor += (0.5) * red;
    } else {
        blendColor = (intensity + 0.66) * red;
    }
    
    float blend = blend_intensity * 0.65;
    blendColor = (1.0 - blend) * gl_FragColor + blend * blendColor;
    blendColor *= 1.0 + 0.3 * blend_intensity;
    blendColor += blend_intensity * vec4(0.2, 0.2, 0.2, 0.0);
    
    gl_FragColor = clamp(blendColor, 0.0, 1.0);
#endif

}
