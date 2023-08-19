// vertex
vsOut vert(vsIn v)
{
    vsOut o = (vsOut)0.0f;
    o.pos = UnityObjectToClipPos(v.vertex);
    o.vertexWS = mul(UNITY_MATRIX_M, v.vertex); // TransformObjectToWorld
    o.vertexOS = v.vertex;
    o.tangent = v.tangent;
    o.uv.xy = v.uv0;
    o.uv.zw = v.uv1;
    o.normal = v.normal;
    o.screenPos = ComputeScreenPos(o.pos);
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
    UNITY_TRANSFER_FOG(o, o.pos);
    return o;
}

// fragment
fixed4 frag(vsOut i, bool frontFacing : SV_IsFrontFace) : SV_Target
{
    // if frontFacing == 1 or _UseBackFaceUV2 == 0, use uv.xy, else uv.zw
    half2 newUVs = (frontFacing || !_UseBackFaceUV2) ? i.uv.xy : i.uv.zw;
    // use only uv.xy for face shader
    newUVs = (_UseFaceMapNew != 0) ? i.uv.xy : newUVs;
    const half3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.vertexWS);
    // get light direction
    const half4 lightDir = getlightDir();
    const half3 rawNormalsWS = (frontFacing != 0) ? UnityObjectToWorldNormal(i.normal) : 
                                                              -UnityObjectToWorldNormal(i.normal);


    /* TEXTURE CREATION */
    float2 main_uv = TRANSFORM_TEX(newUVs, _MainTex);

    // the author's code has the xy and zw elements of _TexelSize swapped so I swizzle them here (?????? wtf)
    fixed4 mainTex = SampleTexture2DBicubicFilter(_MainTex, sampler_MainTex, main_uv, _MainTex_TexelSize.zwxy);
    fixed4 lightmapTex = SampleTexture2DBicubicFilter(_LightMapTex, sampler_LightMapTex, newUVs, _LightMapTex_TexelSize.zwxy);
    fixed4 facemapTex = SampleTexture2DBicubicFilter(_FaceMap, sampler_FaceMap, newUVs, _FaceMap_TexelSize.zwxy);
    fixed4 bumpmapTex = SampleTexture2DBicubicFilter(_BumpMap, sampler_BumpMap, newUVs, _BumpMap_TexelSize.zwxy);

    /* END OF TEXTURE CREATION */


    /* BUFFER, IGNORE */

    half3 headForward = (float3)0.0f;
    half3 headRight = (float3)0.0f;

    half3 modifiedNormalsWS = rawNormalsWS;
    half3 finalNormalsWS = rawNormalsWS;

    // why not initialize these things??? 
    half litFactor = 0.0f;
    fixed emissionFactor = 0.0f;
    fixed4 metal = (float4)0.0f;

    fixed4 finalColor = 1.0;

    /* END OF BUFFER */

    
    /* MATERIAL IDS */
    half idMasks = (_UseFaceMapNew) ? facemapTex.w : lightmapTex.w;

    half materialID = 1;
    if(idMasks >= 0.2 && idMasks <= 0.4 && _UseMaterial4 != 0)
    {
        materialID = 4;
    } 
    else if(idMasks >= 0.4 && idMasks <= 0.6 && _UseMaterial3 != 0)
    {
        materialID = 3;
    }
    else if(idMasks >= 0.6 && idMasks <= 0.8 && _UseMaterial5 != 0)
    {
        materialID = 5;
    }
    else if(idMasks >= 0.8 && idMasks <= 1.0 && _UseMaterial2 != 0)
    {
        materialID = 2;
    }


    // ========================================================= //
    // star cloak chunk 
    if(_StarCloakEnable)
    {
        float3 parallax = normalize(i.parallax);

        float star_speed = _Time.y * _Star01Speed;

        parallax = normalize(parallax);
        float2 star_01_parallax = (parallax.xy * (_StarHeight - 1.0f))   * (float2)-0.1 + (float2(0.0f, star_speed) + TRANSFORM_TEX(newUVs, _StarTex));
        float2 star_02_parallax = (parallax.xy * (_Star02Height - 1.0f)) * (float2)-0.1 + (float2(0.0f, star_speed * 0.5f) + TRANSFORM_TEX(newUVs, _Star02Tex));
                
        float2 pallete_uv = TRANSFORM_TEX(newUVs, _ColorPaletteTex);
        pallete_uv.x = _Time.y * _ColorPalletteSpeed +  pallete_uv.x;
        float3 pallete = _ColorPaletteTex.Sample(sampler_ColorPaletteTex, pallete_uv);

        float2 noise_01_uv = _Time.y * (float2)_Noise01Speed + TRANSFORM_TEX(newUVs, _NoiseTex01);
        float2 noise_02_uv = _Time.y * (float2)_Noise02Speed + TRANSFORM_TEX(newUVs, _NoiseTex02);

        float noise_01_tex = _NoiseTex01.Sample(sampler_NoiseTex01, noise_01_uv).x;
        float noise_02_tex = _NoiseTex02.Sample(sampler_NoiseTex01, noise_02_uv).x;

        float noise = noise_01_tex * noise_02_tex;

        float2 constellation_uv = TRANSFORM_TEX(newUVs, _ConstellationTex);
        float2 const_parallax = (parallax.xy * (_ConstellationHeight - 1.0f)) * (float2)-0.1f + constellation_uv;
        float3 constellation_tex = _ConstellationTex.Sample(sampler_LightMapTex, const_parallax).xyz * (float3)_ConstellationBrightness;

        float2 cloud_uv = TRANSFORM_TEX(newUVs, _CloudTex);
        float2 cloud_parallax = (parallax.xy * (_CloudHeight - 1.0f)) * (float2)-0.1 + (noise * (float2)_Noise03Brightness + cloud_uv);
        float cloud_tex = _CloudTex.Sample(sampler_NoiseTex01, cloud_parallax).x;

        float star_01 = _StarTex.Sample(sampler_StarTex, star_01_parallax).x;
        float star_02 = _Star02Tex.Sample(sampler_StarTex, star_02_parallax).y;

        float stars = star_01 + star_02;
        stars = stars * mainTex.w;
        cloud_tex = cloud_tex * mainTex.w;

        float3 star_color = pallete * stars;
        star_color = star_color * (float3)_StarBrightness;

        float3 cloak = star_color * noise + constellation_tex;
        cloak = ((cloud_tex * (float3)_CloudBrightness) * pallete + cloak);
        mainTex.xyz = lerp(mainTex.xyz, cloak + mainTex.xyz, mainTex.w * _StarCloakBlendRate);

        if(_StarCloakOveride) return mainTex;
    }

    /* ENVIRONMENT LIGHTING */

    fixed4 environmentLighting = calculateEnvLighting(i.vertexWS);

    /* END OF ENVIRONMENT LIGHTING */


    if(_UseFaceMapNew != 0)
    {
        /* TEXTURE CREATION */
        fixed4 lightmapTex_mirrored = SampleTexture2DBicubicFilter(_LightMapTex, sampler_LightMapTex, half2(1.0 - i.uv.x, i.uv.y), _LightMapTex_TexelSize.zwxy);

        /* END OF TEXTURE CREATION */


        /* FACE CALCULATION */

        // get head directions
        headForward = normalize(UnityObjectToWorldDir(_headForwardVector.xyz));
        headRight = normalize(UnityObjectToWorldDir(_headRightVector.xyz));

        // get dot products of each head direction and the lightDir
        half FdotL = dot(normalize(lightDir.xz), headForward.xz);
        half RdotL = dot(normalize(lightDir.xz), headRight.xz);

        // remap both dot products from { -1, 1 } to { 0, 1 } and invert
        RdotL = (_flipFaceLighting != 0) ? RdotL * 0.5 + 0.5 : 1 - (RdotL * 0.5 + 0.5);
        FdotL = 1 - (FdotL * 0.5 + 0.5);

        // get direction of lightmap based on RdotL being above 0.5 or below
        fixed4 lightmapDir = (RdotL <= 0.5) ? lightmapTex_mirrored : lightmapTex;
        
        // use FdotL to drive the face SDF, make sure FdotL has a maximum of 0.999 so that it doesn't glitch
        half shadowRange = min(0.999, FdotL);
        shadowRange = pow(shadowRange, pow((2 - (_LightArea + 0.50)), 3));

        // finally drive faceFactor
        half faceFactor = smoothstep(shadowRange - _FaceMapSoftness, shadowRange + _FaceMapSoftness, lightmapDir.w);

        // use FdotL once again to lerp between shaded and lit for the mouth area
        // faceFactor = faceFactor + facemapTex.w * (1 - FdotL); // this isnt necessary since in game they actually have shadows
        // the thing is that its harder to notice since it uses multiple materials

        litFactor = 1.0 - faceFactor;

        /* END OF FACE CALCULATION */


        /* SHADOW RAMP CREATION */

        fixed4 ShadowFinal;

        if(_UseShadowRamp != 0)
        {
            half2 ShadowRampDayUVs = float2(faceFactor, (((6 - _MaterialID) - 1) * 0.1) + 0.05);
            fixed4 ShadowRampDay = _PackedShadowRampTex.Sample(sampler_PackedShadowRampTex, ShadowRampDayUVs);

            half2 ShadowRampNightUVs = float2(faceFactor, (((6 - _MaterialID) - 1) * 0.1) + 0.05 + 0.5);
            fixed4 ShadowRampNight = _PackedShadowRampTex.Sample(sampler_PackedShadowRampTex, ShadowRampNightUVs);

            ShadowFinal = lerp(ShadowRampNight, ShadowRampDay, _DayOrNight);
        }
        else
        {
            fixed4 ShadowDay = _FirstShadowMultColor;
            fixed4 ShadowNight = _CoolShadowMultColor;
            if(materialID == 2) ShadowDay = _FirstShadowMultColor2; ShadowNight = _CoolShadowMultColor2;
            if(materialID == 3) ShadowDay = _FirstShadowMultColor3; ShadowNight = _CoolShadowMultColor3;
            if(materialID == 4) ShadowDay = _FirstShadowMultColor4; ShadowNight = _CoolShadowMultColor4;
            if(materialID == 5) ShadowDay = _FirstShadowMultColor5; ShadowNight = _CoolShadowMultColor5;
                
            ShadowFinal = lerp(ShadowDay, ShadowNight, _DayOrNight);
        }

        // make lit areas 1
        ShadowFinal = lerp(ShadowFinal, 1, faceFactor);

        /* END OF SHADOW RAMP CREATION */


        /* COLOR CREATION */

        // apply diffuse ramp
        finalColor.xyz = mainTex.xyz * ShadowFinal.xyz;

        // apply face blush
        finalColor.xyz *= lerp(1, lerp(1, _FaceBlushColor, mainTex.w), _FaceBlushStrength);

        // apply nose blush
        finalColor.xyz *= lerp(1, lerp(_NoseBlushColor, 1, lightmapTex.z), _NoseBlushStrength);

        // apply environment lighting
        finalColor.xyz *= lerp(1.0, environmentLighting, _EnvironmentLightingStrength).xyz;
        if(_ReturnFaceMap) return faceFactor;
        /* END OF COLOR CREATION */
    }
    else
    {
        /* NORMAL CREATION */

       
        if(_UseBumpMap)
        {
            half3 normalCreationBuffer;

            fixed4 modifiedNormalMap;
            modifiedNormalMap.xyz = bumpmapTex.xyz;
            normalCreationBuffer.xy = modifiedNormalMap.xy * 2 - 1;
            normalCreationBuffer.z = max(1 - min(_BumpScale, 0.95), 0.001);
            modifiedNormalMap.xyw = normalize(normalCreationBuffer);

            /* because miHoYo stores outline directions in the tangents of the mesh,
            // they cannot be used for normal and bump mapping. because of this, we can just recalculate
            // for them with ddx() and ddy(), don't ask me how they work - I don't know as well kekw */ 
            half3 dpdx = ddx(i.vertexWS);
            half3 dpdy = ddy(i.vertexWS);
            half3 dhdx; dhdx.xy = ddx(newUVs);
            half3 dhdy; dhdy.xy = ddy(newUVs);

            // modify normals
            dhdy.z = dhdx.y; dhdx.z = dhdy.x;
            normalCreationBuffer = dot(dhdx.xz, dhdy.yz);
            half3 recalcTangent = -(0 < normalCreationBuffer) + (normalCreationBuffer < 0);
            dhdx.xy = float2(recalcTangent.xy) * dhdy.yz;
            dpdy *= -dhdx.y;
            dpdx = dpdx * dhdx.x + dpdy;
            dpdx = normalize(dpdx);// normalize(normalCreationBuffer);
            normalCreationBuffer = rawNormalsWS;
            dpdy = normalCreationBuffer.zxy * dpdx.yzx;
            dpdy = normalCreationBuffer.yzx * dpdx.zxy - dpdy.xyz;
            dpdy *= -recalcTangent;
            dpdy *= modifiedNormalMap.y;
            dpdx = modifiedNormalMap.x * dpdx + dpdy;
            modifiedNormalMap.xyw = modifiedNormalMap.www * normalCreationBuffer + dpdx;
            // recalcTangent = rsqrt(dot(modifiedNormalMap.xyw, modifiedNormalMap.xyw));
            // modifiedNormalMap.xyw *= recalcTangent;
            modifiedNormalMap.xyw = normalize(modifiedNormalMap.xyw);
            normalCreationBuffer = (0.99 >= modifiedNormalMap.w) ? modifiedNormalMap.xyw : normalCreationBuffer;

            // hope you understood any of that KEKW, finally switch between normal map and raw normals
            modifiedNormalsWS = normalCreationBuffer;
            finalNormalsWS = (_UseBumpMap) ? modifiedNormalsWS : finalNormalsWS;

        }

        /* END OF NORMAL CREATION */


        /* TEXTURE LINE */

        // thx to manashiku bestie for helping with this owo

        half fragCoord = i.screenPos.z / i.screenPos.w;
        fragCoord = 1.0 / (_ZBufferParams.z * fragCoord + _ZBufferParams.w);

        half textureLineThickness = _TextureLineDistanceControl.x * fragCoord + _TextureLineThickness;
        textureLineThickness = 1.0 - min(textureLineThickness, min(_TextureLineDistanceControl.y, 0.99000001));

        fragCoord = fragCoord >= _TextureLineDistanceControl.z;

        half textureLineSmoothness = -_TextureLineSmoothness * fragCoord + textureLineThickness;

        fragCoord = _TextureLineSmoothness * fragCoord + textureLineThickness;
        fragCoord -= textureLineSmoothness;

        fixed3 textureLine = bumpmapTex.zzz - textureLineSmoothness.xxx;

        fragCoord = 1.0 / fragCoord;

        textureLine *= fragCoord;
        textureLine = saturate(textureLine);
        fragCoord = textureLine * -2.0 + 3.0;
        textureLine *= textureLine;
        textureLine *= fragCoord;

        // kind of unused
        half textureLineFac = (_TextureLineUse != 0.0) ? textureLine.x : 0.0;

        const fixed4 MainTexTintColor = 1.0;

        // i'm pretty sure this is literally just 0 but i am following decompiled code ok shut up
        half3 textureLineCol = _TextureLineMultiplier.xyz * mainTex.xyz - mainTex.xyz * 
                                         _TextureLineMultiplier.www;
                        
        textureLine = textureLine * textureLineCol + mainTex.xyz;

        // this becomes the new diffuse
        fixed4 newDiffuse = fixed4(textureLine, 1.0);

        /* END OF TEXTURE LINE */


        /* DOT CREATION */

        // NdotL
        half NdotL = dot(finalNormalsWS, normalize(lightDir));
        // remap from { -1, 1 } to { 0, 1 }
        NdotL = NdotL * 0.5 + 0.5;

        // NdotH, for some reason they don't remap ranges for the specular
        half3 halfVector = normalize(viewDir + _WorldSpaceLightPos0);
        half NdotH = dot(finalNormalsWS, halfVector);

        /* END OF DOT CREATION */

        // getting the materials inside this branch is weird, why are we doing this
        // its something shared by a bunch of stuff 


        /* SHADOW RAMP CREATION */

        fixed4 ShadowFinal;
        half NdotL_buf;

        // create ambient occlusion from lightmap.g
        half occlusion = ((_UseLightMapColorAO != 0) ? lightmapTex.g : 0.5) * ((_UseVertexColorAO != 0) ? i.vertexcol.r : 1.0);

        // switch between the shadow ramp and custom shadow colors
        if(_UseShadowRamp != 0)
        {
            // calculate shadow ramp width from _ShadowRampWidth and i.vertexcol.g
            half ShadowRampWidthCalc = i.vertexcol.g * 2.0 * _ShadowRampWidth;

            // apply occlusion
            occlusion = smoothstep(0.01, 0.4, occlusion);
            NdotL = lerp(0, NdotL, saturate(occlusion));
            // NdotL_buf will be used as a sharp factor
            NdotL_buf = NdotL;
            litFactor = NdotL_buf < _LightArea;

            // add options for controlling shadow ramp width and shadow push
            NdotL = 1 - ((((_LightArea - NdotL) / _LightArea) / ShadowRampWidthCalc));
            NdotL_buf = NdotL;

            half2 ShadowRampDayUVs = float2(NdotL, (((6 - materialID) - 1) * 0.1) + 0.05);
            fixed4 ShadowRampDay = _PackedShadowRampTex.Sample(sampler_PackedShadowRampTex, ShadowRampDayUVs);

            half2 ShadowRampNightUVs = float2(NdotL, (((6 - materialID) - 1) * 0.1) + 0.05 + 0.5);
            fixed4 ShadowRampNight = _PackedShadowRampTex.Sample(sampler_PackedShadowRampTex, ShadowRampNightUVs);

            ShadowFinal = lerp(ShadowRampNight, ShadowRampDay, _DayOrNight);

            // switch between 1 and ramp edge like how the game does it, also make eyes always lit
            ShadowFinal = (litFactor && lightmapTex.g < 0.95) ? ShadowFinal : 1;
        }
        else
        {
            // apply occlusion
            NdotL = (NdotL + occlusion) * 0.5;
            NdotL = (occlusion > 0.95) ? 1.0 : NdotL;
            NdotL = (occlusion < 0.05) ? 0.0 : NdotL;

            // combine all the _ShadowTransitionRange, _ShadowTransitionSoftness, _CoolShadowMultColor and
            // _FirstShadowMultColor parameters into one object
            half globalShadowTransitionRange = _ShadowTransitionRange;
            half globalShadowTransitionSoftness = _ShadowTransitionSoftness;
            fixed4 globalCoolShadowMultColor = _CoolShadowMultColor;
            fixed4 globalFirstShadowMultColor = _FirstShadowMultColor;

            if(NdotL < _LightArea){
                if(materialID == 2){
                    globalShadowTransitionRange = _ShadowTransitionRange2;
                    globalShadowTransitionSoftness = _ShadowTransitionSoftness2;
                    globalCoolShadowMultColor = _CoolShadowMultColor2;
                    globalFirstShadowMultColor = _FirstShadowMultColor2;
                }
                else if(materialID == 3){
                    globalShadowTransitionRange = _ShadowTransitionRange3;
                    globalShadowTransitionSoftness = _ShadowTransitionSoftness3;
                    globalCoolShadowMultColor = _CoolShadowMultColor3;
                    globalFirstShadowMultColor = _FirstShadowMultColor3;
                }
                else if(materialID == 4){
                    globalShadowTransitionRange = _ShadowTransitionRange4;
                    globalShadowTransitionSoftness = _ShadowTransitionSoftness4;
                    globalCoolShadowMultColor = _CoolShadowMultColor4;
                    globalFirstShadowMultColor = _FirstShadowMultColor4;
                }
                else if(materialID == 5){
                    globalShadowTransitionRange = _ShadowTransitionRange5;
                    globalShadowTransitionSoftness = _ShadowTransitionSoftness5;
                    globalCoolShadowMultColor = _CoolShadowMultColor5;
                    globalFirstShadowMultColor = _FirstShadowMultColor5;
                }

                // apply params, form the final light direction
                half buffer1 = NdotL < _LightArea;
                NdotL = -NdotL + _LightArea;
                NdotL /= globalShadowTransitionRange;
                half buffer2 = NdotL >= 1.0;
                NdotL += 0.01;
                NdotL = log2(NdotL);
                NdotL *= globalShadowTransitionSoftness;
                NdotL = exp2(NdotL);
                NdotL = min(NdotL, 1.0);
                NdotL = (buffer2) ? 1.0 : NdotL;
                NdotL = (buffer1) ? NdotL : 1.0;
            }
            else
            {
                NdotL = 0.0;
            }

            // final NdotL will also be litFactor
            litFactor = NdotL;
            NdotL_buf = 1.0 - NdotL;

            // apply color
            fixed4 ShadowDay = NdotL * globalFirstShadowMultColor;
            fixed4 ShadowNight = NdotL * globalCoolShadowMultColor;

            ShadowFinal = lerp(ShadowDay, ShadowNight, _DayOrNight);

            // switch between 1 and ramp edge like how the game does it, also make eyes always lit
            ShadowFinal = lerp(1, ShadowFinal, litFactor);
        }

        /* END OF SHADOW RAMP CREATION */


        /* METALLIC */

        // create metal factor to be used later
        half metalFactor = (lightmapTex.r > 0.9) * _MetalMaterial;

        // create local view direction matrices: 
        float3 sphere_dir = _headUpVector.xyz;
        float3 sphere_x  = normalize(cross( mul( sphere_dir, (float3x3)unity_ObjectToWorld), UNITY_MATRIX_V._13_23_33 ) );
        float3 sphere_y  = normalize(cross( UNITY_MATRIX_V._13_23_33, sphere_x));

        // multiply world space normals with view matrix
        float3 viewNormal = mul(UNITY_MATRIX_V, finalNormalsWS);
        // https://github.com/poiyomi/PoiyomiToonShader/blob/master/_PoiyomiShaders/Shaders/8.0/Poiyomi.shader#L8397
        // this part (all 5 lines) i literally do not understand but it fixes the skewing that occurs when the camera 
        // views the mesh at the edge of the screen (PLEASE LET ME GO BACK TO BLENDER)
        float3 matcapUV_Detail = viewNormal.xyz * half3(-1, -1, 1);
        float3 matcapUV_Base = (mul(UNITY_MATRIX_V, half4(viewDir, 0)).rgb 
                                        * half3(-1, -1, 1)) + half3(0, 0, 1);
        float3 matcapUVs = matcapUV_Base * dot(matcapUV_Base, matcapUV_Detail) 
                                    / matcapUV_Base.z - matcapUV_Detail;

        // offset UVs to middle and apply _MTMapTileScale
        matcapUVs = float3(matcapUVs.x * _MTMapTileScale, matcapUVs.y, 0) * 0.5 + half3(0.5, 0.5, 0);

        // sample matcap texture with newly created UVs
        metal = _MTMap.Sample(sampler_MTMap, matcapUVs.xy);
        // prevent metallic matcap from glowing
        metal = saturate(metal * _MTMapBrightness);
        metal = lerp(_MTMapDarkColor, _MTMapLightColor, metal);

        // apply _MTShadowMultiColor ONLY to shaded areas
        metal = lerp(metal * _MTShadowMultiColor, metal, saturate(NdotL_buf));

        /* END OF METALLIC */


        /* METALLIC SPECULAR */
        
        half4 metalSpecular = NdotH;
        metalSpecular = saturate(pow(metalSpecular, _MTShininess) * _MTSpecularScale);

        if(_MTSharpLayerOffset < metalSpecular.x){
            metalSpecular = _MTSharpLayerColor;
        }
        else{
            // if _MTUseSpecularRamp is set to 1, shrimply use the specular ramp texture
            if(_MTUseSpecularRamp != 0){
                metalSpecular = _MTSpecularRamp.Sample(sampler_MTSpecularRamp, half2(metalSpecular.x, 0.5));
            }

            // apply _MTSpecularColor
            metalSpecular *= _MTSpecularColor;
            metalSpecular *= lightmapTex.z;
        }

        // apply _MTSpecularAttenInShadow ONLY to shaded areas
        metalSpecular = lerp(metalSpecular * _MTSpecularAttenInShadow, metalSpecular, saturate(NdotL_buf));

        /* END OF METALLIC SPECULAR */


        /* SPECULAR */

        // combine all the _Shininess and _SpecMulti parameters into one object
        half globalShininess = _Shininess;
        half globalSpecMulti = _SpecMulti;
        if(materialID == 2){
            globalShininess = _Shininess2;
            globalSpecMulti = _SpecMulti2;
        }
        else if(materialID == 3){
            globalShininess = _Shininess3;
            globalSpecMulti = _SpecMulti3;
        }
        else if(materialID == 4){
            globalShininess = _Shininess4;
            globalSpecMulti = _SpecMulti4;
        }
        else if(materialID == 5){
            globalShininess = _Shininess5;
            globalSpecMulti = _SpecMulti5;
        }

        half4 specular = NdotH;
        // apply _Shininess parameters
        specular = pow(specular, globalShininess);
        // 1.03 may seem arbitrary, but it is shrimply an optimization due to Unity compression, it's supposed to be a 
        // inversion of lightmapTex.b, also compare specular to inverted lightmapTex.b
        specular = (1.03 - lightmapTex.b) < specular;
        specular = saturate(specular * globalSpecMulti * _SpecularColor * lightmapTex.r);

        /* END OF SPECULAR */


        /* EMISSION */

        // use diffuse tex alpha channel for emission mask
        emissionFactor = 0;

        fixed4 emission = 0;

        // toggle between emission being on or not
        if(_MainTexAlphaUse == 2.0)
        {
            // again, this may seem arbitrary but it's an optimization because miHoYo likes their textures very crunchy!
            emissionFactor = saturate(mainTex.w - 0.03);

            // toggle between game-like emission or user's own custom emission texture, idk why i used a switch here btw
            switch(_EmissionType)
            {
                case 0:
                    emission = _EmissionStrength * fixed4(mainTex.xyz, 1) * _EmissionColor;
                    break;
                case 1:
                    emission = _EmissionStrength * _EmissionColor * 
                            fixed4(_CustomEmissionTex.Sample(sampler_CustomEmissionTex, newUVs).xyz, 1);
                    // apply emission AO
                    emission *= fixed4(_CustomEmissionAOTex.Sample(sampler_CustomEmissionAOTex, newUVs).xyz, 1);
                    break;
                default:
                    break;
            }

            // pulsing emission
            if(_TogglePulse != 0)
            {
                // form the sine wave
                half emissionPulse = sin(_PulseSpeed * _Time.y);    
                // remap from ranges { -1, 1 } to { 0, 1 }
                emissionPulse = emissionPulse * 0.5 + 0.5;
                // ensure emissionPulse never goes below or above the minimum and maximum values set by the user
                emissionPulse = mapRange(0, 1, _PulseMinStrength, _PulseMaxStrength, emissionPulse);
                // apply pulse
                emission = lerp((_EmissionType != 0) ? 0 : fixed4(mainTex.xyz, 1) * _EmissionColor, 
                                emission, emissionPulse);
            }
        }
        // eye glow stuff
        if(_ToggleEyeGlow != 0 && lightmapTex.g > 0.95){
            emissionFactor += 1;
            emission = fixed4(mainTex.xyz, 1) * _EyeGlowStrength;
        }

        /* END OF EMISSION */


        /* WEAPON */

        fixed3 dissolve = 0.0;
        fixed3 weaponPattern = 0.0;
        fixed3 scanLine = 0.0;
        if(_UseWeapon != 0.0){
            half2 weaponUVs = (_ProceduralUVs != 0.0) ? (i.vertexOS.zx + 0.25) * 1.5 : i.uv.zw;

            /* PATTERN */

            half2 weaponPatternUVs = _Time * _Pattern_Speed + weaponUVs; // tmp1.xy
            fixed4 weaponPatternTex = SampleTexture2DBicubicFilter(_WeaponPatternTex, sampler_WeaponPatternTex, weaponPatternUVs, _WeaponPatternTex_TexelSize.zwxy);
            half buf = weaponPatternTex;
            weaponPatternTex = sin(((_WeaponDissolveValue - 0.25) * 6.28));
            weaponPatternTex += 1.0;
            buf *= weaponPatternTex.x;

            weaponPattern = buf * _WeaponPatternColor;

            //return fixed4(buf.xxx, 1.0);

            /* END OF PATTERN */


            /* SCAN LINE */

            half buf2 = 1.0 - weaponUVs.y;
            buf = (_ScanDirection_Switch != 0.0) ? buf2 : weaponUVs.y;
            half buf4 = _ScanSpeed * _Time.y;
            half buf3 = buf * 0.5 + buf4;
            fixed4 scanTex = _ScanPatternTex.Sample(sampler_ScanPatternTex, half2(weaponUVs.x, buf3));

            scanLine = scanTex.xyz * _ScanColorScaler * _ScanColor.xyz;


            /* END OF SCAN LINE */


            /* DISSOLVE */

            calculateDissolve(dissolve, weaponUVs, weaponPatternTex.x);

            /*buf = dissolveTex < 0.99;

            dissolveTex.x -= 0.001;
            dissolveTex.x = dissolveTex.x < 0.0;
            dissolveTex.x = (buf) ? dissolveTex.x : 0.0;*/

            // apply dissolve
            clip(dissolve.x - _ClipAlphaThreshold);

            /* END OF DISSOLVE */
        }

        /* END OF WEAPON */


        /* CUTOUT TRANSPARENCY */

        if(_MainTexAlphaUse == 1.0) clip(mainTex.w - 0.03 - _MainTexAlphaCutoff);

        /* END OF CUTOUT TRANSPARENCY */


        /* COLOR CREATION */

        fixed3 finalDiffuse = ((_TextureLineUse != 0 && _UseBumpMap != 0) ? newDiffuse.xyz : mainTex.xyz);

        // apply diffuse ramp, apply ramp to metallic part only if metallics is disabled bc metal has its own shadow color
        finalColor.xyz = (metalFactor) ? finalDiffuse : finalDiffuse * ShadowFinal.xyz;

        // apply metallic only to anything metalFactor encompasses
        finalColor.xyz = (metalFactor) ? finalColor.xyz * metal.xyz : finalColor.xyz;

        // add specular to finalColor if metalFactor is evaluated as true, else add metallic specular
        finalColor.xyz = (metalFactor) ? finalColor + metalSpecular.xyz : finalColor.xyz + specular.xyz;

        // apply environment lighting
        finalColor.xyz *= lerp(1, environmentLighting, _EnvironmentLightingStrength).xyz;

        // apply emission
        finalColor.xyz = (_EmissionType != 0 && lightmapTex.g < 0.95) ? finalColor.xyz + emission.xyz : 
                                                                        lerp(finalColor, emission, emissionFactor).xyz;

        if(_UseWeapon != 0.0){
            // apply pattern
            finalColor.xyz += max((_UsePattern != 0.0) ? weaponPattern : 0.0, pow(dissolve.y, 2.0) * _WeaponPatternColor * 2);

            // apply scan line
            finalColor.xyz += scanLine;
        }

        /* END OF COLOR CREATION */
    }


    /* FRESNEL CREATION */

    /*----------------------------------------------------/
    u_xlat42 = dot(u_xlat1.xyz, u_xlat1.xyz);
    u_xlat42 = inversesqrt(u_xlat42);
    u_xlat2.xzw = vec3(u_xlat42) * u_xlat1.xyz;  
    u_xlat42 = dot(u_xlat5.xyz, u_xlat2.xzw);
    u_xlat42 = clamp(u_xlat42, 0.0, 1.0);
    u_xlat42 = (-u_xlat42) + 1.0;
    u_xlat42 = max(u_xlat42, 9.99999975e-05);
    u_xlat42 = log2(u_xlat42);
    u_xlat42 = u_xlat42 * _HitColorFresnelPower;
    u_xlat42 = exp2(u_xlat42);
    /----------------------------------------------------*/
    // half3 fresnel = rsqrt(dot(finalNormalsWS, finalNormalsWS));
    // fresnel *= finalNormalsWS; // this is just normalizing it dog
    float3 fresnel = normalize(finalNormalsWS);

    // NdotV
    half NdotV = 1.0 - saturate(dot(fresnel, viewDir));
    NdotV = max(NdotV, 9.99999975e-05);
    NdotV = pow(NdotV, _HitColorFresnelPower);

    /*----------------------------------------------------/
    u_xlat2.xzw = max(_ElementRimColor.xyz, _HitColor.xyz);
    u_xlat2.xzw = vec3(u_xlat42) * u_xlat2.xzw;
    u_xlat0.xyz = u_xlat2.xzw * vec3(vec3(_HitColorScaler, _HitColorScaler, _HitColorScaler)) + u_xlat0.xyz;
    
    for now, idk what u_xlat0 could be
    /----------------------------------------------------*/
    //fresnel = max(_ElementRimColor.xyz, _HitColor.xyz) * NdotV.xxx * _HitColorScaler;
    fresnel = _HitColor.xyz * NdotV.xxx * _HitColorScaler;

    /* END OF FRESNEL */
    float3 vs_normal = normalize(i.normal);
    vs_normal = mul((float3x3)UNITY_MATRIX_V, vs_normal);
    float2 screen_pos = i.screenPos.xy / i.screenPos.w;
    float3 wvp_pos = mul(UNITY_MATRIX_VP, i.vertexWS);
    // in order to hide any weirdness at far distances, fade the rim by the distance from the camera
    float camera_dist = saturate(1.0f / distance(_WorldSpaceCameraPos.xyz, i.vertexWS));

    // multiply the rim widht material values by the lightmap red channel
    // float rim_width = 1.0 * lerp(1.0f, lightmap.r, _RimLightMode);
    
    // sample depth texture, this will be the base
    float org_depth = GetLinearZFromZDepth_WorksWithMirrors(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, screen_pos.xy), screen_pos);

    float rim_side = (i.vertexWS.z * -vs_normal.x) - (i.vertexWS.x * -vs_normal.z);
    rim_side = (rim_side > 0.0f) ? 0.0f : 1.0f;
    

    // create offset screen uv using rim width value and view space normals for offset depth texture
    // float2 offset_uv = 0.1f;
    // offset_uv.x = lerp(offset_uv.x, -offset_uv.x, rim_side);
    // float2 offset = ((vs_normal) * 0.0055f);
    // offset_uv.x = screen_pos.x + ((offset_uv.x * 0.01f + offset.x) * max(0.5f, camera_dist));
    // offset_uv.y = screen_pos.y + (offset_uv.y * 0.01f + offset.y);
    float2 offset_uv = vs_normal.xy * (float2)0.002f + screen_pos.xy;

    // sample depth texture using offset uv
    float offset_depth = GetLinearZFromZDepth_WorksWithMirrors(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, offset_uv.xy), screen_pos);

    float rim_depth = (offset_depth - org_depth);
    rim_depth = pow(rim_depth, 1.0f); 
    rim_depth = smoothstep(0.0f, 1.0f, rim_depth);



    float3 rimLight = (rim_depth * _RimLightIntensity) * max(0.5f, camera_dist);

   
    // rim light mustn't appear in backfaces
    rimLight *= frontFacing;

    /* END OF RIM LIGHT */

    
    /* COLOR CREATION */

    // apply fresnel
    finalColor.xyz += (_UseFresnel != 0.0) ? fresnel : 0.0;

    // apply rim light
    finalColor.xyz = (_RimLightType != 0) ? ColorDodge(rimLight, finalColor.xyz) : finalColor.xyz + rimLight;

    // apply fog
    UNITY_APPLY_FOG(i.fogCoord, finalColor);

    /* END OF COLOR CREATION */


    /* DEBUGGING */

    if(_ReturnDiffuseRGB != 0){ return fixed4(mainTex.xyz, 1.0); }
    if(_ReturnDiffuseA != 0){ return fixed4(mainTex.www, 1.0); }
    if(_ReturnLightmapR != 0){ return fixed4(lightmapTex.xxx, 1.0); }
    if(_ReturnLightmapG != 0){ return fixed4(lightmapTex.yyy, 1.0); }
    if(_ReturnLightmapB != 0){ return fixed4(lightmapTex.zzz, 1.0); }
    if(_ReturnLightmapA != 0){ return fixed4(lightmapTex.www, 1.0); }
    if(_ReturnNormalMap != 0){ return fixed4(bumpmapTex.xyz, 1.0); }
    if(_ReturnTextureLineMap != 0){ return fixed4(bumpmapTex.zzz, 1.0); }
    if(_ReturnVertexColorR != 0){ return fixed4(i.vertexcol.xxx, 1.0); }
    if(_ReturnVertexColorG != 0){ return fixed4(i.vertexcol.yyy, 1.0); }
    if(_ReturnVertexColorB != 0){ return fixed4(i.vertexcol.zzz, 1.0); }
    if(_ReturnVertexColorA != 0){ return fixed4(i.vertexcol.www, 1.0); }
    if(_ReturnRimLight != 0){ return fixed4(rimLight.xxx, 1.0); }
    if(_ReturnNormals != 0){ return fixed4(finalNormalsWS, 1.0); }
    // why was it outputting the modified normals and not the final that were created
    // this is why even if the normal map was turned off it was still acting as if it they were on
    // smfh
    if(_ReturnRawNormals != 0){ return fixed4(rawNormalsWS, 1.0); }
    if(_ReturnTangents != 0){ return i.tangent; }
    if(_ReturnMetal != 0){ return metal; }
    if(_ReturnEmissionFactor != 0){ return emissionFactor; }
    if(_ReturnForwardVector != 0){ return fixed4(headForward, 1.0); }
    if(_ReturnRightVector != 0){ return fixed4(headRight, 1.0); }

    /* END OF DEBUGGING */

    return finalColor;
}
