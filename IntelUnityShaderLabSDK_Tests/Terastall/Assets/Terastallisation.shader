Shader "Hidden/Terastallisation"
{
    Properties
    {
        _Color("Chroma", Color) = (1.0, 1.0, 1.0, 1.0)
        _MainTex("Texture", 2D) = "" {}
        _Alpha("Alpha", Range(0.0, 1.0)) = 1.0
        _Transmission("Transmission", Color) = (0.0, 0.0, 0.0, 1.0) //Volume tex3D()?

        _Metallic("Metallic", Range(0.0, 1.0)) = 1.0
        _Smoothness("Smoothness", Range(0.0, 1.0)) = 1.0
        _NormalMap("Normal Map", 2D) = "" {}
        _EmissionMap("Emission Map", 2D) = "" {}
        [HDR] _Emission("Emission", Color) = (0.0, 0.0, 0.0, 0.0)
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Opaque" }
        Blend SrcAlpha OneMinusSrcAlpha //Blend One One
        Cull Off ZWrite Off ZTest Always

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

            fixed4 _Transmission;

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
                output = blend(output, _Transmission);
                output = blend(output, tex);
                return output;
            } 
            ENDCG
        }
        Blend SrcAlpha DstAlpha
        //Blend One One
        CGPROGRAM
        #pragma surface surface Standard fullforwardshadows alpha:blend
        fixed _Metallic;
        fixed _Smoothness;
        fixed4 _Emission;
        sampler2D _EmissionMap;
        fixed4 _EmissionMap_ST;
        sampler2D _NormalMap;
        fixed4 _NormalMap_ST;
        struct Input { fixed2 uv_MainTex; };
        void surface(Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = fixed4(1.0, 1.0, 1.0, 0.5);
            o.Albedo = c.rgb;
            o.Alpha = c.a;
            o.Metallic = _Metallic;
            o.Smoothness = _Smoothness;
            o.Normal = tex2D(_NormalMap, (IN.uv_MainTex * _NormalMap_ST.xy) + _NormalMap_ST.zw);
            //o.Occlusion = -1.0;
            //o.Emission = o.Normal;
            fixed4 e = tex2D(_EmissionMap, (IN.uv_MainTex * _EmissionMap_ST.xy) + _EmissionMap_ST.zw);
            o.Emission = e.rgb * e.a *_Emission;
        }
        ENDCG
    }
}
