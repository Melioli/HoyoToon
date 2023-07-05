Shader "HoyoToon/StarRail/Hair"
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
        [Header(SPECULAR)]
        [Toggle]_AnisotropySpecular ("Anisotropic Specular", Float) = 0

        _ES_SPColor ("Global Specular Color", Color) = (1, 1, 1, 1)
        _ES_SPIntensity ("Global Specular Intensity", Float) = 1
        // --- specular color
        _SpecularColor0 ("Specular Color 0 | (RGB ID = 0)", Color)   = (1,1,1,1)
        _SpecularColor1 ("Specular Color 1 | (RGB ID = 31)", Color)  = (1,1,1,1)
        _SpecularColor2 ("Specular Color 2 | (RGB ID = 63)", Color)  = (1,1,1,1)
        _SpecularColor3 ("Specular Color 3 | (RGB ID = 95)", Color)  = (1,1,1,1)
        _SpecularColor4 ("Specular Color 4 | (RGB ID = 127)", Color) = (1,1,1,1)
        _SpecularColor5 ("Specular Color 5 | (RGB ID = 159)", Color) = (1,1,1,1)
        _SpecularColor6 ("Specular Color 6 | (RGB ID = 192)", Color) = (1,1,1,1)
        _SpecularColor7 ("Specular Color 7 | (RGB ID = 223)", Color) = (1,1,1,1)
        // --- specular shininess 
        _SpecularShininess0 ("Specular Shininess 0 (Power) | (RGB ID = 0)", Range(0.1, 500))   = 10
        _SpecularShininess1 ("Specular Shininess 1 (Power) | (RGB ID = 31)", Range(0.1, 500))  = 10
        _SpecularShininess2 ("Specular Shininess 2 (Power) | (RGB ID = 63)", Range(0.1, 500))  = 10
        _SpecularShininess3 ("Specular Shininess 3 (Power) | (RGB ID = 95)", Range(0.1, 500))  = 10
        _SpecularShininess4 ("Specular Shininess 4 (Power) | (RGB ID = 127)", Range(0.1, 500)) = 10
        _SpecularShininess5 ("Specular Shininess 5 (Power) | (RGB ID = 159)", Range(0.1, 500)) = 10
        _SpecularShininess6 ("Specular Shininess 6 (Power) | (RGB ID = 192)", Range(0.1, 500)) = 10
        _SpecularShininess7 ("Specular Shininess 7 (Power) | (RGB ID = 223)", Range(0.1, 500)) = 10
        // --- specular Roughness 
        _SpecularRoughness0 ("Specular Roughness 0 | (RGB ID = 0)", Range(0, 1))   = 0.02
        _SpecularRoughness1 ("Specular Roughness 1 | (RGB ID = 31)", Range(0, 1))  = 0.02
        _SpecularRoughness2 ("Specular Roughness 2 | (RGB ID = 63)", Range(0, 1))  = 0.02
        _SpecularRoughness3 ("Specular Roughness 3 | (RGB ID = 95)", Range(0, 1))  = 0.02
        _SpecularRoughness4 ("Specular Roughness 4 | (RGB ID = 127)", Range(0, 1)) = 0.02
        _SpecularRoughness5 ("Specular Roughness 5 | (RGB ID = 159)", Range(0, 1)) = 0.02
        _SpecularRoughness6 ("Specular Roughness 6 | (RGB ID = 192)", Range(0, 1)) = 0.02
        _SpecularRoughness7 ("Specular Roughness 7 | (RGB ID = 223)", Range(0, 1)) = 0.02
        // --- specular Intensity 
        _SpecularIntensity0 ("Specular Intensity 0 | (RGB ID = 0)", Range(0, 50))   = 1
        _SpecularIntensity1 ("Specular Intensity 1 | (RGB ID = 31)", Range(0, 50))  = 1
        _SpecularIntensity2 ("Specular Intensity 2 | (RGB ID = 63)", Range(0, 50))  = 1
        _SpecularIntensity3 ("Specular Intensity 3 | (RGB ID = 95)", Range(0, 50))  = 1
        _SpecularIntensity4 ("Specular Intensity 4 | (RGB ID = 127)", Range(0, 50)) = 1
        _SpecularIntensity5 ("Specular Intensity 5 | (RGB ID = 159)", Range(0, 50)) = 1
        _SpecularIntensity6 ("Specular Intensity 6 | (RGB ID = 192)", Range(0, 50)) = 1
        _SpecularIntensity7 ("Specular Intensity 7 | (RGB ID = 223)", Range(0, 50)) = 1
        // -------------------------------------------
        // rim light
        [Header(RIM)]
        _RimLightMode ("Rim Light Use LightMap.r", Range(0,1)) = 1
        _RimCt ("Rim CT", Float) = 5
        _Rimintensity ("Rim Intensity", Float) = 1
        _RimWeight ("Rim Weight", Float) = 1
        _RimFeatherWidth ("Rim Feather Width", Float) = 0.01
        _RimIntensityTexIntensity ("Rim Texture Intensity", Range(1, -1)) = 0
        _RimWidth ("Rim Width", Float) = 1
        _RimOffset ("Rim Offset", Vector) = (0, 0, 0, 0)
        _RimEdge ("Rim Edge Base", Range(0.01, 0.02)) = 0.015
        // --- Rim Color
        _RimColor0 (" Rim Light Color 0 | (RGB ID = 0)", Color)   = (1, 1, 1, 1)
        _RimColor1 (" Rim Light Color 1 | (RGB ID = 31)", Color)  = (1, 1, 1, 1)
        _RimColor2 (" Rim Light Color 2 | (RGB ID = 63)", Color)  = (1, 1, 1, 1)
        _RimColor3 (" Rim Light Color 3 | (RGB ID = 95)", Color)  = (1, 1, 1, 1)
        _RimColor4 (" Rim Light Color 4 | (RGB ID = 127)", Color) = (1, 1, 1, 1)
        _RimColor5 (" Rim Light Color 5 | (RGB ID = 159)", Color) = (1, 1, 1, 1)
        _RimColor6 (" Rim Light Color 6 | (RGB ID = 192)", Color) = (1, 1, 1, 1)
        _RimColor7 (" Rim Light Color 7 | (RGB ID = 223)", Color) = (1, 1, 1, 1)
        // --- Rim Width
        _RimWidth0 ("Rim Width 0 | (RGB ID = 0)", Float) = 1
        _RimWidth1 ("Rim Width 1 | (RGB ID = 31)", Float) = 1
        _RimWidth2 ("Rim Width 2 | (RGB ID = 63)", Float) = 1
        _RimWidth3 ("Rim Width 3 | (RGB ID = 95)", Float) = 1
        _RimWidth4 ("Rim Width 4 | (RGB ID = 127)", Float) = 1
        _RimWidth5 ("Rim Width 5 | (RGB ID = 159)", Float) = 1
        _RimWidth6 ("Rim Width 6 | (RGB ID = 192)", Float) = 1
        _RimWidth7 ("Rim Width 7 | (RGB ID = 223)", Float) = 1
        // --- Rim Edge Softness 
        _RimEdgeSoftness0 ("Rim Edge Softness 0 | (RGB ID = 0)", Range(0.01, 0.9)) = 0.1
        _RimEdgeSoftness1 ("Rim Edge Softness 1 | (RGB ID = 31)", Range(0.01, 0.9)) = 0.1
        _RimEdgeSoftness2 ("Rim Edge Softness 2 | (RGB ID = 63)", Range(0.01, 0.9)) = 0.1
        _RimEdgeSoftness3 ("Rim Edge Softness 3 | (RGB ID = 95)", Range(0.01, 0.9)) = 0.1
        _RimEdgeSoftness4 ("Rim Edge Softness 4 | (RGB ID = 127)", Range(0.01, 0.9)) = 0.1
        _RimEdgeSoftness5 ("Rim Edge Softness 5 | (RGB ID = 159)", Range(0.01, 0.9)) = 0.1
        _RimEdgeSoftness6 ("Rim Edge Softness 6 | (RGB ID = 192)", Range(0.01, 0.9)) = 0.1
        _RimEdgeSoftness7 ("Rim Edge Softness 7 | (RGB ID = 223)", Range(0.01, 0.9)) = 0.1
        // --- Rim Type
        _RimType0 ("Rim Type 0 | (RGB ID = 0)", Range(0.0, 1.0)) = 1.0
        _RimType1 ("Rim Type 1 | (RGB ID = 31)", Range(0.0, 1.0)) = 1.0
        _RimType2 ("Rim Type 2 | (RGB ID = 63)", Range(0.0, 1.0)) = 1.0
        _RimType3 ("Rim Type 3 | (RGB ID = 95)", Range(0.0, 1.0)) = 1.0
        _RimType4 ("Rim Type 4 | (RGB ID = 127)", Range(0.0, 1.0)) = 1.0
        _RimType5 ("Rim Type 5 | (RGB ID = 159)", Range(0.0, 1.0)) = 1.0
        _RimType6 ("Rim Type 6 | (RGB ID = 192)", Range(0.0, 1.0)) = 1.0
        _RimType7 ("Rim Type 7 | (RGB ID = 223)", Range(0.0, 1.0)) = 1.0
        // --- Rim Dark 
        _RimDark0 ("Rim Dark 0 | (RGB ID = 0)", Range(0.0, 1.0)) = 0.5
        _RimDark1 ("Rim Dark 1 | (RGB ID = 31)", Range(0.0, 1.0)) = 0.5
        _RimDark2 ("Rim Dark 2 | (RGB ID = 63)", Range(0.0, 1.0)) = 0.5
        _RimDark3 ("Rim Dark 3 | (RGB ID = 95)", Range(0.0, 1.0)) = 0.5
        _RimDark4 ("Rim Dark 4 | (RGB ID = 127)", Range(0.0, 1.0)) = 0.5
        _RimDark5 ("Rim Dark 5 | (RGB ID = 159)", Range(0.0, 1.0)) = 0.5
        _RimDark6 ("Rim Dark 6 | (RGB ID = 192)", Range(0.0, 1.0)) = 0.5
        _RimDark7 ("Rim Dark 7 | (RGB ID = 223)", Range(0.0, 1.0)) = 0.5
        
        // outline 


        // _LightMap
    }
    SubShader
    {
        Tags{ "RenderType"="Opaque" "Queue"="Geometry" }

        // ZWrite [_ZWrite]

        HLSLINCLUDE

        #pragma multi_compile _ UNITY_HDR_ON
        #pragma multi_compile_fog
        #define HAIR_MATERIAL

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
        float4 _ES_SPColor;
        float _ES_SPIntensity;
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

        Pass
        {
            Name "ForwardBase"
            Tags{ "LightMode" = "ForwardBase" }
            

            Cull [_Cull]

            // Blend [_SrcBlend] [_DstBlend]

            HLSLPROGRAM

            #pragma multi_compile_fwdbase

            
            
            #pragma vertex vs_base
            #pragma fragment ps_hair

            #include "HoyoToonStarRail-main.hlsl"

            ENDHLSL
        }

    }
}
