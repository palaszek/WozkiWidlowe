Shader "Custom/URP/WaterFull"
{
    Properties
    {
        _BaseColor("Water Color", Color) = (0.0,0.3,0.5,0.5)
        _BaseMap("Albedo", 2D) = "white" {}

        _WaveAmplitude("Wave Height", Range(0,1)) = 0.2
        _WaveFrequency("Wave Frequency", Range(0,10)) = 2.0
        _WaveSpeed("Wave Speed", Range(0,5)) = 1.0

        _SpecularIntensity("Specular Intensity", Range(0,1)) = 0.5
        _Shininess("Shininess", Range(1,100)) = 30
        _FresnelPower("Fresnel Power", Range(0,5)) = 3

        _ReflectionCube("Reflection Cubemap", Cube) = "" {}
        _DepthColor("Deep Color", Color) = (0,0.1,0.2,1)
        _SurfaceColor("Surface Color", Color) = (0.2,0.4,0.6,1)
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "RenderPipeline"="UniversalPipeline" }

        Pass
        {
            Name "WaterRealistic"
            Tags { "LightMode"="UniversalForward" }

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
                float2 uv         : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS    : TEXCOORD1;
                float3 viewDirWS   : TEXCOORD2;
                float2 uv          : TEXCOORD0;
                float3 worldPos    : TEXCOORD3;
            };

            // --- Textures ---
            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            samplerCUBE _ReflectionCube;

            // --- Parameters ---
            float4 _BaseColor;
            float _WaveAmplitude;
            float _WaveFrequency;
            float _WaveSpeed;
            float _SpecularIntensity;
            float _Shininess;
            float _FresnelPower;
            float4 _DepthColor;
            float4 _SurfaceColor;

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                float3 pos = IN.positionOS.xyz;

                // --- SIMPLE SIN WAVES ---
                float wave = sin(pos.x * _WaveFrequency + _Time.y * _WaveSpeed)
                           + cos(pos.z * _WaveFrequency + _Time.y * _WaveSpeed);
                pos.y += wave * _WaveAmplitude;

                float3 worldPos = TransformObjectToWorld(pos);
                OUT.worldPos    = worldPos;
                OUT.positionHCS = TransformWorldToHClip(worldPos);
                OUT.normalWS    = normalize(TransformObjectToWorldNormal(IN.normalOS));
                OUT.viewDirWS   = SafeNormalize(_WorldSpaceCameraPos - worldPos);
                OUT.uv          = IN.uv;

                return OUT;
            }

            float4 frag(Varyings i) : SV_Target
            {
                float3 N = normalize(i.normalWS);
                float3 V = normalize(i.viewDirWS);

                // --- Base color with depth gradient ---
                float4 tex = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
                float t = saturate(i.worldPos.y);
                float4 baseColor = lerp(_DepthColor, _SurfaceColor, t) * tex;
                float3 color = baseColor.rgb;

                // --- Main directional light ---
                Light mainLight = GetMainLight();
                float3 L = mainLight.direction;
                float NdotL = saturate(dot(N,L));
                float3 diffuse = color * mainLight.color * NdotL;

                // --- Specular (Blinn-Phong) ---
                float3 H = normalize(L + V);
                float NdotH = saturate(dot(N,H));
                float3 specular = mainLight.color * _SpecularIntensity * pow(NdotH,_Shininess);

                // --- Fresnel ---
                float fresnel = pow(1 - saturate(dot(N,V)), _FresnelPower);

                // --- Reflection cubemap ---
                float3 R = reflect(-V,N);
                float3 reflection = texCUBE(_ReflectionCube, R).rgb;

                // --- Combine all ---
                float3 finalColor = diffuse + specular * fresnel + reflection * fresnel;

                return float4(finalColor, baseColor.a);
            }

            ENDHLSL
        }
    }
}
