struct v2f
{ 
    float4 uv : TEXCOORD0;
    float4 vertexos : TEXCOORD1;
    V2F_SHADOW_CASTER;
};
v2f vert(appdata_full v)
{
    v2f o;
    o.uv.xy = v.texcoord;
    o.uv.zw = v.texcoord1;
    o.vertexos = v.vertex;
    TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
    return o;
}
float4 frag(v2f i) : SV_Target
{
    float main_tex = _MainTex.Sample(sampler_MainTex, i.uv).w;
    if(_UseWeapon)
    {
        float2 uvs = (_ProceduralUVs != 0.0) ? (i.vertexos.zx + 0.25) * 1.5 : i.uv.zw;
        float3 dissolve = 0.0;
        calculateDissolve(dissolve, uvs.xy, 1.0);
        clip(dissolve.x - _ClipAlphaThreshold);
    }
    if(_MainTexAlphaUse == 1.0) clip(main_tex - _MainTexAlphaCutoff);
    SHADOW_CASTER_FRAGMENT(i)
    return 0;
}