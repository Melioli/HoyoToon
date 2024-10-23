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

float3 hue_shift(float3 in_color, float material_id, float shift1, float shift2, float shift3, float shift4, float shift5, float shift6, float shift7, float shift8,float shiftglobal, float autobool, float autospeed, float mask)
{  
    #if defined(can_shift) 
        float auto_shift = (_Time.y * autospeed) * autobool; 
        
        float shift[8] = 
        {
            shift1,
            shift2,
            shift3,
            shift4,
            shift5,
            shift6,
            shift7,
            shift8
        };
        
        float shift_all = 0.0f;
        if(shift[material_id] > 0)
        {
            shift_all = shift[material_id] + auto_shift;
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
    #else
        return in_color;
    #endif
}

int material_region(float lightmap_alpha)
{
    int material = 0;
    if(lightmap_alpha > 0.5 && lightmap_alpha < 1.5 )
    {
        material = 1;
    } 
    else if(lightmap_alpha > 1.5f && lightmap_alpha < 2.5f)
    {
        material = 2;
    } 
    else if(lightmap_alpha > 2.5f && lightmap_alpha < 3.5f)
    {
        material = 3;
    } 
    else
    {
        material = (lightmap_alpha > 6.5f && lightmap_alpha < 7.5f) ? 7 : 0;
        material = (lightmap_alpha > 5.5f && lightmap_alpha < 6.5f) ? 6 : material;
        material = (lightmap_alpha > 4.5f && lightmap_alpha < 5.5f) ? 5 : material;
        material = (lightmap_alpha > 3.5f && lightmap_alpha < 4.5f) ? 4 : material;
    }

    if(_HairMaterial) material = 0;

    return material;
}

// float shadow_rate(float ndotl, float lightmap_ao, float vertex_ao, float shadow_ramp, float shadow_map)
float shadow_rate(float ndotl, float lightmap_ao, float vertex_ao, float shadow_ramp)
{
    float shadow_ndotl  = ndotl * 0.5f + 0.5f;
    float shadow_thresh = (lightmap_ao + lightmap_ao) * vertex_ao;
    float shadow_area   = min(1.0f, dot(shadow_ndotl.xx, shadow_thresh.xx));
    #ifndef _IS_PASS_LIGHT
        shadow_area = max(0.001f, shadow_area) * 0.85f + 0.15f;
        shadow_area = (shadow_area > shadow_ramp) ? 0.99f : shadow_area;
    #else
        shadow_area = smoothstep(0.5f, 1.0f, shadow_area);
    #endif
    return shadow_area;
}

float shadow_rate_face(float2 uv, float3 light)
{
    #if defined(faceishadow)
        float3 head_forward = normalize(UnityObjectToWorldDir(_headForwardVector.xyz));
        float3 head_right   = normalize(UnityObjectToWorldDir(_headRightVector.xyz));
        float rdotl = dot((head_right.xz),  (light.xz));
        float fdotl = dot((head_forward.xz), (light.xz));

        float2 faceuv = uv;
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
        
        // use only the alpha channel of the texture 
        float facemap = _FaceMap.Sample(sampler_linear_repeat, faceuv).w;
        // interpolate between sharp and smooth face shading
        shadow_step = smoothstep(shadow_step - (0.0001f), shadow_step + (0.0001f), facemap);

    #else
        float shadow_step = 1.00f;
    #endif

    return shadow_step;
}

float3 specular_base(float shadow_area, float ndoth, float lightmap_spec, float3 specular_color, float3 specular_values, float3 specular_color_global, float specular_intensity_global)
{
    #if defined(use_specular)
        float3 specular = ndoth;
        specular = pow(max(specular, 0.01f), specular_values.x);
        specular_values.y = max(specular_values.y, 0.001f);

        float specular_thresh = 1.0f - lightmap_spec;
        float rough_thresh = specular_thresh - specular_values.y;
        specular_thresh = (specular_values.y + specular_thresh) - rough_thresh;
        specular = shadow_area * specular - rough_thresh; 
        specular_thresh = saturate((1.0f / specular_thresh) * specular);
        specular = (specular_thresh * - 2.0f + 3.0f) * pow(specular_thresh, 2.0f);
        specular = (specular_color * specular_color_global) * specular * ((specular_values.z * specular_intensity_global) * 0.35f);
        return specular;
    #else
        return (float3)0.00f;
    #endif
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

// https://github.com/cnlohr/shadertrixx/blob/main/README.md#detecting-if-you-are-on-desktop-vr-camera-etc
bool isVR(){
    // USING_STEREO_MATRICES
    #if UNITY_SINGLE_PASS_STEREO
        return true;
    #else
        return false;
    #endif
}

float remap(float value, float old_min, float old_max, float new_min, float new_max)
{
    return new_min + (value - old_min) * (new_max - new_min) / (old_max - old_min);
}

void dissolve_vertex(in float4 pos_ws, float4 pos,  in float2 uv_0, in float2 uv_2, out float4 dis_pos, out float4 dis_uv)
{
    #if defined(can_dissolve)
        float3 dissolve_position;
        dissolve_position = pos_ws.xyz - _DissolvePosMaskPosM.xyz;
        dissolve_position = dissolve_position.xyz - pos;
        dissolve_position = (float3)_DissolvePosMaskWorldONM * dissolve_position.xyz + pos.xyz;
        float3 dis_pos_off = dissolve_position + float3(1.0f, 1.0f, 0.0f);
        dissolve_position = (float3)_DissolvePosMaskGlobalOnM * dis_pos_off + dissolve_position;

        dissolve_position = dissolve_position + -(_DissolvePosMaskRootOffsetM.xyz);

        float3 dis_light_pos =  float3(1.0f, 1.0f, 0.0f) + (-unity_ObjectToWorld[3].xyz);
        float3 dis_light_pos_2 = (float3)_DissolvePosMaskWorldONM * (-unity_ObjectToWorld[3].xyz) + _DissolvePosMaskPosM.xyz;
        
        dis_light_pos = dis_light_pos + (-dis_light_pos_2);
        dis_light_pos = (float3)_DissolvePosMaskGlobalOnM * dis_light_pos + dis_light_pos_2;

        dis_light_pos = normalize(dis_light_pos.xyz);
        float dis_y = dot(dis_light_pos.xyz, dissolve_position);

        float dis_yy = abs(dis_y) + max(_DissolvePosMaskPosM.w, 0.01f);
        dis_y = dis_yy / (dis_y + dis_y);
        dis_yy = dis_y * -2.0f + 1.0f;
        dis_y = _DissolvePosMaskFilpOnM * dis_yy + dis_y;
        dis_y = dis_y + (-_DissolvePosMaskOnM);
        dis_y = dis_y + 1.0;
        dis_y = saturate(dis_y);
    
        float dis_check = dot(abs(dis_light_pos), (float3)1.0f) >= 0.001f;
        dis_pos.y = dis_check ? dis_y : 1.0f;
        dis_pos.zw = (float2)0.0f;
        
        float2 dissolve_uv = -(uv_0.xy) + uv_2;
        dissolve_uv = (float2)_DissolveUVM * dissolve_uv + uv_0.xy;

        dis_uv.xy = dissolve_uv * _DissolveSTM.xy + _DissolveSTM.zw;
        dis_uv.zw = dissolve_uv * _DistortionSTM.xy + _DistortionSTM.zw;
        dis_pos.x = dissolve_uv.x;
    #endif
}

void dissolve_clip(in float4 ws_pos, in float4 dis_pos, in float4 dis_uv, in float2 uv)
{
    #if defined(can_dissolve)
        float dissolveMapAdd = lerp(_DissolveMapAddM, 0.0f, _DissolveRateM);
        float dissolve_rate = _DissolveRateM;

        float2 dis_tex;
        float4 dis_pos_;
        float3 dissolve_map;
        float2 distort;
        float dissolve_map_2;
        float4 dissolve_mask;
        float dissolve_comp;
        float dis_map_add;
        float dis_clip;
        dis_tex.xy = dis_uv.zw + float2(3.00000011e-06, 3.00000011e-06);
        dis_pos_.x = (-dis_pos.y) + _DissoveDirecMaskM;
        dis_pos_.x = min(abs(dis_pos_.x), 1.0f);
        dis_tex.xy = _DissolveUVSpeedM.zw * _Time.yy + dis_tex.xy;
        dissolve_map.xy = _DissolveMap.Sample(sampler_linear_repeat, dis_tex.xy).xy;
        dis_tex.xy = dissolve_map.xy + (float2)-0.5f;
        distort.xy = -(dis_tex.xy) * (float2)_DissolveDistortionIntensityM + dis_uv.xy;
        dis_tex.xy = _DissolveUVSpeedM.xy * _Time.yy + distort.xy;
        dissolve_map_2 = _DissolveMap.Sample(sampler_linear_repeat, dis_tex.xy).x;
        dissolve_mask = _DissolveMask.Sample(sampler_linear_repeat, uv.xy);
        if(_InvertDissovle) dissolve_mask = 1.0f - dissolve_mask;

        dissolve_comp = dot(dissolve_mask, _DissolveComponentM);     
        dis_map_add = dissolve_map_2 + dissolveMapAdd; 
        dis_clip = dis_pos_.x * dis_map_add;
        dis_clip.x = dissolve_comp * dis_clip.x;
        dis_clip.x = dis_clip.x * dis_pos.y;
        dis_clip.x = dis_clip.x * 1.009f + -0.009f;
        if(_DissolvePosMaskFilpOnM)
        {
            dissolve_rate = remap(dissolve_rate, 0.0f, 1.0f, 1.0f, 0.0f);   
            dis_clip.x = 1.0f - dis_clip.x;
        } 
        clip(dis_clip.x - dissolve_rate);   
    #endif
}

float4 dissolve_color(float4 ws_pos, float4 dis_pos, float4 dis_uv, float2 uv, float4 color)
{
    #if defined(can_dissolve)
        float dissolveMapAdd = lerp(_DissolveMapAddM, 0.0f, _DissolveRateM);
        float dissolve_rate = _DissolveRateM;
        float disolve_direct_mask = -dis_pos.y + _DissoveDirecMaskM;
        float2 dis_tex;
        float4 dis_pos_;
        float3 dissolve_map;
        float2 distort;
        float dissolve_map_2;
        float4 dissolve_mask;
        float dissolve_comp;
        float dis_map_add;
        float dis_clip;
        dis_pos_.x = (-dis_pos.y) + _DissoveDirecMaskM;
        dis_pos_.x = min(abs(dis_pos_.x), 1.0f);
        dis_tex.xy = _DissolveUVSpeedM.zw * _Time.yy + dis_uv.zw;
        dissolve_map.xy = _DissolveMap.Sample(sampler_linear_repeat, dis_tex.xy).xy;
        dis_tex.xy = dissolve_map.xy + (float2)-0.5f;
        distort = -(dis_tex.xy) * (float2)_DissolveDistortionIntensityM + dis_uv.xy;
        dis_tex.xy = _DissolveUVSpeedM.xy * _Time.yy + distort.xy;
        dissolve_map_2 = _DissolveMap.Sample(sampler_linear_repeat, dis_tex.xy).z;
        dissolve_mask = _DissolveMask.Sample(sampler_linear_repeat, uv.xy);   
        if(_InvertDissovle) dissolve_mask = 1.0f - dissolve_mask;
        dissolve_comp = dot(dissolve_mask, _DissolveComponentM);     
        dis_map_add = dissolve_map_2 + dissolveMapAdd; 
        dis_clip = dis_pos_.x * dis_map_add;
        dis_clip.x = dissolve_comp * dis_clip.x;
        dis_clip.x = dis_clip.x * dis_pos.y;
        dis_clip.x = dis_clip.x * 1.009f + -0.009f;
        
        if(_DissolvePosMaskFilpOnM)
        {
            dissolve_rate = remap(1.0 - dissolve_rate, -1.0f, 0.0f, 1.0f, 0.0f);;   
            dis_clip.x = 1.0f - dis_clip.x;
        }  
        
        if(_DissolveClip) clip(dis_clip.x - dissolve_rate);   
        float dis_outline_1 = dissolve_rate + _DissolveOutlineSize1M;
        float dis_outline_2 = dis_outline_1 + (-_DissolveOutlineSize2M); 
        float2 dis_outline_size = dis_clip.xx - float2(dis_outline_1, dis_outline_2); 

        dis_outline_size = saturate(((float2)1.0f / (_DissolveOutlineSmoothStepM.xy + (float2)0.001f)) * dis_outline_size);  
        float3 diss_out_off = color.xyz * dissolve_map_2 + (float3)_DissolveOutlineOffsetM;    
        float3 dis_out_col_1 = diss_out_off * _DissolveOutlineColor1M.xyz;
        float3 dis_out_col_2 = diss_out_off * _DissolveOutlineColor2M.xyz - dis_out_col_1.xyz;   
        float3 dis_out_col = dis_outline_size.yyy * dis_out_col_2 + dis_out_col_1;  
        float dis_alpha = dis_outline_size.x + 1.0f;
        dis_alpha = dis_alpha - _DissolveOutlineColor1M.w;
        dis_alpha = saturate(dis_alpha);    
        float4 dis_color;
        dis_color.xyz = color.xyz - dis_out_col;
        dis_color.xyz = dis_alpha * color.xyz + dis_out_col;    
        float3 u_xlat2 = dis_color.xyz * float3(278.508514f, 278.508514f, 278.508514f) + float3(10.7771997f, 10.7771997f, 10.7771997f);
        u_xlat2.xyz = u_xlat2.xyz * dis_color.xyz;
        float3 u_xlat4 = dis_color.xyz * float3(298.604492f, 298.604492f, 298.604492f) + float3(88.7121964f, 88.7121964f, 88.7121964f);
        u_xlat4.xyz = dis_color.xyz * u_xlat4.xyz + float3(80.6889038f, 80.6889038f, 80.6889038f);
        u_xlat2.xyz = u_xlat2.xyz / u_xlat4.xyz;
        u_xlat4.xyz = (-u_xlat2.xyz) + dis_color.xyz;
        dis_color.xyz = dis_alpha.xxx * u_xlat4.xyz + u_xlat2.xyz;  
        dis_color.w = color.w;
        if(!_DissolveClip) 
        {
            if(_DissolvePosMaskFilpOnM)
            {
                dissolve_rate = remap(dissolve_rate, 1.0, 0.0f, 0.0f, 1.0f);;   
            }  
            
            if((dissolve_rate > 0.85))
            {
                dis_color.w = color.w;
            }
            else if(dissolve_rate < 0.85)
            {
                dis_color.w = color.w * smoothstep(0.0,0.1,(dis_clip.x ) -  dissolve_rate);
                dissolve_rate = smoothstep(-1.0f, 14.0f, dissolve_rate);
                dis_color.w = lerp(dis_color.w, color.w, dissolve_rate);
                dis_color.w = saturate(dis_color.w);
            }

        }

        return dis_color;
    #else
        return color;
    #endif
}

void simple_dissolve(in float4 primary_diffuse, in float2 uv0, in float2 uv1, in float2 uv2, in float4 pos, inout float3 out_color, inout float out_alpha)
{
    #if defined(can_dissolve)
    float2 dissolve_uv[3] =
    {
        uv0,
        uv1,
        uv2
    };

    float gradient = _DissolveGradientMask.Sample(sampler_linear_repeat, dissolve_uv[_DissolveUVChannel]).x + _DissolveGradientOffset;
    if(_DisableDissolveGradient) gradient = 1.0f; // fail safe incase of missing texture or unity fuckery

    float2 distortion_uv = _Time.yy * float2(_DissolveAnimDirection.xy * _DissolveAnimSpeed) + (_DissolveAnimSO.xy * dissolve_uv[_DissolveUVChannel] + _DissolveAnimSO.zw);
    float distortion = _DissolveAnimTex.Sample(sampler_linear_repeat, distortion_uv).x;

    gradient = gradient + _DissolveGradientOffset;
    gradient = gradient * distortion;
    float dis_direction = dot(_DissolveFadeDirection.xyz, pos.xyz);
    dis_direction = smoothstep(_DissovlePosFadeSmoothstep.x * _DissolveSimpleRate, _DissovlePosFadeSmoothstep.y * _DissolveSimpleRate, dis_direction - _DissolveSimpleRate);
    if(_DissolveUsePosition) gradient = gradient * dis_direction;

    gradient = smoothstep(_DissovleFadeSmoothstep.x * _DissolveSimpleRate, _DissovleFadeSmoothstep.y * _DissolveSimpleRate, gradient);
    gradient = saturate(gradient);

    if(_InvertGradient) gradient = 1.0f - gradient;
    
    out_alpha = out_alpha * gradient.x;
    if(_SimpleDissolveClip)(out_alpha - _DissolveClipRate);
    #endif
}

float3 DecodeLightProbe( float3 N )
{
    return ShadeSH9(float4(N,1));
}