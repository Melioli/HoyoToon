// vertex
vsOut vert(vsIn v){
    // vsOut o;
    vsOut o = (vsOut)0.0f;
    // cast all values inside the vsOut structure as 0.0f
    // avoids potential issues of uninitiailzed values

    //o.pos = UnityObjectToClipPos(v.vertex);
    o.vertexWS = mul(UNITY_MATRIX_M, v.vertex); // TransformObjectToWorld, v0
    o.vertexOS = v.vertex;
    o.uv.xy = v.uv0;
    o.uv.zw = v.uv1;
    o.vertexcol = (_VertexColorLinear != 0.0) ? VertexColorConvertToLinear(v.vertexcol) : v.vertexcol;

    const float _OutlineCorrectionWidth = 2.25; // cb0[39].w or cb0[15].x

    // deleted that giant ass block of decompiled code, wtf 


    // easier to understand version, still messy though!
    if(_OutlineType != 0){
        if(_FallbackOutlines != 0){
            // first, form the base outline thickness with vertexcol.w
            vector<float, 3> calcOutline = o.vertexcol.w * (_OutlineWidth * 0.105);
            // get distance between camera and each vertex, ensure thickness does not go below base outline thickness
            float distOutline = max(distance(_WorldSpaceCameraPos, o.vertexWS), 1);
            // clamp distOutline so it doesn't go wild at very far distances
            distOutline = min(distOutline, 10);
            // multiply outline thickness by distOutline to have constant-width outlines
            calcOutline = calcOutline * distOutline;

            // switch between outline types
            switch(_OutlineType){
                case 1:
                    calcOutline *= v.normal;
                    break;
                case 2:
                    calcOutline *= v.tangent.xyz;
                    break;
                default:
                    break;
            }

            // get camera view direction
            vector<half, 3> viewDir = normalize(_WorldSpaceCameraPos - o.vertexWS);

            // optimize outlines for exposed faces so they don't artifact by offsetting in the Z-axis
            calcOutline = calcOutline - mul(unity_WorldToObject, viewDir) * o.vertexcol.z * 0.0015 * _MaxOutlineZOffset;
            // offset vertices
            calcOutline += v.vertex;

            // finally, convert calcOutlines to clip space
            o.pos = UnityObjectToClipPos(calcOutline);
        }
        else{
            // calculations that help the outlines scale consistently even with vastly different FOVs
            vector<half, 4> vViewPosition = mul(UNITY_MATRIX_MV, o.vertexOS); // vViewPosition is u_xlat0\
            // get current FOV
            half fov = (isVR() != 0) ? unity_CameraProjection[1][1] + 0.785398 : unity_CameraProjection[1][1];
            // 2.414 is a constant used in-game, I don't know why
            half fovScale = (2.41400003 / fov) * -vViewPosition.z; // (2.41400003 / fovScale) is 
                                                                                            // u_xlat16
            vector<half, 2> zRange, scales;
            if (fovScale < _OutlineWidthAdjustZs.y){
                zRange = _OutlineWidthAdjustZs.xy;
                scales = _OutlineWidthAdjustScales.xy;
            }
            else{
                zRange = _OutlineWidthAdjustZs.yz;
                scales = _OutlineWidthAdjustScales.yz;
            }
            fovScale = lerpByZ(scales.x, scales.y, zRange.x, zRange.y, fovScale); // just before _OutlineWidth * _OutlineCorrectionWidth
            vector<half, 4> scale;
            //scale.x = _OutlineWidth * _OutlineCorrectionWidth;
            scale = _OutlineWidth * _OutlineCorrectionWidth;
            fovScale *= scale.x;
            //fovScale *= 100.0;
            fovScale *= 150000.0; // workaround
            fovScale *= _Scale;
            // another constant used by the game
            fovScale *= 0.414250195;
            // base outline thickness
            fovScale *= o.vertexcol.w;
            
            /*scale.x = rsqrt(dot(vViewPosition.xyz, vViewPosition.xyz)); // original calculations don't work with improperly ripped models
            scale = vViewPosition * scale.x;*/
            //scale *= _MaxOutlineZOffset;
            scale *= _Scale;

            // o.vertexcol.z contains Z-offset values, though I don't know why they subtract it by 0.5
            half zOffset = saturate(o.vertexcol.z - 0.48);

            // get outline direction, can be either the raw normals (HORRIBLE) or the custom tangents
            vector<half, 3> outlineDirection = (float3)0.0;
            switch(_OutlineType){
                case 1:
                    outlineDirection = v.normal;
                    break;
                case 2:
                    outlineDirection = v.tangent.xyz;
                    break;
                default:
                    break;
            }
            /*outlineDirection = normalize(mul(outlineDirection, UNITY_MATRIX_IT_MV)); // invert transpose model * view matrix
            outlineDirection = normalize(outlineDirection); // workaround optimization

            vViewPosition.xyz += (zOffset * scale);
            vViewPosition.xy += (outlineDirection.xy * fovScale);*/
            
            // original calculations don't work with improperly ripped models
            // had to improvise at this part below

            // get camera view direction
            vector<half, 3> viewDir = normalize(_WorldSpaceCameraPos - o.vertexWS);

            vViewPosition = vector<half, 4>(scale.xyz, 0);
            vViewPosition.xyz = vViewPosition.xyz * outlineDirection.xyz * fovScale;
            vViewPosition = vViewPosition - mul(unity_WorldToObject, viewDir) * zOffset * _MaxOutlineZOffset;
            vViewPosition += o.vertexOS;
            // convert to clip space
            vViewPosition = mul(UNITY_MATRIX_MVP, vViewPosition);

            // output into clip space
            o.pos = vViewPosition;
        }
    }
    else{
        o.pos = vector<float, 4>(0, 0, 0, 0);
    }

    UNITY_TRANSFER_FOG(o, o.pos);

    return o;
}

// fragment
vector<fixed, 4> frag(vsOut i, bool frontFacing : SV_IsFrontFace) : SV_Target{
    // if frontFacing == 1, use uv.xy, else uv.zw
    vector<half, 2> newUVs = (frontFacing) ? i.uv.xy : i.uv.zw;

    // sample textures to objects
    vector<fixed, 4> mainTex = _MainTex.Sample(sampler_MainTex, vector<half, 2>(i.uv.xy));
    vector<fixed, 4> lightmapTex = _LightMapTex.Sample(sampler_LightMapTex, vector<half, 2>(i.uv.xy));


    /* MATERIAL IDS */

    fixed idMasks = lightmapTex.w;

    half materialID = 1;
    if(idMasks >= 0.2 && idMasks <= 0.4 && _UseMaterial4 != 0){
        materialID = 4;
    } 
    else if(idMasks >= 0.4 && idMasks <= 0.6 && _UseMaterial3 != 0){
        materialID = 3;
    }
    else if(idMasks >= 0.6 && idMasks <= 0.8 && _UseMaterial5 != 0){
        materialID = 5;
    }
    else if(idMasks >= 0.8 && idMasks <= 1.0 && _UseMaterial2 != 0){
        materialID = 2;
    }

    /* END OF MATERIAL IDS */


    /* ENVIRONMENT LIGHTING */

    vector<fixed, 4> environmentLighting = calculateEnvLighting(i.vertexWS);
    
    // ensure environmentLighting does not make outlines greater than 1
    environmentLighting = min(1, environmentLighting);

    /* END OF ENVIRONMENT LIGHTING */


    /* COLOR CREATION */

    // form outline colors
    vector<fixed, 4> globalOutlineColor = _OutlineColor;
    if(_UseFaceMapNew == 0){
        if(materialID == 2){
            globalOutlineColor = _OutlineColor2;
        }
        else if(materialID == 3){
            globalOutlineColor = _OutlineColor3;
        }
        else if(materialID == 4){
            globalOutlineColor = _OutlineColor4;
        }
        else if(materialID == 5){
            globalOutlineColor = _OutlineColor5;
        }
    }
    globalOutlineColor.w = 1.0;

    // apply environment lighting
    globalOutlineColor.xyz *= lerp(1, environmentLighting, _EnvironmentLightingStrength).xyz;

    /* END OF COLOR CREATION */


    /* CUTOUT TRANSPARENCY */

    if(_MainTexAlphaUse == 1.0) clip(mainTex.w - 0.03 - _MainTexAlphaCutoff);

    /* END OF CUTOUT TRANSPARENCY */


    /* WEAPON */

    if(_UseWeapon != 0.0){
        vector<half, 2> weaponUVs = (_ProceduralUVs != 0.0) ? (i.vertexOS.zx + 0.25) * 1.5 : i.uv.zw;

        vector<fixed, 3> dissolve = 0.0;

        /* DISSOLVE */

        calculateDissolve(dissolve, weaponUVs.xy, 1.0);

        /*buf = dissolveTex < 0.99;

        dissolveTex.x -= 0.001;
        dissolveTex.x = dissolveTex.x < 0.0;
        dissolveTex.x = (buf) ? dissolveTex.x : 0.0;*/

        /* END OF DISSOLVE */

        // apply pattern
        globalOutlineColor.xyz += pow(dissolve.y, 2.0) * _WeaponPatternColor.xyz * 2;
    
        // apply dissolve
        clip(dissolve.x - _ClipAlphaThreshold);
    }

    /* END OF WEAPON */

    // apply fog
    UNITY_APPLY_FOG(i.fogCoord, globalOutlineColor);

    //return vector<fixed, 4>(i.TtoW0, 1);

    /* END OF COLOR CREATION */


    return globalOutlineColor;
}
