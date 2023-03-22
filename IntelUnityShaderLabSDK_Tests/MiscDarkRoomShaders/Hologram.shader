Shader "Custom/Hologram"
{
    Properties
    {
        _Texture1("Texture1", 2D) = "" {}
        _Texture2("Texture2", 2D) = "" {}
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Opaque" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Back
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vertex
            #pragma fragment fragment
            #include "UnityCG.cginc"
            
            sampler2D _Texture1;
            fixed4 _Texture1_ST;

            sampler2D _Texture2;
            fixed4 _Texture2_ST;

            fixed4 mix(fixed4 a, fixed4 b, float c, float d)
            {
                return (a * c) + (b * d);
            }

            appdata_full vertex(appdata_full input)
            {
                appdata_full output = input;
                input.texcoord2 = input.vertex;
                output.vertex = UnityObjectToClipPos(input.vertex);
                return output;
            }

            fixed4 fragment(appdata_full input) : COLOR
            {
                fixed4 output = fixed4(1.0, 0.023529411764705882, 0.7098039215686275, 1.0);
                fixed4 input1 = tex2D(_Texture1, -1.0 * input.texcoord * _Texture1_ST.xy + _Texture1_ST.zw);
                fixed4 input2 = tex2D(_Texture2, -1.0 * input.texcoord * _Texture2_ST.xy + _Texture2_ST.zw);
                fixed3 viewDir = ObjSpaceViewDir(input.texcoord2);
                fixed mixValue = min(max(1.0 + viewDir.x, 0.0), 1.0);
                output = mix(input1, input2, mixValue, 1.0 - mixValue);
                return output;
            }
            ENDCG
        }
    }
}
