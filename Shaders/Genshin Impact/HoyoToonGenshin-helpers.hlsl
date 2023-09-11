/* helper functions */

float3x3 CalcRotateMatrix(float3 vec) {
   float cosX,sinX;
   float cosY,sinY;
   float cosZ,sinZ;

   sincos(0.48 * vec.x,sinX,cosX);
   sincos(0.42 * vec.y,sinY,cosY);
   sincos(0.45 * vec.z,sinZ,cosZ);

   return float3x3(
      cosY * cosZ + sinX * sinY * sinZ,  cosY * sinZ - sinX * sinY * cosZ, cosX * sinY,
     -cosX * sinZ,                       cosX * cosZ,                      sinX, 
      sinX * cosY * sinZ - sinY * cosZ, -sinY * sinZ - sinX * cosY * cosZ, cosX * cosY
   );
}

// light fallback
half4 getlightDir(){
    half4 lightDir = (_WorldSpaceLightPos0 != 0) ? _WorldSpaceLightPos0 :
                               half4(0, 0, 0, 0) + half4(1, 1, 0, 0);
    return lightDir;
}

// from poiyomi, this is solely for the rim lgiht :DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
bool IsInMirror()
{
    return unity_CameraProjection[2][0] != 0.f || unity_CameraProjection[2][1] != 0.f;
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
    float4 lightX = unity_4LightPosX0 - vertexWSInput.x;
    float4 lightY = unity_4LightPosY0 - vertexWSInput.y;
    float4 lightZ = unity_4LightPosZ0 - vertexWSInput.z;
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
