Shader "Hidden/Terastallisation(Limited)"
{
    Properties
    {
        _Color("Chroma", Color) = (1.0, 1.0, 1.0, 1.0)
        _MainTex("Texture", 2D) = "" {}
        _Alpha("Alpha", Range(0.0, 1.0)) = 1.0
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Opaque" }
        Blend SrcAlpha OneMinusSrcAlpha //Blend One One
        Cull Back ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vertex
            #pragma fragment fragment
            #include "UnityCG.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            fixed4 _MainTex_ST;
            fixed _Alpha;

            struct appdata_custom
            {
                fixed4 vertex   : VERTEX;
                fixed4 position : SV_POSITION;
                fixed4 texcoord : TEXCOORD0;
                fixed4 chroma   : COLOR;
            };

            fixed4 blend(fixed4 dst, fixed4 src)
            {
                fixed4 output = fixed4(0.0, 0.0, 0.0, 0.0);
                output.rgb = (src.rgb * src.a) + (dst.rgb * (1.0 - src.a));
                output.a = (src.a) + (dst.a * (1.0 - src.a)); //(src.a * src.a) + (dst.a * (1.0 - src.a));
                return output;
            }

            appdata_custom vertex(appdata_full input)
            {
                appdata_custom output;
                output.vertex = input.vertex;
                output.position = UnityObjectToClipPos(input.vertex);
                output.texcoord = input.texcoord;
                output.chroma = _Color;
                return output;
            }

            fixed4 fragment(appdata_custom input) : SV_Target
            {
                fixed4 base = input.chroma;
                fixed4 tex = tex2D(_MainTex, (input.texcoord.xy * _MainTex_ST.xy) + _MainTex_ST.zw);
                fixed4 output = fixed4(0.0, 0.0, 0.0, 0.0);
                tex.a *= _Alpha;
                output = blend(output, base);
                output = blend(output, tex);
                return output;
            } 
            ENDCG
        }
        Blend SrcAlpha DstAlpha
        //Blend One One
        CGPROGRAM
        #pragma surface surface Standard fullforwardshadows alpha:blend
        struct Input { fixed2 uv_MainTex; };
        void surface(Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = fixed4(1.0, 1.0, 1.0, 0.5);
            o.Albedo = c.rgb;
            o.Alpha = c.a;
            o.Metallic = 1.0;
            o.Smoothness = 1.0;
        }
        ENDCG
    }
}
