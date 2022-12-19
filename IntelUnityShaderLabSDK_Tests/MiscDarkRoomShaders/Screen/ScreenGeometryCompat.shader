Shader "Custom/ScreenGeometryCompat"
{
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Opaque" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off ZWrite Off ZTest Always

        GrabPass { "_MainTex" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vertex_shader
            #pragma geometry geometry_shader
            #pragma fragment fragment_shader

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
                output.chroma = tex2D(_MainTex, input.uv) * input.uv;
                return output;
            }
            ENDCG
        }
    }
}
