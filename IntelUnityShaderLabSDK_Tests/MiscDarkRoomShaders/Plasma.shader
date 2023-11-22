Shader "Custom/Plasma"
{
    Properties
    {
        _MainTex("Texture", 2D) = "" {}
        _Chroma("Chroma", Color) = (1.0, 1.0, 1.0, 1.0)
        _Multiplier("Multiplier", Vector) = (1.0, 1.0, 1.0, 1.0)
        _Scaler("Scaler", Vector) = (1.0, 1.0, 0.0, 0.01)
        _Timer("Timer", Vector) = (0.0, 0.0, 0.0, 0.0)
        _MainTex2("Texture2", 2D) = "" {}
        _Power("Power", Float) = 0.5
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

            sampler2D _MainTex;
            fixed4 _MainTex_ST;
            fixed4 _Chroma;
            fixed4 _Multiplier;
            fixed4 _Scaler;
            fixed4 _Timer;
            sampler2D _MainTex2;
            fixed4 _MainTex2_ST;
            fixed _Power;

            appdata_full vertex(appdata_full input)
            {
                appdata_full output = input;
                output.vertex = UnityObjectToClipPos(input.vertex);
                output.texcoord2 = input.texcoord;
                output.texcoord2.xy += fixed2((sin(input.texcoord.x * _Scaler.x) * _Scaler.w * (_SinTime.w * _Timer.x + _Timer.w)) + _Scaler.z + (_SinTime.w * _Timer.z),
                                              (sin(input.texcoord.y * _Scaler.y) * _Scaler.w * (_CosTime.w * _Timer.y + _Timer.w)) + _Scaler.z + (_CosTime.w * _Timer.z));
                return output;
            }

            fixed4 fragment(appdata_full input) : SV_Target
            {
                fixed4 warble = input.texcoord2;
                fixed4 output = _Chroma;
                fixed4 sample = tex2D(_MainTex, warble);
                _Multiplier.xyz *= _Multiplier.w;
                if (sample.a == 1.0) { output.rgb *= _Multiplier.x; }
                else if (sample.a > 0.5) { output.rgb *= _Multiplier.y; }
                else { output.rgb *= _Multiplier.z; }
                output *= pow(tex2D(_MainTex2, warble), _Power);
                return output;
            }
            ENDCG
        }
    }
}
