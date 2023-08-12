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
    // copied from the genshin shader because fuck trying to port my mmd method
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

    return face_factor;
}

float3 specular_base(float shadow_area, float ndoth, float lightmap_spec, float3 specular_color, float3 specular_values, float3 specular_color_global, float specular_intensity_global)
{
    float3 specular = ndoth;
    specular = pow(max(specular, 0.01f), specular_values.x);
    specular_values.y = max(specular_values.y, 0.001f);

    float specular_thresh = 1.0f - lightmap_spec;
    float rough_thresh = specular_thresh - specular_values.y;
    specular_thresh = (specular_values.y + specular_thresh) - rough_thresh;
    specular = shadow_area * specular - rough_thresh; 
    specular_thresh = saturate((1.0f / specular_thresh) * specular);
    specular = (specular_thresh * - 2.0f + 3.0f) * pow(specular_thresh, 2.0f);
    specular = (specular_color * specular_color_global) * specular *(specular_values.z * specular_intensity_global);
    return specular;
}

float4 rim_light_calc(float3 normal)
{
     
}

// =============================================================================================================== //
// LIGHTING SPECIFIC 


// Took this from primotoon because aint no way in hell im doing it myself if it already works in the genshin shader
// environment lighting function
float4 get_enviro_light(float3 ws_pos)
{
    // get all the point light positions
    half3 firstPointLightPos = { unity_4LightPosX0.x, unity_4LightPosY0.x, unity_4LightPosZ0.x };
    half3 secondPointLightPos = { unity_4LightPosX0.y, unity_4LightPosY0.y, unity_4LightPosZ0.y };
    half3 thirdPointLightPos = { unity_4LightPosX0.z, unity_4LightPosY0.z, unity_4LightPosZ0.z };
    half3 fourthPointLightPos = { unity_4LightPosX0.w, unity_4LightPosY0.w, unity_4LightPosZ0.w };

    // get all the point light attenuations
    half firstPointLightAtten = 2 * rsqrt(unity_4LightAtten0.x);
    half secondPointLightAtten = 2 * rsqrt(unity_4LightAtten0.y);
    half thirdPointLightAtten = 2 * rsqrt(unity_4LightAtten0.z);
    half fourthPointLightAtten = 2 * rsqrt(unity_4LightAtten0.w);

    // first, get the distance between each vertex and all of the point light positions,
    // then invert the result and apply attenuation, saturate to prevent my guy from glowing
    // lastly, multiply it to the corresponding light's color
    half3 firstPointLight = saturate(lerp(1, 0, distance(ws_pos, firstPointLightPos) - 
                                      firstPointLightAtten)) * unity_LightColor[0];
    half3 secondPointLight = saturate(lerp(1, 0, distance(ws_pos, secondPointLightPos) - 
                                       secondPointLightAtten)) * unity_LightColor[1];
    half3 thirdPointLight = saturate(lerp(1, 0, distance(ws_pos, thirdPointLightPos) - 
                                      thirdPointLightAtten)) * unity_LightColor[2];
    half3 fourthPointLight = saturate(lerp(1, 0, distance(ws_pos, thirdPointLightPos) - 
                                       fourthPointLightAtten)) * unity_LightColor[3];

    // THIS COULD USE SOME IMPROVEMENTS, I DON'T KNOW HOW TO DISABLE THIS FOR SPOT LIGHTS
    // compare with all of the other point lights
    half3 pointLightCalc = firstPointLight;
    pointLightCalc = max(pointLightCalc, secondPointLight);
    pointLightCalc = max(pointLightCalc, thirdPointLight);
    pointLightCalc = max(pointLightCalc, fourthPointLight);

    // get the color of whichever's greater between the light direction and the strongest nearby point light
    float4 environmentLighting = max(_LightColor0, fixed4(pointLightCalc, 1));
    // now get whichever's greater than the result of the first and the nearest light probe
    half3 ShadeSH9Alternative = half3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w) + 
                                          half3(unity_SHBr.z, unity_SHBg.z, unity_SHBb.z) / 3.0;
    //environmentLighting = max(environmentLighting, fixed4(ShadeSH9(vector<half, 4>(0, 0, 0, 1)), 1));
    environmentLighting = max(environmentLighting, fixed4(ShadeSH9Alternative, 1));

    return environmentLighting;
}