Shader "HoyoToon/Honkai Impact"
{
    Properties 
    { 
        //Header
        [HideInInspector] shader_master_label ("✧<b><i><color=#C69ECE>HoyoToon Honkai Impact</color></i></b>✧", Float) = 0
        [HideInInspector] shader_is_using_hoyeditor ("", Float) = 0
        [HideInInspector] footer_github ("{texture:{name:hoyogithub},action:{type:URL,data:https://github.com/Melioli/HoyoToon},hover:Github}", Float) = 0
        [HideInInspector] footer_discord ("{texture:{name:hoyodiscord},action:{type:URL,data:https://discord.gg/meliverse},hover:Discord}", Float) = 0
        [HideInInspector] footer_discord ("{texture:{name:hoyomeliverse},action:{type:URL,data:https://vrchat.com/home/world/wrld_3921fce9-c4c6-4ea4-ad0d-83c6d16a9fbf},hover:Meliverse Avatars}", Float) = 0
        //Header End

        //Material Type
        [HoyoWideEnum(Base, 0, Face, 1, Hair, 2, Eye, 3)]variant_selector("Material Type--{on_value_actions:[
            {value:0,actions:[{type:SET_PROPERTY,data:_StencilPassA=0}, {type:SET_PROPERTY,data:_StencilPassB=0}, {type:SET_PROPERTY,data:_StencilCompA=8}]},
            {value:0,actions:[{type:SET_PROPERTY,data:_StencilCompB=8}, {type:SET_PROPERTY,data:_StencilRef=0}, {type:SET_PROPERTY,data:render_queue=2000}, {type:SET_PROPERTY,data:render_type=Opaque}]},

            {value:1,actions:[{type:SET_PROPERTY,data:_StencilPassA=0}, {type:SET_PROPERTY,data:_StencilPassB=2}, {type:SET_PROPERTY,data:_StencilCompA=6}]},
            {value:1,actions:[{type:SET_PROPERTY,data:_StencilCompB=8}, {type:SET_PROPERTY,data:_StencilRef=16}, {type:SET_PROPERTY,data:render_queue=2000}, {type:SET_PROPERTY,data:render_type=Opaque}]},

            {value:2,actions:[{type:SET_PROPERTY,data:_StencilPassA=0}, {type:SET_PROPERTY,data:_StencilPassB=2}, {type:SET_PROPERTY,data:_StencilCompA=6}]},
            {value:2,actions:[{type:SET_PROPERTY,data:_StencilCompB=8}, {type:SET_PROPERTY,data:_StencilRef=16}, {type:SET_PROPERTY,data:render_queue=2002}, {type:SET_PROPERTY,data:render_type=Opaque}]},
            
            {value:3,actions:[{type:SET_PROPERTY,data:_StencilPassA=0}, {type:SET_PROPERTY,data:_StencilPassB=2}, {type:SET_PROPERTY,data:_StencilCompA=6}]},
            {value:3,actions:[{type:SET_PROPERTY,data:_StencilCompB=8}, {type:SET_PROPERTY,data:_StencilRef=16}, {type:SET_PROPERTY,data:render_queue=2001}, {type:SET_PROPERTY,data:render_type=Opaque}]}]}", Int) = 0
            //Material Type End
            
            // Main
        [HideInInspector] m_start_main ("Main", Float) = 0
        [SmallTexture]_MainTex ("Texture", 2D) = "white" {}
        [SmallTexture]_LightMapTex ("LightMap Texture", 2D) = "white" {}
        _Color ("Main Color", Color) = (1,1,1,1)
        _EnvColor ("Tint Color", Color) = (1,1,1,1)
        [Toggle] _BackFaceUseUV2 ("BackFace Use UV2", Float) = 0
        _BackFaceColor ("Back Face Color", Color) = (1,1,1,1)
        [HideInInspector] _BackColor ("Back Face Color", Color) = (1,1,1,1)
        // Main Alpha
        [HideInInspector] m_start_mainalpha ("Alpha Options", Float) = 0
        [HoyoWideEnum(None, 0, Alpha, 1, Emission, 2)]_AlphaType("Transparency Type--{on_value_actions:[
            {value:0,actions:[{type:SET_PROPERTY,data:_SrcBlend=1}, {type:SET_PROPERTY,data:_DstBlend=0}, {type:SET_PROPERTY,data:render_queue=2000}, {type:SET_PROPERTY,data:render_type=Opaque}]},

            {value:1,actions:[{type:SET_PROPERTY,data:_SrcBlend=5}, {type:SET_PROPERTY,data:_DstBlend=10}, {type:SET_PROPERTY,data:render_queue=2003}, {type:SET_PROPERTY,data:render_type=Opaque}]},

            {value:2,actions:[{type:SET_PROPERTY,data:_SrcBlend=1}, {type:SET_PROPERTY,data:_DstBlend=0}, {type:SET_PROPERTY,data:render_queue=2000}, {type:SET_PROPERTY,data:render_type=Opaque}]}]}", Int) = 0
        [Toggle] _AlphaClip ("Use Alpha Clip", Float) = 0
        _Opaqueness ("Opaqueness", Range(0, 1)) = 1

        [HideInInspector] m_end_mainalpha ("", Float) = 0
        [HideInInspector] m_end_main ("", Float) = 0
                //Main End

                //Face
        [HideInInspector] m_start_faceshading("Face--{condition_show:{type:OR,condition1:{type:PROPERTY_BOOL,data:variant_selector==1},condition2:{type:PROPERTY_BOOL,data:variant_selector==3}}}", Float) = 0.0
        _FaceMapTex ("FaceMap Texture", 2D) = "grey" {}
        _FacExpTex ("Face Expression Texture", 2D) = "black" { }
        _ShadowFeather ("Shadow Feather", Range(0.0001, 1)) = 0.001 // for face
        _headForward ("Forward Vector || XYZ", Vector) = (0, 0, 1, 0)
        _headUp ("Up Vector || XYZ", Vector) = (0, 1, 0, 0)
        _headRight ("Right Vector || XYZ", Vector) = (-1, 0, 0, 0)


        [HideInInspector] m_start_eyes("Eyes", Float) = 0
        [Toggle]_EyeEffectPupil ("Eye Effect Pupil", Float) = 0
        _EyeEffectTex ("Eye Effect Texture", 2D) = "white" { }
        _EyeEffectCenterPos ("Eye Effect Center Position", Vector) = (0.5,0.5,0,0)
        _EyeEffectLocalScale ("Eye Effect Local Scale", Vector) = (1,1,0,0)
        [HideInInspector] m_end_eyes(" ", Float) = 0

        [HideInInspector] m_start_faceexpression("Facial Expressions", Float) = 0
        _ExpBlushColor ("Expression Blush Color", Color) = (1,0,0,1)
        _ExpBlushIntensity ("Expression Blush Intensity", Range(0, 1)) = 0
        _ExpShadowColor ("Expression Shadow Color", Color) = (0.5,0.5,0.5,1)
        _ExpShadowIntensity ("Expression Shadow Intensity", Range(0, 1)) = 0
        _ExpShadowColor2 ("Expression Shadow Color", Color) = (0.5,0.5,0.5,1)
        _ExpShadowIntensity2 ("Expression Shadow Intensity", Range(0, 1)) = 0
        _ExpShadowColor3 ("Expression Shadow Color", Color) = (0.5,0.5,0.5,1)
        _ExpShadowIntensity3 ("Expression Shadow Intensity", Range(0, 1)) = 0
        [HideInInspector] m_end_faceexpression(" ", Float) = 0
        [HideInInspector] m_end_faceshading(" ", Float) = 0
        //Face End

        //Lighting 
        [HideInInspector] m_start_lighting("Lighting Options", Float) = 0
        [Toggle] _FilterLight ("Limit Spot/Point Light Intensity", Float) = 1
        _LightArea ("Light Area Threshold", Range(0, 1)) = 0.51
        [HideInInspector] m_start_shadowcolor("Shadow Colors", Float) = 0
        _ShadowColor ("Shadow Color", Color) = (0.9,0.7,0.75,1)
        _FirstShadowMultColor ("Shadow Color 1", Color) = (0.9,0.7,0.75,1)
        _FirstShadowMultColor2 ("Shadow Color 2", Color) = (0.9,0.7,0.75,1)
        _FirstShadowMultColor3 ("Shadow Color 3", Color) = (0.9,0.7,0.75,1)
        _FirstShadowMultColor4 ("Shadow Color 4", Color) = (0.9,0.7,0.75,1)
        _FirstShadowMultColor5 ("Shadow Color 5", Color) = (0.9,0.7,0.75,1)
        [HideInInspector] m_end_shadowcolor(" ", Float) = 0
        [HideInInspector] m_end_lighting("", Float) = 0
        //Lighting End

        //Specular
        [HideInInspector] m_start_specular("Specular Reflections", Int) = 0
        _Shininess ("Specular Shininess", Range(0.1, 100)) = 10
        _SpecMulti ("Specular Multiply Factor", Range(0, 1)) = 0.1
        _LightSpecColor ("Light Specular Color", Color) = (1,1,1,1)
        [HideInInspector] m_end_specular("", Float) = 0
        //Specular End

        //Outlines
        [HideInInspector] m_start_outlines("Outlines", Float) = 0
        _OutlineWidth ("Outline Width", Range(0, 100)) = 0.0
        _Scale ("Outline Scale", Float) = 0.01 // I don't think there's a noticable difference between hoyo2vrc and maya scales
        _GlobalOutlineScale ("X: Scale W:Distance Toggle", Vector) = (1, 1, 1, 1) //X: Scale Y:Distance Toggle (w > 0.09: manual, w < 0.09: camera)
        _MaxOutlineZOffset ("Max Outline Z Offset", Range(0, 100)) = 1
        _OutlineCamStart ("Outline Camera Adjustment Start Distance", Range(0, 10000)) = 1000
        [Toggle(TRANSPARENTOUTLINE)] _TrasOutline ("Outline is Transparent By MainTex", Float) = 0
        [Toggle] _OutlineTrans ("Outline Tranparent", Float) = 0
        [HideInInspector] m_start_outlinescolor("Outline Colors", Float) = 0
        _OutlineColor ("Outline Color 1", Color) = (0,0,0,1)
        _OutlineColor2 ("Outline Color 2", Color) = (0,0,0,1)
        _OutlineColor3 ("Outline Color 3", Color) = (0,0,0,1)
        _OutlineColor4 ("Outline Color 4", Color) = (0,0,0,1)
        _OutlineColor5 ("Outline Color 5", Color) = (0,0,0,1)
        [HideInInspector] m_end_outlinescolor(" ", Float) = 0
        [HideInInspector] m_end_outlines(" ", Float) = 0
        //Outlines End

        //Rimlights
        [HideInInspector] m_start_rimlight("Rim Light", Float) = 0
        [Toggle] _RimGlow ("Enable Rim", Float) = 0
        _RGColor ("Rim Glow Color 1", Color) = (1,1,1,1)
        _RGShininess ("Rim Glow Shininess", Float) = 1
        _RGScale ("Rim Glow Scale", Float) = 1
        _RGBias ("Rim Glow Bias", Float) = 0
        _RGRatio ("Rim Glow Ratio", Range(-1, 1)) = 0.5
        _RGBloomFactor ("Rim Glow Bloom Factor", Float) = 1
        [HideInInspector] m_start_hardrimlight("Hard Rim Light", Float) = 0
        _HRRimIntensity ("Hard Rim Mask", Range(0, 1)) = 0
        _HRRimPower ("Hard Rim Ratio", Range(0, 3)) = 0.1
        _Hardness ("Rim Hardless", Range(0, 5)) = 0.1
        [Toggle(Hardrim)] _MoreHardRimColor ("More HardRim Color", Range(0, 1)) = 0
        [HideInInspector] m_start_hardrimlightcolors("Hard Rimlight Colors", Float) = 0
        _HRRimColor2 ("Hard Rim Color 2", Color) = (1,1,1,1)
        _HRRimColor3 ("Hard Rim Color 3", Color) = (1,1,1,1)
        _HRRimColor4 ("Hard Rim Color 4", Color) = (1,1,1,1)
        _HRRimColor5 ("Hard Rim Color 5", Color) = (1,1,1,1)
        [HideInInspector] m_end_hardrimlightcolors(" ", Float) = 0
        [HideInInspector] m_end_hardrimlight(" ", Float) = 0
        [HideInInspector] m_end_rimlight(" ", Float) = 0
        //Rimlights End

        //Special Effects
        [HideInInspector] m_start_specialeffects("Special Effects", Float) = 0
        [HideInInspector] m_start_emission("Emission", Float) = 0
        _EmissionStr ("Emission Strength", Float) = 0
        [Toggle(EmissionColor)] _EmissionColorToggle ("Emission Colors", Range(0, 1)) = 0
        [Toggle(PulseToggle)] _usepulse ("Emission Pulsing", Range(0, 1)) = 0

        [HideInInspector] m_start_emissionColor("Emission Colors", Float) = 0
        _EmissionColor ("Emission Color 1", Color) = (1,1,1,1)
        _EmissionColor2 ("Emission Color 2", Color) = (1,1,1,1)
        _EmissionColor3 ("Emission Color 3", Color) = (1,1,1,1)
        _EmissionColor4 ("Emission Color 4", Color) = (1,1,1,1)
        _EmissionColor5 ("Emission Color 5", Color) = (1,1,1,1)
        [HideInInspector] m_end_emissionColor(" ", Float) = 0
        [HideInInspector] m_start_Pulse("Emission Pulsing--{condition_show:{type:PROPERTY_BOOL,data:_usepulse==1.0}}", Float) = 0
        _PulseRate ("Pulse Speed", Range(0, 30)) = 0
        _MinPulse ("Min Pulse Strength", Range(0, 1)) = 0
        _MaxPulse ("Max Pulse Strength", Range(0, 1)) = 1
        [HideInInspector] m_end_Pulse(" ", Float) = 0
        [HideInInspector] m_end_emission(" ", Float) = 0
        [HideInInspector] m_start_dissolve("Dissolve", Float) = 0
        [Toggle(LENGTHWAYSDIS)] _LengthWaysDis ("Enable", Float) = 0
        _MaskDisTex ("Dissolve Mask", 2D) = "White" {}
        _NoiseTex ("Noise Texture", 2D) = "black" { }
        _MainTex2 ("Secondary Diffuse", 2D) = "white" { }
        _AlphaPosition ("AlphaPosition", Float) = 0
        _DisAngle ("DisAngle", Range(0, 360)) = 0
        _DisColor ("DisColor", Color) = (1,1,1,1)
        _DisColorScale ("DisColorScale", Float) = 1
        _Edge ("DisEdge", Range(0, 1)) = 0.2
        _TintColorEdge ("TintColorEdge", Range(0, 1)) = 0
        _AddLightColor ("Dissolve Add Color", Color) = (1, 1, 1, 1)
        _Soft ("SoftEdge", Range(0, 1)) = 0
        _TintColorPower ("TintColorPower", Range(0, 3)) = 1
        _MaskTillingOffset ("MaskDisTexture Tilling(XY) Offset(ZW)", Vector) = (1,1,0,0)
        _MaskOffsetSpeed ("MaskDisTexture Offset Speed", Float) = 0
        _MaskDisTexScale ("Dissolve Mask Scale", Float) = 1
                
        _NoiseIntensity ("Noise Intensity", Range(0, 10)) = 5
        _NoiseTillingOffset ("NoiseTexture Tilling(XY) Offset(ZW)", Vector) = (1,1,0,0)
        [Toggle] _LengthWaysDisBlend ("UseMainTex2 Blend", Float) = 0
        [Toggle] _DissolveUseUV2 ("Dissolve Use UV2 ", Float) = 1
        [Toggle] _OnlyUseMaskDis ("Only Use MaskDisTexture", Float) = 0
        [HideInInspector] m_end_dissolve ("", Float) = 0
        [HideInInspector] m_end_specialeffects(" ", Float) = 0

        //Rendering Options
        [HideInInspector] m_start_renderingOptions("Rendering Options", Float) = 0
        [Enum(UnityEngine.Rendering.CullMode)] _CullMode("Cull Mode", Int) = 0	
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Source Blend", Int) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Destination Blend", Int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilPassA ("Stencil Pass Op A", Float) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilPassB ("Stencil Pass Op B", Float) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilCompA ("Stencil Compare Function A", Float) = 8
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilCompB ("Stencil Compare Function B", Float) = 8
        [IntRange] _StencilRef ("Stencil Reference Value", Range(0, 255)) = 0
        [HideInInspector] m_end_renderingOptions(" ", Float) = 0
        //Rendering Options End
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque" 
            "LightMode" = "ForwardBase"
            // "PassFlags" = "OnlyDirectional" 
            // the above line actually was fucking with the point lights
        }
        Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha OneMinusSrcAlpha
        LOD 100
        HLSLINCLUDE
        Texture2D _MainTex;
        Texture2D _FaceMapTex;
        Texture2D _EyeEffectTex;
        Texture2D _MaskDisTex;
        Texture2D _FacExpTex;
        Texture2D _LightMapTex;
        Texture2D _NoiseTex;
        Texture2D _MainTex2;
        SamplerState sampler_MainTex;
        SamplerState sampler_LightMapTex;
        SamplerState sampler_FaceMapTex;
        SamplerState sampler_FacExpTex;
        SamplerState sampler_NoiseTex;
        SamplerState sampler_MaskDisTex;
        float4 _MainTex_ST;
        float _AlphaType;
        float _AlphaClip;
        float _Opaqueness;
        float _BackFaceUseUV2;
        float4 _BackFaceColor;
        float4 _BackColor;
        float variant_selector;
        float _FilterLight;
        float _LightArea;
        float4 _FirstShadowMultColor;
        float4 _FirstShadowMultColor2;
        float4 _FirstShadowMultColor3;
        float4 _FirstShadowMultColor4;
        float4 _FirstShadowMultColor5;
        float4 _ShadowColor;
        float4 _OutlineColor;
        float4 _OutlineColor2;
        float4 _OutlineColor3;
        float4 _OutlineColor4;
        float4 _OutlineColor5;
        float _TrasOutline;
        float _OutlineTrans;
        float _RimGlow;
        float4 _RGColor;
        float4 _HRRimColor2;
        float4 _HRRimColor3;
        float4 _HRRimColor4;
        float4 _HRRimColor5;
        float4 _SecondShadow;
        float4 _EffectColor;
        float4 _GlobalOutlineScale;
        float3 _headUp;
        float3 _headForward;
        float3 _headRight;
        float _RGShininess;
        float _RGScale;
        float _ShadowFeather;
        float _RGBias;
        float _RGRatio;
        float _HRRimIntensity;
        float _HRRimPower;
        float _MoreHardRimColor;
        float _Shininess;
        float _SpecMulti;
        float4 _LightSpecColor;
        float4 _Color;
        float4 _AddLightColor;
        float4 _EnvColor;
        float _Hardness;
        float _RGBloomFactor;
        float _EmissionStr;
        float _ShadowContrast;
        float _MaxOutlineZOffset;
        float _OutlineCamStart;
        float _OutlineWidth;
        float _UseCameraFade;
        float _FadeDistance;
        float _FadeOffset;
        float _Scale;
        float _VertexAlphaFactor;
        float4 _ExpBlushColor;
        float _ExpBlushIntensity;
        float4 _ExpShadowColor;
        float _ExpShadowIntensity;
        float4 _ExpShadowColor2;
        float _ExpShadowIntensity2;
        float4 _ExpShadowColor3;
        float _ExpShadowIntensity3;
        float _EyeEffectPupil;
        float4 _EyeEffectCenterPos;
        float4 _EyeEffectLocalScale;
        bool _EmissionColorToggle; 
        bool _usepulse; 
        float4 _EmissionColor;
        float4 _EmissionColor2;
        float4 _EmissionColor3;
        float4 _EmissionColor4;
        float4 _EmissionColor5;
        float _PulseRate;
        float _MinPulse;
        float _MaxPulse;
        float _LengthWaysDis;
        // float _NoiseTex;
        float _AlphaPosition;
        float _DisAngle;
        float4 _DisColor;
        float _DisColorScale;
        float _Edge;
        float _TintColorEdge;
        float _Soft;
        float _TintColorPower;
        float4 _MaskTillingOffset;
        float _MaskOffsetSpeed;
        float _MaskDisTexScale;
        float _NoiseIntensity;
        float4 _NoiseTillingOffset;
        float _LengthWaysDisBlend;
        float _DissolveUseUV2;
        float _OnlyUseMaskDis;
        // Unity provided variables : 
        uniform float _GI_Intensity;
        uniform float4x4 _LightMatrix0;


        #include "UnityCG.cginc"
        #include "UnityPBSLighting.cginc"
        #include "UnityShaderVariables.cginc"
        #include "AutoLight.cginc"
        #include "UnityLightingCommon.cginc"
        #include "Lighting.cginc"

        ENDHLSL

        // UsePass "Hidden/HoyoToon/HI3Depth/ShadowCast" // shadow casting

        Pass
        {
            Name "Character Shading"
            Tags{ "LightMode" = "ForwardBase"}    
            Cull [_CullMode]
            Blend [_SrcBlend] [_DstBlend]
            Stencil
            {
                ref [_StencilRef]  
                Comp [_StencilCompA]
                Pass [_StencilPassA] // this doesn't even fucking matter like what?
                Fail Keep
                ZFail Keep
            }
            HLSLPROGRAM

            #pragma vertex vs_model
            #pragma fragment ps_model


            #pragma multi_compile_fwdbase
            #pragma multi_compile _IS_PASS_BASE
                    

            //imports
            #include "Includes/HoyoToonHonkaiImpact-Import.hlsl"

            //shader
            #include "Includes/HoyoToonHonkaiImpact-Common.hlsl"
            #include "Includes/HoyoToonHonkaiImpact-Program.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "Character Stencil"
            Tags{  "LightMode" = "ForwardBase" } 
            Cull [_CullMode]
            Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha OneMinusSrcAlpha

            Stencil
            {
                ref [_StencilRef]              
                Comp [_StencilCompB]
                Pass [_StencilPassB]  
                Fail Keep
                ZFail Keep
            }
            HLSLPROGRAM

            #pragma multi_compile_fwdbase
            #pragma multi_compile _IS_PASS_BASE
            #define stencil


            #pragma vertex vs_model
            #pragma fragment ps_model


            //imports
            #include "Includes/HoyoToonHonkaiImpact-Import.hlsl"

            //shader
            #include "Includes/HoyoToonHonkaiImpact-Common.hlsl"
            #include "Includes/HoyoToonHonkaiImpact-Program.hlsl"
            // 
            ENDHLSL 
        }
        Pass
        {
            Name "Character Lighting"
            Tags { "LightMode" = "ForwardAdd" }
            Cull [_CullMode]
            Blend One One
            // ZWrite Off
            HLSLPROGRAM
            #pragma multi_compile_fwdadd
            #pragma multi_compile _IS_PASS_LIGHT
            #pragma vertex vs_model
            #pragma fragment ps_model

            //imports
            #include "Includes/HoyoToonHonkaiImpact-Import.hlsl"

            //shader
            #include "Includes/HoyoToonHonkaiImpact-Common.hlsl"
            #include "Includes/HoyoToonHonkaiImpact-Program.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "Character Outline"
            Tags{  "LightMode" = "ForwardBase" } 
            Cull front
            Blend SrcAlpha OneMinusSrcAlpha
            HLSLPROGRAM
                    
            #pragma vertex edge_model
            #pragma fragment ps_edge
                    
                    
            //imports
            #include "Includes/HoyoToonHonkaiImpact-Import.hlsl"
                    
            //shader
            #include "Includes/HoyoToonHonkaiImpact-Common.hlsl"
            #include "Includes/HoyoToonHonkaiImpact-Program.hlsl"
                    
            ENDHLSL
        }
    }
    CustomEditor "Hoyo.ShaderEditor"
}
