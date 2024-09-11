Shader "Hidden/HoyoToon/Post Processing"
{
    Properties
    {
        _MainTex ("", 2D) = "white" {}
    }
    HLSLINCLUDE
    //variables and textures 

    int _LayerMask;

    float _BloomMode;
    float _BloomThreshold;
    float _BloomIntensity;
    float4 _BloomWeights;
    float4 _BloomColor;
    float _BloomScalar;
    float _BlurWeight;
    float _UseTonemap;
    float _Exposure;
    float _Contrast;
    float _Saturation;
    
    float _ACESParamA;
    float _ACESParamB;
    float _ACESParamC;
    float _ACESParamD;
    float _ACESParamE;

    Texture2D _MainTex;
    SamplerState sampler_MainTex; 
    float4 _MainTex_TexelSize;

    Texture2D _RenderTarget;
    SamplerState sampler_RenderTarget;

    Texture2D _BloomTexturePre;
    Texture2D _BloomTextureA;
    Texture2D _BloomTextureB;
    Texture2D _BloomTextureC;
    Texture2D _BloomTextureD;
    Texture2D _BloomTextureUp;


    SamplerState sampler_BloomTexturePre;
    SamplerState sampler_BloomTextureA;
    SamplerState sampler_BloomTextureB;
    SamplerState sampler_BloomTextureC;
    SamplerState sampler_BloomTextureD;
    SamplerState sampler_BloomTextureUp;

    #include "UnityCG.cginc"


    const static int kernelSize = 9;
    const static float kernelOffsets[9] = 
    {
        -4.0,
        -3.0,
        -2.0,
        -1.0,
        0.0,
        1.0,
        2.0,
        3.0,
        4.0,
    };
    const static float kernel[9] = 
    {
        0.01621622,
        0.05405405,
        0.12162162,
        0.19459459,
        0.22702703,
        0.19459459,
        0.12162162,
        0.05405405,
        0.01621622
    };

    // since urp functions arent available to birp shaders, writing them myself...
    #define ACEScc_MIDGRAY  0.4135884    

    float3 LogCToLinear(float3 x)
    {
        return (pow(10.0f, (x - 0.386036f) / (0.244161f)) - 0.047996f) / 5.555556f;
    }

    float3 LinearToLogC(float3 x)
    {
        return 0.244161f * log10(5.555556f * x + 0.047996f) + 0.386036f;
    }
    

    float3 newTonemap(float3 color, float3 bloom)
    {
        float3 final = color + bloom;

        float3x3 whiteBalanceMatrix = 
        {
            float3(1.00032, -0.00002, 0.00002),
            float3(0.0004, 0.99977, 0.00008),
            float3(-0.00002, -0.00002, 1.00058)
        };

        final = mul(whiteBalanceMatrix, final);

        final = final * _Exposure;
        float3 f0 = (1.36 * final + 0.047) * final;
        float3 f1 = (0.93 * final + 0.56) * final + 0.14;
        final =  saturate(f0 / f1);
        return final;
    }


    float3 CustomACESTonemapping(float3 x)
    {
        float3 u = _ACESParamA * x + _ACESParamB;
        float3 v = _ACESParamC * x + _ACESParamD;
        return saturate((x * u) / (x * v + _ACESParamE));
    }

    float _BlurSamples;
    static float pi = 3.1415926;
    static int samples = _BlurSamples;
    static float sigma = (float)samples * 0.25;
    static float s = 2 * sigma * sigma; 

    float gauss(float2 i)
    {
        return exp(-(i.x * i.x + i.y * i.y) / s) / (pi * s);
    }

    float3 gaussianBlur(SamplerState sp, Texture2D tx,  float2 uv, float2 scale)
    {
        float3 pixel = (float3)0.0f;
        float weightSum = 0.0f;
        float weight;
        float2 offset;


        for(int i = -samples / 2; i < samples / 2; i++)
        {
            for(int j = -samples / 2; j < samples / 2; j++)
            {
                offset = float2(i, j);
                weight = gauss(offset);
                pixel += tx.Sample(sp, float4(uv + scale * offset, 0.0f, 1.0f)).rgb * weight;
                weightSum += weight;
            }
        }
        return saturate(pixel / weightSum);
    }

    // basic vertex program and structs since they will all use the same ones : 
    struct VertexData {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
    };

    struct v2f {
        float2 uv : TEXCOORD0;
        float4 vertex : SV_POSITION;
    };

    v2f vp(VertexData v) {
        v2f o;
        o.vertex = UnityObjectToClipPos(v.vertex);
        o.uv = v.uv;
        return o;
    }

    float4 fp_pre(v2f i) : SV_TARGET
    {
        float2 uv = (i.uv);
        float4 color = _MainTex.Sample(sampler_MainTex, uv);

        if(_BloomMode == 2) // if bloom mode is set to brightness
        {
            float3 brightness = max(max(color.x, color.y), color.z);
            color.xyz = color.xyz * saturate(brightness - _BloomThreshold);
        }
        else if(_BloomMode == 1) // if bloom mode is set to color
        {
            color.xyz = max((color.xyz) - _BloomThreshold, 0.0f);
        }

        return color * _BloomScalar;
    }

    float4 fp_tone(v2f i) : SV_TARGET
    {
        // initialize inputs : 
        float2 uv = i.uv;
        float4 original = _RenderTarget.Sample(sampler_RenderTarget, uv);

        float4 toned = (float4)1.0f;
        toned.xyz = original;

        float3 bloom = 0.0f;

        if(_BloomMode > 0 && !(_UseTonemap == 3)) 
        {
            bloom = gaussianBlur(sampler_BloomTexturePre, _BloomTexturePre, uv, _BlurWeight * _MainTex_TexelSize);
            bloom = (bloom * _BloomIntensity) * _BloomColor;
            // toned.xyz = toned.xyz + bloom;
        }

        if(_UseTonemap != 3 )
        {
            toned.xyz = newTonemap(toned.xyzw, bloom);
        }
        else if(_UseTonemap == 3)
        {
            toned.xyz = toned.xyz * _Exposure;
            toned.xyz = CustomACESTonemapping(toned.xyz);
            if(_BloomMode > 0) 
            {
                bloom = gaussianBlur(sampler_BloomTexturePre, _BloomTexturePre, uv, _BlurWeight * _MainTex_TexelSize);
                bloom = (bloom * _BloomIntensity) * _BloomColor;
                toned.xyz = toned.xyz + bloom;
            }
            float3 colorLog = LinearToLogC(toned.xyz);
            colorLog = lerp(ACEScc_MIDGRAY, colorLog, _Contrast);
            toned.xyz = LogCToLinear(colorLog);
            float3 luma = dot(toned.xyz, float3(0.2126f, 0.7152f, 0.0722f));
            toned.xyz = lerp(luma, toned, _Saturation);
        }

        

        toned.w = original.w;

        return toned;
    }

    float4 fp_final(v2f i) : SV_TARGET
    {
        return _RenderTarget.Sample(sampler_RenderTarget, i.uv);
    }
    ENDHLSL

    Subshader
    {
        Pass
        {
            Name "Bloom Prefilter"
            HLSLPROGRAM
            #pragma vertex vp
            #pragma fragment fp_pre
            ENDHLSL
        }

        Pass
        {
            Name "Color Grading"
            HLSLPROGRAM
            #pragma vertex vp
            #pragma fragment fp_tone
            ENDHLSL
        }
    }
}