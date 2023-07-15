Shader "Editor/Cubemap"
{
    Properties
    {
        _Color("Albedo", Color) = (0.0, 0.0, 0.0, 1.0)
        _MainTex("Texture", 2D) = "" {}
        _Reflection("Reflection", Float) = 0.1

        _Cubemap("Cubemap", Cube) = "" {}
        _CubemapMin("CubemapMin", Float) = 0.0
        _CubemapMax("CubemapMax", Float) = 1.0
        _CubemapPos("CubemapPos", Vector) = (0.0, 0.0, 0.0, 1.0)
        _CubemapAxis("CubemapAxis", Vector) = (1.0, -1.0, 1.0, 1.0)
        _CubemapRot("CubemapRot", Vector) = (0.0, 0.0, 0.0, 1.0)
        _CubemapPivot("CubemapPivot", Vector) = (0.0, 0.0, 0.0, 1.0)
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "LightMode" = "Always" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off ZWrite On ZTest Always

        Pass
        {
            Name "Cubemap Pass"

            Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "LightMode" = "Always" }
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off ZWrite Off ZTest Always

            CGPROGRAM
            #pragma vertex vertex
            #pragma fragment fragment
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            samplerCUBE _Cubemap;
            fixed4 _Color;
            fixed _Reflection;

            fixed3 _CubemapMin;
            fixed3 _CubemapMax;
            fixed4 _CubemapPos;
            fixed4 _CubemapAxis;
            fixed4 _CubemapRot;
            fixed4 _CubemapPivot;

            struct appdata_cubemap
            {
                fixed4 offset : SV_POSITION;
                fixed4 sample : TEXCOORD0;
                fixed3 worldVertex : TEXCOORD1;
                fixed3 worldDirection : TEXCOORD2;
                fixed3 worldNormal : TEXCOORD3;
            };

            appdata_cubemap vertex(appdata_full input)
            {
                appdata_cubemap output;
                output.offset = UnityObjectToClipPos(input.vertex);
                output.sample = input.texcoord;
                output.worldVertex = mul(unity_ObjectToWorld, input.vertex);
                output.worldDirection = output.worldVertex.xyz - _WorldSpaceCameraPos;
                output.worldNormal = mul(fixed4(input.normal, 0.0), unity_WorldToObject);
                return output;
            }

            fixed3 rotate(fixed3 offset, fixed3 value, fixed3 pivot = fixed3(0.0, 0.0, 0.0))
            {
                fixed3 remap = fixed3(value.y, value.x, value.z);
                fixed3 moved = offset - pivot;
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

            fixed4 fragment(appdata_cubemap input) : COLOR
            {
                fixed3 local = input.worldVertex;
                fixed3 direction = normalize(input.worldDirection);
                fixed3 normal = normalize(input.worldNormal);
                fixed3 reflected = reflect(direction, normal);

                fixed3 intersectMin = (_CubemapMin - local) / reflected;
                fixed3 intersectMax = (_CubemapMax - local) / reflected;
                fixed3 intersect = max(intersectMin, intersectMax);
                fixed distance = min(min(intersect.x, intersect.y), intersect.z);
                fixed3 casted = local + (reflected * distance);

                fixed3 localCast = casted - _CubemapPos.xyz;
                fixed3 globalCast = rotate((localCast * _CubemapAxis.xyz), _CubemapRot.xyz, _CubemapPivot.xyz);

                fixed4 specular = texCUBE(_Cubemap, globalCast);
                fixed4 subsurface = tex2D(_MainTex, input.sample);

                fixed4 output = _Color + ((subsurface * specular) * _Reflection);
                output.r = min(max(output.r, 0.0), 1.0);
                output.g = min(max(output.g, 0.0), 1.0);
                output.b = min(max(output.b, 0.0), 1.0);
                output.w = min(max(output.w, 0.0), 1.0);
                return output;
            }
            ENDCG
        }
    }
}