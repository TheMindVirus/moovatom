Shader "Custom/Multiplexer"
{
    Properties
    {
        _PeakA("PeakA", Range(0.0, 1.0)) = 1.0
        _PeakB("PeakB", Range(0.0, 1.0)) = 1.0
        [NoScaleOffset] _PreviousFrame("Previous Frame", 2D) = "" {} //Output to CustomRenderTexture with Material and Realtime
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Opaque" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off ZWrite Off ZTest Always

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

            fixed _PeakA;
            fixed _PeakB;

            sampler2D _PreviousFrame;
            fixed4 _PreviousFrame_ST;

            appdata_full vertex(appdata_full input)
            {
                appdata_full output = input;
                output.vertex = UnityObjectToClipPos(input.vertex);
                return output;
            }

            fixed4 fragment(appdata_full input) : SV_Target
            {
                fixed4 output = fixed4(0.0, 0.0, 0.0, 0.5);
                fixed4 alternate = fixed4(1.0, 0.0, 0.3, 0.5);
                if ((input.texcoord.x <= DIV1OVER6) && (input.texcoord.x >= DIV0OVER6)) { if (input.texcoord.y <= _PeakA) { output = alternate; } }
                if ((input.texcoord.x <= DIV2OVER6) && (input.texcoord.x >= DIV1OVER6)) { if (input.texcoord.y <= _PeakB) { output = alternate; } }
                if ((input.texcoord.x <= DIV3OVER6) && (input.texcoord.x >= DIV2OVER6)) { if (_PeakA >= 0.00 && _PeakA <  0.25) { if (input.texcoord.y <= _PeakB) { output = alternate; } } else { output = tex2D(_PreviousFrame, fixed2(input.texcoord.x, input.texcoord.y)); } }
                if ((input.texcoord.x <= DIV4OVER6) && (input.texcoord.x >= DIV3OVER6)) { if (_PeakA >= 0.25 && _PeakA <  0.50) { if (input.texcoord.y <= _PeakB) { output = alternate; } } else { output = tex2D(_PreviousFrame, fixed2(input.texcoord.x, input.texcoord.y)); } }
                if ((input.texcoord.x <= DIV5OVER6) && (input.texcoord.x >= DIV4OVER6)) { if (_PeakA >= 0.50 && _PeakA <  0.75) { if (input.texcoord.y <= _PeakB) { output = alternate; } } else { output = tex2D(_PreviousFrame, fixed2(input.texcoord.x, input.texcoord.y)); } }
                if ((input.texcoord.x <= DIV6OVER6) && (input.texcoord.x >= DIV5OVER6)) { if (_PeakA >= 0.75 && _PeakA <= 1.00) { if (input.texcoord.y <= _PeakB) { output = alternate; } } else { output = tex2D(_PreviousFrame, fixed2(input.texcoord.x, input.texcoord.y)); } }
                return output;
            }
            ENDCG
        }
    }
}
