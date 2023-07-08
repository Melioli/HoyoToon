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

    // material = 5;
    return material;
}

float shadow_rate(float ndotl, float lightmap_ao, float vertex_ao, float shadow_ramp)
{
    float shadow_ndotl  = ndotl * 0.5f + 0.5f;
    float shadow_thresh = (lightmap_ao + lightmap_ao) * vertex_ao;
    float shadow_area   = min(1.0f, dot(shadow_ndotl.xx, shadow_thresh.xx));
    shadow_area = max(0.001f, shadow_area) * 0.85f + 0.15f;
    shadow_area = (shadow_area > shadow_ramp) ? 0.99f : shadow_area;
    return shadow_area;
}

float shadow_rate_face(float facemap, float facemap_mirror)
{
    // head directions
    float3 head_forward = normalize(UnityObjectToWorldDir(_headForwardVector.xyz));
    float3 head_right   = normalize(UnityObjectToWorldDir(_headRightVector.xyz));
    
    float2 light_dir = normalize(_WorldSpaceLightPos0.xz);
    // get dot products of each head direction and the lightDir
    half FdotL = dot(light_dir, head_forward.xz);
    half RdotL = dot(light_dir, head_right.xz);
    // remap both dot products from { -1, 1 } to { 0, 1 } and invert
    RdotL = RdotL * 0.5 + 0.5;
    FdotL = 1 - (FdotL * 0.5 + 0.5);
    // get direction of lightmap based on RdotL being above 0.5 or below
    float lightmapDir = (RdotL <= 0.5) ? facemap_mirror : facemap;
    
    // use FdotL to drive the face SDF, make sure FdotL has a maximum of 0.999 so that it doesn't glitch
    half shadow_range = min(0.999, FdotL);
    shadow_range = pow(shadow_range, pow(1, 3));
    // finally drive faceFactor
    half face_factor = smoothstep(shadow_range - 0.001, shadow_range + 0.001, lightmapDir);
    // use FdotL once again to lerp between shaded and lit for the mouth area
    // faceFactor = faceFactor + facemapTex.w * (1 - FdotL); // this isnt necessary since in game they actually have shadows
    // the thing is that its harder to notice since it uses multiple materials

    // litFactor = 1.0 - faceFactor;

    return face_factor;

}

/* 
float shadow_right = (tex2D(_FaceMapTex, float2(      uv.x, uv.y)).a); 
    float shadow_left  = (tex2D(_FaceMapTex, float2(1.0 - uv.x, uv.y)).a);
    float ao = tex2D(_LightMapTex, uv).y;

    float3 head_forward = normalize(UnityObjectToWorldDir(_headForward.xyz));
    float3 head_right = normalize(UnityObjectToWorldDir(_headRight.xyz));

    float rdotl = dot((head_right.xz), -normalize(_WorldSpaceLightPos0.xyz));
    float fdotl = dot((head_forward.xz), -normalize(_WorldSpaceLightPos0.xyz));

    float shadow = 1.0;

    if (rdotl > 0) {
        shadow = shadow_left;
    } else {
        shadow = shadow_right;
    }

    float shadow_step = step(abs(rdotl), ((shadow)));
    float facing_step = step(fdotl, 0);

    return shadow_step * facing_step * ao;
    */

float3 specular_base(float shadow_area, float ndoth, float lightmap_spec, float3 specular_color, float3 specular_values, float3 specular_color_global, float specular_intensity_global)
{
    float3 specular = ndoth;
    specular = pow(max(specular, 0.01f), specular_values.x);

    float specular_thresh = 1.0f - lightmap_spec;
    float rough_thresh = specular_thresh - specular_values.y;
    specular_thresh = (specular_values.y + specular_thresh) - rough_thresh;
    specular = shadow_area * specular - rough_thresh; 
    specular_thresh = saturate((1.0f / specular_thresh) * specular);
    specular = (specular_thresh * - 2.0f + 3.0f) * pow(specular_thresh, 2.0f);
    specular = (specular_color * specular_color_global) * specular *(specular_values.z * specular_intensity_global);
    return specular;
}

