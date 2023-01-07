Shader "Hidden/DaGreenWeb"
{
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Opaque" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vertex_shader
            #pragma fragment fragment_shader
            #define BLIT(X, Y) output.chroma = blit(input.uv, output.chroma, fixed4(-0.47 + (X * 0.01), 0.42 + (Y * 0.01), -0.47 + (X * 0.01) + 0.01, 0.42 + (Y * 0.01) + 0.01), fixed4(0.0, 0.0, 0.0, 1.0))

            struct appdata_unity { fixed4 vertex : POSITION; };
            struct appdata_vertex { fixed4 screen : SV_POSITION; fixed4 uv : TEXCOORD0; };
            struct appdata_fragment { fixed4 chroma : SV_TARGET; };

            fixed4 blit(fixed4 input, fixed4 output, fixed4 position, fixed4 fill)
            {
                if ((input.x > position.x) && (input.x < position.z)
                &&  (input.y > position.y) && (input.y < position.w))
                { output = fill; }
                return output;
            }

            appdata_vertex vertex_shader(appdata_unity input)
            {
                appdata_vertex output;
                output.screen = UnityObjectToClipPos(input.vertex);
                output.uv = input.vertex;
                return output;
            }

            appdata_fragment fragment_shader(appdata_vertex input)
            {
                appdata_fragment output;
                output.chroma = fixed4(0.0, 0.0, 0.0, 0.5);

                if ((input.uv.x > 0.485) || (input.uv.x < -0.485)
                ||  (input.uv.y > 0.405) || (input.uv.y < -0.485))
                { output.chroma = fixed4(0.0, 1.0, 0.3, 0.5); }

                BLIT(0, 0); BLIT(0, 1); BLIT(0, 2); BLIT(0, 3); BLIT(0, 4); BLIT(0, 5);
                BLIT(1, 0);                                                 BLIT(1, 5);
                            BLIT(2, 1); BLIT(2, 2); BLIT(2, 3); BLIT(2, 4);

                BLIT(4, 0); BLIT(4, 1); BLIT(4, 2); BLIT(4, 3);
                                        BLIT(5, 2);             BLIT(5, 4);
                BLIT(6, 0); BLIT(6, 1); BLIT(6, 2); BLIT(6, 3);


                             BLIT(9, 1);  BLIT(9, 2); BLIT(9, 3); BLIT(9, 4);
                BLIT(10, 0);                                                   BLIT(10, 5);
                BLIT(11, 0);              BLIT(11, 2);                         BLIT(11, 5);
                             BLIT(12, 1); BLIT(12, 2);            BLIT(12, 4);

                BLIT(14, 0); BLIT(14, 1); BLIT(14, 2); BLIT(14, 3);
                                                                    BLIT(15, 4);
                                                                    BLIT(16, 4);

                             BLIT(18, 1);              BLIT(18, 3);
                BLIT(19, 0);              BLIT(19, 2);              BLIT(19, 4);
                BLIT(20, 0);              BLIT(20, 2);              BLIT(20, 4);

                             BLIT(22, 1);              BLIT(22, 3);
                BLIT(23, 0);              BLIT(23, 2);              BLIT(23, 4);
                BLIT(24, 0);              BLIT(24, 2);              BLIT(24, 4);

                BLIT(26, 0); BLIT(26, 1); BLIT(26, 2); BLIT(26, 3); BLIT(26, 4);
                                                                    BLIT(27, 4);
                BLIT(28, 0); BLIT(28, 1); BLIT(28, 2); BLIT(28, 3);


                             BLIT(31, 1); BLIT(31, 2); BLIT(31, 3); BLIT(31, 4); BLIT(31, 5);
                BLIT(32, 0);
                             BLIT(33, 1); BLIT(33, 2);
                BLIT(34, 0);
                             BLIT(35, 1); BLIT(35, 2); BLIT(35, 3); BLIT(35, 4); BLIT(35, 5);

                             BLIT(37, 1);              BLIT(37, 3);
                BLIT(38, 0);              BLIT(38, 2);              BLIT(38, 4);
                BLIT(39, 0);              BLIT(39, 2);              BLIT(39, 4);

                BLIT(41, 0); BLIT(41, 1); BLIT(41, 2); BLIT(41, 3);
                BLIT(42, 0);              BLIT(42, 2);              BLIT(42, 4);
                             BLIT(43, 1);              BLIT(43, 3);

                return output;
            }
            ENDCG
        }
    }
}
