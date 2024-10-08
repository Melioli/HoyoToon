Shader "Hidden/HoyoToon/Post Processing/Bloom"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _IncludedLayers ("Included Layers", Int) = 0
        _IsReflectionCamera ("Is Reflection Camera", Float) = 0 // Add this line
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        HLSLINCLUDE
        #include "Includes/BloomDeclarations.hlsl"
        #include "Includes/BloomCommon.hlsl"

        
        ENDHLSL


        Pass
        {
            Name "White Balance"
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment ps_white_balance
            
            #include "UnityCG.cginc"
            #include "Includes/BloomProgram.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "Bloom Prefilter"
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment ps_downsample_pre
            
            #include "UnityCG.cginc"
            #include "Includes/BloomProgram.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "Bloom Horizontal Blur"
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment ps_bloom_blur_h
            
            #include "UnityCG.cginc"
            #include "Includes/BloomProgram.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "Bloom Vertical Blur"
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment ps_bloom_blur_v
            
            #include "UnityCG.cginc"
            #include "Includes/BloomProgram.hlsl"

            ENDHLSL
        }

        Pass 
        {
            Name "Bloom Atlas A Horizontal Blur"
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment ps_bloom_atlas_a_h
            
            #include "UnityCG.cginc"
            #include "Includes/BloomProgram.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "Bloom Atlas A Vertical Blur"
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment ps_bloom_atlas_a_v
            
            #include "UnityCG.cginc"
            #include "Includes/BloomProgram.hlsl"
            ENDHLSL
        }
        
        Pass 
        {
            Name "Bloom Atlas B Horizontal Blur"
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment ps_bloom_atlas_b_h
            
            #include "UnityCG.cginc"
            #include "Includes/BloomProgram.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "Bloom Atlas B Vertical Blur"
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment ps_bloom_atlas_b_v
            
            #include "UnityCG.cginc"
            #include "Includes/BloomProgram.hlsl"
            ENDHLSL
        }

        Pass 
        {
            Name "Bloom Atlas C Horizontal Blur"
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment ps_bloom_atlas_c_h
            
            #include "UnityCG.cginc"
            #include "Includes/BloomProgram.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "Bloom Atlas C Vertical Blur"
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment ps_bloom_atlas_c_v
            
            #include "UnityCG.cginc"
            #include "Includes/BloomProgram.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "Bloom Combine"
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment ps_bloom_combined
            
            #include "UnityCG.cginc"
            #include "Includes/BloomProgram.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "Tone Mapping"
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment ps_tone_mapping
            
            #include "UnityCG.cginc"
            #include "Includes/BloomProgram.hlsl"
            ENDHLSL
        }

    }
}
