Shader "Custom/Outline"
{
    Properties
    {
        _Color("Chroma", Color) = (1.0, 1.0, 1.0, 1.0)
        _Thickness("Thickness", Float) = 1.0
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Opaque" }
        //Blend SrcAlpha OneMinusSrcAlpha
        Cull Off ZWrite Off ZTest Always

        GrabPass { "_Background" }

        Pass //Black1
        {
            CGPROGRAM
            #pragma vertex vertex_shader
            #pragma geometry geometry_shader
            #pragma fragment fragment_shader

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

            [maxvertexcount(4)] void geometry_shader(triangle appdata_vertex input[3], inout TriangleStream<appdata_geometry> triangles)
            {
                appdata_geometry geometry[4];

                geometry[0].vertex = fixed4(-1.0,  1.0, 0.0, 1.0);
                geometry[1].vertex = fixed4(-1.0, -1.0, 0.0, 1.0);
                geometry[2].vertex = fixed4( 1.0,  1.0, 0.0, 1.0);
                geometry[3].vertex = fixed4( 1.0, -1.0, 0.0, 1.0);

                geometry[0].uv = fixed4(0.0, 0.0, 0.0, 1.0);
                geometry[1].uv = fixed4(0.0, 1.0, 0.0, 1.0);
                geometry[2].uv = fixed4(1.0, 0.0, 0.0, 1.0);
                geometry[3].uv = fixed4(1.0, 1.0, 0.0, 1.0);

                triangles.Append(geometry[0]);
                triangles.Append(geometry[1]);
                triangles.Append(geometry[2]);
                triangles.Append(geometry[3]);
            }

            appdata_fragment fragment_shader(appdata_geometry input)
            {
                appdata_fragment output;
                output.chroma = fixed4(0.0, 0.0, 0.0, 1.0);
                return output;
            }
            ENDCG
        }

        Pass //Clipping1
        {
            CGPROGRAM
            #pragma vertex vertex_shader
            #pragma fragment fragment_shader

            fixed4 _Color;

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

            struct appdata_fragment
            {
                fixed4 chroma : SV_TARGET;
            };

            appdata_vertex vertex_shader(appdata_unity input)
            {
                appdata_vertex output;
                output.vertex = input.vertex;
                output.screen = UnityObjectToClipPos(output.vertex);
                output.uv = input.uv;
                return output;
            }

            appdata_fragment fragment_shader(appdata_vertex input)
            {
                appdata_fragment output;
                output.chroma = _Color;
                return output;
            }
            ENDCG
        }

        GrabPass { "_Clipping1" }

        Pass //Black2
        {
            CGPROGRAM
            #pragma vertex vertex_shader
            #pragma geometry geometry_shader
            #pragma fragment fragment_shader

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

            [maxvertexcount(4)] void geometry_shader(triangle appdata_vertex input[3], inout TriangleStream<appdata_geometry> triangles)
            {
                appdata_geometry geometry[4];

                geometry[0].vertex = fixed4(-1.0,  1.0, 0.0, 1.0);
                geometry[1].vertex = fixed4(-1.0, -1.0, 0.0, 1.0);
                geometry[2].vertex = fixed4( 1.0,  1.0, 0.0, 1.0);
                geometry[3].vertex = fixed4( 1.0, -1.0, 0.0, 1.0);

                geometry[0].uv = fixed4(0.0, 0.0, 0.0, 1.0);
                geometry[1].uv = fixed4(0.0, 1.0, 0.0, 1.0);
                geometry[2].uv = fixed4(1.0, 0.0, 0.0, 1.0);
                geometry[3].uv = fixed4(1.0, 1.0, 0.0, 1.0);

                triangles.Append(geometry[0]);
                triangles.Append(geometry[1]);
                triangles.Append(geometry[2]);
                triangles.Append(geometry[3]);
            }

            appdata_fragment fragment_shader(appdata_geometry input)
            {
                appdata_fragment output;
                output.chroma = fixed4(0.0, 0.0, 0.0, 1.0);
                return output;
            }
            ENDCG
        }

        Pass //Clipping2
        {
            CGPROGRAM
            #pragma vertex vertex_shader
            #pragma fragment fragment_shader

            fixed4 _Color;
            fixed _Thickness;

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

            struct appdata_fragment
            {
                fixed4 chroma : SV_TARGET;
            };

            appdata_vertex vertex_shader(appdata_unity input)
            {
                appdata_vertex output;
                output.vertex = input.vertex * (1.1 * _Thickness);
                output.screen = UnityObjectToClipPos(output.vertex);
                output.uv = input.uv;
                return output;
            }

            appdata_fragment fragment_shader(appdata_vertex input)
            {
                appdata_fragment output;
                output.chroma = _Color;
                return output;
            }
            ENDCG
        }

        GrabPass { "_Clipping2" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vertex_shader
            #pragma geometry geometry_shader
            #pragma fragment fragment_shader

            sampler2D _Background;
            fixed4 _Background_ST;

            sampler2D _Clipping1;
            fixed4 _Clipping1_ST;

            sampler2D _Clipping2;
            fixed4 _Clipping2_ST;

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

            [maxvertexcount(4)] void geometry_shader(triangle appdata_vertex input[3], inout TriangleStream<appdata_geometry> triangles)
            {
                appdata_geometry geometry[4];

                geometry[0].vertex = fixed4(-1.0,  1.0, 0.0, 1.0);
                geometry[1].vertex = fixed4(-1.0, -1.0, 0.0, 1.0);
                geometry[2].vertex = fixed4( 1.0,  1.0, 0.0, 1.0);
                geometry[3].vertex = fixed4( 1.0, -1.0, 0.0, 1.0);

                geometry[0].uv = fixed4(0.0, 0.0, 0.0, 1.0);
                geometry[1].uv = fixed4(0.0, 1.0, 0.0, 1.0);
                geometry[2].uv = fixed4(1.0, 0.0, 0.0, 1.0);
                geometry[3].uv = fixed4(1.0, 1.0, 0.0, 1.0);

                triangles.Append(geometry[0]);
                triangles.Append(geometry[1]);
                triangles.Append(geometry[2]);
                triangles.Append(geometry[3]);
            }

            appdata_fragment fragment_shader(appdata_geometry input)
            {
                appdata_fragment output;
                output.chroma = tex2D(_Background, input.uv);
                fixed4 clipping1 = tex2D(_Clipping1, input.uv);
                fixed4 clipping2 = tex2D(_Clipping2, input.uv);
                fixed4 clipping3 = clipping2 - clipping1;
                if ((clipping3.r == 0.0)
                &&  (clipping3.g == 0.0)
                &&  (clipping3.b == 0.0)) { output.chroma.a = 0.0; }
                else { output.chroma = clipping2; }
                return output;
            }
            ENDCG
        }
    }
}
