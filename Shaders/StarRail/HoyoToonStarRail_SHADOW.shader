Shader "HoyoToon/StarRail/Shadow"
{
    Properties
    {
        [Enum(UnityEngine.Rendering.CullMode)] _CullMode ("Cull Mode", Float) = 2
        _Color  ("Front Face Color", Color) = (1, 1, 1, 1)

    }
    SubShader
    {
        Tags{ "RenderType"="Opaque" "Queue"="Geometry" }

        // ZWrite [_ZWrite]

        HLSLINCLUDE
        

        #pragma multi_compile _ UNITY_HDR_ON
        #pragma multi_compile_fog
        #define SHADOW_MATERIAL

        #include "UnityCG.cginc"
        #include "UnityLightingCommon.cginc"
        #include "UnityShaderVariables.cginc"

        #include "HoyoToonStarRail-inputs.hlsli"

        // ============================================
        // common properties 
        // -------------------------------------------
        // COLORS
        float4 _Color;

        ENDHLSL

        Pass
        {
            Name "ForwardBase"
            Tags{ "LightMode" = "ForwardBase" }
            Blend 0 DstColor Zero, DstColor Zero
            ZWrite Off
			Stencil {
				Comp Equal
				Pass Keep
				Fail Keep
				ZFail Keep
			}

            Cull [_Cull]

            // Blend [_SrcBlend] [_DstBlend]

            HLSLPROGRAM

            #pragma multi_compile_fwdbase
            
            #pragma vertex vs_base
            #pragma fragment ps_shadow

            #include "HoyoToonStarRail-main.hlsl"

            ENDHLSL
        }

    }
}
