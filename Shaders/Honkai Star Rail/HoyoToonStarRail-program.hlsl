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
    
    if(_FaceMaterial) // sigh is this even going to work in vr? 
    {

        // float3 outline_direction;
        // float3 outline_side = float3(-0.206f, 0.961f, _OutlineFixSide);
        // float3 ws_pos = mul(i.pos.xyz, (float3x3)unity_ObjectToWorld);
        // float3 view_dir = _WorldSpaceCameraPos - ws_pos.xyz;
        // float4 ws_view;
        // ws_view.xyz  = mul(view_dir, (float3x3)unity_ObjectToWorld);
        // float view_length = length(ws_view);
        // // they reuse the length of the view vector for a later line so as to not do the math twice in a row 
        // // ill just use the length to finish up normalizing the view vector
        // ws_view.yzw = view_length * ws_view.xyz;

        // float side_pos       = ws_pos.x * view_length + -0.1f;
        // outline_direction.x  = dot(outline_side, ws_view.xyz);
        // float4 outline_front = float4(_OutlineFixSide, -0.206f, 0.961f, _OutlineFixFront);
        // outline_direction.y  = dot(outline_front, ws_view.xyz);
        // outline_direction.z  = dot(float2(0.076f, 0.961f), ws_view.xy);

        // outline_direction.x = max(9.999 * (0.1f - max(outline_direction.y, outline_direction.x)), 0.0f);
        // outline_direction.y = outline_direction.x * outline_direction.x * (outline_direction * -2.0f + 3.0f);
        // outline_direction.x = max(outline_direction.x, 1.0f);

        // outline_direction.y = saturate(outline_direction.z);
        // outline_direction.z = 1.0f - outline_direction.z;
        // outline_direction.y = outline_front.x + outline_direction.y;
        // oultine_direction.yw = 

        float4 tmp0;
        float4 tmp1;
        float4 tmp2;
        float4 tmp3;
        tmp0.xy = float2(-0.206, 0.961);
        tmp0.z = _OutlineFixSide;
        tmp1.xyz = mul(i.pos.xyz, (float3x3)unity_ObjectToWorld).xyz;
        tmp2.xyz = _WorldSpaceCameraPos - tmp1.xyz;
        tmp1.xyz = mul(tmp1.xyz, (float3x3)unity_ObjectToWorld).xyz;
        tmp0.w = length(tmp1.xyz);
        tmp1.yzw = tmp0.w * tmp1.xyz;
        tmp0.w = tmp1.x * tmp0.w + -0.1; // outline_side.x * 
        tmp0.x = dot(tmp0.xyz, tmp1.xyz); 
        tmp2.yz = float2(-0.206, 0.961);
        tmp2.xw = -float2(_OutlineFixSide.x, _OutlineFixFront.x);
        tmp0.y = dot(tmp2.xyz, tmp1.xyz);
        tmp0.z = dot(float2(0.076, 0.961), tmp1.xy);
        tmp0.x = max(tmp0.y, tmp0.x);
        tmp0.x = 0.1 - tmp0.x;
        tmp0.x = tmp0.x * 9.999998;
        tmp0.x = max(tmp0.x, 0.0);
        tmp0.y = tmp0.x * -2.0 + 3.0;
        tmp0.x = tmp0.x * tmp0.x;
        tmp0.x = tmp0.x * tmp0.y;
        tmp0.x = min(tmp0.x, 1.0);
        tmp0.y = saturate(tmp0.z);
        tmp0.z = 1.0 - tmp0.z;
        tmp0.y = tmp2.x + tmp0.y;
        tmp0.yw = saturate(tmp0.yw * float2(20.0, 5.0));
        tmp1.x = tmp0.y * -2.0 + 3.0;
        tmp0.y = tmp0.y * tmp0.y;
        tmp0.y = tmp0.y * tmp1.x;
        tmp0.x = max(tmp0.x, tmp0.y);
        tmp0.x = min(tmp0.x, 1.0);
        tmp0.x = tmp0.x - 1.0;
        tmp0.x = i.v_col.y * tmp0.x + 1.0;
        tmp0.x = tmp0.x * _OutlineWidth;
        tmp0.x = tmp0.x * _OutlineScale;
        tmp0.y = tmp0.w * -2.0 + 3.0;
        tmp0.w = tmp0.w * tmp0.w;
        tmp0.y = tmp0.w * tmp0.y;
        tmp1.xy = -float2(_OutlineFixRange1.x, _OutlineFixRange2.x) + float2(_OutlineFixRange3.x, _OutlineFixRange4.x);
        tmp0.yw = tmp0.yy * tmp1.xy + float2(_OutlineFixRange1.x, _OutlineFixRange2.x);

        tmp0.y = smoothstep(tmp0.y, tmp0.w, tmp0.z);

        tmp0.y = tmp0.y * i.v_col.z;
        tmp0.zw = i.v_col.zy > float2(0.0, 0.0);
        tmp0.y = tmp0.z ? tmp0.y : i.v_col.w;
        tmp0.z = i.v_col.y < 1.0;
        tmp0.z = tmp0.w ? tmp0.z : 0.0;
        tmp0.z = tmp0.z ? 1.0 : 0.0;
        tmp0.y = tmp0.z * _FixLipOutline + tmp0.y;
        tmp0.x = tmp0.y * tmp0.x;


        float3 outline_normal;
        outline_normal = mul((float3x3)UNITY_MATRIX_IT_MV, i.tangent.xyz);
        outline_normal.z = -1;
        outline_normal.xyz = normalize(outline_normal.xyz);
        float4 wv_pos = mul(UNITY_MATRIX_MV, i.pos);
        float fov_width = 1.0f / (rsqrt(abs(wv_pos.z / unity_CameraProjection._m11)));
        if(!_EnableFOVWidth) fov_width = 0.5f;
        wv_pos.xyz = wv_pos + (outline_normal * fov_width * tmp0.x);
        o.pos = mul(UNITY_MATRIX_P, wv_pos);
        
        // o.pos = mul(UNITY_MATRIX_MV, i.pos);
        // o.pos = mul(UNITY_MATRIX_P, o.pos);

    }
    else
    {
        float3 outline_normal;
        outline_normal = mul((float3x3)UNITY_MATRIX_IT_MV, i.tangent.xyz);
        outline_normal.z = -1;
        outline_normal.xyz = normalize(outline_normal.xyz);
        float4 wv_pos = mul(UNITY_MATRIX_MV, i.pos);
        float fov_width = 1.0f / (rsqrt(abs(wv_pos.z / unity_CameraProjection._m11)));
        if(!_EnableFOVWidth)fov_width = 0.5f;
        wv_pos.xyz = wv_pos + (outline_normal * fov_width * (i.v_col.w * _OutlineWidth * _OutlineScale));
        o.pos = mul(UNITY_MATRIX_P, wv_pos);
    }
    // float3 outline_normal;
    // outline_normal = mul((float3x3)UNITY_MATRIX_IT_MV, i.tangent.xyz);
    // outline_normal.xyz = normalize(outline_normal.xyz);
    // float4 wv_pos = mul(UNITY_MATRIX_MV, i.pos);
    // // float fov_width = 1.0f / (rsqrt(abs(wv_pos.z / unity_CameraProjection._m11)));
    // // if(!_EnableFOVWidth)fov_width = 0.5f;
    // wv_pos.xyz = wv_pos + (outline_normal * (i.v_col.w * _OutlineWidth * _OutlineScale));
    // o.pos = mul(UNITY_MATRIX_P, wv_pos);

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
        normal.z = normal.z * -1.0f;
    }

    // INITIALIZE OUTPUT COLOR : 
    float4 out_color = color;

    // GET ENVIROMENTAL LIGHTING 
    float4 enviro_light = get_enviro_light(i.ws_pos);
    enviro_light.xyz = lerp(1, enviro_light, _EnvironmentLightingStrength);
    out_color = out_color * enviro_light;

    // COMPUTE HALF VECTOR : 
    float3 half_vector = normalize(view + _WorldSpaceLightPos0);

    // DOT PRODUCTS : 
    float ndotl = dot(normal, _WorldSpaceLightPos0);
    float ndoth = dot(normal, half_vector);
    float ndotv = dot(normal, view);

    // SAMPLE TEXTURES : 
    float4 diffuse = _MainTex.Sample(sampler_MainTex, uv);
    float4 lightmap = _LightMap.Sample(sampler_LightMap, uv);
    float4 facemap = _FaceMap.Sample(sampler_FaceMap, uv);
    float4 faceexp = _FaceExpression.Sample(sampler_LightMap, uv);

    // diffuse alpha toggle
    if(!_IsTransparent) diffuse.w = 1.0f;

    // EXTRACT MATERIAL REGIONS 
    float material_ID = floor(lightmap.w * 8.0f);
    float ramp_ID     = ((material_ID * 2.0f + 1.0f) * 0.0625f);
    // when writing the shader for mmd i had to invert the ramp ID since the uvs are read differently  

    // I dont want to write a set of if else statements like this for the specular, rim, and mlut
    // so this is the next best thing i can do
    int curr_region = material_region(material_ID);
    
    
    // ================================================================================================ //
    // SHADOW AREA :
    float shadow_area = shadow_rate(ndotl, lightmap.y, vcol.x, _ShadowRamp);

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
    

    float3 specular = specular_base(shadow_area, ndoth, lightmap.z, specular_color[curr_region], specular_values[curr_region], _ES_SPColor, _ES_SPIntensity);
    
    // ================================================================================================ //
    // rim light : 
    // populate arrays with material values 
    float4 rim_color[8] =
    {
        _RimColor0,
        _RimColor1,
        _RimColor2,
        _RimColor3,
        _RimColor4,
        _RimColor5,
        _RimColor6,
        _RimColor7,   
    };

    float4 rim_values[8] = // x = width, y = softness, z = type, w = dark
    {
        float4(_RimWidth0, _RimEdgeSoftness0, _RimType0, _RimDark0),
        float4(_RimWidth1, _RimEdgeSoftness1, _RimType0, _RimDark1),
        float4(_RimWidth2, _RimEdgeSoftness2, _RimType0, _RimDark2),
        float4(_RimWidth3, _RimEdgeSoftness3, _RimType0, _RimDark3),
        float4(_RimWidth4, _RimEdgeSoftness4, _RimType0, _RimDark4),
        float4(_RimWidth5, _RimEdgeSoftness5, _RimType0, _RimDark5),
        float4(_RimWidth6, _RimEdgeSoftness6, _RimType0, _RimDark6),
        float4(_RimWidth7, _RimEdgeSoftness7, _RimType0, _RimDark7),
    };

    float2 screen_pos = i.ss_pos.xy / i.ss_pos.ww;
    float camera_depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, screen_pos);
    camera_depth = LinearEyeDepth(camera_depth);
    
    float rim_width = lerp(1.0f, lightmap.x, _RimLightMode) *  _RimWidth;
    ndotl = ndotl * 0.5f + 0.5f;
    float rim_shadow = dot(float2(rim_width, ndotl), float2(rim_width, ndotl));

    // ================================================================================================ //
    out_color = out_color * diffuse;
    out_color.xyz = out_color * shadow_color + specular; 

    // DEBUG
    // out_color.xyz = specular;
    // out_color.xyz = lightmap.x;

    if(_EyeShadowMat) out_color = _Color;


    return out_color;
}

float4 ps_face_stencil(vs_out i, bool vface : SV_IsFrontFace) : SV_Target
{
    float2 uv     = i.uv.xy;
    float4 facemap = _FaceMap.Sample(sampler_FaceMap, uv);
    float4 diffuse = _MainTex.Sample(sampler_MainTex, uv);  
    if(_FaceMaterial)
    {
        clip(facemap.y - _HairBlendSilhouette);
    } 
    else if(_HairMaterial)
    {
        diffuse.a = 0.5f;
    }
    else
    {
        discard;
    }
    float4 out_color = diffuse;
    return out_color;
}


float4 ps_edge(vs_out i, bool vface : SV_IsFrontFace) : SV_Target
{
    float2 uv      = i.uv.xy;
    float lightmap = _LightMap.Sample(sampler_LightMap, uv).w;

    int material_ID = floor(lightmap * 8.0f);

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
