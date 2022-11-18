Shader "Custom/SurfaceLocal"
{
    Properties
    {
        _Color("Albedo", Color) = (1.0, 1.0, 1.0, 1.0)
        _CubeMap("CubeMap", Cube) = "" {}
        _Metallic("Metallic", Range(0.0, 1.0)) = 0.5
        _Smoothness("Smoothness", Range(0.0, 1.0)) = 0.5
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Opaque" }

        CGPROGRAM

        #pragma target 4.0
        #pragma surface surface Standard fullforwardshadows alpha:blend vertex:vertex

        half4 _Color;
        samplerCUBE _CubeMap;
        half _Metallic;
        half _Smoothness;

        struct Input { half3 worldPos; half3 chroma : COLOR; };

        void vertex(inout appdata_full v) { v.color = v.vertex; } //Devoid of all Logic

        void surface(Input IN, inout SurfaceOutputStandard o)
        {
            half4 c = texCUBE(_CubeMap, IN.chroma.xyz) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
            o.Metallic = _Metallic;
            o.Smoothness = _Smoothness;
        }

        ENDCG
    }
}
