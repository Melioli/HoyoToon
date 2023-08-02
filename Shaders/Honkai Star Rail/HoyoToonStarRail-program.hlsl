vs_out vs_base(vs_in i)
{
    vs_out o = (vs_out)0.0f;
    float4 pos_ws  = mul(unity_ObjectToWorld, i.pos);
    float4 pos_wvp = mul(UNITY_MATRIX_VP, pos_ws);
    o.pos = pos_wvp;
    o.ws_pos =  mul(unity_ObjectToWorld, i.pos);
    o.ss_pos = ComputeScreenPos(o.pos);
    // o.ss_pos = o.pos;

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
        if(!_EnableFOVWidth) fov_width = 1;
        wv_pos.xyz = wv_pos + (outline_normal * fov_width * tmp0.x);
        o.pos = mul(UNITY_MATRIX_P, wv_pos);
    }
    else
    {
        float3 outline_normal;
        outline_normal = mul((float3x3)UNITY_MATRIX_IT_MV, i.tangent.xyz);
        outline_normal.z = -1;
        outline_normal.xyz = normalize(outline_normal.xyz);
        float4 wv_pos = mul(UNITY_MATRIX_MV, i.pos);
        float fov_width = 1.0f / (rsqrt(abs(wv_pos.z / unity_CameraProjection._m11)));
        if(!_EnableFOVWidth)fov_width = 1;
        wv_pos.xyz = wv_pos + (outline_normal * fov_width * (i.v_col.w * _OutlineWidth * _OutlineScale));
        o.pos = mul(UNITY_MATRIX_P, wv_pos);
    }
    o.uv = float4(i.uv_0, i.uv_1);
    o.v_col = i.v_col;    
    o.ws_pos = mul(unity_ObjectToWorld, i.pos);
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

    color.a = 1.0f; // this prevents issues with the alpha value of the material being less than 1
    // might remove later

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
    float lightmap_alpha = _LightMap.Sample(sampler_LightMap, i.uv.xy).w;
    float4 facemap = _FaceMap.Sample(sampler_FaceMap, uv);
    float4 faceexp = _FaceExpression.Sample(sampler_LightMap, uv);

    // EXTRACT MATERIAL REGIONS 
    float material_ID = floor(8.0f * lightmap.w);
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

    int4 lut_uv;
    lut_uv.x = material_ID;
    lut_uv.yzw = int3(1,0,0);
    float4 lut_a = _MaterialValuesPackLUT.Load(lut_uv.xwww);
    float4 lut_b = _MaterialValuesPackLUT.Load(lut_uv.xyz);

    
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
        float3(_SpecularShininess0, _SpecularRoughness0, _SpecularIntensity0),
        float3(_SpecularShininess1, _SpecularRoughness1, _SpecularIntensity1),
        float3(_SpecularShininess2, _SpecularRoughness2, _SpecularIntensity2),
        float3(_SpecularShininess3, _SpecularRoughness3, _SpecularIntensity3),
        float3(_SpecularShininess4, _SpecularRoughness4, _SpecularIntensity4),
        float3(_SpecularShininess5, _SpecularRoughness5, _SpecularIntensity5),
        float3(_SpecularShininess6, _SpecularRoughness6, _SpecularIntensity6),
        float3(_SpecularShininess7, _SpecularRoughness7, _SpecularIntensity7),
    };
    
    if(_UseMaterialValuesLUT)
    {
        curr_region = 0;
        specular_color[curr_region] = lut_a;
        specular_values[curr_region] = lut_b.xyz;
    }
    if(_FaceMaterial)
    {
        specular_color[curr_region] = (float4)0.0f;
    }
    specular_values[curr_region].z = max(0.0f, specular_values[curr_region].z); // why would there ever be a reason for a negative specular intensity

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

    if(_UseMaterialValuesLUT) 
    {
        
        // rim_values[curr_region] = _MaterialValuesPackLUT.Load(lut_uv.xwww);
    }

    // dear fucking god i hate this shit
    float2 screen_pos = i.ss_pos.xy / i.ss_pos.ww;
    float camera_depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, screen_pos));    // camera_depth = _ZBufferParams.x * camera_depth.x + _ZBufferParams.y;
   
    
    float rim_width = lerp(1.0f, lightmap.x, _RimLightMode) * (rim_values[curr_region].x - 0.01f);
    ndotl = ndotl * 0.5f + 0.5f;
    float rim_shadow = dot(float2(rim_width, ndotl), float2(rim_width, ndotl)); 

    float3 vs_normal = normalize(mul((float3x3)UNITY_MATRIX_V, i.normal));
    float rim_side = i.ws_pos.z * -normal.x - (i.ws_pos.x * -normal.z); // in game they use the view space normals but thats causing some issues 
    rim_side = (rim_side > 0.0f) ? -1.0f : 1.0f; 
    float rim_depth = camera_depth * _ZBufferParams.z + 3.0f;
    float rim_area = ((rim_side * rim_width) * 0.0055f) / rim_depth;

    float2 rim_offset = _ES_RimLightOffset.xy - _RimOffset;
    float distance_from_camera = saturate(1.0f /  distance(_WorldSpaceCameraPos.xyz, i.ws_pos));
    rim_offset.x = (1.0f - rim_offset.x) * rim_side; // this isnt accurate to the game but i dont think unitys default depth stuff is accurate either
    rim_offset = rim_offset * distance_from_camera; // multiply by camera distance to ensure a consistent thickness
    float2 rim_uv = screen_pos; 
    rim_uv.x = rim_uv.x + (rim_offset.x * 0.01f + (rim_area / rim_depth));
    rim_uv.y = rim_uv.y + (rim_offset.y * 0.01f);

    float offset_depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, rim_uv)); 

    float rim_diff = pow(max(offset_depth - camera_depth, 0.0000001f), _RimEdge);
    float rim_base = rim_diff - 0.82f;
    rim_base = (saturate(rim_base * 12.5f) * -2.0f + 3.0f) * (rim_base * rim_base);
    
    rim_base = (rim_values[curr_region].y < rim_base) ? rim_base * vface : 0.0f;
    
    float3 rim_light = rim_base * rim_color[curr_region] * distance_from_camera; // fade rim light as it gets further from the camera
    // ================================================================================================ //
    // FACE EXPRESSION MAP
    float3 nose_view = view;
    nose_view.y = nose_view.y * 0.5f;
    float nose_ndotv = max(dot(nose_view, normal), 0.0001f);
    float nose_power = max(_NoseLinePower * 8.0f, 0.1f);
    nose_ndotv = pow(nose_ndotv, nose_power);

    float nose_area = facemap.z * nose_ndotv;
    nose_area = (nose_area > 0.1f) ? 1.0f : 0.0f;
    if(_FaceMaterial) diffuse.xyz = lerp(diffuse.xyz, _NoseLineColor, nose_area); 
    
    // ================================================================================================ //
   
   
    out_color = out_color * diffuse;
    if(_EnableAlphaCutoff) clip(out_color.a - _AlphaCutoff);
    out_color.xyz = out_color * shadow_color + (specular + rim_light); 
    // out_color.xyz = out_color.xyz + rim_light;

    if(!_IsTransparent) out_color.w = 1.0f;
    if(_EyeShadowMat) out_color = _Color;
    #ifdef is_stencil // so the hair and eyes dont lose their shading
    if(_FaceMaterial)
    {
        clip(saturate(facemap.y + diffuse.a) - _HairBlendSilhouette); // it is not accurate to use the diffuse alpha channel in this step
        // but it looks weird if the eye shines are specifically omitted from the stencil
    } 
    else if(_HairMaterial)
    {
        // out_color.a = saturate(smoothstep(0.0, 1.0, bangs));
        out_color.a = 0.5f;
    }
    else
    {
        discard;
    }
    #endif

    // out_color.xyz = 1.0f / distance_from_camera;

    return out_color;
}


float4 ps_edge(vs_out i, bool vface : SV_IsFrontFace) : SV_Target
{
    float2 uv      = i.uv.xy;

    if(!vface) // use uv2 if vface is false
    { // so basically if its a backfacing face
        uv.xy = i.uv.zw;
    }
    float lightmap = _LightMap.Sample(sampler_LightMap, uv).w;

    float4 enviro_light = get_enviro_light(i.ws_pos);
    enviro_light.xyz = lerp(1, enviro_light, _EnvironmentLightingStrength);
    // out_color = out_color * enviro_light;

    int material_ID = floor(lightmap * 8.0f);

    int material = material_region(material_ID);

    int4 lut_uv;
    lut_uv.x = material_ID;
    lut_uv.yzw = int3(2,0,0);
    float4 lut = _MaterialValuesPackLUT.Load(lut_uv.xyww);

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

    if(_UseMaterialValuesLUT) outline_color[material] = lut;


    float4 out_color = outline_color[material];
    if(_FaceMaterial) out_color = _OutlineColor;
    out_color.xyz = out_color * enviro_light;
    out_color.a = 1.0f;
    if(i.v_col.w < 0.05f) discard; // discard all pixels with the a vertex color alpha value of less than 0.05f
    // this fixes double sided meshes for hsr having bad outlines
    return out_color;
}
