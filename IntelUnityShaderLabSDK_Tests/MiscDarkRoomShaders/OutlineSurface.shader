Shader "Custom/OutlineSurface"
{
    Properties
    {
        _Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Opaque" }

        GrabPass { "_Background" }

        CGPROGRAM
        #pragma surface surface_shader Flat vertex:vertex_shader alpha:blend noshadow noambient nolightmap
        #include "UnityCG.cginc"

        fixed4 _Color;

        struct Input { float4 vertex; };

        fixed4 LightingFlat(SurfaceOutput s, fixed3 viewDir, fixed atten)
        {
            return fixed4(s.Albedo, s.Alpha);
        }

        void vertex_shader(inout appdata_full INOUT, out Input OUT)
        {
            OUT.vertex = INOUT.vertex *= 1.1;
        }

        void surface_shader(Input IN, inout SurfaceOutput OUT)
        {
            OUT.Albedo = _Color.rgb;
            OUT.Alpha = _Color.a;
        }
        ENDCG

        CGPROGRAM
        #pragma surface surface_shader Flat alpha:blend noshadow noambient nolightmap
        #include "UnityCG.cginc"

        fixed4 _Color;
        sampler2D _Background;

        struct Input { float4 screenPos; };

        fixed4 LightingFlat(SurfaceOutput s, fixed3 viewDir, fixed atten)
        {
            return fixed4(s.Albedo, s.Alpha);
        }

        void surface_shader(Input IN, inout SurfaceOutput OUT)
        {
            OUT.Albedo = tex2D(_Background, IN.screenPos.xy / IN.screenPos.w);
            OUT.Alpha = 1.0;
        }
        ENDCG
    }
}
