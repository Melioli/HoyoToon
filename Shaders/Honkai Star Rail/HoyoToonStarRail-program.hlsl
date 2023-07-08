vs_out vs_base(vs_in i)
{
    vs_out o = (vs_out)0.0f;
    float4 pos_ws  = mul(unity_ObjectToWorld, i.pos);
    float4 pos_wvp = mul(UNITY_MATRIX_VP, pos_ws);
    o.pos = pos_wvp;
    o.ws_pos =  mul(unity_ObjectToWorld, i.pos);
    o.ss_pos = ComputeScreenPos(o.pos);

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

vs_out vs_edge(vs_in i)
{
    vs_out o = (vs_out)0.0f; // cast to 0 to avoid intiailization warnings
    float3 ws_normal = mul(UNITY_MATRIX_V, i.tangent.xyz);
    float3 ws_ps     = mul(i.pos, mul(unity_ObjectToWorld, unity_MatrixV));
    float fov = 1.0f / rsqrt(abs(ws_ps.z / unity_CameraProjection._m11) / 1000.0f);
    i.pos.xyz = i.pos.xyz + (ws_normal.xyz * (i.v_col.w * 1.0f * fov));
    float4 pos_ws  = mul(unity_ObjectToWorld, i.pos);
    o.pos = UnityObjectToClipPos(i.pos.xyz);
    o.uv = float4(i.uv_0, i.uv_1);
    return o;
}

float4 ps_base(vs_out i, bool vface : SV_IsFrontFace) : SV_Target
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
    int curr_region = material_region(material_ID);
    
    
    // ================================================================================================ //
    // SHADOW AREA :
    float shadow_area = shadow_rate(ndotl, lightmp.y, vcol.x, _ShadowRamp);

    // RAMP UVS 
    float2 ramp_uv = {shadow_area, ramp_ID};

    // SAMPLE RAMP TEXTURES
    float3 warm_ramp = _DiffuseRampMultiTex.Sample(sampler_DiffuseRampMultiTex, ramp_uv).xyz; 
    float3 cool_ramp = _DiffuseCoolRampMultiTex.Sample(sampler_DiffuseRampMultiTex, ramp_uv).xyz;

    float3 shadow_color = lerp(warm_ramp, cool_ramp, 0.0f);

    
    if(_FaceMaterial)
    {
        float face_sdf_right = _FaceMap.Sample(sampler_FaceMap, uv).w;
        float face_sdf_left  = _FaceMap.Sample(sampler_FaceMap, float2(1.0f - uv.x, uv.y)).w;

        shadow_area = shadow_rate_face(face_sdf_left, face_sdf_right);

        shadow_color = lerp(_ShadowColor, 1.0f, shadow_area);
    }
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

    float3 specular_values[8] =
    {
        float3(_SpecularShininess0, max(_SpecularRoughness0, 0.001f), _SpecularIntensity0),
        float3(_SpecularShininess1, max(_SpecularRoughness1, 0.001f), _SpecularIntensity1),
        float3(_SpecularShininess2, max(_SpecularRoughness2, 0.001f), _SpecularIntensity2),
        float3(_SpecularShininess3, max(_SpecularRoughness3, 0.001f), _SpecularIntensity3),
        float3(_SpecularShininess4, max(_SpecularRoughness4, 0.001f), _SpecularIntensity4),
        float3(_SpecularShininess5, max(_SpecularRoughness5, 0.001f), _SpecularIntensity5),
        float3(_SpecularShininess6, max(_SpecularRoughness6, 0.001f), _SpecularIntensity6),
        float3(_SpecularShininess7, max(_SpecularRoughness7, 0.001f), _SpecularIntensity7),
    };


    float3 specular = specular_base(shadow_area, ndoth, lightmp.z, specular_color[curr_region], specular_values[curr_region], _ES_SPColor, _ES_SPIntensity);
    

    // ================================================================================================ //
    out_color = out_color * diffuse;
    out_color.xyz = out_color * shadow_color + specular; 

    // DEBUG
    // out_color.xyz = specular;
    // out_color.xyz = lightmp.x;

    if(_EyeShadowMat) out_color = _Color;

    // out_color.xyz = lightmp.w;
    // out_color = shadow_area;

    return out_color;
}

float4 ps_face_stencil(vs_out i, bool vface : SV_IsFrontFace) : SV_Target
{
    float2 uv     = i.uv.xy;
    float4 facemap = _FaceMap.Sample(sampler_FaceMap, uv);
    float4 diffuse = _MainTex.Sample(sampler_MainTex, uv);  
    if(!_FaceMaterial)
    {
        _HairBlendSilhouette = 1.0;
        facemap = 0.0;
    }
    clip(facemap.y - _HairBlendSilhouette);
    float4 out_color = diffuse;
    out_color.a = 0.5f;
    // out_color.xyz = facemap.y;
    return out_color;
}

float4 ps_edge(vs_out i) : SV_Target
{
    float2 uv      = i.uv.xy;
    float lightmp = _LightMap.Sample(sampler_LightMap, uv).w;

    int material_ID = floor(lightmp * 8.0f);

    int material = material_region(material_ID);

    float4 outline_color[8] =
    {
        _OutlineColor0,
        _OutlineColor1,
        _OutlineColor2,
        _OutlineColor3,
        _OutlineColor4,
        _OutlineColor5,
        _OutlineColor6,
        _OutlineColor7,
    };
    
    float4 out_color = outline_color[material];
    if(_FaceMaterial) out_color = _OutlineColor;

    return out_color;
}
