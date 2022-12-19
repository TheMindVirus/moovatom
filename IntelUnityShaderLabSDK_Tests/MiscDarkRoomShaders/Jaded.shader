Shader "Custom/Jaded"
{
    Properties
    {
        [HDR] _Emission("Emission", Color) = (1.0, 1.0, 1.0, 1.0)
        _Debug("Debug", Vector) = (1.1, 0.0, 0.0, 0.0)
    }
    SubShader
    {
        Tags { "Queue" = "Overlay" "RenderType" = "Opaque" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vertex_shader
            #pragma fragment fragment_shader

            fixed4 _Emission;

            struct appdata_unity
            {
                fixed4 vertex : POSITION;
            };

            struct appdata_vertex
            {
                fixed4 vertex : VERTEX;
                fixed4 screen : SV_POSITION;
            };

            struct appdata_fragment
            {
                fixed4 chroma : SV_TARGET;
            };

            appdata_vertex vertex_shader(appdata_unity input)
            {
                appdata_vertex output;
                output.vertex = input.vertex;
                output.screen = UnityObjectToClipPos(output.vertex);
                return output;
            }

            appdata_fragment fragment_shader(appdata_vertex input)
            {
                appdata_fragment output;
                output.chroma = _Emission;
                return output;
            }
            ENDCG
        }

        GrabPass { "_MainTex" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vertex_shader
            #pragma geometry geometry_shader
            #pragma fragment fragment_shader
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            fixed4 _MainTex_ST;
            fixed4 _Emission;
            fixed4 _Debug;

            struct appdata_unity
            {
                fixed4 vertex : POSITION;
                fixed4 uv : TEXCOORD0;
            };

            struct appdata_vertex
            {
                fixed4 vertex : VERTEX;
                fixed4 screen : SV_POSITION;
                fixed4 uv : TEXCOORD0;
            };

            struct appdata_geometry
            {
                fixed4 vertex : SV_POSITION;
                fixed4 uv : TEXCOORD0;
            };

            struct appdata_fragment
            {
                fixed4 chroma : SV_TARGET;
            };

            appdata_vertex vertex_shader(appdata_unity input)
            {
                appdata_vertex output;
                output.vertex = input.vertex;
                output.screen = output.vertex;
                output.uv = input.uv;
                return output;
            }

            [maxvertexcount(4)] void geometry_shader(point appdata_vertex input[1], inout TriangleStream<appdata_geometry> triangles)
            {
                appdata_geometry geometry[4];

                geometry[0].vertex = fixed4(-1.0,  1.0, 0.0, 1.0);
                geometry[1].vertex = fixed4(-1.0, -1.0, 0.0, 1.0);
                geometry[2].vertex = fixed4( 1.0,  1.0, 0.0, 1.0);
                geometry[3].vertex = fixed4( 1.0, -1.0, 0.0, 1.0);

                geometry[0].uv = ComputeGrabScreenPos(geometry[0].vertex);
                geometry[1].uv = ComputeGrabScreenPos(geometry[1].vertex);
                geometry[2].uv = ComputeGrabScreenPos(geometry[2].vertex);
                geometry[3].uv = ComputeGrabScreenPos(geometry[3].vertex);

                triangles.Append(geometry[0]);
                triangles.Append(geometry[1]);
                triangles.Append(geometry[2]);
                triangles.Append(geometry[3]);
            }

            appdata_fragment fragment_shader(appdata_geometry input)
            {
                appdata_fragment output;
                //output.chroma = ((((((((tex2D(_MainTex, input.uv)
                //              + tex2D(_MainTex, input.uv * fixed2(1.01, 1.01))) / 2.0)
                //              + tex2D(_MainTex, input.uv * fixed2(1.01, 0.99))) / 2.0)
                //              + tex2D(_MainTex, input.uv * fixed2(0.99, 0.99))) / 2.0)
                //              + tex2D(_MainTex, input.uv * fixed2(0.99, 1.01))) / 2.0);
                output.chroma = (tex2D(_MainTex, input.uv)
                              +  tex2D(_MainTex, input.uv * fixed2(1.01, 1.01))
                              +  tex2D(_MainTex, input.uv * fixed2(1.01, 0.99))
                              +  tex2D(_MainTex, input.uv * fixed2(0.99, 0.99))
                              +  tex2D(_MainTex, input.uv * fixed2(0.99, 1.01))) / 5.0;
                return output;
            }
            ENDCG
        }
    }
}
