Shader "Hidden/Locked/HoyoToon/Star Rail/Character/68ab7b50744734147a7fa4dc25699981"
{
    Properties 
    { 
		[HideInInspector] shader_master_bg ("UI/background", Float) = 0
        [HideInInspector] shader_master_logo ("UI/hsrlogo", Float) = 0
        [HideInInspector] shader_is_using_hoyeditor ("", Float) = 0
        [HideInInspector] footer_github ("{texture:{name:hoyogithub},action:{type:URL,data:https://github.com/Melioli/HoyoToon},hover:Github}", Float) = 0
		[HideInInspector] footer_discord ("{texture:{name:hoyodiscord},action:{type:URL,data:https://discord.gg/meliverse},hover:Discord}", Float) = 0
        [HoyoToonShaderOptimizerLockButton] _ShaderOptimizerEnabled ("Lock Material", Float) = 1
        [HoyoToonWideEnum(Base, 0, Face, 1, EyeShadow, 2, Hair, 3)]variant_selector("Material Type--{on_value_actions:[
		{value:0,actions:[{type:SET_PROPERTY,data:_BaseMaterial=1.0}, {type:SET_PROPERTY,data:_FaceMaterial=0.0}, {type:SET_PROPERTY,data:_EyeShadowMat=0.0}, {type:SET_PROPERTY,data:_HairMaterial=0.0}]},
        {value:0,actions:[{type:SET_PROPERTY,data:_CullMode=0}, {type:SET_PROPERTY,data:_SrcBlend=5}, {type:SET_PROPERTY,data:_DstBlend=10}]},
        {value:0,actions:[{type:SET_PROPERTY,data:_StencilPassA=2}, {type:SET_PROPERTY,data:_StencilPassB=0}, {type:SET_PROPERTY,data:_StencilCompA=0}]},
        {value:0,actions:[{type:SET_PROPERTY,data:_StencilCompB=0}, {type:SET_PROPERTY,data:_StencilRef=0}, {type:SET_PROPERTY,data:render_queue=2040}, {type:SET_PROPERTY,data:render_type=Opaque}]},
        {value:1,actions:[{type:SET_PROPERTY,data:_BaseMaterial=0.0}, {type:SET_PROPERTY,data:_FaceMaterial=1.0}, {type:SET_PROPERTY,data:_EyeShadowMat=0.0}, {type:SET_PROPERTY,data:_HairMaterial=0.0}]},
        {value:1,actions:[{type:SET_PROPERTY,data:_CullMode=2}, {type:SET_PROPERTY,data:_SrcBlend=1}, {type:SET_PROPERTY,data:_DstBlend=0}]},
        {value:1,actions:[{type:SET_PROPERTY,data:_StencilPassA=0}, {type:SET_PROPERTY,data:_StencilPassB=2}, {type:SET_PROPERTY,data:_StencilCompA=5}]},
        {value:1,actions:[{type:SET_PROPERTY,data:_StencilCompB=5}, {type:SET_PROPERTY,data:_StencilRef=100}, {type:SET_PROPERTY,data:render_queue=2010}, {type:SET_PROPERTY,data:render_type=Opaque}]},
        {value:2,actions:[{type:SET_PROPERTY,data:_BaseMaterial=0.0}, {type:SET_PROPERTY,data:_FaceMaterial=0.0}, {type:SET_PROPERTY,data:_EyeShadowMat=1.0}, {type:SET_PROPERTY,data:_HairMaterial=0.0}]},
        {value:2,actions:[{type:SET_PROPERTY,data:_CullMode=0}, {type:SET_PROPERTY,data:_SrcBlend=2}, {type:SET_PROPERTY,data:_DstBlend=0}]},
        {value:2,actions:[{type:SET_PROPERTY,data:_StencilPassA=0}, {type:SET_PROPERTY,data:_StencilPassB=2}, {type:SET_PROPERTY,data:_StencilCompA=0}]},
        {value:2,actions:[{type:SET_PROPERTY,data:_StencilCompB=8}, {type:SET_PROPERTY,data:_StencilRef=0}, {type:SET_PROPERTY,data:render_queue=2015}, {type:SET_PROPERTY,data:render_type=Opaque}]},
        {value:3,actions:[{type:SET_PROPERTY,data:_BaseMaterial=0.0}, {type:SET_PROPERTY,data:_FaceMaterial=0.0}, {type:SET_PROPERTY,data:_EyeShadowMat=0.0}, {type:SET_PROPERTY,data:_HairMaterial=1.0}]},
        {value:3,actions:[{type:SET_PROPERTY,data:_CullMode=0}, {type:SET_PROPERTY,data:_SrcBlend=1}, {type:SET_PROPERTY,data:_DstBlend=0}]},
        {value:3,actions:[{type:SET_PROPERTY,data:_StencilPassA=0}, {type:SET_PROPERTY,data:_StencilPassB=0}, {type:SET_PROPERTY,data:_StencilCompA=5}]},
        {value:3,actions:[{type:SET_PROPERTY,data:_StencilCompB=8}, {type:SET_PROPERTY,data:_StencilRef=100}, {type:SET_PROPERTY,data:render_queue=2020}, {type:SET_PROPERTY,data:render_type=Opaque}]}]}", Int) = 0
        [HideInInspector] [Toggle] _BaseMaterial ("Use Base Shader", Float) = 1 // on by default
        [HideInInspector] [Toggle] _FaceMaterial ("Use Face Shader", Float) = 0
        [HideInInspector] [Toggle] _EyeShadowMat ("Use EyeShadow Shader", Float) = 0
        [HideInInspector] [Toggle] _HairMaterial ("Use Hair Shader", Float) = 0
        [HideInInspector] m_start_main ("Main", Float) = 0
            [SmallTexture]_MainTex ("Diffuse Texture", 2D) = "white" {}
            [SmallTexture]_LightMap ("Light Map Texture", 2D) = "grey" {}
            [Toggle]_UseMaterialValuesLUT ("Enable Material LUT", Float) = 0
            [SmallTexture]_MaterialValuesPackLUT ("Mat Pack LUT--{condition_show:{type:PROPERTY_BOOL,data:_UseMaterialValuesLUT==1.0}}", 2D) = "white" {}
            [Toggle] _MultiLight ("Enable Lighting from Multiple Sources", Float) = 1
            [Toggle] _FilterLight ("Limit Spot/Point Light Intensity", Float) = 1 // because VRC world creators are fucking awful at lighting you need to do shit like this to not blow your models the fuck up
            [Toggle] _backfdceuv2 ("Back Face Use UV2", float) = 1
            [HideInInspector] m_start_mainalpha ("Alpha Options", Float) = 0
                [Toggle]_IsTransparent ("Enable Transparency", float) = 0
                [Toggle] _EnableAlphaCutoff ("Enable Alpha Cutoff", Float) = 0
                _AlphaTestThreshold ("Alpha Cutoff value", Range(0.0, 1.0)) = 0.0
            [HideInInspector] m_end_mainalpha ("", Float) = 0
            [HideInInspector] m_start_maincolor ("Color Options", Float) = 0
                _Color  ("Front Face Color", Color) = (1, 1, 1, 1)
                _BackColor ("Back Face Color", Color) = (1, 1, 1, 1)
                _Color0("Color 0", Color) = (1.0, 1.0, 1.0, 1.0)
                _Color1("Color 1", Color) = (1.0, 1.0, 1.0, 1.0)
                _Color2("Color 2", Color) = (1.0, 1.0, 1.0, 1.0)
                _Color3("Color 3", Color) = (1.0, 1.0, 1.0, 1.0)
                _Color4("Color 4", Color) = (1.0, 1.0, 1.0, 1.0)
                _Color5("Color 5", Color) = (1.0, 1.0, 1.0, 1.0)
                _Color6("Color 6", Color) = (1.0, 1.0, 1.0, 1.0)
                _Color7("Color 7", Color) = (1.0, 1.0, 1.0, 1.0)
            [HideInInspector] m_end_maincolor ("", Float) = 0
            [HideInInspector] m_start_facingdirection ("Facing Direction", Float) = 0
                _headUpVector ("Up Vector | XYZ", Vector) = (0, 1, 0, 0)
                _headForwardVector ("Forward Vector | XYZ", Vector) = (0, 0, 1, 0)
                _headRightVector ("Right Vector | XYZ ", Vector) = (-1, 0, 0, 0)
            [HideInInspector] m_end_facingdirection ("", Float) = 0
        [HideInInspector] m_end_main ("", Float) = 0
        [HideInInspector] m_start_faceshading("Face--{condition_show:{type:PROPERTY_BOOL,data:_FaceMaterial==1.0}}", Float) = 0
            [SmallTexture] _FaceMap ("Face Map Texture", 2D) = "white" {}
            [SmallTexture] _FaceExpression ("Face Expression map", 2D) = "black" {}
            _NoseLineColor ("Nose Line Color", Color) = (1, 1, 1, 1)
            _NoseLinePower ("Nose Line Power", Range(0, 8)) = 1
            [HideInInspector] m_start_faceexpression("Face Expression", Float) = 0
                _ExCheekColor ("Expression Cheek Color, ", Color) = (1.0, 1.0, 1.0, 1.0)
                _ExMapThreshold ("Expression Map Threshold", Range(0.0, 1.0)) = 0.5
                _ExSpecularIntensity ("Expression Specular Intensity", Range(0.0, 7.0)) = 0.0
                _ExCheekIntensity ("Expression Cheek Intensity", Range(0, 1)) = 0
                _ExShyColor ("Expression Shy Color", Color) = (1, 1, 1, 1)
                _ExShyIntensity ("Expression Shy Intensity", Range(0, 1)) = 0
                _ExShadowColor ("Expression Shadow Color", Color) = (1, 1, 1, 1)
                _ExShadowIntensity ("Expression Shadow Intensity", Range(0, 1)) = 0
            [HideInInspector] m_end_faceexpression("", Float) = 0
        [HideInInspector] m_end_faceshading("", Float) = 0 
        [HideInInspector] m_start_lighting("Lighting Options", Float) = 0
        [HideInInspector] m_end_lighting("", Int) = 0
        [HideInInspector] m_start_specialeffects("Special Effects", Float) = 0
        [HideInInspector] m_end_specialeffects("", Float) = 0
        [HideInInspector] m_start_renderingOptions("Rendering Options", Float) = 0
            [Enum(UnityEngine.Rendering.CullMode)] _CullMode ("Cull Mode", Float) = 2
            [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Source Blend", Int) = 1
            [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Destination Blend", Int) = 0
        [HideInInspector] m_end_renderingOptions("Rendering Options", Float) = 0
    }
    SubShader
    {
        Tags{ "RenderType"="Opaque" "Queue"="Geometry" }
        HLSLINCLUDE
        #define faceishadow
        #include "UnityCG.cginc"
        #include "UnityLightingCommon.cginc"
        #include "UnityShaderVariables.cginc"
        #include "Lighting.cginc"
        #include "AutoLight.cginc"
        #include "UnityInstancing.cginc"
        #include "/HoyoToonStarRail-inputs.hlsli"
        #include "/HoyoToonStarRail-declarations.hlsl"
        #include "/HoyoToonStarRail-common.hlsl"
        ENDHLSL
        Pass
        {
            Name "BasePass"
            Tags{ "LightMode" = "ForwardBase" }
            Cull [_CullMode]
            Blend [_SrcBlend] [_DstBlend]
            Stencil
            {
                ref 100              
        		Comp [_StencilCompA]
        		Pass [_StencilPassA]  
        	}
            HLSLPROGRAM
            #pragma multi_compile_fwdbase
            #define _IS_PASS_BASE
            #pragma vertex vs_base
            #pragma fragment ps_base
            #include "/HoyoToonStarRail-program.hlsl"
            ENDHLSL
        }
        Pass
        {
            Name "Light Pass"
            Tags{ "LightMode" = "ForwardAdd" }
            Cull [_Cull]
            ZWrite Off
            Blend One One
            HLSLPROGRAM
            #pragma multi_compile_fwdadd
            #define _IS_PASS_LIGHT
            #pragma vertex vs_base
            #pragma fragment ps_base 
            #include "/HoyoToonStarRail-program.hlsl"
            ENDHLSL
        }  
        Pass
        {
            Name "Shadow Pass"
            Tags{ "LightMode" = "ShadowCaster" }
            Cull [_Cull]
            Blend [_SrcBlend] [_DstBlend]
            HLSLPROGRAM
            #pragma multi_compile_fwdbase
            #pragma vertex vs_shadow
            #pragma fragment ps_shadow
            #include "/HoyoToonStarRail-program.hlsl"
            ENDHLSL
        } 
    }
    CustomEditor "HoyoToon.ShaderEditor"
}
