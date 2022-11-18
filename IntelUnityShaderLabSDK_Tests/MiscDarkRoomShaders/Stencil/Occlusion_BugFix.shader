Shader "Stencil/Occlusion_BugFix" //Scene View did not match Preview
{
    SubShader
    {
        Tags { "Queue" = "Geometry" "RenderType" = "Opaque" }
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        Stencil
        {
            Ref 1
            Comp Always
            Pass Replace
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vertex
            #pragma fragment fragment
            #include "UnityCG.cginc"
            appdata_full vertex(appdata_full input)
            {
                input.vertex = UnityObjectToClipPos(input.vertex);
                return input;
            }
            half4 fragment(appdata_full input) : SV_Target { return 0; }
            ENDCG
        }
    }
}