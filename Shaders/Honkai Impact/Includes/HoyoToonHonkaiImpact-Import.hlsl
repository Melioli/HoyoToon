struct vs_in
{
    float4 vertex      : POSITION;
    float2 uv           : TEXCOORD0;
    float2 uv2          : TEXCOORD1;
    float3 normal       : NORMAL;
    float4 VertexColor  : COLOR0;
};

struct vs_out
{
    float2 uv           : TEXCOORD0;
    float2 uv2          : TEXCOORD3;
    float4 pos          : SV_POSITION;
    float3 normal       : NORMAL;
    float4 VertexColor  : TEXCOORD1;
    float3 view         : TEXCOORD2;
    float4 ws_pos       : TEXCOORD4;
    float4 mask_uv      : TEXCOORD5;
    float2 dis_angle    : TEXCOORD6;
    SHADOW_COORDS(7)
};

struct edge_in
{
    float4 pos          : POSITION;
    float3 tangent      : TANGENT;
    float2 uv           : TEXCOORD0;
    float4 vertexcolor  : COLOR0; 
    float3 normal      : NORMAL;
};


struct edge_out
{
    float4 pos          : POSITION;
    float4 vertex       : TEXCOORD0;
    float2 uv           : TEXCOORD1;
    float3 normal      : NORMAL;
};

struct stencil_in
{
    float4 pos      : POSITION;
    float2 uv           : TEXCOORD0;
};

struct stencil_out
{
    float2 uv           : TEXCOORD0;
    float4 pos          : SV_POSITION;
    float3 view         : TEXCOORD1;
};