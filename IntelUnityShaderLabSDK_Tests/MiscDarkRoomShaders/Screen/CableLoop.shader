Shader "Custom/CableLoop" //Single-Pass Multiple Billboards - Alastair Cota @ 02:07 04/12/2022
{
    Properties
    {
        [HDR] _Emission("Emission", Color) = (1.0, 1.0, 1.0, 1.0)
        _Position1("Position 1", Vector) = (-0.5, -0.5, -0.5, 1.0)
        _Position2("Position 2", Vector) = (0.5, 0.5, 0.5, 1.0)
        _Scale("Scale", Float) = 100.0
        _Size("Size", Float) = 1.0
        _Sag("Sag", Float) = 1.0
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
            #define TAU   6.283185307179586

            half4 _Emission;
            half4 _Position1;
            half4 _Position2;
            int _Scale;
            half _Size;
            half _Sag;

            half3 interpolation(half3 start, half3 end, half pos, half scale)
            {
                pos /= (scale - 1.0);
                end -= start;
                start += (end * pos);
                pos -= 0.5;
                pos *= 2.0;
                pos = 1.0 - pow(abs(pos), 2.0);
                start.y -= pos * _Sag;
                return start;
            }

            appdata_full vertex_shader(appdata_full input)
            {
                input.texcoord = input.vertex;
                input.vertex.xyz *= 2.0;
                return input;
            }

            half4 fragment_shader(appdata_full input) : COLOR
            {
                half4 output = half4(1.0, 1.0, 1.0, 0.0);
                half3 origin = UnityObjectToViewPos(half4(0.0, 0.0, 0.0, 1.0));
                half2 screen = (input.vertex.xy / _ScreenParams.xy) - 0.5;
                half aspect = _ScreenParams.x / _ScreenParams.y;
               
                half2 position = screen;
                half sf = -1.25 / origin.z;
                half2 xy = half2(0.0, 0.0);
                half2 uv = half2(0.0, 0.0);

                uint scale = (_Scale >= 1) ? _Scale : 1;
                for (uint i = 0; i < scale; ++i)
                {
                    origin = UnityObjectToViewPos(interpolation(_Position1, _Position2, i, scale));
                    position = screen;
                    position.x *= aspect;
                    origin.z *= 1.15;
                    sf = -1.25 / origin.z;
                    xy = half2(position.x + (origin.x / origin.z), position.y + (origin.y / origin.z));
                    uv = xy;
                    uv /= sf;
                    uv -= 0.5;

                    if (sqrt((xy.x * xy.x) + (xy.y * xy.y)) < (0.05 * sf * _Size))
                    {
                        output.rgb *= _Emission.rgb;
                        output.a = _Emission.a;
                    }
                }
                return output;
            }
            ENDCG
        }
    }
}