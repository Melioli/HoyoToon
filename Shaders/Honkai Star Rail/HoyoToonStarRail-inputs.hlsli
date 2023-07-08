struct vs_in
{
    float4 pos     : POSITION;
    float3 normal  : NORMAL;
    float4 tangent : TANGENT;
    float2 uv_0    : TEXCOORD0;
    float2 uv_1    : TEXCOORD1;
    float4 v_col   : COLOR0;
};

struct vs_out
{
    float4 pos     : SV_POSITION;
    float3 normal  : NORMAL; // ws normals
    float4 tangent : TANGENT; // ws tangents
    float4 uv      : TEXCOORD0; // uv0 and uv1
    float3 view    : TEXCOORD1; // view vector
    float4 ws_pos  : TEXCOORD2; // world space position, this is used to sample the camera depth texture 
    float4 ss_pos  : TEXCOORD3;
    float4 v_col   : COLOR0; // vertex color 
    UNITY_FOG_COORDS(5) // i dont understand the importance of this
};
