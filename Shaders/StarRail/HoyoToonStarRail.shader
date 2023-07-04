Shader "HoyoToon/StarRail"
{
    Properties
    {
        [Enum(UnityEngine.Rendering.CullMode)] _CullMode ("Cull Mode", Float) = 2
        // main coloring 
        [NoScaleOffset]_MainTex ("Texture", 2D) = "white" {}
        _VertexShadowColor ("Vertex Shadow Color", Color) = (1, 1, 1, 1) // unsure of what this does yet for star rail
        _Color  ("Front Face Color", Color) = (1, 1, 1, 1)
        _BackColor ("Back Face Color", Color) = (1, 1, 1, 1)
        _EnvColor ("Env Color", Color) = (1, 1, 1, 1)
        _AddColor ("Env Color", Color) = (0, 0, 0, 0)
        [NoScaleOffset] _LightMap ("Light Map Texture", 2D) = "grey" {}
        // -------------------------------------------
        // normal map, dont know if star rail even uses these yet... 
        [Toggle] _UseNormalMap ("Use Normal Map", Float) = 0
        _NormalMap ("Normal Map Texture", 2D) = "bump" {}
        _NormalScale ("Normal Map Scale", Range(0, 4)) = 1
        // -------------------------------------------
        // shadow 
        [NoScaleOffset]_DiffuseRampMultiTex     ("Warm Shadow Ramp | 8 ramps", 2D) = "white" {} 
        [NoScaleOffset]_DiffuseCoolRampMultiTex ("Cool Shadow Ramp | 8 ramps", 2D) = "white" {}
        _ShadowRamp ("Shadow Ramp", Range(0.01, 1)) = 1
        [Toggle]_ShadowBoost ("Shadow Boost Enable", Float) = 0
        _ShadowBoostVal ("Shadow Boost Value", Range(0,1)) = 0
        // -------------------------------------------
        // specular 
        [Toggle]_AnisotropySpecular ("Anisotropic Specular", Float) = 0
        // --- specular color
        _SpecularColor0 ("Specular Color | (RGB ID = 0)", Color)   = (1,1,1,1)
        _SpecularColor1 ("Specular Color | (RGB ID = 31)", Color)  = (1,1,1,1)
        _SpecularColor2 ("Specular Color | (RGB ID = 63)", Color)  = (1,1,1,1)
        _SpecularColor3 ("Specular Color | (RGB ID = 95)", Color)  = (1,1,1,1)
        _SpecularColor4 ("Specular Color | (RGB ID = 127)", Color) = (1,1,1,1)
        _SpecularColor5 ("Specular Color | (RGB ID = 159)", Color) = (1,1,1,1)
        _SpecularColor6 ("Specular Color | (RGB ID = 192)", Color) = (1,1,1,1)
        _SpecularColor7 ("Specular Color | (RGB ID = 223)", Color) = (1,1,1,1)
        // --- specular shininess 
        _SpecularShininess0 ("Specular Shininess (Power) | (RGB ID = 0)", Range(0.1, 500))   = 10
        _SpecularShininess1 ("Specular Shininess (Power) | (RGB ID = 31)", Range(0.1, 500))  = 10
        _SpecularShininess2 ("Specular Shininess (Power) | (RGB ID = 63)", Range(0.1, 500))  = 10
        _SpecularShininess3 ("Specular Shininess (Power) | (RGB ID = 95)", Range(0.1, 500))  = 10
        _SpecularShininess4 ("Specular Shininess (Power) | (RGB ID = 127)", Range(0.1, 500)) = 10
        _SpecularShininess5 ("Specular Shininess (Power) | (RGB ID = 159)", Range(0.1, 500)) = 10
        _SpecularShininess6 ("Specular Shininess (Power) | (RGB ID = 192)", Range(0.1, 500)) = 10
        _SpecularShininess7 ("Specular Shininess (Power) | (RGB ID = 223)", Range(0.1, 500)) = 10
        // --- specular Roughness 
        _SpecularRoughness0 ("Specular Roughness (Power) | (RGB ID = 0)", Range(0, 1))   = 0.02
        _SpecularRoughness1 ("Specular Roughness (Power) | (RGB ID = 31)", Range(0, 1))  = 0.02
        _SpecularRoughness2 ("Specular Roughness (Power) | (RGB ID = 63)", Range(0, 1))  = 0.02
        _SpecularRoughness3 ("Specular Roughness (Power) | (RGB ID = 95)", Range(0, 1))  = 0.02
        _SpecularRoughness4 ("Specular Roughness (Power) | (RGB ID = 127)", Range(0, 1)) = 0.02
        _SpecularRoughness5 ("Specular Roughness (Power) | (RGB ID = 159)", Range(0, 1)) = 0.02
        _SpecularRoughness6 ("Specular Roughness (Power) | (RGB ID = 192)", Range(0, 1)) = 0.02
        _SpecularRoughness7 ("Specular Roughness (Power) | (RGB ID = 223)", Range(0, 1)) = 0.02
        // --- specular Intensity 
        _SpecularIntensity0 ("Specular Intensity (Power) | (RGB ID = 0)", Range(0, 50))   = 1
        _SpecularIntensity1 ("Specular Intensity (Power) | (RGB ID = 31)", Range(0, 50))  = 1
        _SpecularIntensity2 ("Specular Intensity (Power) | (RGB ID = 63)", Range(0, 50))  = 1
        _SpecularIntensity3 ("Specular Intensity (Power) | (RGB ID = 95)", Range(0, 50))  = 1
        _SpecularIntensity4 ("Specular Intensity (Power) | (RGB ID = 127)", Range(0, 50)) = 1
        _SpecularIntensity5 ("Specular Intensity (Power) | (RGB ID = 159)", Range(0, 50)) = 1
        _SpecularIntensity6 ("Specular Intensity (Power) | (RGB ID = 192)", Range(0, 50)) = 1
        _SpecularIntensity7 ("Specular Intensity (Power) | (RGB ID = 223)", Range(0, 50)) = 1
        // outline 

        

        // _LightMap
    }
    SubShader
    {
        Tags{ "RenderType"="Opaque" "Queue"="Geometry" }

        // ZWrite [_ZWrite]

        HLSLINCLUDE

        #pragma vertex vert
        #pragma fragment frag

        #pragma multi_compile _ UNITY_HDR_ON
        #pragma multi_compile_fog

        #include "UnityCG.cginc"
        #include "UnityLightingCommon.cginc"
        #include "UnityShaderVariables.cginc"

        #include "HoyoToonStarRail-inputs.hlsli"

        // ============================================
        // common properties 
        // -------------------------------------------
        // TEXTURES AND SAMPLERS
        Texture2D _MainTex;
        SamplerState sampler_MainTex; 
        Texture2D _LightMap;
        SamplerState sampler_LightMap;
        Texture2D _DiffuseRampMultiTex;
        SamplerState sampler_DiffuseRampMultiTex;
        Texture2D _DiffuseCoolRampMultiTex;
        SamplerState sampler_DiffuseCoolRampMultiTex;

        // COLORS
        float4 _Color;
        float4 _BackColor;
        float4 _EnvColor;
        float4 _AddColor;

        // shadow properties
        float _ShadowRamp;
        float _ShadowBoost; // these two values are used on the shadow mapping to increase its brightness
        float _ShadowBoostVal;

        // specular properties 
        float4 _SpecularColor0; 
        float4 _SpecularColor1; 
        float4 _SpecularColor2; 
        float4 _SpecularColor3; 
        float4 _SpecularColor4; 
        float4 _SpecularColor5; 
        float4 _SpecularColor6; 
        float4 _SpecularColor7;     
        float  _SpecularShininess0; 
        float  _SpecularShininess1; 
        float  _SpecularShininess2; 
        float  _SpecularShininess3; 
        float  _SpecularShininess4; 
        float  _SpecularShininess5; 
        float  _SpecularShininess6; 
        float  _SpecularShininess7; 
        float  _SpecularRoughness0; 
        float  _SpecularRoughness1; 
        float  _SpecularRoughness2; 
        float  _SpecularRoughness3; 
        float  _SpecularRoughness4; 
        float  _SpecularRoughness5; 
        float  _SpecularRoughness6; 
        float  _SpecularRoughness7; 
        float  _SpecularIntensity0; 
        float  _SpecularIntensity1; 
        float  _SpecularIntensity2; 
        float  _SpecularIntensity3; 
        float  _SpecularIntensity4; 
        float  _SpecularIntensity5; 
        float  _SpecularIntensity6; 
        float  _SpecularIntensity7; 



        // #include "HoyoToonGenshin-helpers.hlsl"

        ENDHLSL

        Pass{
            Name "ForwardBase"

            Tags{ "LightMode" = "ForwardBase" }

            Cull [_Cull]

            // Blend [_SrcBlend] [_DstBlend]

            HLSLPROGRAM

            #pragma multi_compile_fwdbase

            // pass specific properties

            #include "HoyoToonStarRail-main.hlsl"

            ENDHLSL
        }
        // 
        
    }
}
