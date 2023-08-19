// vertex
vsOut vert(vsIn v)
{
    vsOut o = (vsOut)0.0f;
    if(_OutlineType == 0)
    {
        return (vsOut)0.0f; // outline is set to off, zero everything out
    }
    o.uv.xy = v.uv0;
    o.uv.zw = v.uv1;
    o.vertexWS = mul(UNITY_MATRIX_M, v.vertex); // TransformObjectToWorld, v0
    o.vertexOS = v.vertex;
    float3 outline_normal = (_OutlineType == 2) ? v.tangent.xyz : v.normal.xyz;
    if(_FallbackOutlines)
    {
        outline_normal = mul((float3x3)UNITY_MATRIX_IT_MV, outline_normal);
        outline_normal.z = 0.009f;
        outline_normal.xy = normalize(outline_normal.xy);
        float4 wv_pos = mul(UNITY_MATRIX_MV, v.vertex);
        float fov_width = 1.0f / (rsqrt(abs(wv_pos.z / unity_CameraProjection._m11)));
        // if(!_EnableFOVWidth)fov_width = 1;
        wv_pos.xyz = wv_pos + (outline_normal * (v.vertexcol.w * _OutlineWidth * _Scale));
        o.pos = mul(UNITY_MATRIX_P, wv_pos);
    }
    else
    {
        float3 ws_view = mul(UNITY_MATRIX_MV, o.vertexOS);
        float4 wv_pos = mul(UNITY_MATRIX_MV, v.vertex);
        float fov = 1.0f / (rsqrt(abs(-ws_view.z / unity_CameraProjection._m11)));
        float depth = fov;
        
        float2 range;
        float2 scale;

        if(depth < _OutlineWidthAdjustZs.y)
        {
            range = _OutlineWidthAdjustZs.xy;
            scale = _OutlineWidthAdjustScales.xy;
        }
        else
        {
            range = _OutlineWidthAdjustZs.zw;
            scale = _OutlineWidthAdjustScales.zw;
        }
        
        float offset = lerpByZ(scale.x, scale.y, range.x, range.y, depth);
        offset = offset * 0.414f * v.vertexcol.w * _OutlineWidth * (_Scale * 100);

        outline_normal = mul((float3x3)UNITY_MATRIX_IT_MV, outline_normal);
        outline_normal.z = 0.0f;
        outline_normal.xy = normalize(outline_normal.xy);

        wv_pos.xyz = wv_pos.xyz + outline_normal * offset;
        o.pos = mul(UNITY_MATRIX_P, wv_pos);
    }
    o.vertexcol = v.vertexcol;
    return o;
}

// fragment
vector<fixed, 4> frag(vsOut i, bool frontFacing : SV_IsFrontFace) : SV_Target
{
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

 
    return globalOutlineColor;
}
