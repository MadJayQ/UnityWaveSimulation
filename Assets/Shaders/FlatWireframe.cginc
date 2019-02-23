#if !defined(WIREFRAME_INCLUDED)
#define WIREFRAME_INCLUDED

#define CUSTOM_GEOMETRY_INTERPOLATORS \
    float2 barycentricCoordinates : TEXCOORD9;

float3 _WireframeColor;
float _WireframeSmoothing;
float _WireframeThickness;

#include "LightingInput.cginc"

//Override our albedo function
float3 WireframeAlbedo(Interpolators i) {
    float3 albedo = GetAlbedo(i);
    float3 barys;
    barys.xy = i.barycentricCoordinates;
    barys.z = 1 - barys.x - barys.y;
    float deltas = fwidth(barys);
    float3 smoothing = deltas * _WireframeSmoothing;
    float3 thickness = deltas * _WireframeThickness;
    barys = smoothstep(thickness, thickness + smoothing, barys);
    float minBaryCoordinate = min(barys.x, min(barys.y, barys.z));
    return lerp(_WireframeColor, albedo, minBaryCoordinate);
}
#define ALBEDO_FUNCTION WireframeAlbedo

#include "Lighting.cginc"

struct GeometryInterpolators {
    VertexOutput data;
    CUSTOM_GEOMETRY_INTERPOLATORS
};

[maxvertexcount(3)]
void GeometryProgram (
	triangle VertexOutput i[3],
	inout TriangleStream<GeometryInterpolators> stream
) {

    float3 p0 = i[0].worldPos.xyz;
    float3 p1 = i[1].worldPos.xyz;
    float3 p2 = i[2].worldPos.xyz;

    #if defined(USE_FLAT_SHADING)
        float3 triangleNormal = normalize(cross(p1 - p0, p2 - p0));
        i[0].normal = triangleNormal;
        i[1].normal = triangleNormal;
        i[2].normal = triangleNormal;
    #endif

    GeometryInterpolators g0, g1, g2;
    g0.data = i[0];
    g1.data = i[1];
    g2.data = i[2];

    g0.barycentricCoordinates = float3(1, 0, 0);
	g1.barycentricCoordinates = float3(0, 1, 0);
	g2.barycentricCoordinates = float3(0, 0, 1);

	stream.Append(g0);
	stream.Append(g1);
	stream.Append(g2);
}

#endif