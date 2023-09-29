// vertex
vsOut vert(vsIn v, uint id : SV_VertexID)
{
    vsOut o = (vsOut)0.0f;
    o.pos = UnityObjectToClipPos(v.vertex);
    float4 pos_ws  = mul(unity_ObjectToWorld, v.vertex);
    float4 pos_wvp = mul(UNITY_MATRIX_VP, pos_ws);

    o.pos = pos_wvp;
    // o.vertexWS = mul(UNITY_MATRIX_M, v.vertex); // TransformObjectToWorld
    o.vertexWS = pos_ws; // TransformObjectToWorld
    o.vertexOS = v.vertex;
    o.tangent = v.tangent;
    o.uv.xy = v.uv0;
    o.uv.zw = v.uv1;
    o.uvb = v.uv2;
    o.normal = v.normal;
    o.screenPos = ComputeScreenPos(pos_wvp);
    o.vertexcol = (_VertexColorLinear != 0.0) ? VertexColorConvertToLinear(v.vertexcol) : v.vertexcol;
    o.parallax = 0.0f;

    float4 view;
    view.xyz = _WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz;
    view.xyz = normalize(view.xyz);
    view.w = 0.0f;
    float3 normal  = mul((float3x3)unity_ObjectToWorld, v.normal); // transform normals to worldspace
    normal = normalize(normal);
    float4 tangent;
    tangent.xyz = mul((float3x3)unity_ObjectToWorld, v.tangent.xyz); // transform tangents to worldspace
    tangent.xyz = normalize(tangent.xyz);
    tangent.w = v.tangent.w * unity_WorldTransformParams.w; // tangent uv direction
    float3 bitangent = cross(normal.xyz, tangent.xyz) * tangent.w; // get worldspace bitangent

    float3 parallax;
    parallax.y = bitangent.x;
    parallax.x = tangent.y;
    parallax.z = normal.z;
    parallax = view.yyy * parallax;
    tangent.y = bitangent.z;
    tangent.z = normal.x;
    bitangent.x = tangent.z;
    bitangent.z = normal.y;

    view.xyw = bitangent.xyz * view.xxx + parallax;
    o.parallax = float4(tangent.xyz * view.zzz + view.xyw, 0.0f);
    return o;
}

// fragment
float4 frag(vsOut i, bool frontFacing : SV_IsFrontFace) : SV_Target
{
    // initialize final color
    float4 finalColor = (float4)1.0f;

    // initialize vertex inputs : 
    float2 uv = (frontFacing || !_UseBackFaceUV2) ? i.uv.xy : i.uv.zw;
    float3 view = normalize(_WorldSpaceCameraPos.xyz - i.vertexWS);
    float3 normal = i.normal;
    float3 light  = _WorldSpaceLightPos0;

   
    if(_UseUVScroll)
    {   
        float2 swing = sin(_Time.yy * float2(_UVScrollX, _UVScrollY));
        swing.x = mapRange(0, 1, 0, 1, swing.x);
        swing.y = mapRange(0, 1, 0, 1, swing.y);
        float2 scrolling = (_Time.yy) * float2(_UVScrollX, _UVScrollY);
        uv.x = (_EnableScrollXSwing) ? uv.x + swing.x : uv.x + scrolling.x;
        uv.y = (_EnableScrollYSwing) ? uv.y + swing.y : uv.y + scrolling.y;
    }
    
    // create half floattor for specular
    float3 half_floattor = normalize(view + light);

    // invert normals if theyre back facing 
    normal = (frontFacing) ? normal : -normal;
    // normal = normalize(i.normal);
    normal = UnityObjectToWorldNormal(i.normal);
    normal = normalize(normal);

    // sample textures : 
    float4 diffuse   = _MainTex.Sample(sampler_MainTex, uv * _MainTex_ST.xy + _MainTex_ST.zw);
    float4 lightmap  = _LightMapTex.Sample(sampler_LightMapTex, uv);
    float4 facemap   = _FaceMapTex.Sample(sampler_LightMapTex, uv);
    float4 normalmap = _BumpMap.Sample(sampler_BumpMap, uv);
    float4 matmask   = _MaterialMasksTex.Sample(sampler_LightMapTex, uv);

    float alpha = (_MainTexAlphaUse != 1) ? 1.0f : diffuse.w; 

    // initialize dot products : 
    float ndotl = dot(normal, light);
    float ndotv = dot(normal, view);
    float ndoth = dot(normal, half_floattor);

    // get enviromental colors
    float4 environmentLighting = calculateEnvLighting(i.vertexWS);
    // get average environment color for adjusting the brightness of the rim light in dark areas
    float avg_env_col = (environmentLighting.x + environmentLighting.y + environmentLighting.z) / 3; // this is something i picked up while writing project diva shaders for mmd
    float rim_env_col = clamp(avg_env_col, 0.05f, 1.0f); // 


    // ========================================================= //
    // extract material ids from lightmap alpha
    float ID_tex = (_UseFaceMapNew) ? facemap.w : lightmap.w;
    // faces use the facemap as their lightmaps, this is how they give faces their own shadow colors separate from ramps
    int material_ID = 1;
    if(ID_tex >= 0.2 && ID_tex <= 0.4 && _UseMaterial4 != 0)
    {
        material_ID = 4;
    } 
    else if(ID_tex >= 0.4 && ID_tex <= 0.6 && _UseMaterial3 != 0)
    {
        material_ID = 3;
    }
    else if(ID_tex >= 0.6 && ID_tex <= 0.8 && _UseMaterial5 != 0)
    {
        material_ID = 5;
    }
    else if(ID_tex >= 0.8 && ID_tex <= 1.0 && _UseMaterial2 != 0)
    {
        material_ID = 2;
    }
    // its more efficient to determine the index for the arrays than to contiuosly perform if checks
    // ========================================================= //
    // initialize material arrays 
    float4 material_color[5] =
    {
        _Color, _Color2, _Color3, _Color4, _Color5,
    };

    float4 shadow_colors_warm[5] =
    {
        _FirstShadowMultColor, _FirstShadowMultColor2, _FirstShadowMultColor3, _FirstShadowMultColor4, _FirstShadowMultColor5
    };

    float4 shadow_colors_cool[5] =
    {
        _CoolShadowMultColor, _CoolShadowMultColor2, _CoolShadowMultColor3, _CoolShadowMultColor4, _CoolShadowMultColor5
    };

    float2 shadow_transitions[5] = // x = range y = softness
    {
        float2(_ShadowTransitionRange, _ShadowTransitionSoftness), float2(_ShadowTransitionRange2, _ShadowTransitionSoftness2), float2(_ShadowTransitionRange3, _ShadowTransitionSoftness3),  float2(_ShadowTransitionRange4, _ShadowTransitionSoftness4), float2(_ShadowTransitionRange5, _ShadowTransitionSoftness5),
    };

    float2 specular_values[5] =  // x = shininess y = multi
    {
        float2(_Shininess, _SpecMulti), float2(_Shininess2, _SpecMulti2), float2(_Shininess3, _SpecMulti3), float2(_Shininess4, _SpecMulti4), float2(_Shininess5, _SpecMulti5), 
    };

    // ========================================================= //
    float3 rim_depth = (float3) 0.0f;
    float3 vs_normal = normalize(mul(UNITY_MATRIX_V, normal));
    float4 rim_color[5] =
    {
        _RimColor0,
        _RimColor1,
        _RimColor2,
        _RimColor3,
        _RimColor4, 
    };
    if(_UseRimLight == 1)
    {
        // do stupid normal floattor stuff for the rim lights
        if(isVR())
        {
            _RimThreshold = 0.8f;
            _RimLightThickness = _RimLightThickness * 0.3f;
            
        } 
        
        float3 rim_normal = (vs_normal);      

        float normal_max = max(max(abs(rim_normal.y), abs(rim_normal.x)), abs(rim_normal.z));

        float2 normal_cmp;
        normal_cmp.x = normal_max == abs(rim_normal).x;
        normal_cmp.y = normal_max == abs(rim_normal).z;
        float2 normal_something;
        normal_something.x = normal_max == 0.5f ? 0.5f : 0.25f;
        normal_something.y = normal_cmp.y ? 0.5f : 0.25;
        float3 rim_normal_a = normal_cmp.y ? rim_normal.xyz : rim_normal.xzy;
        rim_normal = normal_cmp.x ? rim_normal.xyz : rim_normal_a;
        float rim_lt_check = rim_normal.z < 0.0f;
        rim_normal.xy = rim_normal * 0.5f + 0.5f;
        rim_normal.xy = rim_normal * 0.5f + normal_something;
        rim_normal.xy = rim_normal * 2.0 - 1.0f;
        rim_normal.z = 0.0f;
        // rim lighting
        float2 screen_pos = i.screenPos.xy / i.screenPos.w;
        float3 wvp_pos = mul(UNITY_MATRIX_VP, i.vertexWS);
        // in order to hide any weirdness at far distances, fade the rim by the distance from the camera
        float camera_dist = (distance(_WorldSpaceCameraPos.xyz, i.vertexWS)) * 0.5f + 0.5f;
        camera_dist = saturate(smoothstep(2.0f, 0.0f, camera_dist));
        //  if(isVR() && IsInMirror())
        // {
        //     camera_dist = saturate(smoothstep(0.0f, 2.0f, (1.0f / camera_dist)));
        // }
        // else 
        // {
        //     camera_dist = saturate(smoothstep(2.0f, 0.0f, camera_dist));
        // }
        // camera_dist = clamp(camera_dist, 0.5, 1.0);
        // return camera_dist.xxxx;

        // sample depth texture, this will be the base
        float org_depth = GetLinearZFromZDepth_WorksWithMirrors(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, screen_pos.xy), screen_pos);
        float2 offset_uv = screen_pos.xy;
        // offset_uv = lerp(offset_uv, -offset_uv, rim_side);
        offset_uv = (rim_normal.xy * ((float2)0.004f * _RimLightThickness) * clamp(camera_dist, 0.3f, 1.0f)) + offset_uv;
        // offset_uv = (rim_normal.xy * ((float2)0.004f * _RimLightThickness)) + offset_uv;

        // sample depth texture using offset uv
        float offset_depth = GetLinearZFromZDepth_WorksWithMirrors(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, offset_uv.xy), offset_uv);

        rim_depth = (offset_depth - org_depth);
        rim_depth = max(rim_depth, 0.001f);
        rim_depth = pow(rim_depth, 0.04f); 
        
        rim_depth = rim_depth + -0.8f;
        rim_depth = rim_depth * 10.0f;

        rim_depth = clamp(rim_depth, 0.0, 1.0);
        rim_depth = (rim_depth * rim_depth) * (rim_depth * -2.0f + 3.0f);
        
        org_depth = min((-org_depth + 2.0f) * 0.3f + org_depth, 1.0f);
        rim_depth = org_depth.x * rim_depth;
        if(_SharpRimLight)
        {
            rim_depth = rim_depth < _RimThreshold ? 0.0f : rim_depth;
        }
        else
        {
            rim_depth = smoothstep(_RimThreshold, 1.0f, rim_depth); 
        }

        rim_depth = rim_depth * clamp(camera_dist.x, 0.1f, 1.0f);
        // rim_depth = rim_depth < 0.9f ? 0.0f : 1.0f; 
        rim_depth = (rim_depth * _RimLightIntensity) * rim_color[material_ID];
    }
    else if(_UseRimLight == 2)
    {
        float rim_values[5] = 
        {
            _RimPower0,
            _RimPower1,
            _RimPower2,
            _RimPower3,
            _RimPower4,
        }; 

        float2 screen_pos = i.screenPos.xy / i.screenPos.w;
        screen_pos.xy = screen_pos.xy;
        float3 wvp_pos = mul(UNITY_MATRIX_VP, i.vertexWS);
        // in order to hide any weirdness at far distances, fade the rim by the distance from the camera
        float camera_dist = (distance(_WorldSpaceCameraPos.xyz, i.vertexWS)) * 0.5f + 0.5f;
        camera_dist = saturate(smoothstep(5.0f, 0.0f, camera_dist));

        // multiply the rim widht material values by the lightmap red channel
        float rim_width = _RimLightThickness;
        
        // sample depth texture, this will be the base
        float org_depth = GetLinearZFromZDepth_WorksWithMirrors(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, screen_pos.xy), screen_pos);

        float rim_side = (i.vertexWS.z * -vs_normal.x) - (i.vertexWS.x * -vs_normal.z);
        rim_side = (rim_side > 0.0f) ? 0.0f : 1.0f;
        

        // create offset screen uv using rim width value and view space normals for offset depth texture
        float2 offset_uv = 0.0f;
        offset_uv.x = lerp(offset_uv.x, -offset_uv.x, rim_side);
        float2 offset = ((rim_width * vs_normal) * 0.0055f) * camera_dist;
        offset_uv.x = screen_pos.x + ((offset_uv.x * 0.01f + offset.x)); 
        offset_uv.y = screen_pos.y + (offset_uv.y * 0.01f + offset.y);

        // sample depth texture using offset uv
        float offset_depth = GetLinearZFromZDepth_WorksWithMirrors(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, offset_uv.xy), offset_uv);

        rim_depth = (offset_depth - org_depth);
        rim_depth = pow(rim_depth, 0.8f); 
        rim_depth = smoothstep(0.0f, _RimLightThickness, rim_depth);


        // float rim_env_col = clamp(avg_env_col, 0.25f, 1.0f);
        float3 rim_light = (rim_color[material_ID].xyz * rim_depth * _RimLightIntensity) * camera_dist;
        // rim_light = rim_light * rim_env_col;  
        rim_depth = rim_light;  

    }


    // ========================================================= //
    // material coloring
    float4 color = 1.0f;
    if(_UseMaterialMasksTex)
    {
        matmask = matmask * float4(_UseMaterial3, _UseMaterial4, _UseMaterial5, _UseMaterial5);
        color = lerp(_Color, _Color2, matmask.w);
        color = lerp(color, _Color3, matmask.x);
        color = lerp(color, _Color4, matmask.y);
        color = lerp(color, _Color5, matmask.z);
    }
    else
    {
        color = material_color[material_ID - 1];
    }

    if(_StarCloakEnable) // almost forgot the most important part
    {
        if(_StarCockType == 0)
        {
            float2 uv_use = i.uv.xy;
            if(_StarUVSource == 1)
            {
                uv_use = i.uv.zw;
            }
            else if(_StarUVSource == 2)
            {
                uv_use = i.uvb.xy;
            }
            float3 parallax = normalize(i.parallax);

            float star_speed = _Time.y * _Star01Speed;

            parallax = normalize(parallax);
            float2 star_01_parallax = (parallax.xy * (_StarHeight - 1.0f))   * (float2)-0.1 + (float2(0.0f, star_speed) + TRANSFORM_TEX(uv, _StarTex));
            float2 star_02_parallax = (parallax.xy * (_Star02Height - 1.0f)) * (float2)-0.1 + (float2(0.0f, star_speed * 0.5f) + TRANSFORM_TEX(uv, _Star02Tex));
                    
            float2 pallete_uv = TRANSFORM_TEX(uv, _ColorPaletteTex);
            pallete_uv.x = _Time.y * _ColorPalletteSpeed +  pallete_uv.x;
            float3 pallete = _ColorPaletteTex.Sample(sampler_ColorPaletteTex, pallete_uv);

            float2 noise_01_uv = _Time.y * (float2)_Noise01Speed + TRANSFORM_TEX(uv, _NoiseTex01);
            float2 noise_02_uv = _Time.y * (float2)_Noise02Speed + TRANSFORM_TEX(uv, _NoiseTex02);

            float noise_01_tex = _NoiseTex01.Sample(sampler_NoiseTex01, noise_01_uv).x;
            float noise_02_tex = _NoiseTex02.Sample(sampler_NoiseTex01, noise_02_uv).x;

            float noise = noise_01_tex * noise_02_tex;

            float2 constellation_uv = TRANSFORM_TEX(uv, _ConstellationTex);
            float2 const_parallax = (parallax.xy * (_ConstellationHeight - 1.0f)) * (float2)-0.1f + constellation_uv;
            float3 constellation_tex = _ConstellationTex.Sample(sampler_LightMapTex, const_parallax).xyz * (float3)_ConstellationBrightness;

            float2 cloud_uv = TRANSFORM_TEX(uv, _CloudTex);
            float2 cloud_parallax = (parallax.xy * (_CloudHeight - 1.0f)) * (float2)-0.1 + (noise * (float2)_Noise03Brightness + cloud_uv);
            float cloud_tex = _CloudTex.Sample(sampler_NoiseTex01, cloud_parallax).x;

            float star_01 = _StarTex.Sample(sampler_StarTex, star_01_parallax).x;
            float star_02 = _Star02Tex.Sample(sampler_StarTex, star_02_parallax).y;

            float stars = star_01 + star_02;
            stars = stars * diffuse.w;
            cloud_tex = cloud_tex * diffuse.w;

            float3 star_color = pallete * stars;
            star_color = star_color * (float3)_StarBrightness;

            float3 cloak = star_color * noise + constellation_tex;
            cloak = ((cloud_tex * (float3)_CloudBrightness) * pallete + cloak);
            diffuse.xyz = lerp(diffuse.xyz, cloak + diffuse.xyz, diffuse.w * _StarCloakBlendRate);

            if(_StarCloakOveride) return diffuse;
        }
        else if(_StarCockType == 1)
        {
            float2 uv_use = i.uv.xy;
            if(_StarUVSource == 1)
            {
                uv_use = i.uv.zw;
            }
            else if(_StarUVSource == 2)
            {
                uv_use = i.uvb.xy;
            }

            float2 noise_uv = uv_use.xy * _NoiseMap_ST.xy + _NoiseMap_ST.zw;
            noise_uv = _Time.yy * _NoiseSpeed.xy + noise_uv;
            float noise_tex = _NoiseMap.Sample(sampler_LightMapTex, noise_uv).x;
            float2 flow_uv = uv_use.xy * _FlowMap_ST.xy + _FlowMap_ST.zw;
            flow_uv = noise_tex.xx * _NoiseScale.x + flow_uv;
            flow_uv = _Time.yy * _FlowMaskSpeed.xy + flow_uv;

            float flowmap = _FlowMap.Sample(sampler_LightMapTex, flow_uv).x;

            float2 flow2_uv = uv_use.xy * _FlowMap02_ST.xy + _FlowMap02_ST.zw;
            flow2_uv = _Time.yy * _FlowMask02Speed.xy + flow2_uv;

            float flowmap2 = _FlowMap02.Sample(sampler_LightMapTex, flow2_uv).x;

            float2 mask_uv = uv_use.xy * _NoiseMap_ST.xy + _NoiseMap_ST.zw;


            float3 uv_color = max(uv_use.y, 0.0001f);
            uv_color = pow(uv_color, _BottomPower) * _BottomScale;            
            uv_color = saturate(uv_color);
            uv_color.xyz = lerp(_BottomColor01, _BottomColor02, uv_color.x);
            float3 flow_color = _FlowColor * _FlowScale; 

            float3 flow = flowmap2 + flowmap;
            flow = flow * flow_color;

            float3 flowmask = max(uv_use.y, 0.0001f);
            flowmask = pow(flowmask, _FlowMaskPower) * _FlowMaskScale; 
            flowmask = saturate(flowmask);
            flow = flow * flowmask;

            float masktex = _FlowMask.Sample(sampler_LightMapTex, mask_uv);

            flow = flow * masktex + uv_color;

            // return float3(noise_tex.xxx).xyzz;s

            


            diffuse.xyz = lerp(diffuse.xyz, flow, diffuse.w);
        }
    }

    if(_HandEffectEnable)
    {
        float2 mask_uv = i.uvb.xy * _Mask_ST.xy + _Mask_ST.zw;
        mask_uv.xy = _Time.y * float2(_Mask_Speed_U, 0.0f) + mask_uv;
        float3 masktex = _Mask.Sample(sampler_Mask, mask_uv.xy).xyz;

        float2 effuv1 = i.uvb.xy * _Tex01_UV.xy + _Tex01_UV.zw;
        effuv1.xy = _Time.yy * float2(_Tex01_Speed_U, _Tex01_Speed_V) + effuv1.xy;
        float3 eff1 = _MainTex.Sample(sampler_MainTex, effuv1.xy).xyw;
        float2 effuv2 = i.uvb.xy * _Tex02_UV.xy + _Tex02_UV.zw;
        effuv2.xy = _Time.yy * float2(_Tex02_Speed_U, _Tex02_Speed_V) + effuv2.xy;
        float3 eff2 = _MainTex.Sample(sampler_MainTex, effuv2.xy).xyw;
        float3 effmax = max(eff1.y, eff2.y);
        float2 effuv3 = i.uvb.xy * _Tex03_UV.xy + _Tex03_UV.zw;
        effuv3.xy = _Time.yy * float2(_Tex03_Speed_U, _Tex03_Speed_V) + effuv3.xy;
        float3 eff3 = _MainTex.Sample(sampler_MainTex, effuv3.xy).xyw;
        effmax = max(effmax, eff3.y);
        float2 effmul = masktex.xz * eff3.zx;
        effmax = max(masktex.y, effmax);
        effmul.xy = eff1.zx * eff2.zx + effmul.xy;
        effmax = (-effmul.y) + effmax;

        float downrange = i.uv.x>=_DownMaskRange;

        downrange = (downrange) ? 1.0 : 0.0;
        effmul.x = downrange * effmul.x;
        float2 effuv4 = i.uvb.xy * _Tex04_UV.xy + _Tex04_UV.zw;
        effuv4.xy = _Time.yy * float2(_Tex04_Speed_U, _Tex04_Speed_V) + effuv4.xy;
        float eff4 = _MainTex.Sample(sampler_MainTex, effuv4.xy).z;
        float2 effuv5 = i.uvb.xy * _Tex05_UV.xy + _Tex05_UV.zw;
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
        outeff.xyz = outeff * lerp(1.0f, environmentLighting, _EnvironmentLightingStrength).xyz;
        effmax.x = max(i.uvb.y, 0.0001f);
        effmax.x = pow(effmax.x, _GradientPower);
        effmax.x = effmax.x * _GradientScale;
        outeff.w = saturate(effmax.x * effmul.x); 

        // clip(outeff.w - _MainTexAlphaCutoff);
        clip(saturate(1.0f - (i.uvb.y > 0.995f)) - 0.1f);
        

        return outeff; 
    }

    if(!_DisableColors) diffuse = diffuse * color;
    // ========================================================= //
    // shadow 
    float litFactor = 1.0f;
    float3 fresnel = (float3)0.0f;
    
    if(_UseFresnel)
    {
        fresnel = saturate(1.0f - dot(normal, view));
        fresnel = max(1.0f - ndotv, 0.000001f);
        fresnel = pow(fresnel, _HitColorFresnelPower);
        fresnel = _HitColor.xyz * fresnel.xxx * _HitColorScaler;
    }
    float3 headForward = normalize(UnityObjectToWorldDir(_headForwardVector.xyz));
    float3 headRight = normalize(UnityObjectToWorldDir(_headRightVector.xyz));
    float3 shadow_color = (float3)1.0f;
    float shadow_area = 1.0f;
    float3 specular = (float3)0.0f;
    float metal_area = (lightmap.x > 0.9f) * _MetalMaterial;
    float3 metal = (float3)1.0f;
    float3 metal_specular = (float3)0.0f;
    float3 emission = 0.0f;
    if(_UseFaceMapNew != 0.0f) // face shading
    // besides the additional option of using material shadow colors
    // this comes from straight from primotoon but i dont care, the way i do it in mmd has always been buggy cuz of rotation matrices and shit
    // 
    {

        float lightmap_flipped = _LightMapTex.Sample(sampler_LightMapTex, float2(1.0f - uv.x, uv.y)).w;

        // get dot products of each head direction and the lightDir
        half FdotL = dot(normalize(light.xz), headForward.xz);
        half RdotL = dot(normalize(light.xz), headRight.xz);

        // remap both dot products from { -1, 1 } to { 0, 1 } and invert
        RdotL = (_flipFaceLighting != 0.0f) ? RdotL * 0.5f + 0.5f : 1 - (RdotL * 0.5f + 0.5f);
        FdotL = 1 - (FdotL * 0.5f + 0.5f);

        // get direction of lightmap based on RdotL being above 0.5 or below
        fixed4 lightmapDir = (RdotL <= 0.5f) ? lightmap_flipped : lightmap.w;
        
        // use FdotL to drive the face SDF, make sure FdotL has a maximum of 0.999 so that it doesn't glitch
        half shadowRange = min(0.999, FdotL);
        shadowRange = pow(shadowRange, pow((2.0f - (_LightArea + 0.50f)), 3.0f));

        // finally drive faceFactor
        half faceFactor = smoothstep(shadowRange - _FaceMapSoftness, shadowRange + _FaceMapSoftness, lightmapDir.w);

        // use FdotL once again to lerp between shaded and lit for the mouth area
        // faceFactor = faceFactor + facemapTex.w * (1 - FdotL); // this isnt necessary since in game they actually have shadows
        // the thing is that its harder to notice since it uses multiple materials

        litFactor = 1.0f - faceFactor;

        /* END OF FACE CALCULATION */


        /* SHADOW RAMP CREATION */

        float4 ShadowFinal;

        if(_UseShadowRamp != 0)
        {

            float2 ramp_uvs = float2(faceFactor, (((6.0f - _MaterialID) - 1.0f) * 0.1f) + 0.5f);
            float4 ramp_day = _PackedShadowRampTex.Sample(sampler_PackedShadowRampTex, ramp_uvs); 
            float4 ramp_nit = _PackedShadowRampTex.Sample(sampler_PackedShadowRampTex, ramp_uvs + float2(0.0f, 0.5f));

            ShadowFinal = lerp(ramp_day, ramp_nit, _DayOrNight);
        }
        else
        {
            ShadowFinal = lerp(shadow_colors_warm[material_ID - 1], shadow_colors_cool[material_ID - 1], _DayOrNight);
        }

        // make lit areas 1
        ShadowFinal = lerp(ShadowFinal, 1.0f, faceFactor);

        /* END OF SHADOW RAMP CREATION */


        /* COLOR CREATION */

        // apply diffuse ramp
        finalColor.xyz = diffuse.xyz * ShadowFinal.xyz;

        // apply face blush
        finalColor.xyz *= lerp(1, lerp(1, _FaceBlushColor, diffuse.w), _FaceBlushStrength);

        // apply nose blush
        finalColor.xyz *= lerp(1, lerp(_NoseBlushColor, 1, lightmap.z), _NoseBlushStrength);

        // apply environment lighting
        finalColor.xyz *= lerp(1.0, environmentLighting, _EnvironmentLightingStrength).xyz;

        finalColor.w = finalColor.w * color.w;
        // if(_ReturnFaceMap) return faceFactor;
        /* END OF COLOR CREATION */
        // return ShadowFinal;
    }
    else // everything else
    {
        if(_UseBumpMap)
        {
            
            float3 bumpmap = normalmap.xyz;
            bumpmap.xy = bumpmap.xy * 2.0f - 1.0f;
            bumpmap.z = max(1.0f - min(_BumpScale, 0.95f), 0.001f);
            bumpmap.xyz = normalize(bumpmap);

            // world space position derivative
            float3 p_dx = ddx(i.vertexWS);
            float3 p_dy = ddy(i.vertexWS);

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

            float3 bitangent = (corrected_normal.yzx * tangent.zxy) - (corrected_normal.zxy * tangent.yzx); 
            bitangent = bitangent * -uv_det;

            float3x3 tbn = {tangent, bitangent, corrected_normal};

            float3 mapped_normals = mul(bumpmap.xyz, tbn);
            mapped_normals = normalize(mapped_normals); // for some reason, this normalize messes things up in mmd

            mapped_normals = (0.99f >= bumpmap.z) ? mapped_normals : corrected_normal;

            normal = mapped_normals;
        }
        if(_TextureLineUse) // its ultimately better to only use the texture lines if the bump map is on since the textures come togehter but ill leave them decoupled so custom features can be implemented later
        {   
            float3 line_color = (_TextureLineMultiplier.xyz * diffuse.xyz - diffuse.xyz) * _TextureLineMultiplier.www;
            float line_dist = LinearEyeDepth(i.screenPos.z / i.screenPos.w); // this may need to be replaced with the version that works for mirrors, will wait for feedback

            float line_thick = _TextureLineDistanceControl.x * line_dist + _TextureLineThickness;
            line_thick = 1.0f - min(line_thick, min(_TextureLineDistanceControl.y, 0.99f));

            line_dist = (line_dist > _TextureLineDistanceControl.z) ? 1.0f : 0.0f;
            line_thick = 1.0f - line_thick;
            
            float line_smooth = -_TextureLineSmoothness * line_dist + line_thick;
            line_dist = _TextureLineSmoothness * line_dist + line_thick;
            line_dist = -line_smooth + line_dist;

            float lines = normalmap.z - line_smooth;
            line_dist = 1.0f / line_dist;
            lines = lines * line_dist;
            lines = saturate(lines);
            line_dist = lines * -2.0f + 3.0f;
            lines = lines * lines;
            lines = lines * line_dist;
            // these 6 lines above are a smoothstep
            diffuse.xyz = lines * line_color + diffuse.xyz;
        }


       
        
        // initialize dot products : 
        float ndotl = dot(normal, light);
        float ndotv = dot(normal, view);
        float ndoth = dot(normal, half_floattor);

        ndotl = ndotl * 0.5f + 0.5f;
        float shadow_ao = ((_UseLightMapColorAO) ? lightmap.y : 0.5) * ((_UseVertexColorAO) ? i.vertexcol.x : 1.0);
        if(_UseShadowRamp)
        {
            float ramp_width = i.vertexcol.y * 2.0f * _ShadowRampWidth;
            ndotl = (ndotl + shadow_ao) * 0.5f;
            ndotl = (shadow_ao > 0.95f) ? 1.0f : ndotl;
            ndotl = (shadow_ao < 0.05f) ? 0.0f : ndotl;

            // // shadow_ao = smoothstep(0.00f, 0.4f, shadow_ao);
            // // shadow_area = lerp(0, ndotl, saturate(shadow_ao));
            float shadow_thresh = ndotl < _LightArea;
            ndotl = 1.0f - (((_LightArea - ndotl) / _LightArea) / ramp_width);
            
            // float shadow_thresh = shadow_area < _LightArea;
            // ndotl = 1.0f - (((_LightArea - ndotl) / _LightArea) / ramp_width);
            shadow_area = ndotl;

            float2 ramp_uvs = float2(ndotl, (((6.0f - material_ID) - 1.0f) * 0.1f) + 0.05f);
            float4 ramp_day = _PackedShadowRampTex.Sample(sampler_PackedShadowRampTex, ramp_uvs);
            float4 ramp_nit = _PackedShadowRampTex.Sample(sampler_PackedShadowRampTex, ramp_uvs + float2(0.0f, 0.5f));
                       
            shadow_color = lerp(ramp_nit, ramp_day, _DayOrNight);
            shadow_color = (shadow_thresh && lightmap.y < 0.95f) ? shadow_color : 1.0f;
        }
        else
        {
            ndotl = (ndotl + shadow_ao) * 0.5f;
            ndotl = (shadow_ao > 0.95f) ? 1.0f : ndotl;
            ndotl = (shadow_ao < 0.05f) ? 0.0f : ndotl;

            if(ndotl < _LightArea)
            {
                float shadow_check1 = ndotl < _LightArea;
                ndotl = (-ndotl + _LightArea) / shadow_transitions[material_ID - 1].x;
                float shadow_check2 = ndotl >= 1.0f;
                ndotl = ndotl + 0.01f;
                ndotl = pow(ndotl, shadow_transitions[material_ID - 1].y);
                ndotl = min(ndotl, 1.0f);
                ndotl = shadow_check2 ? 1.0f : ndotl;
                ndotl = shadow_check1 ? ndotl : 1.0f;
            }
            else
            {
                ndotl = 0.0;
            }

            shadow_area = ndotl;
            shadow_color = lerp(1.0f, shadow_area * lerp(shadow_colors_warm[material_ID - 1], shadow_area * shadow_colors_cool[material_ID - 1], _DayOrNight), shadow_area);
        }
       
        if(_MetalMaterial)
        {
            // sphere mapping, non skewed from uts2
            float3 view_normal = mul((float3x3)UNITY_MATRIX_V, normal);
            float3 uv_detail = view_normal.xyz * float3(-1.0f, -1.0f, 1.0f);
            float3 uv_base   = mul((float3x3)UNITY_MATRIX_V, view).xyz * float3(-1.0f, -1.0f, 1.0f) + float3(0.0f, 0.0f, 1.0f);
            float2 sphere_uv = (uv_base * dot(uv_base, uv_detail) / uv_base.z - uv_detail).xy;
            sphere_uv = (sphere_uv * float2(_MTMapTileScale, 0.0f)) / 2.0f + 0.5f;

            // sample metal sphere map
            metal = _MTMap.Sample(sampler_MTMap, sphere_uv).xyz;

            metal = saturate(metal * _MTMapBrightness);
            metal = lerp(_MTMapDarkColor, _MTMapLightColor, metal);
            metal = lerp(metal * _MTShadowMultiColor, metal, saturate(shadow_area + 0.75f));

            // metal specular 
            metal_specular = pow(max(ndoth, 0.001f), _MTShininess) * _MTSpecularScale;
            if(_MTSharpLayerOffset < metal_specular.x)
            {
                metal_specular = _MTSharpLayerColor;
            }
            else
            {
                if(_MTUseSpecularRamp) metal_specular = _MTSpecularRamp.Sample(sampler_MTSpecularRamp, float2(metal_specular.x, 0.5f));

                metal_specular = (metal_specular * _MTSpecularColor) * lightmap.z;
            }

            metal_specular = lerp(metal_specular * _MTSpecularAttenInShadow, metal_specular, saturate(shadow_area));
        }

        if(_SpecularHighlights)
        {
            specular = specular_values[material_ID - 1].y * _SpecularColor;
            ndoth = pow(max(ndoth,0.001f), specular_values[material_ID - 1].x);
            ndoth = (1.0f - lightmap.z) < ndoth;
            specular = specular * ndoth * (float3)0.5f * lightmap.r;
        } 
        emission = (float3)0.0f;
        float emis_area = 0.0f;
        float pulse = 1.0f;
        float eyepulse = 1.0f;
        if(_TogglePulse != 0)
        {
            // form the sine wave
            pulse = sin(_PulseSpeed * _Time.y);    
            // remap from ranges { -1, 1 } to { 0, 1 }
            pulse = pulse * 0.5 + 0.5;
            // ensure emissionPulse never goes below or above the minimum and maximum values set by the user
            pulse = mapRange(0, 1, _PulseMinStrength, _PulseMaxStrength, pulse);
            if(_EyePulse)
            {
                eyepulse = pulse;
            }
            
        }

        if(_MainTexAlphaUse == 2.0f)
        {
            
            emis_area = diffuse.w - 0.03f;
            emission =  lerp((float3)0.0f, _EmissionStrength * diffuse.xyz * _EmissionColor, saturate(emis_area * pulse));
        }
        else if (_EmissionType == 1)
        {
            float3 customemi   = _CustomEmissionTex.Sample(sampler_CustomEmissionTex, uv).xyz;
            emis_area = _CustomEmissionAOTex.Sample(sampler_CustomEmissionAOTex, uv).xyz;
            emission = lerp((float3)0.0f, _EmissionStrength * customemi.xyz * _EmissionColor, saturate(emis_area * pulse));
        }
        if(_ToggleEyeGlow !=0 && lightmap.y > 0.95f)
        {
            emis_area = diffuse.w + 0.97f;
            emission =  lerp((float3)0.0f, _EyeGlowStrength * diffuse.xyz * _EmissionColor, saturate(emis_area * eyepulse));
        }
        
                
        finalColor.xyz = (metal_area) ? diffuse.xyz * metal + metal_specular: diffuse.xyz * shadow_color + specular;
        finalColor.xyz = finalColor + emission;
        finalColor.w = alpha * color.w;
        finalColor.xyz = finalColor.xyz * lerp(1.0f, environmentLighting, _EnvironmentLightingStrength).xyz;



        // finalColor.xyz = shadow_area;
        // finalColor.xyz = i.vertexcol.w;
        if(_MainTexAlphaUse == 1.0f)clip(finalColor.w - _MainTexAlphaCutoff);
        
    }
    if(_CausToggle)
    {
        float2 caus_uv = i.vertexWS.xy;
        caus_uv.x = caus_uv.x + i.vertexWS.z; 
        if(_CausUV) caus_uv = uv;
        if((i.vertexWS.y == 0.0f)) caus_uv = uv;
        float2 caus_uv_a = _CausTexSTA.xy * caus_uv + _CausTexSTA.zw;
        float2 caus_uv_b = _CausTexSTB.xy * caus_uv + _CausTexSTB.zw;
        caus_uv_a = _CausSpeedA * _Time.yy + caus_uv_a;
        caus_uv_b = _CausSpeedB * _Time.yy + caus_uv_b;
        float3 caus_a = (float3)0.0f;
        float3 caus_b = (float3)0.0f;
        if(_EnableSplit)
        {
            float caus_a_r = _CausTexture.Sample(sampler_LightMapTex, caus_uv_a + float2(_CausSplit, _CausSplit)).x;
            float caus_a_g = _CausTexture.Sample(sampler_LightMapTex, caus_uv_a + float2(_CausSplit, -_CausSplit)).x;
            float caus_a_b = _CausTexture.Sample(sampler_LightMapTex, caus_uv_a + float2(-_CausSplit, -_CausSplit)).x;
            float caus_b_r = _CausTexture.Sample(sampler_LightMapTex, caus_uv_b + float2(_CausSplit, _CausSplit)).x;
            float caus_b_g = _CausTexture.Sample(sampler_LightMapTex, caus_uv_b + float2(_CausSplit, -_CausSplit)).x;
            float caus_b_b = _CausTexture.Sample(sampler_LightMapTex, caus_uv_b + float2(-_CausSplit, -_CausSplit)).x;
            caus_a = float3(caus_a_r, caus_a_g, caus_a_b);
            caus_b = float3(caus_b_r, caus_b_g, caus_b_b);
        }
        else
        {
            caus_a = _CausTexture.Sample(sampler_LightMapTex, caus_uv_a).xxx;
            caus_b = _CausTexture.Sample(sampler_LightMapTex, caus_uv_b).xxx;
        }

        float3 caus = min(caus_a, caus_b);  
        caus = pow(caus, _CausExp) * _CausColor * _CausInt;      
        finalColor.xyz = finalColor.xyz + caus;
    }

    float3 dissolve = 0.0f;
    float3 weapon_pattern = 0.0f;
    float3 scan_line = 0.0f;
    if(_UseWeapon)
    {
        half2 weaponUVs = (_ProceduralUVs) ? (i.vertexOS.zx + 0.25f) * 1.5f : i.uv.zw;

        half2 weaponPatternUVs = _Time.yy * _Pattern_Speed + weaponUVs; // tmp1.xy
        fixed4 weaponPatternTex = _WeaponPatternTex.Sample(sampler_WeaponPatternTex, weaponPatternUVs);
        half buf = weaponPatternTex;
        weaponPatternTex = sin(((_WeaponDissolveValue - 0.25f) * 6.28f));
        weaponPatternTex += 1.0f;
        buf *= weaponPatternTex.x;      
        weapon_pattern = buf * _WeaponPatternColor;      
        half buf2 = 1.0 - weaponUVs.y;
        buf = (_ScanDirection_Switch) ? buf2 : weaponUVs.y;
        half buf4 = _ScanSpeed * _Time.y;
        half buf3 = buf * 0.5 + buf4;
        fixed4 scanTex = _ScanPatternTex.Sample(sampler_ScanPatternTex, half2(weaponUVs.x, buf3));      
        scan_line = scanTex.xyz * _ScanColorScaler * _ScanColor.xyz;     
        calculateDissolve(dissolve, weaponUVs, weaponPatternTex.x);     
        // apply dissolve
        clip(dissolve.x - _ClipAlphaThreshold);
        finalColor.xyz = finalColor.xyz + max((_UsePattern != 0.0f) ? weapon_pattern : 0.0, pow(dissolve.y, 2.0f) * _WeaponPatternColor * 2.0f);
        finalColor.xyz = finalColor.xyz + scan_line;
    }
    finalColor.xyz = finalColor.xyz + fresnel;
    finalColor.xyz = (_RimLightType > 0) ? ((rim_depth == 1.0f) ? rim_depth : min(finalColor.xyz / (1.0f - (rim_depth)), 1.0f)) : finalColor.xyz + (rim_depth * rim_env_col);



    
    if(_ReturnDiffuseRGB) return float4(diffuse.xyz, 1.0f);
    if(_ReturnDiffuseA) return float4(diffuse.www, 1.0f);
    if(_ReturnLightmapR) return float4(lightmap.xxx, 1.0f);
    if(_ReturnLightmapG) return float4(lightmap.yyy, 1.0f);
    if(_ReturnLightmapB) return float4(lightmap.zzz, 1.0f);
    if(_ReturnLightmapA) return float4(lightmap.www, 1.0f);
    if(_ReturnFaceMap) return float4(facemap.xyz, 1.0f);
    if(_ReturnFaceMapAlpha) return float4(facemap.www, 1.0f);
    if(_ReturnNormalMap) return float4(normalmap.xy, 1.0f, 1.0f);
    if(_ReturnTextureLineMap) return float4(normalmap.zzz, 1.0f);
    if(_ReturnVertexColorR) return float4(i.vertexcol.xxx, 1.0f);
    if(_ReturnVertexColorG) return float4(i.vertexcol.yyy, 1.0f);
    if(_ReturnVertexColorB) return float4(i.vertexcol.zzz, 1.0f);
    if(_ReturnVertexColorA) return float4(i.vertexcol.www, 1.0f);
    if(_ReturnRimLight) return float4(rim_depth.xxx, 1.0f);
    if(_ReturnNormals) return float4(normal.xyz, 1.0f);
    if(_ReturnRawNormals) return float4(i.normal.xyz, 1.0f);
    if(_ReturnTangents) return float4(i.tangent.xyz, 1.0f);
    if(_ReturnMetal) return float4(metal.xyz, 1.0f);
    if(_ReturnSpecular) return float4(specular.xyz, 1.0f);
    if(_ReturnEmissionFactor) return float4(emission.xyz, 1.0f);
    if(_ReturnForwardVector) return float4(headForward.xyz, 1.0f);
    if(_ReturnRightVector) return float4(headRight.xyz, 1.0f);
    
    return finalColor;
}
