vs_out vert(vs_in i)
{
    vs_out o = (vs_out)0.0f;
    float4 pos_ws  = mul(unity_ObjectToWorld, i.pos);
    float4 pos_wvp = mul(UNITY_MATRIX_VP, pos_ws);
    o.pos = pos_wvp;

    o.uv = float4(i.uv_0, i.uv_1); // populate this with both uvs to save on texcoords 
    o.normal = mul((float3x3)unity_ObjectToWorld, i.normal) ; // WORLD SPACE NORMAL 
    o.tangent.xyz = mul((float3x3)unity_ObjectToWorld, i.tangent.xyz); // WORLD SPACE TANGENT
    o.tangent.w = i.tangent.w * unity_WorldTransformParams.w; 
    // in case the data stored in the tangent slot is actually proper tangents and not a 2nd set of normals
    o.view = _WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, i.pos).xyz;
    // its more efficient to do this in the vertex shader instead of trying to calculate the view vector for every pixel 
    o.v_col = i.v_col;    
    
    UNITY_TRANSFER_FOG(o, o.pos);
    return o;
}

float4 frag(vs_out i, bool vface : SV_IsFrontFace) : SV_Target
{
    // INITIALIZE VERTEX SHADER INPUTS : 
    float3 normal = normalize(i.normal);
    float3 view   = normalize(i.view);
    float2 uv     = i.uv.xy;
    float4 vcol   = i.v_col;

    // MATERIAL COLOR :
    float4 color = _Color;

    if(!vface) // use uv2 if vface is false
    { // so basically if its a backfacing face
        uv.xy = i.uv.zw;
        color = _BackColor;
        normal = normal * -1.0f;
    }

    // INITIALIZE OUTPUT COLOR : 
    float4 out_color = color;

    // COMPUTE HALF VECTOR : 
    float3 half_vector = normalize(view + _WorldSpaceLightPos0);

    // DOT PRODUCTS : 
    float ndotl = dot(normal, _WorldSpaceLightPos0);
    float ndoth = dot(normal, half_vector);
    float ndotv = dot(normal, view);

    // SAMPLE TEXTURES : 
    float4 diffuse = _MainTex.Sample(sampler_MainTex, uv);
    float4 lightmp = _LightMap.Sample(sampler_LightMap, uv);

    // EXTRACT MATERIAL REGIONS 
    float material_ID = floor(lightmp.w * 8.0f);
    float ramp_ID     = ((material_ID * 2.0f + 1.0f) * 0.0625f);
    // when writing the shader for mmd i had to invert the ramp ID since the uvs are read differently  

    // I dont want to write a set of if else statements like this for the specular, rim, and mlut
    // so this is the next best thing i can do
    int curr_region = 0; // 0-7 in case i want to throw stuff into arrays 
    if(material_ID > 0.5 && material_ID < 1.5 )
    {
        curr_region = 1;
    } 
    else if(material_ID > 1.5f && material_ID < 2.5f)
    {
        curr_region = 2;
    } 
    else if(material_ID > 2.5f && material_ID < 3.5f)
    {
        curr_region = 3;
    } 
    else
    {
        curr_region = (material_ID > 6.5f && material_ID < 7.5f) ? 7 : 0;
        curr_region = (material_ID > 5.5f && material_ID < 6.5f) ? 6 : curr_region;
        curr_region = (material_ID > 4.5f && material_ID < 5.5f) ? 5 : curr_region;
        curr_region = (material_ID > 3.5f && material_ID < 4.5f) ? 4 : curr_region;
    }
    
    
    // ================================================================================================ //
    // SHADOW AREA :
    float shadow_ndotl  = ndotl * 0.5f + 0.5f;
    float shadow_thresh = (lightmp.y + lightmp.y) * vcol.x;
    float shadow_area   = min(1.0f, dot(shadow_ndotl.xx, shadow_thresh.xx));
    shadow_area = max(0.001f, shadow_area) * 0.85f + 0.15f;
    shadow_area = (shadow_area > _ShadowRamp) ? 0.99f : shadow_area;

    // RAMP UVS 
    float2 ramp_uv = {shadow_area, ramp_ID};

    // SAMPLE RAMP TEXTURES
    float3 warm_ramp = _DiffuseRampMultiTex.Sample(sampler_DiffuseRampMultiTex, ramp_uv).xyz; 
    float3 cool_ramp = _DiffuseCoolRampMultiTex.Sample(sampler_DiffuseRampMultiTex, ramp_uv).xyz;

    float3 shadow_color = lerp(warm_ramp, cool_ramp, 0.0f);
    // ================================================================================================ //
    // specular : 
    float4 specular_color[8] =
    {
        _SpecularColor0,
        _SpecularColor1,
        _SpecularColor2,
        _SpecularColor3,
        _SpecularColor4,
        _SpecularColor5,
        _SpecularColor6,
        _SpecularColor7,
    };
    // ================================================================================================ //
    out_color = out_color * diffuse;
    out_color.xyz = out_color * shadow_color; 

    // DEBUG
    out_color = specular_color[curr_region];
    
    return out_color;
}
