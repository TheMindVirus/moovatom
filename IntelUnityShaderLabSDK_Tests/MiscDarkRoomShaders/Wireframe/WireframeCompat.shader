Shader "Custom/WireframeCompat"
{
    Properties
    {
        _Color("Chroma", Color) = (1.0, 1.0, 1.0, 1.0)
        _Thickness("Thickness", Float) = 1.0
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Opaque" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Front
        ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vertex_shader
            #pragma geometry geometry_shader
            #pragma fragment fragment_shader

            fixed4 _Color;
            fixed _Thickness;

            struct appdata_unity
            {
                fixed4 vertex : POSITION;
            };

            struct appdata_vertex
            {
                fixed4 vertex : VERTEX;
                fixed4 screen : SV_POSITION;
                fixed4 chroma : COLOR;
            };

            appdata_vertex vertex_shader(appdata_unity input)
            {
                appdata_vertex output;
                output.vertex = input.vertex;
                output.screen = UnityObjectToClipPos(input.vertex);
                output.chroma = fixed4(0.0, 0.0, 0.0, 0.0);
                return output;
            }

            [maxvertexcount(3)]
            void geometry_shader(triangle appdata_vertex input[3], inout TriangleStream<appdata_vertex> triangleStream)
            {
                input[0].chroma = fixed4(1.0, 0.0, 0.0, 1.0);
                input[1].chroma = fixed4(0.0, 1.0, 0.0, 1.0);
                input[2].chroma = fixed4(0.0, 0.0, 1.0, 1.0);

                triangleStream.Append(input[0]);
                triangleStream.Append(input[1]);
                triangleStream.Append(input[2]);
            }

            fixed4 fragment_shader(appdata_vertex input) : SV_Target
            {
                fixed thickness = 0.1 * _Thickness;
                fixed4 output = input.chroma;
                output.rgb = ((input.chroma.r < thickness)
                           || (input.chroma.g < thickness)
                           || (input.chroma.b < thickness)) ? 1.0 : 0.0;
                output.rgb *= _Color.rgb;
                output.a = _Color.a;
                return output;
            }
            ENDCG
        }

        Tags { "Queue" = "Transparent" "RenderType" = "Opaque" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Back
        ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vertex_shader
            #pragma geometry geometry_shader
            #pragma fragment fragment_shader

            fixed4 _Color;
            fixed _Thickness;

            struct appdata_unity
            {
                fixed4 vertex : POSITION;
            };

            struct appdata_vertex
            {
                fixed4 vertex : VERTEX;
                fixed4 screen : SV_POSITION;
                fixed4 chroma : COLOR;
            };

            appdata_vertex vertex_shader(appdata_unity input)
            {
                appdata_vertex output;
                output.vertex = input.vertex;
                output.screen = UnityObjectToClipPos(input.vertex);
                output.chroma = fixed4(0.0, 0.0, 0.0, 0.0);
                return output;
            }

            [maxvertexcount(3)]
            void geometry_shader(triangle appdata_vertex input[3], inout TriangleStream<appdata_vertex> triangleStream)
            {
                input[0].chroma = fixed4(1.0, 0.0, 0.0, 1.0);
                input[1].chroma = fixed4(0.0, 1.0, 0.0, 1.0);
                input[2].chroma = fixed4(0.0, 0.0, 1.0, 1.0);

                triangleStream.Append(input[0]);
                triangleStream.Append(input[1]);
                triangleStream.Append(input[2]);
            }

            fixed4 fragment_shader(appdata_vertex input) : SV_Target
            {
                fixed thickness = 0.1 * _Thickness;
                fixed4 output = input.chroma;
                output.rgb = ((input.chroma.r < thickness)
                           || (input.chroma.g < thickness)
                           || (input.chroma.b < thickness)) ? 1.0 : 0.0;
                output.rgb *= _Color.rgb;
                output.a = _Color.a;
                return output;
            }
            ENDCG
        }
    }
}