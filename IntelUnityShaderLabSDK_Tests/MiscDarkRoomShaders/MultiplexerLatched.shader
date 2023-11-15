Shader "Custom/MultiplexerLatched"
{
    Properties
    {
        _PeakA("PeakA", Range(0.0, 1.0)) = 1.0
        _PeakB("PeakB", Range(0.0, 1.0)) = 1.0
        _Color("Color", Color) = (1.0, 0.0, 0.2, 0.5)
        _Clear("Clear", Color) = (0.0, 0.0, 0.0, 0.5)
        [NoScaleOffset] _PreviousFrame("Previous Frame", 2D) = "" {}
        //Output to CustomRenderTexture with Material and Realtime
        //Enable Double-Buffering Per Pixel on Initial Pass
        //Additional Settings: 2D 1280x720 NoAA NoCompat R32G32B32A32_SFLOAT NoDepth NoMipMaps NoDynamicScaling Clamp Point NoAniso
        //Material Initial Pass Realtime MaterialSource Material Realtime NoPeriod DoubleBuffered NoWrap Pixel
    }
    SubShader
    {
        //Tags { "Queue" = "Transparent" "RenderType" = "Opaque" }
        //Blend SrcAlpha OneMinusSrcAlpha
        //Cull Off ZWrite Off ZTest Always

        Pass
        {
            Name "Initial Pass"
            CGPROGRAM
            #pragma vertex vertex
            #pragma fragment fragment
            #include "UnityCG.cginc"
            #define DIV0OVER6 0.00 //(0/6)
            #define DIV1OVER6 0.17 //(1/6)
            #define DIV2OVER6 0.33 //(2/6)
            #define DIV3OVER6 0.50 //(3/6)
            #define DIV4OVER6 0.67 //(4/6)
            #define DIV5OVER6 0.83 //(5/6)
            #define DIV6OVER6 1.00 //(6/6)
            #define DIV1OVER12 0.08 //(1/12)

            fixed _PeakA;
            fixed _PeakB;
            fixed4 _Color;
            fixed4 _Clear;
            sampler2D _PreviousFrame;
            fixed4 _PreviousFrame_ST;
            sampler2D _NextFrame;
            fixed4 _NextFrame_ST;

            fixed prepass(int channel)
            {
                fixed result = 1.0;
                fixed offset = DIV1OVER12;
                fixed source = offset + DIV1OVER6;
                     if (channel == 1) { offset += DIV2OVER6; }
                else if (channel == 2) { offset += DIV3OVER6; }
                else if (channel == 3) { offset += DIV4OVER6; }
                else if (channel == 4) { offset += DIV5OVER6; }
                uint steps = 100;
                uint source_step_reached = 0;
                uint offset_step_reached = 0;
                fixed3 sample = fixed3(0.0, 0.0, 0.0);
                fixed stride = 1.0 / (fixed)steps;
                fixed step = 0.0;
                [unroll(steps)]
                for (uint i = 0; i < steps; ++i)
                {
                    sample = tex2Dlod(_PreviousFrame, fixed4(source, step, 0.0, 0.0));
                    if ((sample.r == _Clear.r) && (sample.g == _Clear.g) && (sample.b == _Clear.b)) { break; }
                    source_step_reached = i;
                    step += stride;
                }
                step = 0.0;
                [unroll(steps)]
                for (uint j = 0; j < steps; ++j)
                {
                    sample = tex2Dlod(_PreviousFrame, fixed4(offset, step, 0.0, 0.0));
                    if ((sample.r == _Clear.r) && (sample.g == _Clear.g) && (sample.b == _Clear.b)) { break; }
                    offset_step_reached = j;
                    step += stride;
                }
                result = abs((int)offset_step_reached - (int)source_step_reached) <3;
                return result;
            }

            appdata_full vertex(appdata_full input)
            {
                appdata_full output = input;
                output.vertex = UnityObjectToClipPos(input.vertex);
                return output;
            }

            fixed4 fragment(appdata_full input) : SV_Target
            {
                fixed4 output = tex2D(_PreviousFrame, fixed2(input.texcoord.x, input.texcoord.y));
                fixed4 alternate = _Color;
                fixed4 clear = _Clear;
                if ((input.texcoord.x <= DIV1OVER6) && (input.texcoord.x >= DIV0OVER6)) { if (input.texcoord.y <= _PeakA) { output = alternate; } else { output = clear; } }
                if ((input.texcoord.x <= DIV2OVER6) && (input.texcoord.x >= DIV1OVER6)) { if (input.texcoord.y <= _PeakB) { output = alternate; } else { output = clear; } }
                if ((input.texcoord.x <= DIV3OVER6) && (input.texcoord.x >= DIV2OVER6)) { if ((_PeakA >= 0.00) && (_PeakA <  0.25)) { if (prepass(1) > 0.5) { if (input.texcoord.y <= _PeakB) { output = alternate; } else { output = clear; } } } }
                if ((input.texcoord.x <= DIV4OVER6) && (input.texcoord.x >= DIV3OVER6)) { if ((_PeakA >= 0.25) && (_PeakA <  0.50)) { if (prepass(2) > 0.5) { if (input.texcoord.y <= _PeakB) { output = alternate; } else { output = clear; } } } }
                if ((input.texcoord.x <= DIV5OVER6) && (input.texcoord.x >= DIV4OVER6)) { if ((_PeakA >= 0.50) && (_PeakA <  0.75)) { if (prepass(3) > 0.5) { if (input.texcoord.y <= _PeakB) { output = alternate; } else { output = clear; } } } }
                if ((input.texcoord.x <= DIV6OVER6) && (input.texcoord.x >= DIV5OVER6)) { if ((_PeakA >= 0.75) && (_PeakA <= 1.00)) { if (prepass(4) > 0.5) { if (input.texcoord.y <= _PeakB) { output = alternate; } else { output = clear; } } } }
                return output;
            }
            ENDCG
        }
    }
}
