struct vertex_in
{
    float4 vertex  : POSITION;
    float2 uv0     : TEXCOORD0;
    float2 uv1     : TEXCOORD1;
    float2 uv2     : TEXCOORD2;
    float2 uv3     : TEXCOORD3;
    float3 normal  : NORMAL;
    float4 tangent : TANGENT;
    float4 color   : COLOR0;
};

struct vertex_out
{
    float4 coord0  : TEXCOORD0; 
    float4 coord1  : TEXCOORD1; 
    float4 tangent : TEXCOORD2;
    float3 view    : TEXCOORD3;
    float4 os_pos  : TEXCOORD4;
    float4 ws_pos  : TEXCOORD5;
    float4 ss_pos  : TEXCOORD6;
    float3 normal  : NORMAL;
    float4 color   : COLOR0;
    float4 pos  : SV_POSITION;
    SHADOW_COORDS(7)
};