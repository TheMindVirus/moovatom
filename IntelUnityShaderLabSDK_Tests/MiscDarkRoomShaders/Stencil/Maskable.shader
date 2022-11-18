Shader "Stencil/Maskable"
{
    Properties
    {
        _Color("Chroma", Color) = (1, 1, 1, 0.5)
        _MainTex("Texture", 2D) = "white" {}
        _Glossiness("Smoothness", Range(0.0, 1.0)) = 0.5
        _Metallic("Metallic", Range(0.0, 1.0)) = 0.0
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType"= "Opaque" }
        Cull Off
        ZTest Always
        Stencil { Ref 1 Comp NotEqual }

        CGPROGRAM
        #pragma surface surface Standard fullforwardshadows alpha:blend

        uniform half4 _Color;
        uniform sampler2D _MainTex;
        uniform half4 _MainTex_ST;
        uniform half _Metallic;
        uniform half _Smoothness;

        struct Input
        {
            half4 color : COLOR;
            half4 normal : NORMAL;
            half4 texcoord : TEXCOORD0;
        };

        void surface(Input IN, inout SurfaceOutputStandard output)
        {
            half4 chroma = tex2D(_MainTex, (IN.texcoord.xy * _MainTex_ST.xy) + _MainTex_ST.zw) * _Color;
            output.Albedo = chroma.rgb;
            output.Alpha = chroma.a;
            output.Normal = IN.normal;
            output.Metallic = _Metallic;
            output.Smoothness = _Smoothness;
        }
        ENDCG
    }
}