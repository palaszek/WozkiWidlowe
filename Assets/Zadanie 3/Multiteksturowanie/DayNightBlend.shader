Shader "Custom/URP_DayNightBlend"
{
    Properties
    {
        _DayTex   ("Day Texture",   2D) = "white" {}
        _NightTex ("Night Texture", 2D) = "black" {}
        _Blend    ("Blend", Range(0,1)) = 0
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "Queue"="Geometry"
            "RenderPipeline"="UniversalPipeline"
        }

        Pass
        {
            Name "Forward"
            Tags { "LightMode"="UniversalForward" }

            Cull Front

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv         : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv          : TEXCOORD0;
            };

            TEXTURE2D(_DayTex);
            SAMPLER(sampler_DayTex);

            TEXTURE2D(_NightTex);
            SAMPLER(sampler_NightTex);

            float4 _DayTex_ST;
            float4 _NightTex_ST;

            float _Blend;

            Varyings vert (Attributes IN)
            {
                Varyings OUT;

                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _DayTex);

                return OUT;
            }

            half4 frag (Varyings IN) : SV_Target
            {
                half4 dayCol   = SAMPLE_TEXTURE2D(_DayTex,   sampler_DayTex,   IN.uv);
                half4 nightCol = SAMPLE_TEXTURE2D(_NightTex, sampler_NightTex, IN.uv);

                return lerp(dayCol, nightCol, _Blend);
            }

            ENDHLSL
        }
    }
}
