Shader "Custom/Textured"
{
    Properties { _MainTex ("Albedo (RGB)", 2D) = "white" {} }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "LightingMode" = "Always" }
        Blend SrcAlpha OneMinusSrcAlpha
        Pass
        {
            CGPROGRAM
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma vertex vertex
            #pragma fragment fragment
            #pragma target 4.0

            sampler2D _MainTex;
            fixed4 _Color;

            appdata_full vertex(appdata_full input) { input.vertex = UnityObjectToClipPos(input.vertex); return input; }
            fixed4 fragment(appdata_full input) : SV_TARGET { float dir = 1.0, atx = 1.0; return tex2D(_MainTex, input.texcoord) * fixed4(_LightColor0.rgb * dot(input.normal, dir) * atx, _LightColor0.a); }
            //fixed4 fragment(appdata_full input) : SV_TARGET { return fixed4(input.normal, 0.5f); }
            ENDCG
        }
    }
}
