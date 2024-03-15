Shader "Hidden/HoyoToon/HI3Depth" // theirs is more in depth, but it's unlikely we'll need their oddly specific one
{
    Properties
    {
    }
    SubShader
    {
        Tags { "LIGHTMODE" = "SHADOWCASTER" }
        LOD 100
        Pass
        {
            Name "ShadowCast"
            Tags { "LIGHTMODE" = "SHADOWCASTER" }
            Cull Off
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 pos : POSITION;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
            };


            v2f vert (appdata i)
            {
                v2f o;
                o.pos = mul(UNITY_MATRIX_MVP, i.pos);

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 col = float4(0.0f, 0.0f, 0.0f, 0.0f);
                return col;
            }
            ENDHLSL
        }
    }
}
