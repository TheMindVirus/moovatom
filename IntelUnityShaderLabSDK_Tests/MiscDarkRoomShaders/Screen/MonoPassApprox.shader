Shader "Custom/MonoPass/Approx"
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
        Cull Off
        ZWrite Off
        ZTest Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vertex_shader
            #pragma geometry geometry_shader
            #pragma fragment fragment_shader

            fixed4 _Color;
            fixed _Thickness;

            fixed4 vertex_shader(fixed4 vertex : POSITION) : SV_POSITION { return vertex; }

            struct Vertex { fixed4 vertex : VERTEX; fixed4 screen : SV_POSITION; };

            Vertex NewVertex(fixed4 vertex, fixed4 screen) { Vertex output; output.vertex = vertex; output.screen = screen; return output; }

            [maxvertexcount(4)] void geometry_shader(point fixed4 input[1] : SV_POSITION, inout TriangleStream<Vertex> patch : SV_POSITION)
            {
                patch.Append(NewVertex(input[0], fixed4(-1.0,  1.0, 0.0, 1.0)));
                patch.Append(NewVertex(input[0], fixed4(-1.0, -1.0, 0.0, 1.0))); 
                patch.Append(NewVertex(input[0], fixed4( 1.0,  1.0, 0.0, 1.0)));
                patch.Append(NewVertex(input[0], fixed4( 1.0, -1.0, 0.0, 1.0)));
            }

            fixed4 fragment_shader(Vertex input) : COLOR
            {
                fixed4 output = fixed4(1.0, 1.0, 1.0, 0.0);
                fixed4 vertex = input.vertex;
                fixed4 clipos = mul(UNITY_MATRIX_P,
                                mul(UNITY_MATRIX_V,
                                mul(UNITY_MATRIX_M, vertex)));

                fixed2 screen = (input.screen.xy / _ScreenParams.xy) - 0.5;
                fixed aspect = _ScreenParams.x / _ScreenParams.y;

                screen.x *= aspect;
                clipos.y *= 0.5;
                clipos.xy /= clipos.w;

                fixed2 xy = fixed2(screen.x - clipos.x, screen.y + clipos.y);
                fixed size = 0.01 * _Thickness;

                if ((abs(xy.x) < size) && (abs(xy.y) < size))
                {
                    output.rgb *= _Color.rgb;
                    output.a = _Color.a;
                }
                //output = fixed4(screen.xy, 0.0, 1.0);
                return output;
            }
/*
            fixed4 fragment_shader(fixed4 vertex : SV_POSITION) : COLOR
            {
                fixed4 output = fixed4(1.0, 1.0, 1.0, 0.0);

                fixed3 origin = mul(UNITY_MATRIX_V, mul(UNITY_MATRIX_M, fixed4(0.0, 0.0, 0.0, 1.0)));
                origin.z *= 1.15;

                fixed aspect = _ScreenParams.x / _ScreenParams.y;
                fixed2 screen = (vertex.xy / _ScreenParams.xy) - 0.5;
                fixed2 position = screen;
                position.x *= aspect;

                fixed zoom = -1.25 / origin.z;
                fixed size = 0.4 * zoom * _Thickness;

                fixed2 xy = fixed2(position.x + (origin.x / origin.z),
                                   position.y + (origin.y / origin.z));

                if ((abs(xy.x) < size) && (abs(xy.y) < size))
                {
                    output.rgb *= _Color.rgb;
                    output.a = _Color.a;
                }

                return output;
            }
*/
            ENDCG
        }
    }
}
