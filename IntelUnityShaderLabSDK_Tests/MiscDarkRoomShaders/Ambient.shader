Shader "Custom/Ambient"
{
    Properties
    {
        _Color ("Colour", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "LightMode" = "ForwardAdd" } //TODO: Mix with ForwardBase pass for Directional Lights
        Blend SrcAlpha OneMinusSrcAlpha
        //Cull Front

        Pass
        {
            CGPROGRAM
            #pragma vertex vertex
            #pragma fragment fragment
            #pragma target 4.0
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #include "UnityDeferredLibrary.cginc"

            struct vertex_data
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct fragment_data
            {
                float4 vertex : INPUT_VERTEX;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
                float4 position : SV_POSITION;
                float4 light : INCIDENT_LIGHT;
            };

            fixed4 _Color;

            fragment_data vertex(vertex_data input)
            {
                fragment_data output;
                output.vertex = input.vertex;
                output.normal = input.normal;
                output.uv = input.uv;
                output.position = UnityObjectToClipPos(input.vertex);
                output.light = _LightColor0 * float4(0.5, 0.5, 0.5, 1.0);
                output.light.a = _Color.a;
                return output;
            }

            fixed4 fragment(fragment_data input) : SV_Target
            {
                fixed4 output = input.light; //_Color;
                return output;
            }
            ENDCG
        }
    }
}
