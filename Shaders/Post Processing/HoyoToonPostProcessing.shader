Shader "Hidden/HoyoToon/Post Processing"
{
    Properties
    {
        _MainTex ("", 2D) = "white" {}
    }
    HLSLINCLUDE
    //variables and textures 

    float _BloomMode;
    float _BloomThreshold;
    float _BloomIntensity;
    float4 _BloomWeights;
    float4 _BloomColor;
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
    const static float kernelOffsets[9] = {
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
    const static float kernel[9] = {
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
    
    // functions : 
    float3 tonemap(float3 color)
    {
        float3 c0 = (1.36 * color + 0.047) * color;
        float3 c1 = (0.93 * color + 0.56) * color + 0.14;
        return saturate(c0 / c1);
    }



    float3 CustomACESTonemapping(float3 x)
    {
        float3 u = _ACESParamA * x + _ACESParamB;
        float3 v = _ACESParamC * x + _ACESParamD;
        return saturate((x * u) / (x * v + _ACESParamE));
    }

    static const float e = 2.71828f;

	float W_f(float x,float e0,float e1) {
		if (x <= e0)
			return 0;
		if (x >= e1)
			return 1;
		float a = (x - e0) / (e1 - e0);
		return a * a*(3.0f - 2.0f * a);
	}
	float H_f(float x, float e0, float e1) {
		if (x <= e0)
			return 0;
		if (x >= e1)
			return 1;
		return (x - e0) / (e1 - e0);
	}

	float GranTurismoTonemapper(float x) {
		float P = 1.f;
		float a = 1.f;
		float m = 0.22f;
		float l = 0.4f;
		float c = 1.33f;
		float b = 0.f;
		float l0 = (P - m)*l / a;
		float L0 = m - m / a;
		float L1 = m + (1.f - m) / a;
		float L_x = m + a * (x - m);
		float T_x = m * pow(x / m, c) + b;
		float S0 = m + l0;
		float S1 = m + a * l0;
		float C2 = a * P / (P - S1);
		float S_x = P - (P - S1)*pow(e,-(C2*(x-S0)/P));
		float w0_x = 1 - W_f(x, 0.f, m);
		float w2_x = H_f(x, m + l0, m + l0);
		float w1_x = 1 - w0_x - w2_x;
		float f_x = T_x * w0_x + L_x * w1_x + S_x * w2_x;
		return f_x;
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
            color.xyz = max(color.xyz - _BloomThreshold, 0.0f);
        }

        return color;
    }

    float4 fp_hora(v2f i) : SV_TARGET
    {
        float2 uv = (i.uv);
        float2 offset = _BlurWeight * _MainTex_TexelSize * float2(1.0f, 0.0); 
        half4 color = 0.0;

        [unroll]
        for (int i = 0; i < kernelSize; i++)
        {
            float2 sampleUV = uv + kernelOffsets[i] * offset;
            color += kernel[i] * _MainTex.Sample(sampler_MainTex, sampleUV);
        }

        return color;
    }
    
    float4 fp_horb(v2f i) : SV_TARGET
    {
        float2 uv = (i.uv);
        float2 offset = _BlurWeight * _MainTex_TexelSize * float2(2.0f, 0.0); 
        half4 color = 0.0;
        [unroll]
        for (int i = 0; i < kernelSize; i++)
        {
            float2 sampleUV = uv + kernelOffsets[i] * offset;
            color += kernel[i] * _MainTex.Sample(sampler_MainTex, sampleUV);
        }

        return color;
    }

    float4 fp_vera(v2f i) : SV_TARGET
    {
        float2 uv = (i.uv);
        float2 offset = _BlurWeight * _MainTex_TexelSize * float2(0.0f, 1.0); 
        half4 color = 0.0;

        [unroll]
        for (int i = 0; i < kernelSize; i++)
        {
            float2 sampleUV = uv + kernelOffsets[i] * offset;
            color += kernel[i] * _MainTex.Sample(sampler_MainTex, sampleUV);
        }

        return color;
    }

    float4 fp_verb(v2f i) : SV_TARGET
    {
        float2 uv = (i.uv);
        float2 offset = _BlurWeight * _MainTex_TexelSize * float2(0.0f, 2.0); 
        half4 color = 0.0;
        [unroll]
        for (int i = 0; i < kernelSize; i++)
        {
            float2 sampleUV = uv + kernelOffsets[i] * offset;
            color += kernel[i] * _MainTex.Sample(sampler_MainTex, sampleUV);
        }

        return color;
    }

    float4 fp_up(v2f i) : SV_TARGET
    {
        float2 uv = i.uv;
        float4 color = (float4)0.0f;

        color = color + _BloomTextureA.Sample(sampler_BloomTextureA, uv) * _BloomWeights.x;
        color = color + _BloomTextureB.Sample(sampler_BloomTextureB, uv) * _BloomWeights.y;
        color = color + _BloomTextureC.Sample(sampler_BloomTextureC, uv) * _BloomWeights.z;
        color = color + _BloomTextureD.Sample(sampler_BloomTextureD, uv) * _BloomWeights.w;
        
        return color;
    }

    float4 fp_tone(v2f i) : SV_TARGET
    {
        // initialize inputs : 
        float2 uv = i.uv;
        float4 original = _RenderTarget.Sample(sampler_RenderTarget, uv);

        float4 toned = (float4)1.0f;
        toned.xyz = original;

        if(_BloomMode > 0 && !(_UseTonemap == 3)) 
        {
            float3 bloomed = _BloomTextureUp.Sample(sampler_BloomTextureUp, uv);
            bloomed = bloomed * _BloomIntensity * _BloomColor;
            toned.xyz = toned.xyz + bloomed;
        }

        toned.xyz = toned.xyz * _Exposure;

        if(_UseTonemap == 2) 
        {
            toned.xyz = tonemap(toned.xyz);
        }
        else if(_UseTonemap == 1)
        {
            toned.xyz = float3(GranTurismoTonemapper(toned.x), GranTurismoTonemapper(toned.y), GranTurismoTonemapper(toned.z));
        }
        else if(_UseTonemap == 3)
        {
            toned.xyz = CustomACESTonemapping(toned.xyz);
            if(_BloomMode > 0) 
            {
                float3 bloomed = _BloomTextureUp.Sample(sampler_BloomTextureUp, uv);
                bloomed = bloomed * _BloomIntensity * _BloomColor;
                toned.xyz = toned.xyz + bloomed;
            }
        }

        
        float3 colorLog = LinearToLogC(toned.xyz);
        colorLog = lerp(ACEScc_MIDGRAY, colorLog, _Contrast);
        toned.xyz = LogCToLinear(colorLog);
        

        float3 luma = dot(toned.xyz, float3(0.2126f, 0.7152f, 0.0722f));
        toned.xyz = lerp(luma, toned, _Saturation);

        toned.w = original.w;

        return toned;
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
            Name "Bloom Horizontal A"
            HLSLPROGRAM
            #pragma vertex vp
            #pragma fragment fp_hora
            ENDHLSL
        }

        Pass
        {
            Name "Bloom Horizontal B"
            HLSLPROGRAM
            #pragma vertex vp
            #pragma fragment fp_horb
            ENDHLSL
        }

        Pass
        {
            Name "Bloom Vertical A"
            HLSLPROGRAM
            #pragma vertex vp
            #pragma fragment fp_vera
            ENDHLSL
        }

        Pass
        {
            Name "Bloom Vertical B"
            HLSLPROGRAM
            #pragma vertex vp
            #pragma fragment fp_verb
            ENDHLSL
        }

        Pass
        {
            Name "Bloom Upsample"
            HLSLPROGRAM
            #pragma vertex vp
            #pragma fragment fp_up
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