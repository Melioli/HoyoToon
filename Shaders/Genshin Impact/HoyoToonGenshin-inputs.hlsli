struct vsIn{
    float4 vertex : POSITION;
    float3 normal : NORMAL0;
    float4 tangent : TANGENT;
    float2 uv0 : TEXCOORD0;
    float2 uv1 : TEXCOORD1;
    float2 uv2 : TEXCOORD2;
    float4 vertexcol : COLOR0;
};

struct vsOut{
    float4 pos : SV_POSITION;
    float3 normal : NORMAL; // object space
    float4 tangent : TANGENT;
    float4 uv : TEXCOORD0; // first 2 elements of vector for UV0, last 2 for UV1
    float2 uvb : TEXCOORD5;
    float4 vertexWS : TEXCOORD1;
    float4 screenPos : TEXCOORD2;
    float4 vertexOS : TEXCOORD3;
    float4 parallax            : TEXCOORD4;
    // UNITY_FOG_COORDS(5)
    float4 vertexcol : COLOR0;
};
