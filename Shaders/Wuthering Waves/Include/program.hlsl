vertex_out vs_model (vertex_in v)
{
    vertex_out o;
    v.color = float4(sRGBToLinear(v.color.xyz), v.color.w);
    
    o.vertex = UnityObjectToClipPos(v.vertex);
    #if defined(_is_shadow)
        if(_EnableHairShadow)
        {
            float4 ws_pos = mul(unity_ObjectToWorld, v.vertex);
            float3 vl = mul(_WorldSpaceLightPos0.xyz, UNITY_MATRIX_V) * (1.f / ws_pos.w);
            float3 offset_pos = ((vl * .001f) * float3(4,0,0)) + v.vertex.xyz;
            v.vertex.xyz = offset_pos;
            o.vertex = UnityObjectToClipPos(v.vertex);
        }
        // o.vertex = 0.f;
    #endif
    o.coord0.xy = v.uv0;
    o.coord0.zw = v.uv1;
    o.coord1.xy = v.uv2;
    o.coord1.zw = v.uv3;
    o.os_pos = v.vertex;
    o.ws_pos = mul(unity_ObjectToWorld, v.vertex);
    o.ss_pos = ComputeGrabScreenPos(o.vertex);
    o.normal = mul((float3x3)unity_ObjectToWorld, v.normal);
    o.tangent.xyz = mul((float3x3)unity_ObjectToWorld, v.tangent.xyz);
    o.tangent.w = v.tangent.w * unity_WorldTransformParams.w; 
    o.view = _WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz;
    o.color = v.color;
    return o;
}

vertex_out vs_edge (vertex_in v)
{
    vertex_out o;
    o.coord0.xy = v.uv0;
    o.coord0.zw = v.uv1;
    o.coord1.xy = v.uv2;
    o.coord1.zw = v.uv3;
    o.color = v.color;
    o.vertex = UnityObjectToClipPos(v.vertex);
    
    float4 wv_pos = mul(UNITY_MATRIX_MV, v.vertex);

    o.normal = mul((float3x3)unity_ObjectToWorld, v.normal);
    o.tangent.xyz = mul((float3x3)unity_ObjectToWorld, v.tangent.xyz);
    o.tangent.w = v.tangent.w * unity_WorldTransformParams.w; 


    float3 bitangent = cross(o.normal, o.tangent.xyz) * o.tangent.w;

    float3 outline = 0;
    
    if(_Outline > 0)
    {
        outline = (_Outline == 1) ? o.tangent : o.normal;
        float width = _OutlineWidth * 0.01 * (v.color.y);
        outline = mul((float3x3)UNITY_MATRIX_V, outline.xyz);
        wv_pos.xyz = outline * width + wv_pos;
        o.vertex = mul(UNITY_MATRIX_P, wv_pos);
    }
    else // if no outline, then just set everything to 0 so it esentially doesnt display...
    {
        o = (vertex_out)0.0f; 
    }

    // float4 wv_pos = mul(UNITY_MATRIX_MV, v.vertex);
    
    return o;
}

fixed4 ps_model (vertex_out i) : SV_Target
{
    // initialize output color : 
    float4 output = (float4)1.f;

    // intialize inputs : 
    float2 uv = i.coord0.xy;


    float2 gradient = i.coord1.zw;
    float3 normal = normalize(i.normal);
    float4 tangent = i.tangent;
    float3 bitangent = normalize(cross(normal, tangent.xyz) * tangent.w);
    float3 view = normalize(i.view);
    float4 vertexcolor = i.color;
    float2 screen = (i.ss_pos.xy / i.ss_pos.w);
    float3 light = normalize(_WorldSpaceLightPos0.xyz);
    float3 half_vector = normalize(light + view);

    // sample textures
    float4 diffuse = _MainTex.Sample(sampler_MainTex, uv);
    float4 typemask = _TypeMask.Sample(sampler_TypeMask, uv);
    float4 mask = _MaskTex.Sample(sampler_MaskTex, uv);
    float4 normalmap = _Normal_Roughness_Metallic.Sample(sampler_Normal_Roughness_Metallic, uv);
    float stencil_mask = _StencilMask.Sample(sampler_StencilMask, uv).x;
   
    float shadow_mask = (_UseMainTexA) ? diffuse.w : mask.y;

    if(_UseNormalMap) // only if normal mapping is enabled however
    {
        float3 map = (_NormalFlip) ? float3(1.f - normalmap.x, 1.f - normalmap.y, 1.f) : float3(normalmap.x, normalmap.y, 1.f);
        normal_online(map, i.ws_pos, uv, normal, _NormalStrength);
    } 

    // initialize color
    float4 color = _BaseColor;
    color.xyz = diffuse.xyz * color;

    if(_MaterialType == 3 || _MaterialType == 4) typemask.x = vertexcolor.x;
    
    // get skin ids
    float3 skin_id = skin_type(vertexcolor.x, typemask.x);

    // intialize subsurface color
    float4 subsurface = lerp(_SubsurfaceColor, _SkinSubsurfaceColor, skin_id.x);

    // specular, metallness, roughness? 
    float3 spec = float3(1.0,1.0,1.0) * normalmap.zww;

    // initialize the lighting for the functions to modify 
    float4 shadow_color = (float4)1.0f;
    float3 specular = (float3)0.0f;
    float3 emission = 0.0f;

    // because techinically they have edits of a single uber shader for the character shading ill split it up into different functions
    if(_MaterialType == 0) // base/body/cloth shading 
    {   
        stencil_mask = 0;
        if(_UseStocking && (skin_id.y > 0.5))
        {
            material_tight(color.xyz, shadow_color, specular, half_vector, light, normal, tangent, bitangent, i.ws_pos, uv, normalmap.xy, view);
        }
        else 
        {
            material_basic(color.xyz, shadow_color, specular, normal, light, half_vector, spec, uv, shadow_mask.x, skin_id.xy, typemask.xy);
        }
    }
    else if(_MaterialType == 1) // face shading, there isnt
    {
        
        material_face(shadow_color.xyz, normal, light, uv, shadow_mask, skin_id, typemask.y);
    }
    else if(_MaterialType == 2) // eyes shading
    {
        material_eye(color.xyz, stencil_mask, emission.xyz, normal, tangent, bitangent, uv, view, vertexcolor);
    }
    else if(_MaterialType == 3 || _MaterialType == 4) // hair shading
    {
        stencil_mask = diffuse.w;
        material_hair(shadow_color.xyz, specular.xyz, normal, light, half_vector, mask, skin_id);
    }

    output.xyz = shadow_color.xyz * color.xyz + specular.xyz;
    output.xyz = output.xyz + emission;
    output.xyz = color;

    // stencil block
    #ifdef is_stencil
        if(_EnabelStencil)
        {
            if(_MaterialType == 2 || _MaterialType == 1)
            {
                clip((stencil_mask) - 0.5f);
                output.w = stencil_mask;
            }
            else if (_MaterialType == 3)
            {
                output.w = saturate((diffuse.w) );
            }
            else 
            {
                clip(-1);
            }
            return output;
        }
    #endif
    // hair cast shadow block
    #if defined(_is_shadow)
        if(_MaterialType == 3) 
        {
            float2 ramp_uv;
            ramp_uv.x = 0.1f;
            ramp_uv.y = 1.0 - 0.1;
            float3 ramp = _Ramp.Sample(sampler_Ramp, ramp_uv); 
            float4 subsurface = lerp(_SubsurfaceColor, _SkinSubsurfaceColor, skin_id.x);
            float3 shadow = lerp(subsurface, ramp, 1 * _RampInt);
            shadow = saturate(sqrt(shadow));
            output.xyz = shadow;
        }
        else if(_MaterialType != 3)
        {
            clip(-1.f);
        }
    #endif

    #if defined(_is_face_shadow)
        if(_MaterialType == 1) 
        {
            float2 ramp_uv;
            ramp_uv.x = 0.1f;
            ramp_uv.y = 1.0 - 0.1;
            float3 ramp = _Ramp.Sample(sampler_Ramp, ramp_uv); 
            float4 subsurface = lerp(_SubsurfaceColor, _SkinSubsurfaceColor, skin_id.x);
            float3 shadow = lerp(subsurface, ramp, 1 * _RampInt);
            shadow = saturate(sqrt(shadow));
            output.xyz = shadow;
        }
        else
        {
            clip(-1.f);
        }
    #endif

    return output;
}

float4 ps_edge (vertex_out i) : SV_TARGET
{
    float2 uv = i.coord0.xy;
    float4 diffuse = _OutlineTexture.Sample(sampler_OutlineTexture, uv);
    float4 color = (_UseMainTex) ? diffuse * _OutlineColor :  _OutlineColor;
    color.w = 1.f;
    if(_Outline == 0) clip(-1);
    if(_MaterialType == 2) clip(-1); 
    return color;
}

