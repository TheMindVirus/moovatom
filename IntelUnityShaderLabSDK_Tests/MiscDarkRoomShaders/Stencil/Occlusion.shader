Shader "Stencil/Occlusion"
{
    SubShader
    {
        Tags { "Queue" = "Geometry" "RenderType" = "Opaque" }
        ZWrite Off
        Stencil
        {
            Ref 1
            Comp Always
            Pass Replace
        }
        Pass {}
    }
}