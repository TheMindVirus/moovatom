Shader "Custom/RotationInvariant"
{
    Properties
    {
        [HDR] _Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _Scale("Scale", Vector) = (1.0, 1.0, 1.0, 1.0)
        _Rotation("Rotation", Vector) = (0.0, 0.0, 0.0, 1.0)
        _Transform("Transform", Vector) = (0.0, 0.0, 0.0, 1.0)
        _Randomness("Randomness", Float) = 10.0
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "LightMode" = "ForwardBase" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vertex
            #pragma fragment fragment
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #define DEGREES (3.1415926535897932384626433832795028841971693993751058209749445923 / 180)

            fixed4 _Color;
            fixed4 _Scale;
            fixed4 _Rotation;
            fixed4 _Transform;
            fixed _Randomness;

            fixed3 rotate(fixed3 pos, fixed3 value, fixed3 pivot = fixed3(0.0, 0.0, 0.0))
            {
                fixed3 remap = fixed3(value.y * DEGREES, value.x * DEGREES, value.z * DEGREES);
                fixed3 moved = pos - pivot;
                fixed3x3 _matrix;
                _matrix[0].x = cos(remap.x) * cos(remap.z);
                _matrix[0].y = (-1.0 * cos(remap.y) * sin(remap.z)) + (sin(remap.y) * sin(remap.x) * cos(remap.z));
                _matrix[0].z = (sin(remap.y) * sin(remap.z)) + (cos(remap.y) * sin(remap.x) * cos(remap.z));
                _matrix[1].x = cos(remap.x) * sin(remap.z);
                _matrix[1].y = (cos(remap.y) * cos(remap.z)) + (sin(remap.y) * sin(remap.x) * sin(remap.z));
                _matrix[1].z = (-1.0 * sin(remap.y) * cos(remap.z)) + (cos(remap.y) * sin(remap.x) * sin(remap.z));
                _matrix[2].x = (-1.0 * sin(remap.x));
                _matrix[2].y = sin(remap.y) * cos(remap.x);
                _matrix[2].z = cos(remap.y) * cos(remap.x);
                fixed3 rotated = fixed3((moved.x * _matrix[0].x) + (moved.y * _matrix[0].y) + (moved.z * _matrix[0].z),
                                        (moved.x * _matrix[1].x) + (moved.y * _matrix[1].y) + (moved.z * _matrix[1].z),
                                        (moved.x * _matrix[2].x) + (moved.y * _matrix[2].y) + (moved.z * _matrix[2].z));
                return rotated + pivot;
            }

            appdata_full vertex(appdata_full input)
            {
                appdata_full output = input;
                //output.vertex = UnityObjectToClipPos(input.vertex);
                fixed3 randomness = _CosTime.xyz * _CosTime.w * _Randomness;
                fixed4x4 model = 0;
                //model[3].xyz = UNITY_MATRIX_M[3].xyz;
                model[0].x = _Scale.x;
                model[1].y = _Scale.y;
                model[2].z = _Scale.z;
                model[3].w = _Scale.w;
                output.vertex.xyz = rotate(output.vertex, (_Rotation.xyz * _Rotation.w) + randomness);
                model[0].w = UNITY_MATRIX_M[0].w;
                model[1].w = UNITY_MATRIX_M[1].w;
                model[2].w = UNITY_MATRIX_M[2].w;
                output.vertex.xyz += _Transform.xyz;
                output.vertex.w = _Transform.w;
                output.vertex = mul(UNITY_MATRIX_P, mul(UNITY_MATRIX_V, mul(model, output.vertex)));
                return output;
            }

            fixed4 fragment(appdata_full input) : SV_Target
            {
                fixed4 output = _Color;
                fixed3 n = input.normal;
                fixed atten = sqrt(sqrt((n.x * n.x) + (n.y * n.y)) + (n.z * n.z));
                output.rgb *= pow(atten, 4);
                return output;
            }
            ENDCG
        }
    }
}
