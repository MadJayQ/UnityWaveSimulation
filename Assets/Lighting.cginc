#if !defined(LIGHTING_INCLUDED)
#define LIGHTING_INCLUDED

#include "LightingInput.cginc"

#if !defined(ALBEDO_FUNCTION)
    #define ALBEDO_FUNCTION GetAlbedo
#endif

float3 CreateBinormal(float3 normal, float3 tangent, float binormalSign) {
    return cross(normal, tangent.xyz) * (binormalSign * unity_WorldTransformParams.w);
}

void InitializeFragmentNormal(inout Interpolators i) {
    float3 tangentSpaceNormal = GetTangentSpaceNormal(i);

    float3 binormal = i.binormal;

	i.normal = normalize(
		tangentSpaceNormal.x * i.tangent +
		tangentSpaceNormal.y * binormal +
		tangentSpaceNormal.z * i.normal
	);
}


VertexOutput VertexProgram(VertexInput v) {
    VertexOutput o;

    UNITY_INITIALIZE_OUTPUT(VertexOutput, o);
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_TRANSFER_INSTANCE_ID(v, o);
    
    //Translate vertex to clip space
    o.pos = UnityObjectToClipPos(v.vertex);
    //Compute world position
    o.worldPos.xyz = mul(unity_ObjectToWorld, v.vertex);
    //Compute normal
    o.normal = UnityObjectToWorldNormal(v.normal);
    //Compute tangent
    o.tangent = UnityObjectToWorldDir(v.tangent.xyz);
    //Compute binormal
    o.binormal = CreateBinormal(o.normal, o.tangent, v.tangent.w);

    o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);


    UNITY_TRANSFER_SHADOW(o, v.uv1);

    return o;
}

FragmentOutput FragmentProgram(Interpolators i) {
    UNITY_SETUP_INSTANCE_ID(i);

    float alpha = GetAlpha(i);
    float3 albedo = ALBEDO_FUNCTION(i);

    InitializeFragmentNormal(i);

    float3 viewDirection = normalize(_WorldSpaceCameraPos - i.worldPos.xyz);
    float3 specularTint;
    float oneMinusReflectivity;

    FragmentOutput output;
    float3 lightDir = _WorldSpaceLightPos0.xyz;
    float3 lightColor = _LightColor0.rgb;
    float3 diffuse = albedo * lightColor * DotClamped(lightDir, i.normal);
    output.color = float4(UNITY_LIGHTMODEL_AMBIENT.xyz + diffuse, 1);
    return output;
}

#endif