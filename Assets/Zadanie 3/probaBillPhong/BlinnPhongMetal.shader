Shader "Custom/URP/BlinnPhongMetal"
{
    Properties
    {
        _BaseColor("Base Color", Color) = (0.8,0.8,0.8,1)
        _BaseMap("Albedo (RGB)", 2D) = "white" {}
        _NormalMap("Normal Map", 2D) = "bump" {}

        _SpecularIntensity("Specular Intensity", Range(0,1)) = 0.8
        _Shininess("Shininess", Range(1,100)) = 50
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" }

        Pass
        {
            Name "BlinnPhongPass"
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
                float3 normalWS    : TEXCOORD0;
                float3 tangentWS   : TEXCOORD1;
                float3 viewDirWS   : TEXCOORD2;
                float2 uv          : TEXCOORD3;
                float3 worldPos    : TEXCOORD4;
            };

            // --- textures ---
            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);

            // --- params ---
            float4 _BaseColor;
            float _SpecularIntensity;
            float _Shininess;

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                float3 worldPos = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.positionHCS = TransformWorldToHClip(worldPos);
                OUT.normalWS = normalize(TransformObjectToWorldNormal(IN.normalOS));
                OUT.tangentWS = normalize(TransformObjectToWorldDir(IN.tangentOS.xyz));
                OUT.viewDirWS = SafeNormalize(_WorldSpaceCameraPos - worldPos);
                OUT.uv = IN.uv;
                OUT.worldPos = worldPos;

                return OUT;
            }

float3 GetNormal(float2 uv, float3 N, float3 T)
{
    // Pobranie normal mapy
    float3 normalTex = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, uv).rgb;
    normalTex = normalTex * 2 - 1; // z [0,1] do [-1,1]

    // Bitangent
    float3 B = cross(N, T);

    // TBN
    float3x3 TBN = float3x3(T, B, N);
    return normalize(mul(TBN, normalTex));
}

float4 frag(Varyings i) : SV_Target
{
    // Normalka
    float3 N = GetNormal(i.uv, i.normalWS, i.tangentWS);
    float3 V = normalize(i.viewDirWS);

    // Pobranie koloru bazowego
    float3 albedo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv).rgb * _BaseColor.rgb;

    // Glowne oswietlenie
    Light mainLight = GetMainLight();
    float3 L = normalize(mainLight.direction);
    float3 H = normalize(L + V);

    // Diffuse
    float NdotL = saturate(dot(N,L));
    float3 diffuse = albedo * mainLight.color * NdotL;

    // Specular Blinn-Phong
    float NdotH = saturate(dot(N,H));
    float3 specular = mainLight.color * _SpecularIntensity * pow(NdotH,_Shininess);

    return float4(diffuse + specular, 1.0);
}

            ENDHLSL
        }
    }
}
