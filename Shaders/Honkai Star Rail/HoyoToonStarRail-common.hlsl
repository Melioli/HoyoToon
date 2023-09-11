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

// https://github.com/cnlohr/shadertrixx/blob/main/README.md#detecting-if-you-are-on-desktop-vr-camera-etc
bool isVR(){
    // USING_STEREO_MATRICES
    #if UNITY_SINGLE_PASS_STEREO
        return true;
    #else
        return false;
    #endif
}

// =============================================================================================================== //
// LIGHTING SPECIFIC 


// originally i was using something from primotoon but the point light attenuation fall of was being calcuated wrong
// so i had to do it myself :(
float4 get_enviro_light(float3 ws_pos)
{
   // get all the point light positions
    float4 lightX = unity_4LightPosX0 - ws_pos.x;
    float4 lightY = unity_4LightPosY0 - ws_pos.y;
    float4 lightZ = unity_4LightPosZ0 - ws_pos.z;
    float4 lengthSq = (float4)0.0f;
    lengthSq = lengthSq + (lightX * lightX);
    lengthSq = lengthSq + (lightY * lightY);
    lengthSq = lengthSq + (lightZ * lightZ);
    lengthSq = max(lengthSq, 0.000001f);
    float4 range = 5.0f * (1.0f / sqrt(unity_4LightAtten0));
    float4 attenUV = sqrt(lengthSq) / range;
    float4 atten = saturate(1.0f / (1.0f + 25.0f * attenUV * attenUV) * saturate((1.0f - attenUV) * 5.0f));
    atten.x = lerp(1.0f, 0.0f, atten.x);
    atten.y = lerp(1.0f, 0.0f, atten.y);
    atten.z = lerp(1.0f, 0.0f, atten.z);
    atten.w = lerp(1.0f, 0.0f, atten.w);
    float3 firstcolor  = lerp(unity_LightColor[0].xyz, 0.0f, atten.x);
    float3 secondcolor = lerp(unity_LightColor[1].xyz, 0.0f, atten.y);
    float3 thirdcolor  = lerp(unity_LightColor[2].xyz, 0.0f, atten.z);
    float3 fourthcolor = lerp(unity_LightColor[3].xyz, 0.0f, atten.w);
    float3 pointlight = firstcolor;
    pointlight = max(pointlight, secondcolor);
    pointlight = max(pointlight, thirdcolor);
    pointlight = max(pointlight, fourthcolor);
    float3 light =  max(_LightColor0, float4(pointlight, 1.0f));
    half3 ShadeSH9Alternative = half3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w) + half3(unity_SHBr.z, unity_SHBg.z, unity_SHBb.z) / 3.0;
    light = max(light, ShadeSH9Alternative);         
    return float4(light, 1.0f);
}