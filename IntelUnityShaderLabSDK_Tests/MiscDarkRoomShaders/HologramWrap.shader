Shader "Custom/HologramWrap"
{
    Properties
    {
        _Color("Albedo", Color) = (0.0, 1.0, 1.0, 1.0)
        _Alpha("Cutoff", Float) = 0.25
        _Scale("Scalar", Float) = 2.0
        _Power("Vector", Float) = 10.0
        _Debug("Debug", Float) = 10.0
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Opaque" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vertex
            #pragma fragment fragment
            #include "UnityCG.cginc"

            fixed4 _Color;
            fixed _Alpha;
            fixed _Scale;
            fixed _Power;
            fixed _Debug;

            appdata_full vertex(appdata_full input)
            {
                appdata_full output = input;
                output.vertex = UnityObjectToClipPos(input.vertex);
                return output;
            }

            fixed4 fragment(appdata_full input) : SV_Target
            {
                fixed4 output = _Color;
                fixed2 uv = abs((((input.texcoord.xy * _Debug) % 1) * _Scale) - (_Scale / 2));
                output.a = (pow(uv.x, _Power) + pow(uv.y, _Power)) / 2;
                if (output.a > _Alpha) { output.a = (_Alpha * 2) - output.a; }
                output.a = min(max(output.a, 0.0), 1.0);
                return output;
            }
            ENDCG
        }
    }
}