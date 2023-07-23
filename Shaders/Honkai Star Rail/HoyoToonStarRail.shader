Shader "HoyoToon/StarRail"
{
    Properties
    {
        [Enum(UnityEngine.Rendering.CullMode)] _CullMode ("Cull Mode", Float) = 2
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Source Blend", Int) = 1
		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Destination Blend", Int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilPassA ("Stencil Pass Op A", Float) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilPassB ("Stencil Pass Op B", Float) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilCompA ("Stencil Compare Function A", Float) = 8
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilCompB ("Stencil Compare Function B", Float) = 8
        [IntRange] _StencilRef ("Stencil Reference Value", Range(0, 255)) = 0

        // material types
        [Header(Material Shaders)] [Space]
        [Toggle(BASE_MATERIAL)] _BaseMaterial ("Use Base Shader", Float) = 1 // on by default
        [Toggle(FACE_MATERIAL)] _FaceMaterial ("Use Face Shader", Float) = 0
        [Toggle(EYESHADOW_MATERIAL)] _EyeShadowMat ("Use EyeShadow Shader", Float) = 0
        [Toggle(HAIR_MATERIAL)] _HairMaterial ("Use Hair Shader", Float) = 0
        // main coloring 
        [Header(COMMON)]
        [NoScaleOffset]_MainTex ("Texture", 2D) = "white" {}
        [Toggle]_IsTransparent ("use main texture alpha as transparency", float) = 0
        _VertexShadowColor ("Vertex Shadow Color", Color) = (1, 1, 1, 1) // unsure of what this does yet for star rail
        _Color  ("Front Face Color", Color) = (1, 1, 1, 1)
        _BackColor ("Back Face Color", Color) = (1, 1, 1, 1)
        _EnvColor ("Env Color", Color) = (1, 1, 1, 1)
        _AddColor ("Env Color", Color) = (0, 0, 0, 0)
        [NoScaleOffset] _LightMap ("Light Map Texture", 2D) = "grey" {}
        _EnvironmentLightingStrength ("Environment Lighting Strength", Range(0.0, 1.0)) = 1.0

        [Header(FACE)]
        _headForwardVector ("Forward Vector | XYZ", Vector) = (0, 0, 1, 0)
        _headRightVector ("Right Vector | XYZ ", Vector) = (1, 0, 0, 0)
        [NoScaleOffset] _FaceMap ("Face Map Texture", 2D) = "white" {}
        _HairBlendSilhouette ("Hair Blend Silhouette", Range(0, 1)) = 0.5
        [NoScaleOffset] _FaceExpression ("Face Expression map", 2D) = "black" {}

        // -------------------------------------------
        // shadow 
        [Header(SHADOW)] 
        [NoScaleOffset]_DiffuseRampMultiTex     ("Warm Shadow Ramp | 8 ramps", 2D) = "white" {} 
        [NoScaleOffset]_DiffuseCoolRampMultiTex ("Cool Shadow Ramp | 8 ramps", 2D) = "white" {}
        _ShadowRamp ("Shadow Ramp", Range(0.01, 1)) = 1
        [Toggle]_ShadowBoost ("Shadow Boost Enable", Float) = 0
        _ShadowBoostVal ("Shadow Boost Value", Range(0,1)) = 0

        _ShadowColor ("Shadow Color", Color) = (0.5,0.5,0.5,1)
        _DarkColor   ("Dark Color", Color) = (0.85,0.85,0.85,1)
        _EyeShadowColor ("Eye Shadow Color", Color) = (1,1,1,1)
        _EyeBaseShadowColor ("EyeBase Shadow Color", Vector) = (1,1,1,1)
		_EyeShadowAngleMin ("EyeBase Shadow Min Angle", Range(0.36, 1.36)) = 0.85
		_EyeShadowMaxAngle ("EyeBase Shadow Max Angle", Range(0, 1)) = 1
		_ShadowThreshold ("Shadow Threshold", Range(0, 1)) = 0.5
		_ShadowFeather ("Shadow Feather", Range(0.0001, 0.05)) = 0.0001
		_BackShadowRange ("Back Shadow Range", Range(0, 1)) = 0
        // -------------------------------------------
        // specular 
        [Header(SPECULAR)]
        [Toggle]_AnisotropySpecular ("Anisotropic Specular", Float) = 0
        _ES_SPColor ("Global Specular Color", Color) = (0.5, 0.5, 0.5, 1)
        _ES_SPIntensity ("Global Specular Intensity", Float) = 0.5
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
        // -------------------------------------------
        // OUTLINE 
        // --- 
        [Header(OUTLINE)] _Outline ("Outline", Range(0, 1)) = 0
        [Toggle]_EnableFOVWidth ("Use camera perspective FOV to scale outlines", Float) = 1
        _OutlineWidth ("Outline Width", Range(0, 1)) = 0.1
        _OutlineScale ("Outline Scale", Range(0, 1)) = 0.1
        _OutlineColor ("Face Outline Color", Color) = (0, 0, 0, 1)
		_OutlineColor0 ("Outline Color 0 | (ID = 0)", Color) = (0,0,0,1)
		_OutlineColor1 ("Outline Color 1 | (ID = 31)", Color) = (0,0,0,1)
		_OutlineColor2 ("Outline Color 2 | (ID = 63)", Color) = (0,0,0,1)
		_OutlineColor3 ("Outline Color 3 | (ID = 95)", Color) = (0,0,0,1)
		_OutlineColor4 ("Outline Color 4 | (ID = 127)", Color) = (0,0,0,1)
		_OutlineColor5 ("Outline Color 5 | (ID = 159)", Color) = (0,0,0,1)
		_OutlineColor6 ("Outline Color 6 | (ID = 192)", Color) = (0,0,0,1)
		_OutlineColor7 ("Outline Color 7 | (ID = 223)", Color) = (0,0,0,1)
        _OutlineFixRange1 ("Lip _Outline Show Start", Range(0, 1)) = 0.1
        _OutlineFixRange2 ("Lip _Outline Show Max", Range(0, 1)) = 0.1
        _OutlineFixRange3 ("Lip _Outline Show Start", Range(0, 1)) = 0.1
        _OutlineFixRange4 ("Lip _Outline Show Max", Range(0, 1)) = 0.1
        _OutlineFixSide ("Outline Fix Star Side", Range(0, 1)) = 0.6
		_OutlineFixFront ("Outline Fix Star Front", Range(0, 1)) = 0.05
        _FixLipOutline ("TurnOn Temp Lip Outline", Range(0, 1)) = 0
		// _OutlineWidth ("Outline Width", Range(0, 1)) = 0.1
		[KeywordEnum(Normal, Tangent, UV2)] _OutlineNormalFrom ("Outline Normal From", Float) = 0 


        // _LightMap
    }
    SubShader
    {
        Tags{ "RenderType"="Opaque" "Queue"="Geometry" }

        // ZWrite [_ZWrite]

        HLSLINCLUDE


        // #pragma multi_compile _ UNITY_HDR_ON
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
        Texture2D _LightMap;
        Texture2D _DiffuseRampMultiTex;
        Texture2D _DiffuseCoolRampMultiTex;
        Texture2D _FaceMap;
        Texture2D _FaceExpression;
        SamplerState sampler_MainTex;
        SamplerState sampler_LightMap;
        SamplerState sampler_DiffuseRampMultiTex;
        SamplerState sampler_FaceMap;


        UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
        
        // MATERIAL STATES
        bool _BaseMaterial;
        bool _FaceMaterial;
        bool _EyeShadowMat;
        bool _HairMaterial;
        bool _IsTransparent;

        // COLORS
        float4 _Color;
        float4 _BackColor;
        float4 _EnvColor;
        float4 _AddColor;

        // face specific properties 
        float3 _headForwardVector;
        float3 _headRightVector;
        float _HairBlendSilhouette;
        float3 _ShadowColor;

        // shadow properties
        float _ShadowRamp;
        float _ShadowBoost; // these two values are used on the shadow mapping to increase its brightness
        float _ShadowBoostVal;

        float _EnvironmentLightingStrength;

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

        // rim light properties 
        float _RimLightMode;
        float _RimCt;
        float _Rimintensity;
        float _RimWeight;
        float _RimFeatherWidth;
        float _RimIntensityTexIntensity;
        float _RimWidth;
        float4 _RimOffset;
        float _RimEdge;
        float4 _RimColor0;
        float4 _RimColor1;
        float4 _RimColor2;
        float4 _RimColor3;
        float4 _RimColor4;
        float4 _RimColor5;
        float4 _RimColor6;
        float4 _RimColor7;
        float _RimWidth0;
        float _RimWidth1;
        float _RimWidth2;
        float _RimWidth3;
        float _RimWidth4;
        float _RimWidth5;
        float _RimWidth6;
        float _RimWidth7;
        float _RimEdgeSoftness0;
        float _RimEdgeSoftness1;
        float _RimEdgeSoftness2;
        float _RimEdgeSoftness3;
        float _RimEdgeSoftness4;
        float _RimEdgeSoftness5;
        float _RimEdgeSoftness6;
        float _RimEdgeSoftness7;
        float _RimType0;
        float _RimType1;
        float _RimType2;
        float _RimType3;
        float _RimType4;
        float _RimType5;
        float _RimType6;
        float _RimType7;
        float _RimDark0;
        float _RimDark1;
        float _RimDark2;
        float _RimDark3;
        float _RimDark4;
        float _RimDark5;
        float _RimDark6;
        float _RimDark7;

        // outline properties 
        float _EnableFOVWidth;
        float _OutlineWidth;
        float _OutlineScale;
        float _OutlineFixFront;
        float _OutlineFixSide;
        float _OutlineFixRange1;
        float _OutlineFixRange2;
        float _OutlineFixRange3;
        float _OutlineFixRange4;
        float _FixLipOutline;
        float4 _OutlineColor;
        float4 _OutlineColor0;
        float4 _OutlineColor1;
        float4 _OutlineColor2;
        float4 _OutlineColor3;
        float4 _OutlineColor4;
        float4 _OutlineColor5;
        float4 _OutlineColor6;
        float4 _OutlineColor7;
        



        #include "HoyoToonStarRail-common.hlsl"

        ENDHLSL

        Pass
        {
            Name "BasePass"
            Tags{ "LightMode" = "ForwardBase" }
            Cull [_Cull]
            Blend [_SrcBlend] [_DstBlend]
            Stencil
            {
				ref [_StencilRef]  
                Comp [_StencilCompA]
				Pass [_StencilPassA]
                Fail Keep
				ZFail Keep
			}

            HLSLPROGRAM
            #pragma multi_compile_fwdbase
            
            #pragma vertex vs_base
            #pragma fragment ps_base

            #include "HoyoToonStarRail-program.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "EyeStencilPass"
            Tags{ "LightMode" = "ForwardBase" }
            Cull [_Cull] 
            Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha OneMinusSrcAlpha
            // BlendOp Add
            // ZWrite Off
            // Ztest Equal
            Stencil
            {
                ref [_StencilRef]              
				Comp [_StencilCompB]
				Pass [_StencilPassB]  
                Fail Keep
				ZFail Keep
			}

            // Cull [_Cull]
            // Blend [_SrcBlend] [_DstBlend]

            HLSLPROGRAM
            #pragma multi_compile_fwdbase            
            #pragma vertex vs_base
            #pragma fragment ps_face_stencil

            #include "HoyoToonStarRail-program.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "Outline"
            Tags{ "LightMode" = "ForwardBase" }
            Cull Front
            
            Blend SrcAlpha OneMinusSrcAlpha
            Stencil
            {
                ref [_StencilRef]              
				Comp [_StencilCompA]
				Pass [_StencilPassA]  
                Fail Keep
				ZFail Keep
			}

            // Cull [_Cull]
           

            // Blend [_SrcBlend] [_DstBlend]

            HLSLPROGRAM

            #pragma multi_compile_fwdbase
            
            #pragma vertex vs_edge
            #pragma fragment ps_edge

            #include "HoyoToonStarRail-program.hlsl"

            ENDHLSL
        }
    }
}
