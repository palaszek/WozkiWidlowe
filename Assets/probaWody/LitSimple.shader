Shader "Custom/URP/LitSimple"
{
    Properties
    {
        _BaseMap("Albedo", 2D) = "white" {}
        _BaseColor("Color", Color) = (1,1,1,1)

        _NormalMap("Normal Map", 2D) = "bump" {}
        _NormalScale("Normal Strength", Range(0,2)) = 1
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" "RenderPipeline"="UniversalPipeline" }

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
                float4 tangentOS  : TANGENT;
                float2 uv         : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS    : TEXCOORD1;
                float3 tangentWS   : TEXCOORD2;
                float3 bitangentWS : TEXCOORD3;
                float2 uv          : TEXCOORD0;
                float3 positionWS  : TEXCOORD4;
            };

            TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
            TEXTURE2D(_NormalMap); SAMPLER(sampler_NormalMap);

            float4 _BaseColor;
            float _NormalScale;

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                OUT.positionWS  = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.positionHCS = TransformWorldToHClip(OUT.positionWS);

                OUT.normalWS   = normalize(TransformObjectToWorldNormal(IN.normalOS));
                float3 tangentWS = normalize(TransformObjectToWorldDir(IN.tangentOS.xyz));
                OUT.tangentWS = tangentWS;
                OUT.bitangentWS = cross(OUT.normalWS, tangentWS) * IN.tangentOS.w;

                OUT.uv = IN.uv;
                return OUT;
            }

float4 frag(Varyings i) : SV_Target
{
    float4 albedo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv) * _BaseColor;

    float3 normalTS = UnpackNormalScale(
        SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, i.uv),
        _NormalScale
    );

    float3 normalWS = normalize(
        i.tangentWS * normalTS.x +
        i.bitangentWS * normalTS.y +
        i.normalWS * normalTS.z
    );

    // --- MAIN LIGHT (URP 7–10) ---
    Light mainLight = GetMainLight();

    float NdotL = saturate(dot(normalWS, mainLight.direction));

    float3 color = albedo.rgb * (mainLight.color * NdotL + 0.05);

    return float4(color, albedo.a);
}

            ENDHLSL
        }
    }
}
