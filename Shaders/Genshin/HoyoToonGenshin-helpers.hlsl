/* helper functions */

// light fallback
half4 getlightDir(){
    half4 lightDir = (_WorldSpaceLightPos0 != 0) ? _WorldSpaceLightPos0 :
                               half4(0, 0, 0, 0) + half4(1, 1, 0, 0);
    return lightDir;
}

// map range function
float mapRange(const float min_in, const float max_in, const float min_out, const float max_out, const float value){
    float slope = (max_out - min_out) / (max_in - min_in);
    
    return min_out + slope * (value - min_in);
}

float lerpByZ(const float startScale, const float endScale, const float startZ, const float endZ, const float z){
   float t = (z - startZ) / max(endZ - startZ, 0.001);
   t = saturate(t);
   return lerp(startScale, endScale, t);
}

// environment lighting function
fixed4 calculateEnvLighting(float3 vertexWSInput){
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
    half3 firstPointLight = saturate(lerp(1, 0, distance(vertexWSInput, firstPointLightPos) - 
                                      firstPointLightAtten)) * unity_LightColor[0];
    half3 secondPointLight = saturate(lerp(1, 0, distance(vertexWSInput, secondPointLightPos) - 
                                       secondPointLightAtten)) * unity_LightColor[1];
    half3 thirdPointLight = saturate(lerp(1, 0, distance(vertexWSInput, thirdPointLightPos) - 
                                      thirdPointLightAtten)) * unity_LightColor[2];
    half3 fourthPointLight = saturate(lerp(1, 0, distance(vertexWSInput, thirdPointLightPos) - 
                                       fourthPointLightAtten)) * unity_LightColor[3];

    // THIS COULD USE SOME IMPROVEMENTS, I DON'T KNOW HOW TO DISABLE THIS FOR SPOT LIGHTS
    // compare with all of the other point lights
    half3 pointLightCalc = firstPointLight;
    pointLightCalc = max(pointLightCalc, secondPointLight);
    pointLightCalc = max(pointLightCalc, thirdPointLight);
    pointLightCalc = max(pointLightCalc, fourthPointLight);

    // get the color of whichever's greater between the light direction and the strongest nearby point light
    fixed4 environmentLighting = max(_LightColor0, fixed4(pointLightCalc, 1));
    // now get whichever's greater than the result of the first and the nearest light probe
    half3 ShadeSH9Alternative = half3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w) + 
                                          half3(unity_SHBr.z, unity_SHBg.z, unity_SHBb.z) / 3.0;
    //environmentLighting = max(environmentLighting, fixed4(ShadeSH9(half4(0, 0, 0, 1)), 1));
    environmentLighting = max(environmentLighting, fixed4(ShadeSH9Alternative, 1));

    return environmentLighting;
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

float3 calculateRimLight(float3 normal, float4 screenpos, float4 ws_pos, float rimint, float2 rimwidth, float factor)
{

    float3 vs_normal = mul(UNITY_MATRIX_V, float4(normal, 0.0f));
    float2 screen_pos = screenpos.xy / screenpos.w;
    float3 wvp_pos = mul(UNITY_MATRIX_VP, ws_pos).xyz;
    // in order to hide any weirdness at far distances, fade the rim by the distance from the camera
    float camera_dist = saturate(1.0f / distance(_WorldSpaceCameraPos.xyz, ws_pos));

    // multiply the rim widht material values by the lightmap red channel
    float rim_width = rimwidth;
    
    // sample depth texture, this will be the base
    float org_depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, screen_pos.xy));

    float2 offset_uv = vs_normal.xy * (float2)0.002f + screen_pos.xy;


    float offset_depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, offset_uv.xy));

    float rim_depth = -org_depth + offset_depth;
    // rim_depth = pow(rim_depth, 1.0); 
    rim_depth = smoothstep(0.0f, rimwidth, rim_depth);



    float3 rim_light = rim_depth ;
    // float3 rim_light = rim_side;
    return rim_light;
}

/* https://github.com/penandlim/JL-s-Unity-Blend-Modes/blob/master/John%20Lim's%20Blend%20Modes/CGIncludes/PhotoshopBlendModes.cginc */

// color dodge blend mode
fixed3 ColorDodge(const fixed3 s, const fixed3 d){
    return d / (1.0 - min(s, 0.999));
}

fixed4 ColorDodge(const fixed4 s, const fixed4 d){
    return fixed4(d.xyz / (1.0 - min(s.xyz, 0.999)), d.w);
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

// https://gist.github.com/Reedbeta/e8d3817e3f64bba7104b8fafd62906df
// THIS IS NOT SUPPOSED TO BE USED NORMALLY, THE ONLY REASON AS TO WHY THIS IS HERE IS BECAUSE
// MODEL RIPS CAN OCCASIONALLY BE IN .GLTF/.GLB FORMAT WHICH ENFORCES LINEAR VERTEX COLORS, WE
// CAN WORK AROUND THAT IN-SHADER THROUGH THESE FUNCTIONS
float3 sRGBToLinear(const float3 rgb){
  // See https://gamedev.stackexchange.com/questions/92015/optimized-linear-to-srgb-glsl
  return lerp(pow((rgb + 0.055) * (1.0 / 1.055), (float3)2.4),
              rgb * (1.0/12.92),
              rgb <= (float3)0.04045);
}

float3 LinearToSRGB(const float3 rgb){
  // See https://gamedev.stackexchange.com/questions/92015/optimized-linear-to-srgb-glsl
  return lerp(1.055 * pow(rgb, (float3)(1.0 / 2.4)) - 0.055,
              rgb * 12.92,
              rgb <= (float3)0.0031308);
}

float4 VertexColorConvertToLinear(const float4 input){
    return float4(sRGBToLinear(input.xyz),
                            input.w); // retain alpha
}

void calculateDissolve(out float3 input, float2 uvs, float factor){
    float buf2 = 1.0 - uvs.y;
    float buf = (_DissolveDirection_Toggle != 0.0) ? buf2 : uvs.y;
    buf = _WeaponDissolveValue * 2.1 + buf;
    float2 dissolveUVs = float2(uvs.x, buf - 1.0); // tmp1.xy

    fixed4 dissolveTex = _WeaponDissolveTex.Sample(sampler_WeaponDissolveTex, dissolveUVs);
    buf = dissolveTex * 3.0 * factor;
    buf = buf * 0.5 + dissolveTex.x;

    input = saturate(float3(buf.x, dissolveTex.y, 0.0));
}

// apache license: https://gitlab.com/s-ilent/filamented/-/blob/master/Filamented/SharedFilteringLib.hlsl
float4 cubic(float v){
    float4 n = float4(1.0, 2.0, 3.0, 4.0) - v;
    float4 s = n * n * n;
    float x = s.x;
    float y = s.y - 4.0 * s.x;
    float z = s.z - 4.0 * s.y + 6.0 * s.x;
    float w = 6.0 - x - y - z;
    return float4(x, y, z, w);
}

float4 SampleTexture2DBicubicFilter(Texture2D tex, SamplerState smp, float2 coord, const float4 texSize){
    coord = coord * texSize.xy - 0.5;
    float fx = frac(coord.x);
    float fy = frac(coord.y);
    coord.x -= fx;
    coord.y -= fy;

    float4 xcubic = cubic(fx);
    float4 ycubic = cubic(fy);

    float4 c = float4(coord.x - 0.5, coord.x + 1.5, coord.y - 0.5, coord.y + 1.5);
    float4 s = float4(xcubic.x + xcubic.y, xcubic.z + xcubic.w, ycubic.x + ycubic.y, ycubic.z + ycubic.w);
    float4 offset = c + float4(xcubic.y, xcubic.w, ycubic.y, ycubic.w) / s;

    float4 sample0 = tex.Sample(smp, float2(offset.x, offset.z) * texSize.zw);
    float4 sample1 = tex.Sample(smp, float2(offset.y, offset.z) * texSize.zw);
    float4 sample2 = tex.Sample(smp, float2(offset.x, offset.w) * texSize.zw);
    float4 sample3 = tex.Sample(smp, float2(offset.y, offset.w) * texSize.zw);

    float sx = s.x / (s.x + s.y);
    float sy = s.z / (s.z + s.w);

    return lerp(
        lerp(sample3, sample2, sx),
        lerp(sample1, sample0, sx), sy);
}
