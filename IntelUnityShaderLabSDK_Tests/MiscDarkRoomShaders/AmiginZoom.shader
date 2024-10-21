Shader "Hidden/AmiginZoom"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "" {}
        _Zoom ("Zoom", Range(0, 1)) = 0
        _Fade ("Fade", Range(0, 1)) = 0.5
        _Steps ("Steps", Range(1, 100)) = 10
        _Dilation ("Dilation", Range(0, 1)) = 0
    }
    SubShader
    {
        //Tags { "Queue" = "Transparent", "RenderType" = "Opaque" }
        Tags { "Queue" = "Transparent" "RenderType" = "Opaque" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off ZWrite Off ZTest Always

        GrabPass { "_GrabPass" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vertex
            #pragma fragment fragment
            #include "UnityCG.cginc"

            sampler2D _GrabPass;
            fixed4 _GrabPass_ST;
            sampler2D _MainTex;
            fixed4 _MainTex_ST;

            fixed _Zoom;
            fixed _Fade;
            fixed _Steps;
            fixed _Dilation;

            appdata_full vertex(appdata_full input)
            {
                appdata_full output = input;
                //output.vertex = UnityObjectToClipPos(input.vertex);
                output.vertex.xy *= -2.0;
                return output;
            }

            fixed4 fragment(appdata_full input) : SV_Target
            {
                fixed4 zoom = 0.0 - (_Zoom * 0.5); //zoom *= _CosTime.w * 10 % 0.1; //!!!
                fixed2 coord = (input.texcoord * (1.0 + zoom)) + (-0.5 * zoom);
                coord *= _MainTex_ST.xy; coord += _MainTex_ST.zw;
                fixed4 output = tex2D(_GrabPass, coord);
                //fixed4 output = fixed4(0.0, 0.0, 0.0, 1.0);
                uint steps = uint(_Steps);
                fixed increment = 1.0 / steps;
                [unroll(99)]
                for (uint i = 0; i < steps; ++i)
                {
                    //fixed angle = sin((input.texcoord.x * input.texcoord.x) + (input.texcoord.y * input.texcoord.y))
                    fixed4 sample = tex2D(_GrabPass, coord); sample.a = _Fade;
                    output.rgb = (sample.a * sample.rgb) + ((1.0 - sample.a) * output.rgb);
                    //output.a = (sample.a * sample.a) + ((1.0 - sample.a) * output.a);
                    //output.rgb = (increment * sample.rgb);
                    //output.rgb = (increment * sample.rgb) + ((1.0 - increment) * output.rgb);
                    output.a = 1.0; //sample.a;
                    zoom -= (_Dilation * increment);
                    coord = (input.texcoord * (1.0 + zoom)) + (-0.5 * zoom);
                    coord *= _MainTex_ST.xy; coord += _MainTex_ST.zw;
                }
                //output.rgb /= steps;
                //fixed4 output = tex2D(_GrabPass, (input.texcoord * _MainTex_ST.xy) + _MainTex_ST.zw);
                //if (input.texcoord.x < 0.1) { output.rgb = 0.0; output.a = 1.0; }
                return output;
            }
            ENDCG
        }
    }
}
