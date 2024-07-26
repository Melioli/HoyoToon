float materialID(float alpha)
{
    float region = alpha;

    float material = 1.0f;

    material = (_UseMaterial2 && (region >= 0.8f)) ? 2.0f : 1.0f;
    material = (_UseMaterial3 && (region >= 0.4f && region <= 0.6f)) ? 3.0f : material;
    material = (_UseMaterial4 && (region >= 0.2f && region <= 0.4f)) ? 4.0f : material;
    material = (_UseMaterial5 && (region >= 0.6f && region <= 0.8f)) ? 5.0f : material;

    return material;
}

// from: https://github.com/cnlohr/shadertrixx/blob/main/README.md#best-practice-for-getting-depth-of-a-given-pixel-from-the-depth-texture
float GetLinearZFromZDepth_WorksWithMirrors(float zDepthFromMap, float2 screenUV)
{
	#if defined(UNITY_REVERSED_Z)
	zDepthFromMap = 1 - zDepthFromMap;
			
	// When using a mirror, the far plane is whack.  This just checks for it and aborts.
	if( zDepthFromMap >= 1.0 ) return _ProjectionParams.z;
	#endif

	float4 clipPos = float4(screenUV.xy, zDepthFromMap, 1.0);
	clipPos.xyz = 2.0f * clipPos.xyz - 1.0f;
	float4 camPos = mul(unity_CameraInvProjection, clipPos);
	return -camPos.z / camPos.w;
}

float3 DecodeLightProbe( float3 N )
{
    return ShadeSH9(float4(N,1));
}

float4 maintint(float4 diffuse)
{
    float4 u_xlat1 = diffuse;
    float4 u_xlat16_4 = u_xlat1 * _MainTexTintColor;
    float4 u_xlat16_5 = u_xlat16_4 + u_xlat16_4;
    float4 u_xlat16_6 = u_xlat1 + _MainTexTintColor;
    u_xlat16_6.xyz = u_xlat16_6.xyz + u_xlat16_6.xyz;
    u_xlat16_4.xyz = u_xlat16_4.xyz * float3(-4.0, -4.0, -4.0) + u_xlat16_6.xyz;
    u_xlat16_6.x = (0.5f < u_xlat1.x) ? float(1.0) : float(0.0);
    u_xlat16_6.y = (0.5f < u_xlat1.y) ? float(1.0) : float(0.0);
    u_xlat16_6.z = (0.5f < u_xlat1.z) ? float(1.0) : float(0.0);
    u_xlat16_4.xyz = u_xlat16_4.xyz + float3(-1.0, -1.0, -1.0);
    u_xlat16_4.xyz = u_xlat16_6.xyz * u_xlat16_4.xyz + u_xlat16_5.xyz;
    return u_xlat16_4;
}

float4 coloring(float region, float4 mask)
{
    float4 colors[5] = 
    {
        _Color,
        _Color2,
        _Color3,
        _Color4,
        _Color5,
    };

    float4 color = _Color;
    color = colors[region - 1.0f];

    color = (!_DisableColors) ? color : (float4)1.0f;
    return color;
}

float4 material_mask_coloring(float4 mask)
{

    mask = mask * float4(_UseMaterial3, _UseMaterial4, _UseMaterial5, _UseMaterial2);
    float3 color = lerp(_Color, _Color2, mask.w);
    color = lerp(color, _Color3, mask.x);
    color = lerp(color, _Color4, mask.y);
    color = lerp(color, _Color5, mask.z);
    return float4(color, 1.0f);
}

float packed_channel_picker(SamplerState texture_sampler, Texture2D texture_2D, float2 uv, float channel)
{
    float4 packed = texture_2D.Sample(texture_sampler, uv);

    float choice;
    if(channel == 0) {choice = packed.x;}
    else if(channel == 1) {choice = packed.y;}
    else if(channel == 2) {choice = packed.z;}
    else if(channel == 3) {choice = packed.w;}

    return choice;
}

float3 hue_shift(float3 in_color, float material_id, float shift1, float shift2, float shift3, float shift4, float shift5, float shiftglobal, float autobool, float autospeed, float mask)
{   
    float auto_shift = (_Time.y * autospeed) * autobool; 
    
    float shift[5] = 
    {
        shift1,
        shift2,
        shift3,
        shift4,
        shift5
    };
    
    float shift_all = 0.0f;
    if(shift[material_id - 1] > 0)
    {
        shift_all = shift[material_id - 1] + auto_shift;
    }
     
    
    auto_shift = (_Time.y * autospeed) * autobool; 
    if(shiftglobal > 0)
    {
        shiftglobal = shiftglobal + auto_shift;
    }
    

    float hue = shift_all + shiftglobal;
    hue = lerp(0.0f, 6.27f, hue);

    float3 k = (float3)0.57735f;
    float cosAngle = cos(hue);

    float3 adjusted_color = in_color * cosAngle + cross(k, in_color) * sin(hue) + k * dot(k, in_color) * (1.0f - cosAngle);

    return lerp(in_color, adjusted_color, mask);
}

float3 normal_mapping(float3 normalmap, float4 vertexws, float2 uv, float3 normal)
{
    float3 bumpmap = normalmap.xyz;
    bumpmap.xy = bumpmap.xy * 2.0f - 1.0f;
<<<<<<< Updated upstream
    bumpmap.z = max(1.0f - min(_BumpScale, 0.5f), 0.001f);
    bumpmap.xyz = normalize(bumpmap);   
=======
    bumpmap.z = max(-min(_BumpScale, 0.5f) + 1.0f, 0.001f);
    bumpmap.xyz = _DummyFixedForNormal ? bumpmap : normalize(bumpmap);   // why why why
>>>>>>> Stashed changes
    // world space position derivative
    float3 p_dx = ddx(vertexws);
    float3 p_dy = ddy(vertexws);  
    // texture coord derivative
    float3 uv_dx;
    uv_dx.xy = ddx(uv);
    float3 uv_dy;
    uv_dy.xy = ddy(uv); 
    uv_dy.z = -uv_dx.y;
    uv_dx.z = uv_dy.x;  
    // this functions the same way as the w component of a traditional set of tangents.
    // determinent of the uv the direction of the bitangent
    float3 uv_det = dot(uv_dx.xz, uv_dy.yz);
    uv_det = -sign(uv_det); 
    // normals are inverted in the case of a back-facing poly
    // useful for the two sided dresses and what not... 
    float3 corrected_normal = normal;   
    float2 tangent_direction = uv_det.xy * uv_dy.yz;
    float3 tangent = (tangent_direction.y * p_dy.xyz) + (p_dx * tangent_direction.x);
    tangent = normalize(tangent);
    float3 bitangent = cross(corrected_normal.xyz, tangent.xyz);
    bitangent = bitangent * -uv_det;    
    float3x3 tbn = {tangent, bitangent, corrected_normal};  
    float3 mapped_normals = mul(bumpmap.xyz, tbn);
    mapped_normals = normalize(mapped_normals); // for some reason, this normalize messes things up in mmd  
    mapped_normals = (0.99f >= bumpmap.z) ? mapped_normals : corrected_normal;  
    return mapped_normals; 
}

void detail_line(float2 sspos, float sdf, inout float3 diffuse)
{
    float3 line_color = (_TextureLineMultiplier.xyz * diffuse.xyz - diffuse.xyz) * _TextureLineMultiplier.www;
    float line_dist = LinearEyeDepth(sspos.x / sspos); // this may need to be replaced with the version that works for mirrors, will wait for feedback    
    float line_thick = _TextureLineDistanceControl.x * line_dist + _TextureLineThickness;
    line_thick = 1.0f - min(line_thick, min(_TextureLineDistanceControl.y, 0.99f)); 
    line_dist = (line_dist > _TextureLineDistanceControl.z) ? 1.0f : 0.0f;
    line_thick = 1.0f - line_thick;

    float line_smooth = -_TextureLineSmoothness * line_dist + line_thick;
    line_dist = _TextureLineSmoothness * line_dist + line_thick;
    line_dist = -line_smooth + line_dist;   
    float lines = sdf - line_smooth;
    line_dist = 1.0f / line_dist;
    lines = lines * line_dist;
    lines = saturate(lines);
    line_dist = lines * -2.0f + 3.0f;
    lines = lines * lines;
    lines = lines * line_dist;
    // these 6 lines above are a smoothstep
    diffuse.xyz = lines * line_color + diffuse.xyz;
}

float shadow_area_face(float2 uv, float3 light)
{   
    // float3 light = normalize(_WorldSpaceLightPos0.xyz);
    
    float3 head_forward = normalize(UnityObjectToWorldDir(_headForwardVector.xyz));
    float3 head_right   = normalize(UnityObjectToWorldDir(_headRightVector.xyz));
    float rdotl = dot((head_right.xz),  (light.xz));
    float fdotl = dot((head_forward.xz), (light.xz));

    float2 faceuv = 1.0f;
    if(rdotl > 0.0f )
    {
        faceuv = uv;
    }  
    else
    {
        faceuv = uv * float2(-1.0f, 1.0f) + float2(1.0f, 0.0f);
    }

    float shadow_step = 1.0f - (fdotl * 0.5f + 0.5f);

    // apply rotation offset
    shadow_step = smoothstep(max(_FaceMapRotateOffset, 0.0), min(_FaceMapRotateOffset + 1.0f, 1.0f), shadow_step);
    
    // use only the alpha channel of the texture 
    float facemap = _FaceMapTex.Sample(sampler_FaceMapTex, faceuv).w;
    // interpolate between sharp and smooth face shading
    shadow_step = smoothstep(shadow_step - (_FaceMapSoftness), shadow_step + (_FaceMapSoftness), facemap);

    

    return shadow_step;
}

float3 shadow_area_ramp(float lightmapao, float vertexao, float vertexwidth, float ndotl, float material_id)
{
    float3 shadow = 1.0f;

    lightmapao = (_UseLightMapColorAO) ? lightmapao + -0.5f : 0.0f;
    float shadow_thresh = dot(lightmapao.xx, abs(lightmapao.xx)) + 0.5f;
    shadow_thresh = (_UseVertexColorAO) ? shadow_thresh * vertexao : shadow_thresh;

    float shadow_bright = 0.95f < shadow_thresh;
    float shadow_dark = shadow_thresh < 0.05f;

    float shadow_area = (shadow_bright) ? 1.0f : ((ndotl * 0.5f + 0.5f) + shadow_thresh) * 0.5f;
    shadow_area = (shadow_dark) ? 0.0f : shadow_area;

    float shadow_check = shadow_area < _LightArea;
    
    shadow_area = (-shadow_area + _LightArea) / _LightArea;

    float width = (_UseVertexRampWidth) ? max(0.01f, vertexwidth + vertexwidth) * _ShadowRampWidth : _ShadowRampWidth;

    shadow_area = shadow_area / width;

    shadow.x = 1.0f - min(shadow_area, 1.0f);
    shadow.x = shadow_check ? shadow.x : 1.0f;
    shadow.y = shadow_check ? 1.0f : 0.0f; 
    shadow.z = shadow_area;

    return shadow;
}

float shadow_area_transition(float lightmapao, float vertexao, float ndotl, float material_id)
{
    float shadow = 1.0f;

    lightmapao = (_UseLightMapColorAO) ? lightmapao - 0.5f: 0.5f;

    float shadow_thresh = dot(lightmapao.xx, abs(lightmapao.xx)) + 0.5f;
    shadow_thresh = (_UseVertexColorAO) ? shadow_thresh * vertexao : shadow_thresh;

    float shadow_bright = shadow_thresh > 0.95f; 
    float shadow_dark = shadow_thresh < 0.05f;

    shadow_thresh = (shadow_thresh + (ndotl * 0.5f + 0.5f)) * 0.5f;
    
    shadow = (shadow_bright) ? 1.0f : shadow_thresh;
    shadow = (shadow_dark) ? 0.0f : shadow;
    float transition; 
    float area = (shadow < _LightArea);
    
    #ifdef _IS_PASS_LIGHT
    float2 trans_value[5] =
    {
        float2(0.1f, 1.0f),
        float2(0.1f, 1.0f),
        float2(0.1f, 1.0f),
        float2(0.1f, 1.0f),
        float2(0.1f, 1.0f),
    };
    #else
    float2 trans_value[5] =
    {
        float2(_ShadowTransitionRange, _ShadowTransitionSoftness),
        float2(_ShadowTransitionRange2, _ShadowTransitionSoftness2),
        float2(_ShadowTransitionRange3, _ShadowTransitionSoftness3),
        float2(_ShadowTransitionRange4, _ShadowTransitionSoftness4),
        float2(_ShadowTransitionRange5, _ShadowTransitionSoftness5),
    };
    #endif
    

    shadow = -shadow + _LightArea;
    shadow = shadow / trans_value[material_id - 1].x;
    float check = shadow.x >= 1.0f;
    transition = min(pow(shadow + 0.009f, trans_value[material_id - 1].y), 1.0f);

    shadow = (check) ? 1.0f : transition;
    shadow = (_UseShadowTransition) ? shadow : 1.0f;
    shadow = (area) ? shadow : 0.0f;

    #ifdef _IS_PASS_LIGHT
    shadow.x = saturate(1.0f - shadow.x);
    #endif

    return shadow;
}

void shadow_color(in float lightmapao, in float vertexao, in float customao, in float vertexwidth, in float ndotl, in float material_id, in float2 uv, inout float3 shadow, inout float3 metalshadow, inout float3 color, float3 light)
{
    if(_CustomAOEnable)
    {
        ndotl = ndotl * customao;
    }
    float3 outcolor = (float3)1.0f;
    float4 warm_shadow_array[5] = 
    {
        _FirstShadowMultColor,
        _FirstShadowMultColor2,
        _FirstShadowMultColor3,
        _FirstShadowMultColor4,
        _FirstShadowMultColor5,
    };
    float4 cool_shadow_array[5] =
    {
        _CoolShadowMultColor,
        _CoolShadowMultColor2,
        _CoolShadowMultColor3,
        _CoolShadowMultColor4,
        _CoolShadowMultColor5,
    };
    outcolor = lerp(warm_shadow_array[material_id - 1], cool_shadow_array[material_id - 1], _DayOrNight);
    
    float3 outshadow = (float3)1.0f;
    if(_UseShadowRamp) outshadow = shadow_area_ramp(lightmapao, vertexao, vertexwidth, ndotl, material_id);
    if(!_UseShadowRamp) outshadow = shadow_area_transition(lightmapao, vertexao, ndotl, material_id);  

    if(_UseFaceMapNew)
    {
        outshadow = shadow_area_face(uv, light).xxx;
        if(_CustomAOEnable) outshadow = outshadow * customao;        
    }
    shadow = outshadow;
    metalshadow = outshadow;

    

    if(_UseShadowRamp)
    {
        float2 day_ramp_coords = -((material_id - 1.0f) * 0.1f + 0.05f) + 1.0f;
        day_ramp_coords.x = shadow.x;
        float2 night_ramp_coords = -((material_id - 1.0f) * 0.1f + 0.55f) + 1.0f;
        night_ramp_coords.x = shadow.x;
        float3 dayramp = _PackedShadowRampTex.SampleLevel(sampler_PackedShadowRampTex, day_ramp_coords, 0.0f).xyz;
        float3 nightramp = _PackedShadowRampTex.SampleLevel(sampler_PackedShadowRampTex, night_ramp_coords, 0.0f);
        float3 ramp = lerp(dayramp, nightramp, _DayOrNight);
        color = lerp(1.0f, ramp, shadow.y);
    }
    else if(_UseFaceMapNew)
    {
        color = lerp(outcolor, 1.0f, shadow.x);
    }
    else
    {
        color = lerp(1.0f, outcolor, shadow.x);
    }
    
}

void metalics(in float3 shadow, in float3 normal, float3 ndoth, float speculartex, float backfacing, inout float3 color)
{
    float shadow_transition = ((bool)shadow.y) ? shadow.z : 0.0f;
    shadow_transition = saturate(shadow_transition);
    float2 ugh = backfacing ? 1.0f : shadow.y;

    // calculate centered sphere coords for spheremapping
    float2 sphere_uv = mul(normal, (float3x3)UNITY_MATRIX_I_V ).xy;
    sphere_uv.x = sphere_uv.x * _MTMapTileScale; 
    sphere_uv = sphere_uv * 0.5f + 0.5f;  

    // sample sphere map 
    float sphere = _MTMap.Sample(sampler_MTMap, sphere_uv).x;
    sphere = sphere * _MTMapBrightness;
    sphere = saturate(sphere);
    
    // float3 metal_color = sphere.xxx;
    float3 metal_color = lerp(_MTMapDarkColor, _MTMapLightColor, sphere.xxx);
    metal_color = color * metal_color;

    ndoth = max(0.001f, ndoth);
    ndoth = pow(ndoth, _MTShininess) * _MTSpecularScale;
    ndoth = saturate(ndoth);

    float specular_sharp = _MTSharpLayerOffset<ndoth;

    float3 metal_specular = (float3)ndoth;
    if(specular_sharp)
    {
        metal_specular = _MTSharpLayerColor;
    }
    else
    {
        if(_MTUseSpecularRamp)
        {
            metal_specular = _MTSpecularRamp.Sample(sampler_MTSpecularRamp, float2(metal_specular.x, 0.5f)) * _MTSpecularColor;
            metal_specular = metal_specular * speculartex; 
        }
        else
        {  
            metal_specular = metal_specular * _MTSpecularColor;
            metal_specular = metal_specular * speculartex; 
        }    
    }

    float3 metal_shadow = lerp(1.0f, _MTShadowMultiColor, shadow_transition);
    metal_specular = lerp(metal_specular , metal_specular* _MTSpecularAttenInShadow, shadow_transition);
    float3 metal = metal_color + (metal_specular * (float3)0.5f);
    metal = metal * metal_shadow;  

    float metal_area = saturate((speculartex > 0.89f) - _UseCharacterLeather);

    if(_DebugMode && (_DebugMetal == 1))
    {
        metal = (metal_area) ? metal : (float3)0.0f;
        color.xyz = metal;
    }
    else
    {
        metal = (metal_area) ? metal : color;
        color.xyz = metal; 
    }

}

void specular_color(in float ndoth, in float3 shadow, in float lightmapspec, in float lightmaparea, in float material_id, inout float3 specular)
{
    float2 spec_array[5] =
    {
        float2(_Shininess, _SpecMulti),
        float2(_Shininess2, _SpecMulti2),
        float2(_Shininess3, _SpecMulti3),
        float2(_Shininess4, _SpecMulti4),
        float2(_Shininess5, _SpecMulti5),        
    };

    float4 color_array[5] =
    {
        _SpecularColor, 
        _SpecularColor2, 
        _SpecularColor3, 
        _SpecularColor4, 
        _SpecularColor5, 
    };
    
    float term = ndoth;
    term = pow(max(ndoth, 0.001f), spec_array[material_id - 1].x);
    float check = term > (-lightmaparea + 1.015);
    specular = term * (color_array[material_id - 1] * spec_array[material_id - 1].y) * lightmapspec; 
    specular = lerp((float3)0.0f, specular * (float3)0.5f, check);
}

void leather_color(in float ndoth, in float3 normal, in float3 light, in float lightmapspec, inout float3 leather, inout float3 holographic, inout float3 color)
{
    float2 sphere_uv = mul(normal , (float3x3)UNITY_MATRIX_I_V).xy; 
    float xaxis = sphere_uv.x * 0.5f + 0.5f;
    float area =  pow( 4.0 * xaxis * (1.0 - xaxis), 1); // this is to fix any weird edge when offseting the sphere coords
    sphere_uv.y = lerp(sphere_uv.y, sphere_uv.y + _LeatherReflectOffset, area);
    sphere_uv.x = sphere_uv.x * _MTMapTileScale;
    sphere_uv = sphere_uv * 0.5f + 0.5f;  

    // sample the leather matcap first before calculating the specular shines, i just felt like it
    float3 matcap = _LeatherReflect.SampleLevel(sampler_MTMap, sphere_uv, _LeatherReflectBlur) * _LeatherReflectScale;
    // blur controls the miplevel of the matcap giving a quick way to blur/soften the shine

    // main shine
    float specular = min(pow(max(ndoth, 0.001f), _LeatherSpecularRange), 1.0f);
    specular = smoothstep(0.5, _LeatherSpecularSharpe, specular.x) * _LeatherSpecularScale;

    // detail shine
    float3 detail = min(pow(max(ndoth, 0.001f), _LeatherSpecularDetailRange), 1.0f);
    detail = smoothstep(0.5f, _LeatherSpecularDetailSharpe, detail.x) * _LeatherSpecularDetailScale;
    detail = detail.xxx * _LeatherSpecularDetailColor.xyz;

    // holographic
    float holo = saturate(dot(normal, light) * 0.5f + 0.5f) * _LeatherLaserTiling + _LeatherLaserOffset;
    float3 holo_ramp = _LeatherLaserRamp.Sample(sampler_MainTex, holo.xx).xyz * _LeatherLaserScale;

    // combined
    float3 combined = max(matcap, specular * _LeatherSpecularColor + detail);

    leather = 0 + combined;
    leather = saturate(holo_ramp * holo_ramp + leather);
    color = (lightmapspec * leather) + color;
    
}

void glass_color(inout float4 color, in float4 uv, in float3 view, in float3 normal)
{   
    float2 specular_uv = (uv.zw * _GlassSpecularTex_ST.xy) * (float2)_GlassTiling + _GlassSpecularTex_ST.zw;
    specular_uv = (_GlassSpecularOffset + -1.0f) * view.xy + specular_uv;
    float2 detail_uv = (float2)_GlassSpecularDetailOffset * (float2)1.0f + specular_uv;

    float shine_a = _GlassSpecularTex.Sample(sampler_MainTex, specular_uv).x;
    float shine_b = _GlassSpecularTex.Sample(sampler_MainTex, detail_uv).y;

    float detail_length = (uv.w + (-_GlassSpecularDetailLength)) / max(_GlassSpecularDetailLengthRange, 0.0001f);
    detail_length = saturate(detail_length);
    float detail = (detail_length * shine_b) * _GlassSpecularDetailColor;

    float specular_length = (uv.w + (-_GlasspecularLength)) / max(_GlasspecularLengthRange, 0.0001f);
    specular_length = saturate(specular_length);
    float3 specular = ((specular_length * shine_a) * _GlassSpecularColor) + detail;

    float ndotv = pow(1.0 - dot(normal, view), _GlassThickness) * _GlassThicknessScale;
    float3 thickness = saturate(ndotv * _GlassThickness) * _GlassThicknessColor;

    specular = specular + thickness;

    float4 main = _MainTex.Sample(sampler_MainTex, uv.xy);

    color.xyz = (main * _MainColor) * _MainColorScaler + specular;
    color.w = main.w;
}

float pulsate(float rate, float max_value, float min_value, float time_offset)
{
    float pulse = sin(_Time.yy * rate + time_offset) * 0.5f + 0.5f;
    return pulse = smoothstep(min_value, max_value, pulse);
}

float4 emission_color(in float3 color, in float material_id)
{
    float3 e_color[5] =
    {
        float3((_EmissionColor1_MHY * max(_EmissionScaler1, 1.0f)).xyz),
        float3((_EmissionColor2_MHY * max(_EmissionScaler2, 1.0f)).xyz),
        float3((_EmissionColor3_MHY * max(_EmissionScaler3, 1.0f)).xyz),
        float3((_EmissionColor4_MHY * max(_EmissionScaler4, 1.0f)).xyz),
        float3((_EmissionColor5_MHY * max(_EmissionScaler5, 1.0f)).xyz),
    };

    float e_scaler[5] =
    {
        _EmissionScaler1,
        _EmissionScaler2,
        _EmissionScaler3,
        _EmissionScaler4,
        _EmissionScaler5,
    };

    float3 emission = e_color[material_id - 1].xyz * (_EmissionColor_MHY * max(_EmissionScaler, 1.0f)) * color; 
    return max(float4(emission.xyz, e_scaler[material_id - 1] * _EmissionScaler), 0.0f);
}

float4 emission_color_eyes(in float3 color, in float material_id)
{
    return max(float4((_EmissionColorEye * max(_EmissionScaler, 1.0f)) * max(_EyeGlowStrength, 1.0f) * color, _EmissionScaler * _EyeGlowStrength), 0.0f);
}

float3 outline_emission(in float3 color, in float material_id)
{
    float4 e_color[5] = 
    {
        _OutlineGlowColor,
        _OutlineGlowColor2,
        _OutlineGlowColor3,
        _OutlineGlowColor4,
        _OutlineGlowColor5,
    };

    float3 emission = e_color[material_id - 1].xyz * _OutlineGlowInt * color;
    return emission;
}

void nyx_state_marking(inout float3 color, in float2 uv0, in float2 uv1, in float2 uv2, in float2 uv3, in float3 normal, in float3 view, in float4 ws_pos)
{

    float2 uv[4] = 
    {
        uv0,
        uv1,
        uv2,
        uv3
    };

    float2 screen = ((ws_pos.xy / ws_pos.w) * _ScreenParams.xy) / _ScreenParams.x;

    float nyx_mask = packed_channel_picker(sampler_MainTex, _TempNyxStatePaintMaskTex, uv[_NyxBodyUVCoord], _TempNyxStatePaintMaskChannel); 
    
    float2 noise_uv = frac(_NyxStateOutlineColorNoiseAnim * _Time.yy);
    noise_uv = noise_uv * _NyxStateOutlineColorNoiseScale.xy + screen;
    float nyx_noise = _NyxStateOutlineNoise.Sample(sampler_MainTex, noise_uv).x;

    float2 ramp_uv;
    ramp_uv.x =  nyx_noise * _NyxStateOutlineColorNoiseTurbulence + noise_uv;
    ramp_uv.y = (_DayOrNight) ? 0.25f : 0.75f;
    float3 nyx_ramp = _NyxStateOutlineColorRamp.Sample(sampler_MainTex, ramp_uv);
    color = lerp(color, nyx_ramp * _NyxStateOutlineColorOnBodyMultiplier.xyz, nyx_mask * _NyxStateOutlineColorOnBodyOpacity);
}

void fresnel_hit(in float ndotv, inout float3 color)
{   
    ndotv = saturate(ndotv);
    ndotv = max(pow(1.0f - ndotv, _HitColorFresnelPower), 0.00001f);
    float3 rim_color = max(_ElementRimColor.xyz, _HitColor.xyz);
    color = (rim_color * ndotv) * (float3)_HitColorScaler + color;
}

float extract_fov()
{
    return 2.0f * atan((1.0f / unity_CameraProjection[1][1]))* (180.0f / 3.14159265f);
}

float fov_range(float old_min, float old_max, float value)
{
    float new_value = (value - old_min) / (old_max - old_min);
    return new_value; 
}

float outlinelerp(float start_scale, float end_scale, float start_z, float end_z, float z)
{
    float t = (z - start_z) / max(end_z - start_z, 0.001f);
    t = saturate(t);
    return lerp(start_scale, end_scale, t);
}

bool isVR()
{
    // USING_STEREO_MATRICES
    #if UNITY_SINGLE_PASS_STEREO
        return true;
    #else
        return false;
    #endif
}

// genshin fov range = 30 to 90
float3 camera_position()
{
    #ifdef USING_STEREO_MATRICES
        return lerp(unity_StereoWorldSpaceCameraPos[0], unity_StereoWorldSpaceCameraPos[1], 0.5);
    #endif
    return _WorldSpaceCameraPos;
}

float3 rimlighting(float4 sspos, float3 normal, float4 wspos, float3 light, float material_id, float3 color, float3 view)
{
    // // // instead of relying entirely on the camera depth texture, calculate a camera depth vector like this
    float4 camera_pos =  mul(unity_WorldToCamera, wspos);
    float camera_depth = saturate(1.0f - ((camera_pos.z / camera_pos.w) / 5.0f)); // tuned for vrchat

    float fov = extract_fov();
    fov = clamp(fov, 0, 150);
    float range = fov_range(0, 180, fov);
    float width_depth = camera_depth / range;
    float rim_width = lerp(_RimLightThickness * 0.5f, _RimLightThickness * 0.45f, range) * width_depth;

    if(isVR())
    {
        rim_width = rim_width * 0.66f;
    }
    // screen space uvs
    float2 screen_pos = sspos.xy / sspos.w;

    // camera space normals : 
    float3 vs_normal = mul((float3x3)unity_WorldToCamera, normal);
    vs_normal.z = 0.001f;
    vs_normal = normalize(vs_normal);

    // screen normals reconstructed using screen position
    float cs_ndotv = -dot(-view.xyz, vs_normal) + 1.0f;
    cs_ndotv = saturate(cs_ndotv);
    cs_ndotv = max(cs_ndotv, 0.0099f);
    float cs_ndotv_pow = pow(cs_ndotv, 5.0f);

    // sample original camera depth texture
    float4 depth_og = GetLinearZFromZDepth_WorksWithMirrors(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, screen_pos), screen_pos);

    float3 normal_cs = mul((float3x3)unity_WorldToCamera, normal);
    normal_cs.z = 0.001f;
    normal_cs.xy = normalize(normal_cs.xyz).xy;
    normal_cs.xyz = normal_cs.xyz * (rim_width);
    float2 pos_offset = normal_cs * 0.001f + screen_pos;
    // sample offset depth texture 
    float depth_off = GetLinearZFromZDepth_WorksWithMirrors(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, pos_offset), pos_offset);

    float depth_diff = (-depth_og) + depth_off;

    depth_diff = max(depth_diff, 0.001f);
    depth_diff = pow(depth_diff, 0.04f);
    depth_diff = (depth_diff - 0.8f) * 10.0f;
    depth_diff = saturate(depth_diff);
    
    float rim_depth = depth_diff * -2.0f + 3.0f;
    depth_diff = depth_diff * depth_diff;
    depth_diff = depth_diff * rim_depth;
    rim_depth = (-depth_og) + 2.0f;
    rim_depth = rim_depth * 0.3f + depth_og;
    rim_depth = min(rim_depth, 1.0f);
    depth_diff = depth_diff * rim_depth;

    depth_diff = lerp(depth_diff, 0.0f, saturate(step(depth_diff, _RimThreshold)));

    float4 rim_colors[5] = 
    {
        _RimColor1, _RimColor2, _RimColor3, _RimColor4, _RimColor5
    };

    // get rim light color 
    float3 rim_color = rim_colors[material_id - 1] * _RimColor;
    rim_color = rim_color * cs_ndotv;

    depth_diff = depth_diff * _RimLightIntensity;
    depth_diff *= camera_depth;

    float3 rim_light = depth_diff * cs_ndotv_pow;
    rim_light = saturate(rim_light);

    rim_light = saturate(rim_light * (color.xyz * (float3)5.0f));

    
    return rim_light;
}

void weapon_shit(inout float3 diffuse_color, float diffuse_alpha, float2 uv, float3 normal, float3 view, float3 wspos)
{
    float ndotv = pow(max(1.0f - dot(normal, view), 0.0001f), 2.0f);

    float2 uv_wp = uv * _WeaponPatternTex_ST.xy + _WeaponPatternTex_ST.zw;
    float2 weapon_uv = uv;
    if(_DissolveDirection_Toggle)
    {
        weapon_uv.y = weapon_uv.y - 1.0f;
    }
    weapon_uv.y = (_WeaponDissolveValue * 2.09f + weapon_uv.y) + -1.0f;
    
    float2 weapon_tex = _WeaponDissolveTex.Sample(sampler_WeaponDissolveTex, weapon_uv).xy;

    float2 pattern_uv = _Time.yy * (float2)_Pattern_Speed + uv_wp;

    float pattern_tex = _WeaponPatternTex.Sample(sampler_WeaponPatternTex, pattern_uv).x;

    ndotv = ndotv * 1.1f + pattern_tex;

    float weapon_dissolve = sin((_WeaponDissolveValue + -0.25f) * 6.28f) + 1.0f;
    ndotv = ndotv * weapon_dissolve;
    ndotv = ndotv * 0.5f + (weapon_tex.y * 3.0f);

    float3 weapon_view = -wspos.xyz + _WorldSpaceCameraPos.xyz;
    weapon_view = normalize(weapon_view);

    float skill_ndotv = dot(normal, weapon_view);

    skill_ndotv = pow(max(1.0f - saturate(skill_ndotv), 0.001f), _SkillEmisssionPower);
    
    float3 skill_fresnel = skill_ndotv * _SkillEmisssionColor;

    float2 scan_uv = uv * _ScanPatternTex_ST.xy + _ScanPatternTex_ST.zw;
    if(_ScanDirection_Switch)
    {
        scan_uv.y = -scan_uv.y + 1.0f;
    }
    scan_uv.y = scan_uv.y * 0.5f + (_Time.y * _ScanSpeed);
    float scan_tex = _ScanPatternTex.Sample(sampler_ScanPatternTex, scan_uv).x;

    float3 weapon_color = ndotv * _WeaponPatternColor.xyz + diffuse_color;
    weapon_color = skill_fresnel * (float3)_SkillEmissionScaler + weapon_color; 
    weapon_color = (scan_tex * _ScanColorScaler) * _ScanColor.xyz + weapon_color;

    ndotv = diffuse_alpha + ndotv;
    ndotv = skill_fresnel * _SkillEmissionScaler + ndotv;
    ndotv =  (scan_tex * _ScanColorScaler) * _ScanColor.x + ndotv;
    ndotv = saturate(ndotv);

    float ndotv_check = (0.0099f < ndotv);

    weapon_color = weapon_color + (-diffuse_color);
    weapon_color = ndotv * weapon_color + diffuse_color;
    weapon_color = ndotv_check ? weapon_color : diffuse_color;

    
    float4 diffuse_diss;
    diffuse_diss.x = max(weapon_color.z, weapon_color.y);
    diffuse_diss.w = max(weapon_color.x, diffuse_diss.x);

    float3 color = weapon_color.xyz;

    diffuse_color = color;

    clip(weapon_tex.x - 0.001f);
}

// star cloak shit
void star_cocks(inout float4 diffuse_color, float2 uv0, float2 uv1, float2 uv2, float4 sspos, float ndotv, float3 light, float3 parallax)
{
    // initialize different uvs
    float2 uv = uv0;
    if(_StarUVSource == 1)
    {
        uv = uv1;
    }
    else if(_StarUVSource == 2)
    {
        uv = uv2;
    }

    float fov = extract_fov();
    fov = clamp(fov, 0, 150);
    float range = fov_range(0, 180, fov);
    
    if(_StarCockType == 0) // paimon/dainsleif 
    {
        parallax = normalize(parallax);

        float2 star_parallax = parallax * (_StarHeight + -1.0f);


        float star_speed = _Time.y * _Star01Speed;
        float2 star_1_uv = uv * _StarTex_ST.xy + _StarTex_ST.zw;
        star_1_uv.y = star_speed + star_1_uv.y;
        star_1_uv.xy = star_parallax * (float2)-0.1 + star_1_uv;

        float2 star_2_uv = uv * _Star02Tex_ST.xy + _Star02Tex_ST.zw;
        star_2_uv.y = star_speed * 0.5f + star_2_uv.y;
        star_parallax = parallax * (_Star02Height + -1.0f);
        star_2_uv.xy = star_parallax * (float2)-0.1f + star_2_uv.xy;

        float2 color_uv = uv.xy * _ColorPaletteTex_ST.xy + _ColorPaletteTex_ST.zw;
        color_uv.x = _Time.y * _ColorPalletteSpeed + color_uv.x;
        float3 color_palette = _ColorPaletteTex.Sample(sampler_PackedShadowRampTex, color_uv);

        float2 noise_1_uv = uv.xy * _NoiseTex01_ST.xy + _NoiseTex01_ST.zw;
        noise_1_uv = _Time.yy * (float2)_Noise01Speed + noise_1_uv;
        float2 noise_2_uv = uv.xy * _NoiseTex02_ST.xy + _NoiseTex02_ST.zw;
        noise_2_uv = _Time.yy * (float2)_Noise02Speed + noise_2_uv;

        float noise_1 = _NoiseTex01.Sample(sampler_LightMapTex, noise_1_uv).x;
        float noise_2 = _NoiseTex02.Sample(sampler_LightMapTex, noise_2_uv).x;

        float noise = noise_1 * noise_2;
        float star_1 = _StarTex.Sample(sampler_LightMapTex, star_1_uv).x;
        float star_2 = _Star02Tex.Sample(sampler_LightMapTex, star_2_uv).y;
        
        float3 stars = star_2 + star_1;
        stars = diffuse_color.w * stars;
        stars = color_palette * stars;

        stars = stars * (float3)_StarBrightness;

        float2 const_uv = uv.xy * _ConstellationTex_ST.xy + _ConstellationTex_ST.zw;
        star_parallax = parallax * (_ConstellationHeight + -1.0f);
        const_uv = star_parallax * (float2)-0.1f + const_uv;
        float3 constellation = _ConstellationTex.Sample(sampler_LightMapTex, const_uv).xyz;
        constellation = constellation * (float3)_ConstellationBrightness;

        float2 cloud_uv = uv.xy * _CloudTex_ST.xy + _CloudTex_ST.zw;
        star_parallax = parallax * (_CloudHeight + -1.0f);

        cloud_uv = noise * (float2)_Noise03Brightness + cloud_uv;
        cloud_uv = star_parallax * (float2)-0.1f + cloud_uv;
        float cloud = _CloudTex.Sample(sampler_LightMapTex, cloud_uv).x;

        cloud = cloud * diffuse_color.w;
        cloud = cloud * _CloudBrightness;


        float3 everything = stars * noise + constellation;

        float3 everything_2 = diffuse_color.xyz + everything;
        
        everything_2  = cloud * color_palette + everything_2;
        
        diffuse_color.xyz = everything_2;

    }
    else if(_StarCockType == 1) // skirk
    {
        float4 weird_view = float4(_WorldSpaceCameraPos.xyz, 0.0f) - unity_ObjectToWorld[3] * (_ScreenParams.x / _ScreenParams.y);
        weird_view.x = dot(weird_view, weird_view);
        weird_view.x = sqrt(weird_view.x);

        weird_view.x = lerp(1.0f, weird_view.x, range);

        float3 star_flicker;
        star_flicker.x = _Time.y * _StarFlickerParameters.x;
        star_flicker.y = ndotv * _StarFlickerParameters.y;
        star_flicker.y = star_flicker.y * weird_view.x + star_flicker.x;
        star_flicker.y = frac(star_flicker.y);
        star_flicker.y = (star_flicker.y >= _StarFlickerParameters.z) ? 1.0f : 0.0f;

        float2 star_uv;
        star_uv = uv * _StarTex_ST.xy + _StarTex_ST.zw;

        float2 screen_uv = sspos.xy / sspos.w;
        screen_uv = screen_uv * 2.0f - 1.0f;
        screen_uv.x = screen_uv.x * (_ScreenParams.x / _ScreenParams.y);

        screen_uv = screen_uv * weird_view.x;
        screen_uv = screen_uv * (float2)_StarTiling + (-star_uv);
        star_uv = (float2)_UseScreenUV * screen_uv + star_uv;
        star_uv = star_uv + frac(_Time.yy * _StarTexSpeed.xy);

        float3 star_tex = _StarTex.Sample(sampler_LightMapTex, star_uv);
        float star_grey =  dot(star_tex, float3(0.03968f, 0.4580f, 0.006f));
        float star_flick = star_grey >= _StarFlickRange;

        float2 star_mask = _StarMask.Sample(sampler_LightMapTex, uv).xy;
        float mask_red = -star_mask.x + 1.0f;

        float3 flicker_color = lerp(0.0f, star_flicker.y * _StarFlickColor.xyz, star_flick);

        float3 star_color = star_tex.xyz * _StarColor.xyz + flicker_color;

        float2 block_stuff = float2((-_BlockHighlightViewWeight.x + _CloakViewWeight.x), (-_BlockHighlightSoftness.x + _BlockHighlightRange.x));

        float block_masked = star_mask.y * block_stuff.x + _BlockHighlightViewWeight;

        float4 blockhighmask = _BlockHighlightMask.Sample(sampler_LightMapTex, uv.xy);



        float4 block_light = light.zzzz * block_masked.xxxx + float4(0.0f, 0.2f, 0.5f, 0.8f);
        block_light = frac(block_light);
        block_light = block_light * 2.0f - 1.0f;
        block_light = -abs(block_light) + 1.0f;
        block_light = block_stuff.y + block_light;
        block_light = block_light / (block_stuff.y + _BlockHighlightRange);
        block_light = saturate(block_light);
        
        float2 blocks = blockhighmask.xy * block_light.xy;

        float2 brightuv = uv.xy + frac(_Time.yy * _BrightLineMaskSpeed.xy);
        float brightmask = _BrightLineMask.Sample(sampler_LightMapTex, brightuv).x;
        brightmask = pow(brightmask, _BrightLineMaskContrast) * _BrightLineColor;

        float3 block_thing = blocks.y + blocks.x;
        block_thing = blockhighmask.z * block_light.z + block_thing;
        block_thing = blockhighmask.w * block_light.w + block_thing;
        block_thing = saturate(block_thing) * _BlockHighlightColor;

        float3 everything = star_color * mask_red + block_thing;

        everything.xyz = diffuse_color.w * brightmask + everything.xyz; 
        everything.xyz = _Color.xyz * diffuse_color.xyz + everything.xyz; 
        diffuse_color.xyz = everything;

    }
    else if(_StarCockType == 2)
    {
        float2 noise_uv = uv * _NoiseMap_ST.xy + _NoiseMap_ST.zw;
        noise_uv = _Time.yy * _NoiseSpeed.xy + noise_uv;
        float noise = _NoiseMap.Sample(sampler_LightMapTex, noise_uv).x;

        float2 flow_1_uv = uv * _FlowMap_ST.xy + _FlowMap_ST.zw;
        flow_1_uv = noise.xx * (float2)_NoiseScale + flow_1_uv;
        flow_1_uv = _Time.yy * _FlowMaskSpeed.xy + flow_1_uv;

        float2 flow_2_uv = uv * _FlowMap02_ST.xy + _FlowMap02_ST.zw;
        flow_2_uv = _Time.yy * _FlowMask02Speed.xy + flow_2_uv;

        float2 mask_uv = uv * _FlowMask_ST.xy + _FlowMask_ST.zw;
        
        float grad_bottom_area = max(uv.y, 0.0001f);
        grad_bottom_area = pow(grad_bottom_area, _BottomPower) * _BottomScale;
        float3 bottom_grad = lerp(_BottomColor01, _BottomColor02, grad_bottom_area);

        float3 flow_color = _FlowColor.xyz * (float3)_FlowScale;
        float flow_map_1 = _FlowMap.Sample(sampler_LightMapTex, flow_1_uv).x;
        float flow_map_2 = _FlowMap02.Sample(sampler_LightMapTex, flow_2_uv).x;
        
        float3 flow = flow_map_1 + flow_map_2;
        flow = flow * flow_color;

        float grad_mask_area = max(uv.y, 0.0001f);
        grad_mask_area = pow(grad_mask_area, _FlowMaskPower) * _FlowMaskScale;
        grad_mask_area = saturate(grad_mask_area);

        flow = flow * grad_mask_area;

        float flow_mask = _FlowMask.Sample(sampler_LightMapTex, mask_uv).x;
        bottom_grad = flow * flow_mask + bottom_grad;

        diffuse_color.xyz = lerp(diffuse_color.xyz, bottom_grad, diffuse_color.w);
    }

}

void arm_effect(inout float4 diffuse, float2 uv0, float2 uv1, float2 uv2, float3 view, float3 normal, float ndotl)
{
    float2 uv = uv2;

    float2 mask_uv = uv * _Mask_ST.xy + _Mask_ST.zw;
    mask_uv.xy = _Time.y * float2(_Mask_Speed_U, 0.0f) + mask_uv;
    float3 masktex = _Mask.Sample(sampler_LightMapTex, mask_uv.xy).xyz;

    float2 effuv1 = uv * _Tex01_UV.xy + _Tex01_UV.zw;
    effuv1.xy = _Time.yy * float2(_Tex01_Speed_U, _Tex01_Speed_V) + effuv1.xy;
    float3 eff1 = _MainTex.Sample(sampler_MainTex, effuv1.xy).xyw;
    float2 effuv2 = uv * _Tex02_UV.xy + _Tex02_UV.zw;
    effuv2.xy = _Time.yy * float2(_Tex02_Speed_U, _Tex02_Speed_V) + effuv2.xy;
    float3 eff2 = _MainTex.Sample(sampler_MainTex, effuv2.xy).xyw;
    float3 effmax = max(eff1.y, eff2.y);
    float2 effuv3 = uv * _Tex03_UV.xy + _Tex03_UV.zw;
    effuv3.xy = _Time.yy * float2(_Tex03_Speed_U, _Tex03_Speed_V) + effuv3.xy;
    float3 eff3 = _MainTex.Sample(sampler_MainTex, effuv3.xy).xyw;
    effmax = max(effmax, eff3.y);
    float2 effmul = masktex.xz * eff3.zx;
    effmax = max(masktex.y, effmax);
    effmul.xy = eff1.zx * eff2.zx + effmul.xy;
    effmax = (-effmul.y) + effmax;

    float downrange = uv.x>=_DownMaskRange;

    downrange = (downrange) ? 1.0 : 0.0;
    effmul.x = downrange * effmul.x;
    float2 effuv4 = uv * _Tex04_UV.xy + _Tex04_UV.zw;
    effuv4.xy = _Time.yy * float2(_Tex04_Speed_U, _Tex04_Speed_V) + effuv4.xy;
    float eff4 = _MainTex.Sample(sampler_MainTex, effuv4.xy).z;
    float2 effuv5 = uv * _Tex05_UV.xy + _Tex05_UV.zw;
    effuv5.xy = _Time.yy * float2(_Tex05_Speed_U, _Tex05_Speed_V) + effuv5.xy;
    float eff5 = _MainTex.Sample(sampler_MainTex, effuv5.xy).z;
    float eff9 = eff5 * eff4;

    float toprange = eff9.x>=_TopMaskRange;

    float linerange = eff9.x>=_TopLineRange;

    linerange = (linerange) ? -1.0 : -0.0;
    toprange = (toprange) ? 1.0 : 0.0;
    effmul.x = toprange * effmul.x;
    linerange = linerange + toprange;
    linerange = effmul.x * linerange;
    effmax = max(linerange, effmax);

    effmax = saturate(effmax);

    float3 efflight = lerp(_LineColor, _LightColor, effmax);
    _LightColor = lerp(_ShadowColor, _LightColor, (1.0f - (ndotl.x * 0.5 + 0.5)) <= _ShadowWidth);
    effmax = lerp(_LightColor, _LineColor, effmax);
    efflight.xyz = (-effmax) + efflight.xyz;
    float effshadow = ndotl.x * 0.5 + 0.5;
    effshadow = 1.0;

    float shadowbool = _ShadowWidth>=effshadow;

    effshadow = (shadowbool) ? 1.0 : 0.0;
    effmax = effshadow.xxx * efflight.xyz + effmax;
    float efffrsn = dot(normal.xyz, view.xyz);
    efflight.x = (-efffrsn.x) + 1.0;
    efflight.x = max(efflight.x, 0.0001f);
    
    efflight.x = pow(efflight.x, _FresnelPower);
    efflight.x = efflight.x + _FresnelScale;
    efflight.x = saturate(efflight.x);
    float4 outeff;
    outeff.xyz = _FresnelColor.xyz * efflight.xxx + effmax; 
    // outeff.xyz = outeff;
    effmax.x = max(uv.x, 0.0001f);
    effmax.x = pow(effmax.x, _GradientPower);
    effmax.x = effmax.x * _GradientScale;
    outeff.w = saturate(effmax.x * effmul.x); 
    diffuse.xyz = outeff.xyz;

    float grad_alpha = max(uv.y, 9.99999975e-05);
    grad_alpha.x = log2(grad_alpha.x);
    grad_alpha.x = grad_alpha.x * _GradientPower;
    grad_alpha.x = exp2(grad_alpha.x);
    grad_alpha.x = grad_alpha.x * _GradientScale;
    diffuse.w = saturate(grad_alpha.x * effmul.x);

    // above is old code
    // below is new code
    
    // float3 mask_uv;
    // mask_uv.xy = uv.xy * _Mask_ST.xy + _Mask_ST.zw;
    // mask_uv.xy = mask_uv.xy + float2(0.0f, _Time.y * _Mask_Speed_U);
    // float3 mask_tex = _Mask.Sample(sampler_LightMapTex, mask_uv.xy);
    // float4 tex_uv;
    // tex_uv.xy = uv.xy * _Tex01_UV.xy + _Tex01_UV.zw;
    // tex_uv.xy = _Time.yy * float2(_Tex01_Speed_U, _Tex01_Speed_V) + tex_uv.xy;
    // float3 tex01 = _MainTex.Sample(sampler_MainTex, tex_uv).xyw;
    // float2 tex2_uv = uv.xy * _Tex02_UV.xy + _Tex02_UV.zw;
    // tex2_uv.xy = _Time.yy * float2(_Tex02_Speed_U, _Tex02_Speed_V) + tex2_uv.xy;
    // float3 tex02 = _MainTex.Sample(sampler_MainTex, tex2_uv.xy).xyw;
    // float4 maxy; 
    // maxy.x = max(tex01.y, tex02.y);
    // float2 tex3_uv = uv.xy * _Tex03_UV.xy + _Tex03_UV.zw;
    // tex3_uv = _Time.yy * float2(_Tex03_Speed_U, _Tex03_Speed_V) + tex3_uv;
    // float3 tex03 = _MainTex.Sample(sampler_MainTex, tex3_uv).xyw;
    // maxy.x = max(maxy.x, tex03.y);
    // float2 tex_masked = mask_tex.xz * tex03.zx;
    // maxy.x = max(mask_tex.y, maxy.x);
    // tex_masked.xy = tex01.zx * tex02.zx + tex_masked.xy;
    // maxy.x = (-tex_masked.y) + maxy.x;

    // bool bool_a = uv0.x>=_DownMaskRange;

    // float4 bool_a_check = (bool_a) ? 1.0 : 0.0;
    // tex_masked.x = bool_a_check * tex_masked.x;
    // mask_uv.xy = uv.xy * _Tex04_UV.xy + _Tex04_UV.zw;
    // mask_uv.xy = _Time.yy * float2(_Tex04_Speed_U, _Tex04_Speed_V) + mask_uv.xy;
    // mask_tex.x = _MainTex.Sample(sampler_MainTex, mask_uv.xy).z;
    // float2 tex5_uv = uv.xy * _Tex05_UV.xy + _Tex05_UV.zw;
    // tex5_uv.xy = _Time.yy * float2(_Tex05_Speed_U, _Tex05_Speed_V) + tex5_uv.xy;
    // float tex05 = _MainTex.Sample(sampler_MainTex, tex5_uv.xy).z;
    // mask_uv.x = tex05 * mask_tex.x;

    // bool bool_b = mask_uv.x>=_TopMaskRange;
    // bool_a = mask_uv.x>=_TopLineRange;

    // bool_a_check = (bool_a) ? -1.0 : -0.0;
    // float4 bool_b_check = (bool_b) ? 1.0 : 0.0;
    // tex_masked.x = bool_b_check * tex_masked.x;
    // bool_a_check = bool_a_check + bool_b_check;
    // bool_a_check = tex_masked.x * bool_a_check;
    // maxy.x = max(bool_a_check, maxy.x);

    // maxy.x = clamp(maxy.x, 0.0, 1.0);

    // float3 line_color = _LineColor.xyz + (-_LightColor.xyz);
    // line_color.xyz = maxy.xxx * line_color.xyz + _LightColor.xyz;
    // float3 line_comb = (-_ShadowColor.xyz) + _LineColor.xyz;
    // float4 line_shadow;
    // line_shadow.xzw = maxy.xxx * line_comb.xyz + _ShadowColor.xyz;
    // line_color.xyz = (-line_shadow.xzw) + line_color.xyz;
    // mask_uv.xyz = (-view.xyz) * _WorldSpaceLightPos0.www + _WorldSpaceLightPos0.xyz;
    // mask_uv.x = dot(mask_uv.xyz, normal.xyz);
    // float shadow_area = mask_uv.x * 0.5 + 0.5;
    // shadow_area = (-shadow_area) + 1.0;

    // bool_a = _ShadowWidth>=shadow_area;

    // shadow_area = (bool_a) ? 1.0 : 0.0;
    // line_shadow.xzw = (float3)shadow_area * line_color.xyz + line_shadow.xzw;
    // mask_uv.xyz = normalize(normal);
    // tex_uv.xyz = normalize(view);
    // mask_uv.x = dot(tex_uv.xyz, mask_uv.xyz);
    // float ndotv_b = (-mask_uv.x) + 1.0;
    // ndotv_b.x = max(ndotv_b.x, 9.99999975e-05);
    // ndotv_b.x = log2(ndotv_b.x);
    // ndotv_b.x = ndotv_b.x * _FresnelPower;
    // ndotv_b.x = exp2(ndotv_b.x);
    // ndotv_b.x = ndotv_b.x + _FresnelScale;

    // ndotv_b.x = clamp(ndotv_b.x, 0.0, 1.0);
    // diffuse.xyz = _FresnelColor.xyz * ndotv_b.xxx + line_shadow.xzw;
    // float grad_alpha = max(uv.y, 9.99999975e-05);
    // grad_alpha.x = log2(grad_alpha.x);
    // grad_alpha.x = grad_alpha.x * _GradientPower;
    // grad_alpha.x = exp2(grad_alpha.x);
    // grad_alpha.x = grad_alpha.x * _GradientScale;
    // diffuse.w = saturate(grad_alpha.x * tex_masked.x);

    clip(saturate(1.0f - (uv.y > 0.995f)) - 0.1f );
}

