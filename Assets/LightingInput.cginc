#if !defined(LIGHTING_UTIL_INCLUDED)
#define LIGHTING_UTIL_INCLUDED
#include "UnityPBSLighting.cginc"
#include "AutoLight.cginc"

UNITY_INSTANCING_BUFFER_START(InstanceProperties)
    UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
#define _Color_arr InstanceProperties
UNITY_INSTANCING_BUFFER_END(InstanceProperties)

sampler2D _MainTex;
float4 _MainTex_ST;

float _Metallic;
float _Smoothness;

struct VertexInput {
    UNITY_VERTEX_INPUT_INSTANCE_ID
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float4 tangent : TANGENT;
    float2 uv : TEXCOORD0; 
    float2 uv1 : TEXCOORD1;
    float2 uv2 : TEXCOORD2;

};

struct FragmentOutput {
    #if defined(DEFERRED_PASS)
        //TODO(Jake): Add deferred pass fragment output

    #else
        float4 color : SV_TARGET;
    #endif
};

struct Interpolators {
    UNITY_VERTEX_INPUT_INSTANCE_ID
    #if defined(LOD_FADE_CROSSFADE)
        UNITY_VPOS_TYPE vpos : VPOS;
    #else
        float4 pos : SV_POSITION;
    #endif

    float4 uv : TEXCOORD0;
    float3 normal : TEXCOORD1;
    float3 tangent : TEXCOORD2;
    float3 binormal : TEXCOORD3;
    float3 worldPos : TEXCOORD4;

    UNITY_SHADOW_COORDS(5)

    #if defined (CUSTOM_GEOMETRY_INTERPOLATORS)
    CUSTOM_GEOMETRY_INTERPOLATORS
    #endif
};

struct VertexOutput {
    UNITY_VERTEX_INPUT_INSTANCE_ID //Used to access instanced properties for fragment shader
    float4 pos : SV_POSITION;
    float4 uv : TEXCOORD0;
    float3 normal : TEXCOORD1;
    float3 tangent : TEXCOORD2;
    float3 binormal : TEXCOORD3;
    float3 worldPos : TEXCOORD4;

    UNITY_SHADOW_COORDS(5)
};

float3 GetTangentSpaceNormal(Interpolators i) {
    float3 normal = float3(0, 0, 1);
    return normal;
}

float3 GetAlbedo(Interpolators i)
{
    float3 albedo = tex2D(_MainTex, i.uv.xy).rgb * UNITY_ACCESS_INSTANCED_PROP(_Color_arr, _Color).rgb;
    return albedo;
}

float GetAlpha(Interpolators i)
{
    float alpha = UNITY_ACCESS_INSTANCED_PROP(_Color_arr, _Color).a;
    return alpha;
}

float GetMetallic (Interpolators i) {
    return _Metallic;
}
#endif