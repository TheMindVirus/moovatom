Shader "Toon/TwoTone"
{
    Properties
    {
        _Color ("Color", Color) = (0.0, 0.0, 1.0, 1.0)
        _Auxiliary ("Auxiliary", Color) = (1.0, 1.0, 1.0, 1.0)
        _Threshold ("Threshold", Range(0, 2)) = 1.0

        _Emission ("Emission", Float) = (1.0, 1.0, 1.0, 1.0)
        _Normal ("Normal", Float) = (1.0, 1.0, 1.0, 1.0)

        _Specular ("Specular", Range(0, 1)) = 1
        _Gloss ("Gloss", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
            
        CGPROGRAM
        #pragma surface surface Model alpha:blend
        #include "UnityLightingCommon.cginc"
        #include "UnityGlobalIllumination.cginc"

        fixed4 _Color;
        fixed4 _Auxiliary;
        fixed _Threshold;

        fixed3 _Emission;
        fixed3 _Normal;

        fixed _Specular;
        fixed _Gloss;
    
        //half4 LightingModel(SurfaceOutput s, half3 lightDir, half atten) //Lambert BlinnPhong Built-In
        half4 LightingModel(SurfaceOutput s, half3 viewDir, UnityGI gi)
        {
            //return half4((s.Albedo.rgb * 0.5) + (gi.light.color * 0.5), s.Alpha);
            //return half4(s.Albedo.rgb * ((gi.light.color > 0) ? 1.0 : 0.5), s.Alpha);

            fixed intensity = (gi.light.color.r + gi.light.color.g + gi.light.color.b) / 3.0;

            //return half4((intensity < _Threshold) ? _Color.rgba : _Auxiliary.rgba);
            //fixed attenuation = dot(s.Normal, viewDir) * atten; // * _LightColor0.rgb; //Lambert

            fixed attenuation = gi.light.color;
            fixed lighting = dot(s.Normal * 10, viewDir) * attenuation;
            fixed threshold = _Threshold;
            return half4((lighting < threshold) ? _Color - intensity : _Auxiliary + intensity);

            //return half4(attenuation, attenuation, attenuation, 1.0);
            //return half4(s.Albedo.rgb * ((false) ? 1.0 : 0.3), s.Alpha);
        }

        //half3 LightingModel_GI(SurfaceOutput s, UnityGIInput data, inout UnityGI gi)
        void LightingModel_GI(SurfaceOutput s, UnityGIInput data, inout UnityGI gi)
        {
            //gi.light.color = data.light.color;
            //gi.light.dir = data.light.dir;
            //gi.light.ndotl = data.light.ndotl;
            //gi.indirect.diffuse = 1.0 - s.Specular
            //gi.indirect.specular = s.Specular;
            //data.worldPos = float3(0, 0, 0);
            //data.worldViewDir = half3(0, 0, 0);
            //data.atten = half(0);
            //data.ambient = half3(0, 0, 0);
            //data.lightmapUV = float4(0, 0, 0, 0); //uv0.xy, uv1.xy
#if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION) || defined(UNITY_ENABLE_REFLECTION_BUFFERS)
            //data.boxMin[0] = float4(0, 0, 0, 0);
            //data.boxMin[1] = float4(0, 0, 0, 0);
#endif
#ifdef UNITY_SPECCUBE_BOX_PROJECTION
            //data.boxMax[0] = float4(0, 0, 0, 0);
            //data.boxMax[1] = float4(0, 0, 0, 0);
            //data.probePosition[0] = float4(0, 0, 0, 0);
            //data.probePosition[1] = float4(0, 0, 0, 0);
#endif
            //data.probeHDR[0] = float4(0, 0, 0, 0);
            //data.probeHDR[1] = float4(0, 0, 0, 0);
            //return s.color;
        }
    
        struct Input
        {
            fixed4 color : COLOR;
            //float2 uv_MainTex;
            //float2 uv_DecalTex;
            //float2 uv_BumpMap;
            //float2 uv_Detail;
            //float3 viewDir;
            //float3 worldPos;
            //float3 worldRefl;
            //INTERNAL_DATA;
        };

        void surface(Input IN, inout SurfaceOutput o)
        {
            o.Albedo = IN.color.rgb;
            o.Alpha = IN.color.a;
            //o.Albedo = _Color.rgb;
            //o.Alpha = _Color.a;
            o.Emission = _Emission;
            o.Normal = _Normal;
            o.Specular = _Specular;
            o.Gloss = _Gloss;
        }
        ENDCG
    }
}