Shader "Custom/HullDomain"
{
    Properties
    {
        _Color("Albedo", Color) = (1.0, 1.0, 1.0, 1.0)
        [HDR] _Emission("Emission", Color) = (1.0, 1.0, 1.0, 1.0)
        _MainTex("Texture", 2D) = "" {}
        [HDR] _EmissionMap("Emission Map", 2D) = "" {}
        _Metallic("Metallic", Float) = 0.0
        _Smoothness("Smoothness", Float) = 0.0
        _TessellationFactor("Tessellation Factor", Vector) = (2.0, 2.0, 2.0, 2.0)
        _GeometryRotation("Geometry Rotation", Vector) = (0.0, 0.0, 0.0, 0.0)
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Opaque" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Back
        ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma target 5.0
            #pragma vertex vertex_shader
            #pragma hull hull_shader
            #pragma domain domain_shader
            #pragma geometry geometry_shader
            #pragma fragment fragment_shader
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            fixed4 _Color;
            fixed4 _Emission;
            sampler2D _MainTex;
            fixed4 _MainTex_ST;
            sampler2D _EmissionMap;
            fixed4 _EmissionMap_ST;
            fixed4 _TessellationFactor;
            fixed4 _GeometryRotation;

            struct appdata
            {
                fixed4 vertex : SV_POSITION;
                fixed2 texcoord : TEXCOORD0;
                fixed4 _ShadowCoord : TEXCOORD2;
            };

            struct tessel
            {
                fixed edge[3] : SV_TessFactor;
                fixed inside : SV_InsideTessFactor;
            };

            fixed3 interpolation(fixed3 start, fixed3 end, fixed pos, fixed scale)
            {
                pos /= (scale - 1.0);
                end -= start;
                start += (end * pos);
                pos -= 0.5;
                pos *= 2.0;
                pos = 1.0 - pow(abs(pos), 2.0);
                start.y -= pos;
                return start;
            }

            fixed3 rotation(fixed3 pos, fixed3 value, fixed3 pivot = fixed3(0.0, 0.0, 0.0))
            {
                fixed3 remap = fixed3(value.x, value.y, value.z);
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

            fixed4 projection(fixed4 input, fixed aspect)
            {
                input = UnityObjectToClipPos(input);
                //input = mul(UNITY_MATRIX_P, mul(UNITY_MATRIX_MV, fixed4(0.0, 0.0, 0.0, 1.0))
                //     + fixed4(input.x, input.y, 0.0, 0.0)); //Billboard Aspect
                return input;
            }

            appdata vertex_shader(appdata_full input)
            {
                appdata output;
                output.vertex = UnityObjectToClipPos(input.vertex);
                output.texcoord = input.texcoord;
                output._ShadowCoord = ComputeScreenPos(output.vertex);
                return output;
            }

            [domain("tri")]
            [outputcontrolpoints(3)]
            [outputtopology("triangle_cw")]
            [partitioning("integer")]
            [patchconstantfunc("patch_shader")]
            appdata hull_shader(InputPatch<appdata, 3> patch, uint id : SV_OutputControlPointID)
            {
                return patch[id];
            }

            tessel patch_shader(InputPatch<appdata, 3> patch)
            {
                tessel the;
                the.edge[0] = _TessellationFactor.x;
                the.edge[1] = _TessellationFactor.y;
                the.edge[2] = _TessellationFactor.z;
                the.inside = _TessellationFactor.w;
                return the;
            }

            [domain("tri")]
            appdata domain_shader(tessel the, const OutputPatch<appdata_full, 3> patch, fixed3 domain : SV_DomainLocation)
            {
                appdata output;
                output.vertex = fixed4(((patch[0].vertex.x * domain[0]) + (patch[1].vertex.x * domain[1]) + (patch[2].vertex.x * domain[2])) / 3,
                                      ((patch[0].vertex.y * domain[0]) + (patch[1].vertex.y * domain[1]) + (patch[2].vertex.y * domain[2])) / 3,
                                      ((patch[0].vertex.z * domain[0]) + (patch[1].vertex.z * domain[1]) + (patch[2].vertex.z * domain[2])) / 3,
                                      ((patch[0].vertex.w * domain[0]) + (patch[1].vertex.w * domain[1]) + (patch[2].vertex.w * domain[2])) / 3);
                output.texcoord = fixed4(((patch[0].texcoord.x * domain[0]) + (patch[1].texcoord.x * domain[1]) + (patch[2].texcoord.x * domain[2])) / 3,
                                        ((patch[0].texcoord.y * domain[0]) + (patch[1].texcoord.y * domain[1]) + (patch[2].texcoord.y * domain[2])) / 3,
                                        ((patch[0].texcoord.z * domain[0]) + (patch[1].texcoord.z * domain[1]) + (patch[2].texcoord.z * domain[2])) / 3,
                                        ((patch[0].texcoord.w * domain[0]) + (patch[1].texcoord.w * domain[1]) + (patch[2].texcoord.w * domain[2])) / 3);
                output._ShadowCoord = ComputeScreenPos(UnityObjectToClipPos(output.vertex));
                return output;
            }

            [maxvertexcount(100)]
            void geometry_shader(point appdata input[1], inout TriangleStream<appdata> output)
            {
                appdata geometry;
                uint scale = 25;
                half size = 0.1;
                half aspect = _ScreenParams.x / _ScreenParams.y;
                fixed3 pos1 = fixed3(-0.5, -0.5, -0.5);
                fixed3 pos2 = fixed3(0.5, 0.5, 0.5);
                for (uint i = 0; i < scale; ++i)
                {
                    fixed3 pos = interpolation(pos1, pos2, i, scale);
                    fixed3 dir = normalize(ObjSpaceViewDir(UnityObjectToClipPos(half4(pos, 0.0))));

                    geometry.vertex = fixed4(pos.x - size, pos.y - size, pos.z, 0.0);
                    dir = normalize(ObjSpaceViewDir(geometry.vertex));
                    //dir = normalize(ObjSpaceViewDir(UnityObjectToClipPos(geometry.vertex)));
                    geometry.vertex = fixed4(rotation(geometry.vertex, dir + _GeometryRotation.xyz, pos), 0.0);
                    geometry.vertex = projection(geometry.vertex, aspect);
                    geometry.texcoord = geometry._ShadowCoord = ComputeScreenPos(geometry.vertex);
                    output.Append(geometry);

                    geometry.vertex = fixed4(pos.x + size, pos.y - size, pos.z, 0.0);
                    dir = normalize(ObjSpaceViewDir(geometry.vertex));
                    //dir = normalize(ObjSpaceViewDir(UnityObjectToClipPos(geometry.vertex)));
                    geometry.vertex = fixed4(rotation(geometry.vertex, dir + _GeometryRotation.xyz, pos), 0.0);
                    geometry.vertex = projection(geometry.vertex, aspect);
                    geometry.texcoord = geometry._ShadowCoord = ComputeScreenPos(geometry.vertex);
                    output.Append(geometry);

                    geometry.vertex = fixed4(pos.x - size, pos.y + size, pos.z, 0.0);
                    dir = normalize(ObjSpaceViewDir(geometry.vertex));
                    //dir = normalize(ObjSpaceViewDir(UnityObjectToClipPos(geometry.vertex)));
                    geometry.vertex = fixed4(rotation(geometry.vertex, dir + _GeometryRotation.xyz, pos), 0.0);
                    geometry.vertex = projection(geometry.vertex, aspect);
                    geometry.texcoord = geometry._ShadowCoord = ComputeScreenPos(geometry.vertex);
                    output.Append(geometry);

                    geometry.vertex = fixed4(pos.x + size, pos.y + size, pos.z, 0.0);
                    dir = normalize(ObjSpaceViewDir(geometry.vertex));
                    //dir = normalize(ObjSpaceViewDir(UnityObjectToClipPos(geometry.vertex)));
                    geometry.vertex = fixed4(rotation(geometry.vertex, dir + _GeometryRotation.xyz, pos), 0.0);
                    geometry.vertex = projection(geometry.vertex, aspect);
                    geometry.texcoord = geometry._ShadowCoord = ComputeScreenPos(geometry.vertex);
                    output.Append(geometry);

                    output.RestartStrip();
                }
            }

            fixed4 fragment_shader(appdata input) : SV_Target
            {
                //return fixed4(1.0, 1.0, 1.0, 1.0);
                return fixed4(0.0, input.texcoord.xy, 1.0);
                //return (tex2D(_MainTex, (input.texcoord * _MainTex_ST.xy) + _MainTex_ST.zw) * _Color)
                //     + (tex2D(_EmissionMap, (input.texcoord * _EmissionMap_ST.xy) + _EmissionMap_ST.zw) * _Emission);
            }

            ENDCG
        }
        CGPROGRAM
        #pragma target 5.0
        #pragma surface surface_shader Standard fullforwardshadows alpha:blend

        fixed _Metallic;
        fixed _Smoothness;

        struct Input
        {
            float uv_MainTex;
        };

        void surface_shader(Input IN, inout SurfaceOutputStandard output)
        {
            output.Metallic = _Metallic;
            output.Smoothness = _Smoothness;
        }
        ENDCG
        CGPROGRAM
        #pragma target 5.0
        #pragma surface surface_shader Model alpha:blend

        struct Input
        {
            float uv_MainTex;
        };

        fixed4 LightingModel(SurfaceOutput s, fixed3 lightDir, fixed atten)
        {
            fixed NdotL = dot(s.Normal, lightDir);
            fixed4 c;
            c.rgb = s.Albedo * _LightColor0.rgb * (NdotL * atten);
            c.a = s.Alpha;
            return c;
        }

        void surface_shader(Input IN, inout SurfaceOutput output)
        {
            
        }
        ENDCG
        Pass
        {
            Tags { "LightMode" = "ShadowCaster" }

            CGPROGRAM
            #pragma vertex vertex_shader
            #pragma fragment fragment_shader
            void vertex_shader() {}
            void fragment_shader() {}
            ENDCG
        }
    }
}
