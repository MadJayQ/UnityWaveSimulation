#if !defined(GERSTNER_INCLUDED)
#define GERSTNER_INCLUDED

float _Wavelength;
float _Steepness;
float _Speed;

struct GerstnerWaveData {
    float2 direction;
    float steepness;
    float wavelength;
};

void GerstnerWave (GerstnerWaveData waveData, inout VertexOutput o) {
    float2 waveDirection = normalize(waveData.direction);
    float waveSteepness = waveData.steepness;
    float waveLength = waveData.wavelength;
    float3 p = o.worldPos.xyz;

    float k = 2 * UNITY_PI / waveLength;
    float c = sqrt(9.8 / k);
    float f = k * (dot(waveDirection, p.xz) - c * _Time.y);
    float a = waveSteepness / k;
    

    //Add our waves effect on our tangent
    o.tangent += float3(
        -waveDirection.x * waveDirection.x * (waveSteepness * sin(f)),
        waveDirection.x * (waveSteepness * cos(f)),
        -waveDirection.x * waveDirection.y * (waveSteepness * sin(f))
    );

    //Add our waves effect on our binormal
    o.binormal += float3(
        -waveDirection.x * waveDirection.y * (waveSteepness * sin(f)),
        waveDirection.y * (waveSteepness * cos(f)),
        -waveDirection.y * waveDirection.y * (waveSteepness * sin(f))
    );

    o.worldPos += float3(waveDirection.x * (a * cos(f)), a * sin(f), waveDirection.y * (a * cos(f)));
}

VertexOutput WavesVertexProgram(VertexInput v) {
    VertexOutput o;

    UNITY_INITIALIZE_OUTPUT(VertexOutput, o);
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_TRANSFER_INSTANCE_ID(v, o);
    
    
    //Compute world position
    o.worldPos.xyz = mul(unity_ObjectToWorld, v.vertex);

    o.tangent = float3(1, 0, 0);
    o.binormal = float3(0, 0, 1);

    GerstnerWaveData wave1;
    wave1.direction = float2(1, 1);
    wave1.steepness = 0.25;
    wave1.wavelength = 60;

    GerstnerWaveData wave2;
    wave2.direction = float2(1.0, 0.6);
    wave2.steepness = 0.25;
    wave2.wavelength = 31.0;

    GerstnerWaveData wave3;
    wave3.direction = float2(1.0, 1.3);
    wave3.steepness = 0.25;
    wave3.wavelength = 18.0;

    GerstnerWave(wave1, o);
    GerstnerWave(wave2, o);
    GerstnerWave(wave3, o);

    o.normal = normalize(cross(o.binormal, o.tangent));

    //Translate back to clip space
    o.pos = UnityObjectToClipPos(mul(unity_WorldToObject, o.worldPos));
    //o.tangent = UnityObjectToWorldDir(v.tangent.xyz);

    o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);

    UNITY_TRANSFER_SHADOW(o, v.uv1);

    return o;
}


FragmentOutput WavesShadingProgram(Interpolators i) {
    UNITY_SETUP_INSTANCE_ID(i);

    float alpha = GetAlpha(i);
    float3 albedo = ALBEDO_FUNCTION(i);//float3(0.0966, 0.596, 0.805);

    InitializeFragmentNormal(i);

    float3 viewDirection = normalize(_WorldSpaceCameraPos - i.worldPos.xyz);
    FragmentOutput output;
    float3 lightDir = _WorldSpaceLightPos0.xyz;
    
    output.color = float4(albedo, 1);
    return output;
}

#endif