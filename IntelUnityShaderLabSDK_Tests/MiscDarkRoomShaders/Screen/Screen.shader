Shader "Custom/Screen" //Screen-Space Billboards - Alastair Cota @ 00:44 04/12/2022
{
    Properties
    {
        _MainTex("Texture", 2D) = "" {}
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Opaque" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off
        ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vertex_shader
            #pragma fragment fragment_shader
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            half4 _MainTex_ST;

            appdata_full vertex_shader(appdata_full input)
            {
                input.vertex.xyz *= 2.0; //Fullscreen Shader
                return input;
            }

            half4 fragment_shader(appdata_full input) : COLOR
            {
                half4 output = half4(0.0, 0.0, 0.0, 0.0);
                half3 origin = UnityObjectToViewPos(half4(0.0, 0.0, 0.0, 1.0));
                half2 screen = (input.vertex.xy / _ScreenParams.xy) - 0.5;
                half aspect = _ScreenParams.x / _ScreenParams.y;
                half2 position = screen;

                position.x *= aspect;
                //position.xy *= input.vertex.z;
                origin.z *= 1.15;
                half sf = -1.25 / origin.z;
                half2 uv = half2(position.x + (origin.x / origin.z), position.y + (origin.y / origin.z));
                if ((abs(uv.x) < (0.5 * sf))
                && (abs(uv.y) < (0.5 * sf)))
                {
                    //output = half4(1.0, 1.0, 1.0, 1.0);
                    output = tex2D(_MainTex, (uv / sf) - 0.5);
                }

                //Debug Lenses
                //if ((screen.x > 0.0) && (screen.y > 0.0)) { output = half4(1.0, 1.0, 1.0, 1.0); }
                //if ((abs(screen.x) > 0.49) || (abs(screen.y) > 0.49)) { output = half4(1.0, 1.0, 1.0, 1.0); }
                //output.xyz = (screen.x + 0.5) * (screen.y + 0.5);
                //if (output.x > 0.1) { output.a = 0.0; }
                //output.rgb = origin.z / -10.0;
                //output.rgb = _ScreenParams.w - 1.0;
                //output.a = 1.0;

                return output;
            }
            ENDCG
        }
    }
}