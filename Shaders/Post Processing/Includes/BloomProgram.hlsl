// -------------------------------------------------------------------------------------------------
// This is the main vertex shader for the entire image effect, its used for all passes:
v2f vert (appdata v)
{
    v2f o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.uv0 = v.vertex.xy;
    return o;
}

// -------------------------------------------------------------------------------------------------
// This is the first pass, it takes the downsized original texture and prefilters it for the bloom effect:
float4 ps_downsample_pre (v2f i) : SV_Target
{
    float4 col = sample_bloom_texture(_OriginalTexture, sampler_linear_clamp, i.uv0, _MainTex_TexelSize);
    col = prefilter(col);
    // col.a = 1.0;
    return col;
}

// -------------------------------------------------------------------------------------------------
// These next two passes are the horizontal and verteical blur passes. 
float4 ps_bloom_blur_h (v2f i) : SV_Target
{
    float4 col = bloom_blur_h(_PreFilter, sampler_linear_clamp, i.uv0, _PreFilter_TexelSize);
    // col.a = 1.0;
    return col;
}

float4 ps_bloom_blur_v (v2f i) : SV_Target
{
    float4 col = bloom_blur_v(_BloomH, sampler_linear_clamp, i.uv0, _PreFilter_TexelSize);
    // col.a = 1.0;
    return col;
}

// -------------------------------------------------------------------------------------------------
// the first quadrant of the bloom atlas is done here, these are both the blur passes since the bloom atlas needs to be blurred itteratively: 

// the atlas a passes are for the first quadrant of the bloom atlas
float4 ps_bloom_atlas_a_h (v2f i) : SV_Target
{
    float4 col = bloom_blur_a(_BloomV, sampler_linear_clamp, i.uv0, _BloomV_TexelSize, float2(1, 0));
    // col.a = 1.0;
    return col;
}

float4 ps_bloom_atlas_a_v (v2f i) : SV_Target
{
    float4 col = bloom_blur_a(_BloomAH, sampler_linear_clamp, i.uv0, _BloomAH_TexelSize, float2(0, 1));
    // col.a = 1.0;
    return col;
}

// -------------------------------------------------------------------------------------------------
// the second quadrant of the bloom atlas

// the atlas b passes are for the second quadrant of the bloom atlas
float4 ps_bloom_atlas_b_h (v2f i) : SV_Target
{
    float4 col = bloom_blur_b(_BloomAV, sampler_linear_clamp, i.uv0, _BloomAV_TexelSize, float2(1, 0));
    // col.a = 1.0;
    return col;
}

float4 ps_bloom_atlas_b_v (v2f i) : SV_Target
{
    float4 col = bloom_blur_b(_BloomBH, sampler_linear_clamp, i.uv0, _BloomBH_TexelSize, float2(0, 1));
    // col.a = 1.0;
    return col;
}

// -------------------------------------------------------------------------------------------------
// the third quadrant of the bloom atlas
// the atlas c passes are for the third quadrant of the bloom atlas
float4 ps_bloom_atlas_c_h (v2f i) : SV_Target
{
    float4 col = bloom_blur_c(_BloomBV, sampler_linear_clamp, i.uv0, _BloomBV_TexelSize, float2(1, 0));
    // col.a = 1.0;
    return col;
}

float4 ps_bloom_atlas_c_v (v2f i) : SV_Target
{
    float4 col = bloom_blur_c(_BloomCH, sampler_linear_clamp, i.uv0, _BloomCH_TexelSize, float2(0, 1));
    // col.a = 1.0;
    return col;
}

// // -------------------------------------------------------------------------------------------------
// // This pass combines the 3 bloom quadrant textures into a single texture. 
// float4 ps_bloom_atlas_combine(v2f i) : SV_Target
// {
//     float2 uv = i.uv0;
//     float4 final = float4(0, 0, 0, 0);
//     float2 scalar = float2(1, 1);

//     // tmpA
//     if (uv.y < 0.53797)
//     {
//         float2 scaledUV = float2(uv.x, uv.y / 0.53797);
//         if ((scaledUV.x < 1) && (scaledUV.y < 1)) final = sample_texture(sampler_linear_clamp, _BloomAV, scaledUV);
//     }
//     // tmpB
//     else if (uv.y < 0.53797 + 0.31646)
//     {
//         float2 scaledUV = float2((uv.x) / 0.58553, (uv.y - (0.53797)) / (0.31646));
//         if ((scaledUV.x < 1) && (scaledUV.y < 1)) final = sample_texture(sampler_linear_clamp, _BloomBV, scaledUV);
//     }
//     // tmpC
//     else
//     {
//         float2 scaledUV = float2((uv.x) / 0.23684, (uv.y - (0.86076)) / (0.12658));
//         if ((scaledUV.x < 1) && (scaledUV.y < 1)) final = sample_texture(sampler_linear_clamp, _BloomCV, scaledUV);
//     }

//     final.a = 1.0;
//     return final;
// }

// -------------------------------------------------------------------------------------------------
// Then we take the combined bloom atlas and then the original prefilter texture and combine them together to create the final bloom image:
float4 ps_bloom_combined(v2f i, uint layer : SV_RenderTargetArrayIndex) : SV_Target
{
    float4 pre = sample_texture(sampler_linear_clamp, _PreFilter, i.uv0) * _BlurLevelWeights.xxxx;

    // sample each of the quadrants of the bloom atlas so they are centered on the screen, effectively undoing the atlas formation
    float4 bloom = sample_texture(sampler_linear_clamp, _BloomCV, i.uv0);
    pre = bloom * _BlurLevelWeights.yyyy + pre;
    pre = bloom * _BlurLevelWeights.zzzz + pre;
    pre = bloom * _BlurLevelWeights.wwww + pre;
    // combine the quadrants together to form the final bloom image
    float4 final = pre;
    // final.a = 1.0;
    return final;
}

float4 ps_tone_mapping(v2f i) : SV_Target
{   
    // float4 col = sample_texture(sampler_linear_clamp, _HDRTexture, i.uv0);
    float4 col = sharpening(_HDRTexture, sampler_linear_clamp, i.uv0, _Sharpening);
    col.xyz = vignette(col, i.uv0);
    float4 bloom = sample_texture(sampler_linear_clamp, _MHYBloomTex, i.uv0);
    float4 final = col;
    if(_GameType == 1.0f)
    {
        col = col * 0.95f;
        final = tone_mapping(col, bloom, i.uv0, 1.0);

        float3x3 whiteBalanceMatrix = float3x3(
            1.0,0.021,-0.019,
            0.001,1.03999996,0.00999999978,
            -0.0,-0.00,0.951
        );
        float3 balanced = mul(whiteBalanceMatrix, final.rgb);   

        if(_UseBalance) final.xyz = balanced;
    }
    else if(_GameType == 2.0f)
    {
        final = tone_mapping_star_rail(col, bloom, i.uv0);
    }
     else if(_GameType == 3.0f)
    {
        final = tone_mapping_star_rail(col, bloom, i.uv0);
    }

    float layerValue = sample_texture(sampler_LayerTex, _LayerTex, i.uv0).r;
    bool isIncluded = layerValue > 0;

    return isIncluded ? final : col;
}

float4 ps_white_balance(v2f i) : SV_Target
{
    float4 col = sample_texture(sampler_linear_clamp, _MainTex, i.uv0);
    // col.xyz = col.xyz;
    // float3 balanced = col;

    // float3x3 whiteBalanceMatrix = float3x3(
    //     1.0,0.021,-0.019,
    //     0.001,1.03999996,0.00999999978,
    //     -0.0,-0.00,0.951
    // );
    // balanced.rgb = mul(whiteBalanceMatrix, balanced.rgb);   

    // if(_UseBalance) col.xyz = balanced;
    
    float layerValue = sample_texture(sampler_LayerTex, _LayerTex, i.uv0).r;
    bool isIncluded = layerValue > 0;

    return isIncluded ? col : sample_texture(sampler_linear_clamp, _MainTex, i.uv0);
}
