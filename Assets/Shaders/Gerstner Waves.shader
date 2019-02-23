
Shader "Custom/Gerstner Waves"
{
    Properties
    {
        [Header(Color Properties)]
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        [Header(Wave Properties)]
        _Wavelength ("Wavelength", Float) = 10
        _Steepness ("Steepness", Range(0, 1)) = 0.5
        _Speed("Speed", Float) = 2
        [HideInInspector] _SrcBlend ("_SrcBlend", Float) = 1
		[HideInInspector] _DstBlend ("_DstBlend", Float) = 0
		[HideInInspector] _ZWrite ("_ZWrite", Float) = 1
        [Header(Wireframe Properties)]
        _WireframeColor ("Wireframe Color", Color) = (0, 0, 0)
		_WireframeSmoothing ("Wireframe Smoothing", Range(0, 10)) = 1
		_WireframeThickness ("Wireframe Thickness", Range(0, 10)) = 1
    }
    SubShader
    {
        Pass {
            Tags { "RenderType"="Opaque" }
            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWrite]

            CGPROGRAM
            #pragma target 4.6

            #pragma multi_compile_fwdbase
		    #pragma multi_compile_fog
		    //#pragma multi_compile_instancing
		    //#pragma instancing_options lodfade force_same_maxcount_for_gl

            //#pragma vertex VertexProgram
            #pragma vertex WavesTessellationVertexProgram
            //#pragma fragment WavesShadingProgram
            #pragma fragment DrawNormals
            #pragma hull WavesHullProgram
            #pragma domain WavesDomainProgram
            #pragma geometry GeometryProgram

            //#define USE_FLAT_SHADING
            #define FORWARD_BASE_PASS

            #include "FlatWireframe.cginc"
            #include "GerstnerWaves.cginc"
            #include "WavesTessellation.cginc"

            FragmentOutput DrawNormals(Interpolators i) {
                FragmentOutput output;
                output.color = float4((i.normal * i.tangent) * 0.5 + 0.5, 1);
                return output;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
