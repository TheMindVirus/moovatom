﻿Shader "Custom/POST/FastBloomClamped"
{
    Properties
    {
        _Intensity("Intensity", Float) = 1.0
        _Debug("Debug", Vector) = (0.0, 0.0, 0.0, 0.0)
    }
    SubShader
    {
        Tags { "Queue" = "Overlay" "RenderType" = "TransparentCutout" "DisableBatching" = "True" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off ZWrite Off ZTest Off

        GrabPass { "_Background" }

        Pass
        {
            Name "Recombinant"
            CGPROGRAM
            #pragma vertex vertex_shader
            #pragma geometry geometry_shader
            #pragma fragment fragment_shader

            sampler2D _Background;
            fixed4 _Debug;

            fixed _Intensity;

            struct appdata_unity { fixed4 vertex : POSITION; fixed4 texcoord : TEXCOORD; };
            struct appdata_vertex { fixed4 vertex : VERTEX; fixed4 screen : SV_POSITION; fixed4 texcoord : TEXCOORD; };
            struct appdata_geometry { fixed4 screen : SV_POSITION; fixed4 texcoord : TEXCOORD; };
            struct appdata_fragment { fixed4 chroma : COLOR; };

            appdata_vertex vertex_shader(appdata_unity input)
            {
                appdata_vertex output;
                output.vertex = input.vertex;
                output.screen = input.vertex;
                output.texcoord = input.texcoord;
                return output;
            }

            [maxvertexcount(4)] void geometry_shader(triangle appdata_vertex input[3], inout TriangleStream<appdata_geometry> patch)
            {
                appdata_geometry geometry[4];

                geometry[0].screen = fixed4(-1.0,  1.0, 0.0, 1.0);
                geometry[1].screen = fixed4(-1.0, -1.0, 0.0, 1.0);
                geometry[2].screen = fixed4( 1.0,  1.0, 0.0, 1.0);
                geometry[3].screen = fixed4( 1.0, -1.0, 0.0, 1.0);

                geometry[0].texcoord = fixed4(0.0, 0.0, 0.0, 1.0);
                geometry[1].texcoord = fixed4(0.0, 1.0, 0.0, 1.0);
                geometry[2].texcoord = fixed4(1.0, 0.0, 0.0, 1.0);
                geometry[3].texcoord = fixed4(1.0, 1.0, 0.0, 1.0);

                patch.Append(geometry[0]);
                patch.Append(geometry[1]);
                patch.Append(geometry[2]);
                patch.Append(geometry[3]);
            }

            fixed4 blend(fixed4 src, fixed4 dst, fixed srcMix, fixed dstMix)
            {
                fixed4 res;
                res.rgb = (src.rgb * srcMix) + (dst.rgb * dstMix);
                res.a = 1.0;
                return res;
            }

            fixed4 clamp(fixed4 input)
            {
                fixed4 output;
                output.r = min(max(input.r, 0.0), 1.0);
                output.g = min(max(input.g, 0.0), 1.0);
                output.b = min(max(input.b, 0.0), 1.0);
                output.a = min(max(input.a, 0.0), 1.0);
                return output;
            }

            appdata_fragment fragment_shader(appdata_geometry input)
            {
                appdata_fragment output;
                output.chroma = fixed4(0.0, 0.0, 0.0, 0.0);

                //Shader Parameters
                fixed2 counter = fixed2(0.0, 0.0);
                fixed2 offset = fixed2(0.0, 0.0);
                fixed2 scale = fixed2(5, 5);
                const uint total = ((scale.x + 1) * (scale.y + 1));
                const fixed increment = 0.001 * _Intensity;
                scale *= increment;
                fixed2 halfscale = scale * 0.5;
                fixed4 source = fixed4(0.0, 0.0, 0.0, 0.0);
                fixed4 threshold = fixed4(1.0, 1.0, 1.0, 0.0) * 0.9;
                for (uint i = 0; i < total; ++i)
                {
                    offset = input.texcoord.xy + (counter - halfscale);
                    source = ((offset.x >= 0.0) && (offset.x <= 1.0) && (offset.y >= 0.0) && (offset.y <= 1.0))
                        ? (clamp(tex2D(_Background, offset) - threshold) * 1.5) : 0.0;
                    output.chroma += source;
                    counter.x += increment;
                    if (counter.x > scale.x) { counter.x = 0.0; counter.y += increment; }
                }
                output.chroma /= total;
                output.chroma = blend(tex2D(_Background, input.texcoord.xy), output.chroma, 0.75, 10.0);
                return output;
            }
            ENDCG
        }
    }
}
