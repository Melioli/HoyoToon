struct vs_in
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float4 tangent : TANGENT;
    float2 uv_0 : TEXCOORD0;
    float2 uv_1 : TEXCOORD1;
    float3 uv_2 : TEXCOORD2;
    float4 uv_3 : TEXCOORD3;
    float4 color : COLOR0;
};

struct vs_out
{
    float4 pos : SV_POSITION;
    float3 normal : NORMAL;
    float4 tangent : TANGENT;
    float4 uv_a : TEXCOORD0;
    float4 uv_b : TEXCOORD1;
    float3 view : TEXCOORD2;
    float4 ws_pos : TEXCOORD3;
    float4 color : COLOR0;
    UNITY_VERTEX_OUTPUT_STEREO
    SHADOW_COORDS(7)
};

struct edge_in
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float4 tangent : TANGENT;
    float2 uv_0 : TEXCOORD0;
    float4 color : COLOR0; // the xyz of this are normals MonkaS
};

struct edge_out
{
    float4 vertex : SV_POSITION;
    float4 uv_a : TEXCOORD0;
    float4 color : COLOR0;
    float3 normal : NORMAL;
};

struct shadow_in 
{
    float4 vertex : POSITION; 
    float3 normal : NORMAL;
    float2 uv_0 : TEXCOORD0;
    float2 uv_1 : TEXCOORD1;
};

struct shadow_out
{
    float4 pos : SV_POSITION;
    float4 uv_a : TEXCOORD0;
    float3 normal : NORMAL;
    float4 ws_pos : TEXCOORD1;
    float3 view : TEXCOORD2;
};