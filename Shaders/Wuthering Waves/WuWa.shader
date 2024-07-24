Shader "HoyoToon/Wuthering Waves/Character"
{
    Properties
    {
        // GUI THINGS
        [HideInInspector] shader_master_label ("✧<b><i><color=#C69ECE>HoyoToon Wuthering Waves</color></i></b>✧", Float) = 0
		[HideInInspector] shader_is_using_hoyeditor ("", Float) = 0
        [HideInInspector] footer_github ("{texture:{name:hoyogithub},action:{type:URL,data:https://github.com/Melioli/HoyoToon},hover:Github}", Float) = 0
		[HideInInspector] footer_discord ("{texture:{name:hoyodiscord},action:{type:URL,data:https://discord.gg/meliverse},hover:Discord}", Float) = 0

        [Enum(Base, 0, Face, 1, Eye, 2, Bangs, 3, Hair, 4)] _MaterialType ("Material Type--{on_value_actions:[
        {value:0,actions:[{type:SET_PROPERTY,data:_StencilPassA=2}, {type:SET_PROPERTY,data:_StencilPassB=0}, {type:SET_PROPERTY,data:_StencilCompA=0}]},
        {value:0,actions:[{type:SET_PROPERTY,data:_StencilCompB=0}, {type:SET_PROPERTY,data:_StencilRef=0}, {type:SET_PROPERTY,data:render_queue=2040}, {type:SET_PROPERTY,data:render_type=Opaque}]},

        {value:1,actions:[{type:SET_PROPERTY,data:_StencilPassA=0}, {type:SET_PROPERTY,data:_StencilPassB=2}, {type:SET_PROPERTY,data:_StencilCompA=5}]},
        {value:1,actions:[{type:SET_PROPERTY,data:_StencilCompB=5}, {type:SET_PROPERTY,data:_StencilRef=100}, {type:SET_PROPERTY,data:render_queue=2010}, {type:SET_PROPERTY,data:render_type=Opaque}]},

        {value:2,actions:[{type:SET_PROPERTY,data:_StencilPassA=0}, {type:SET_PROPERTY,data:_StencilPassB=2}, {type:SET_PROPERTY,data:_StencilCompA=5}]},
        {value:2,actions:[{type:SET_PROPERTY,data:_StencilCompB=5}, {type:SET_PROPERTY,data:_StencilRef=100}, {type:SET_PROPERTY,data:render_queue=2011}, {type:SET_PROPERTY,data:render_type=Opaque}]},

        {value:3,actions:[{type:SET_PROPERTY,data:_StencilPassA=0}, {type:SET_PROPERTY,data:_StencilPassB=0}, {type:SET_PROPERTY,data:_StencilCompA=5}]},
        {value:3,actions:[{type:SET_PROPERTY,data:_StencilCompB=8}, {type:SET_PROPERTY,data:_StencilRef=100}, {type:SET_PROPERTY,data:render_queue=2020}, {type:SET_PROPERTY,data:render_type=Opaque}]},
        
        {value:4,actions:[{type:SET_PROPERTY,data:_StencilPassA=2}, {type:SET_PROPERTY,data:_StencilPassB=0}, {type:SET_PROPERTY,data:_StencilCompA=0}]},
        {value:4,actions:[{type:SET_PROPERTY,data:_StencilCompB=0}, {type:SET_PROPERTY,data:_StencilRef=0}, {type:SET_PROPERTY,data:render_queue=2040}, {type:SET_PROPERTY,data:render_type=Opaque}]}]}", Float) = 0
        [HideInInspector] m_start_main ("Main", Float) = 0
            [HideInInspector] m_start_coretex ("Main Textures", Float) = 0
                [HideInInspector] m_start_diff ("Diffuse Texture", Float) = 0
                    _MainTex ("Diffuse Texture", 2D) = "white" {}
                    [Toggle] _UseMainTexA ("Alpha is Toon Mask", Float) = 0
                [HideInInspector]  m_end_diff ("", Float) = 0
                [HideInInspector] m_start_mask ("Type Mask", Float) = 0
                    _MaskTex ("Mask", 2D) = "grey" {}
                    [Toggle] _UseSDFShadow ("Use SDF Shadow", Float) = 0
                [HideInInspector] m_end_mask ("", Float) = 0
                [HideInInspector] m_start_type ("ID Mask", Float) = 0
                    _TypeMask ("Type Mask (ID)", 2D) = "grey" {}
                    [Toggle] _UseSkinMask ("Skin Mask Enable", Float) = 0
                    [Toggle] _UseRampMask ("Ramp Mask Enable", Float) = 0
                [HideInInspector] m_end_type ("", Float) = 0
                [HideInInspector] m_start_nrm("Normal|Roughness|Metal", Float) = 0
                    _Normal_Roughness_Metallic ("Normal Map(RG)|Roughness(B)|Metallic(G)", 2D) = "bump" {}
                [HideInInspector] m_end_nrm("", Float) = 0
            [HideInInspector] m_end_coretex ("", Float) = 0
            [HideInInspector] m_start_coloring ("Colors", Float) = 0
                _BaseColor ("Base Color", Color) = (1,1,1,1)
                _SkinColor ("Skin Color", Color) = (1,1,1,1)
                _SubsurfaceColor ("Subsurface Color", Color) = (0.5,0.5,0.5,1)
                _SkinSubsurfaceColor ("Skin Subsurface Color", Color) = (0.9387,0.6038,0.4072,1.0)
            [HideInInspector] m_end_coloring ("", Float) = 0
            [HideInInspector] m_start_facingdirection ("Facing Direction", Float) = 0
                _headUpVector ("Up Vector | XYZ", Vector) = (0, 1, 0, 0)
                _headForwardVector ("Forward Vector | XYZ", Vector) = (0, 0, 1, 0)
                _headRightVector ("Right Vector | XYZ ", Vector) = (-1, 0, 0, 0)
            [HideInInspector] m_end_facingdirection ("", Float) = 0
        [HideInInspector] m_end_main ("", Float) = 0
        [HideInInspector] m_start_bump("Normal|Roughness|Metal", Float) = 0
            [Toggle] _UseNormalMap ("Enable Bump Mapping", Float) = 0
            [Toggle] _NormalFlip ("Enable Bump Mapping", Float) = 0
            _NormalStrength ("Bump Strength", Float) = 1
        [HideInInspector] m_end_bump("", Float) = 0

        [HideInInspector] m_start_spec("Specular", Float) = 0
            [Toggle] _UseToonSpecular ("Use Toon Specular", Float) = 0
            _SpecularPower ("Specular Power", Float) = 1
            _SpecStrength ("Specular Strength", Float) = 0.2 
            [HideInInspector] m_start_matcap ("Metal MatCap", Float) = 0
                _MetalSpecularPower ("Metal Specular Power", Float) = 1
                _MatCapTex ("MatCap Texture", 2D) = "black" {}
                _MetalMatCapBack ("Metal MatCap Back Intensity", Float) = 1
                _MatCapInt ("MatCap Intensity", Float) = 1
                _MetalMatCapInt ("Metal MatCap Intensity", Float) = 1
            [HideInInspector] m_end_matcap ("", Float) = 0
        [HideInInspector] m_end_spec("", Float) = 0

        [HideInInspector] m_start_rim ("Rim Light", Float) = 0
            [Toggle] _EnableRim ("Use Rim Lighting", Float) = 0
            _RimWidth ("Rim Width", Float) = 1
        [HideInInspector] m_end_rim ("", Float) = 0

        [HideInInspector] m_start_stock ("Stocking", Float) = 0
            [Toggle] _UseStocking ("Enable Stocking", Float) = 0
            _AnistropyColor ("Anisotropic Highlight Color", Color) = (0.0139, 0.0139, 0.0139, 1.0)
            _StockingLightColor ("", Color) = (0.0139, 0.0139, 0.0139, 1.0)
            _StockingEdgeColor ("Stocking Edge Color", Color) = (0.609,0.542,0.596,1.0)
            _StockingColor ("Stocking Color", Color) = (0.731,0.689,0.739,1.0)
            _AnistropyInt ("", Float) = 1
            _AnistropyNormalInt ("", Float) = 1
            _Stocking_KneeSkinIntensityOffset ("", Float) = 0.1
            _Stocking_KneeSkinRangeOffset ("", Float) = 2
            _StockingIntensity ("", Float) = 1.0
            _StockingLightRangeMax ("", Float) = 1
            _StockingLightRangeMin ("", Float) = 0.4
            _StockingRangeMax ("", Float) = 1.0
            _StockingRangeMiddle ("", Float) = 0.48
            _StockingRangeMin ("", Float) = 0.4
            _StockingSkinRange ("", Float) = 6
        [HideInInspector] m_end_stock ("Stocking", Float) = 0

        [HideInInspector] m_start_eye ("Eye", Float) = 0
            _EyeScale ("Eye Scale", Float) = 0.8
            _HeightRatioInput ("Highlight Ratio", Float) = 0.4
            [HideInInspector] m_start_eyetex ("Eye", Float) = 0
                _HeightLightMap ("Highlight Map", 2D) = "black" {}
                _EM ("Highlight EM Map", 2D) = "black" {}
            [HideInInspector] m_end_eyetex ("", Float) = 0
            [HideInInspector] m_start_hlight ("Highlight", Float) = 0
                _RotateAngle ("Rotation Angle", Float) = 0.11
                _LightShakeScale ("Light Shake Scale", Float) = 0.01
                _LightShakeSpeed ("Light Shake Speed", Float) = 10
                _LightShakPositionX ("Light Shake X", Float) = 0.5
                _LightShakPositionY ("Light Shake Y", Float) = 0.5
                _SecondLight_PositionX ("Secont Light Position X", Float) = 0.5
                _SecondLight_PositionY ("Secont Light Position Y", Float) = 0.5
                _LightPositionX ("Light Position X", Float) = 0.5
                _LightPositionY ("Light Position Y", Float) = 0.5
                _UseHeightLightShape ("Use Highlight Shape", Float) = 0.5
                _UseEyeSDF ("Use Eye SDF", Float) = 0.5
                _HeightLight_PositionX ("Highlight Pos X", Float) = 0.54
                _HeightLight_PositionY ("Highlight Pos Y", Float) = 0.58 
                _HeightLight_WidthX ("Highlight Width X", Float) = 1.71
                _HeightLight_WidthY ("HighLight Width Y", Float) = 1.03
            [HideInInspector] m_end_hlight ("", Float) = 0
            [HideInInspector] m_start_parallax ("Parallax", Float) = 0
                _ParallaxSteps ("Step Count", Int) = 25 
                _ParallaxHeight ("Parallax Height", Float) = 0.2
            [HideInInspector] m_end_parallax ("", Float) = 0
        [HideInInspector] m_end_eye ("", Float) = 0
        
        [HideInInspector] m_start_shadow ("Shadow", Float) = 0
            
            _ShadowProcess ("Shadow Process", Float) = 0.55
            _BackShadowProcessOffset ("Back Shadow Offset", Float) = -0.1
            _FrontShadowProcessOffset ("Front Shadow Offset", Float) = 0.4
            _ShadowOffsetPower ("Shadow Offset Power", Float) = 0.56
            _MaskShadowOffsetStrength ("Mask Shadow Offset Strength", Float) = .42
            _ShadowWidth ("Shadow Width", Float) = 0.01
            _SolidShadowWidth ("Solid Shadow Width", Float) = 0.9
            _SolidShadowProcess ("Solid Shadow Process", Float) = 0.1
            _SolidShadowStrength ("Solid Shadow Strength", Float) = 1
            [HideInInspector] m_start_ramp ("Shadow Ramp", Float) = 0
                [Toggle] _UseRampColor ("Use Shadow Ramp", Float) = 0
                _Ramp ("Shadow Ramp", 2D) = "white" {}
                _RampPosition ("Ramp Position", Float) = 0.5
                _RampProcess ("Ramp Process", Float) = 0.5 
                _RampWidth ("Ramp Width", Float) = 0.1
                _RampInt ("Ramp Intensity", Float) = 0.3
            [HideInInspector] m_end_ramp ("", Float) = 0
            [HideInInspector] m_start_hair ("Hair Shadow", Float) = 0
                [Toggle] _EnableHairShadow ("Enable Hair Shadow", Float) = 0
                _HairShadowColor("Hair Subsurface Color", Color) = (0.938686,0.603828,0.40724,1.0)
            [HideInInspector] m_end_hair ("", Float) = 0
        [HideInInspector] m_end_shadow ("", Float) = 0

        [HideInInspector] m_start_outline ("Outline", Float) = 0
            [Enum(Off, 0, Tangent, 1, Normal, 2)] _Outline ("Outline Type", Float) = 1
            _OutlineWidth ("Outline Width", Float) = 0.11
            _OutlineTexture ("Outline Texture", 2D) = "white" {}
            _OutlineColor ("Outline Color", Color) = (0.765, 0.765, 0.765, 1.0)
            [Toggle] _UseMainTex ("Use Outline Texture", Float) = 1
        [HideInInspector] m_end_outline ("", Float) = 0

        [HideInInspector] m_start_special ("Special Effects", Float) = 0
            [HideInInspector] m_start_stencil ("Stencil", Float) = 0
            [Toggle] _EnabelStencil ("Enable Stencil", Float) = 1 
                _StencilMask ("Stencil Mask", 2D) = "white" {}
                [Enum(UnityEngine.Rendering.StencilOp)] _StencilPassA ("Stencil Pass Op A", Float) = 0
                [Enum(UnityEngine.Rendering.StencilOp)] _StencilPassB ("Stencil Pass Op B", Float) = 0
                [Enum(UnityEngine.Rendering.CompareFunction)] _StencilCompA ("Stencil Compare Function A", Float) = 8
                [Enum(UnityEngine.Rendering.CompareFunction)] _StencilCompB ("Stencil Compare Function B", Float) = 8
                [IntRange] _StencilRef ("Stencil Reference Value", Range(0, 255)) = 0
            [HideInInspector] m_end_stencil ("", Float) = 0
        [HideInInspector] m_end_special ("", Float) = 0
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        HLSLINCLUDE
        #include "UnityCG.cginc"
        #include "UnityLightingCommon.cginc"
        #include "UnityShaderVariables.cginc"
        #include "Lighting.cginc"
        #include "AutoLight.cginc"
        #include "UnityInstancing.cginc"
        #include "include/declaration.hlsl"
        #include "include/common.hlsl"
        #include "include/input.hlsl"
        

        ENDHLSL

        // Pass
        // {
        //     Name "Character Stencil Shadow"
        //     Tags{ "LightMode" = "ForwardBase" }
        //     // portal
        //     // ZTest Less
        //     // ZClip False
        //     ZWrite Off
        //     ColorMask 0

        //     Stencil
        //     {
        //         Ref 102
        //         Comp Greater
        //         Pass replace
        //         Fail replace
        //         ZFail replace
        //     }
        //     HLSLPROGRAM
        //     #pragma multi_compile_fwdbase
        //     #pragma multi_compile _is_shadow
        //     #pragma vertex vs_model
        //     #pragma fragment ps_model
        //     #include "include/program.hlsl"
        //     ENDHLSL
        // }

        // Pass
        // {
        //     Name "Character Face Shadow"
        //     Tags{ "LightMode" = "ForwardBase" }
        //     Blend DstColor Zero
        //     // Blend One Zero
            
        //     Stencil
        //     {
        //         Ref 104
        //         Comp Always
        //         Pass keep
        //         Fail replace
        //         ZFail keep
        //     }
        //     HLSLPROGRAM
        //     #pragma multi_compile_fwdbase
        //     #pragma multi_compile _is_face_shadow
        //     #pragma vertex vs_model
        //     #pragma fragment ps_model
        //     #include "include/program.hlsl"
        //     ENDHLSL
        // }

        Pass
        {
            Name "Character"
            Tags{ "LightMode" = "ForwardBase" }
            
            Blend One Zero
            Stencil
            {
				ref [_StencilRef]  
                Comp [_StencilCompA]
				Pass [_StencilPassA]
			}
            HLSLPROGRAM
            #pragma multi_compile_fwdbase
            #pragma vertex vs_model
            #pragma fragment ps_model
            #include "include/program.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "Stencil"
            Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha OneMinusSrcAlpha
            Stencil
            {
                ref [_StencilRef]              
				Comp [_StencilCompB]
				Pass [_StencilPassB]
			}
            HLSLPROGRAM
            #define is_stencil
            #pragma multi_compile_fwdbase
            #pragma vertex vs_model
            #pragma fragment ps_model
            #include "include/program.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "Outline"
            Cull Front
            Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha OneMinusSrcAlpha
            ZClip False
            Stencil
            {
				ref [_StencilRef]  
                Comp [_StencilCompA]
				Pass [_StencilPassA]
			}
            HLSLPROGRAM
            #pragma multi_compile_fwdbase
            #pragma vertex vs_edge
            #pragma fragment ps_edge
            #include "include/program.hlsl"
            ENDHLSL
        }

        
        
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
    CustomEditor "HoyoToon.ShaderEditor"
}
