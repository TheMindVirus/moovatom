Shader "Unlit/Tex3D"
{
    Properties
    {
        _MainTex ("Texture", 3D) = "white" {}
        _Alpha ("Alpha", float) = 0.02
        _StepSize ("Step Size", float) = 0.01
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "LightMode" = "Always" }
        //Blend One OneMinusSrcAlpha
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off
        //LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vertex_shader
            #pragma fragment fragment_shader
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            //#include "AutoLight.cginc"
            //#include "UnityDeferredLibrary.cginc"
            //#include "UnityPBSLighting.cginc"

            #define RAYTRACE_SAMPLES   128
            #define EPSILON            0.00001f

            sampler3D _MainTex;
            float4 _MainTex_ST;
            float _Alpha;
            float _StepSize;

            struct vertex_data
            {
                float4 vertex : POSITION;
            };

            struct fragment_data
            {
                float4 vertex : SV_POSITION;
                float3 object : TEXCOORD0;
                float3 surface : TEXCOORD1;
                float3 world : WORLD_POSITION;
                float4 light : INCIDENT_LIGHT;
            };

            /*sampler2D _Ramp;
            half4 LightingRamp(SurfaceOutput s, half3 lightDir, half atten)
            {
                half NdotL = dot(s.Normal, lightDir);
                half diff = NdotL * 0.5f + 0.5f;
                half3 ramp = tex2D(_Ramp, float2(diff, 0.0f)).rgb;
                half4 c;
                c.rgb = s.Albedo * _LightColor0.rgb * ramp * atten;
                c.a = s.Alpha;
                return c;
            }*/

            float4 BlendUnder(float4 input, float4 value) //Blackmagic
            {
                float4 output = input;
                output.rgb += (1.0f - input.a) * value.a * value.rgb;
                output.a += (1.0f - input.a) * value.a;
                return output;
            }

            fragment_data vertex_shader(vertex_data input)
            {
                fragment_data output;
                output.object = input.vertex;
                output.world = mul(unity_ObjectToWorld, input.vertex).xyz;
                output.surface = output.world - _WorldSpaceCameraPos;
                output.vertex = UnityObjectToClipPos(input.vertex);
                output.light = _LightColor0;
                return output;
            }

            fixed4 fragment_shader(fragment_data input) : SV_Target
            {
                float4 output = float4(0.0f, 0.0f, 0.0f, 0.0f);
                float3 origin = input.object;
                float3 direction = mul(unity_WorldToObject, float4(normalize(input.surface), 1.0f));
                float3 position = origin;

                for (int i = 0; i < RAYTRACE_SAMPLES; ++i)
                {
                    if (max(abs(position.x), max(abs(position.y), abs(position.z))) < 0.5f + EPSILON)
                    {
                        float4 sampled = tex3D(_MainTex, position + float3(0.5f, 0.5f, 0.5f));
                        sampled.a *= _Alpha;
                        output = BlendUnder(output, sampled);
                        output.rgb *= _LightColor0.rgb; //input.light.rgb;
                        //output.rgb *= float3(0.95f, 0.95f, 0.95f);
                        position += direction * _StepSize;
                    }
                }
                return output;
            }
            ENDCG
        }
    }
}