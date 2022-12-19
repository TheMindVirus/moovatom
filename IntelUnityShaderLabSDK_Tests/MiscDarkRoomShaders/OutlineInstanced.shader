Shader "Custom/OutlineInstanced"
{
    Properties
    {
        _Color("Chroma", Color) = (1.0, 1.0, 1.0, 1.0)
        _Thickness("Thickness", Float) = 1.0
    }
    SubShader
    {
        Tags { "Queue" = "AlphaTest" "RenderType" = "TransparentCutout" }
        //Blend SrcAlpha OneMinusSrcAlpha
        Cull Off ZWrite Off ZTest Always

        //GPU INSTANCING MUST BE ENABLED MANUALLY IN A CHECKBOX
        //PRONE TO MULTIPLE INSTANCE GLITCHING AND OVERRIDING
        //ESPECIALLY DUE TO GRAB PASS AT CERTAIN CAMERA ANGLES
        //THIS IS NOT DUE TO DYNAMIC OCCLUSION CULLING
        //BUT IN FACT BLEND MODE BETWEEN PASSES
        //MULTIPLY AND AVERAGE IS NOT SUPPORTED

        //GrabPass { "_Background[0]" }
        GrabPass { "_Background" }

        //Blend SrcAlpha OneMinusSrcAlpha
        //Blend SrcColor DstColor, SrcAlpha DstAlpha
        //Blend SrcColor One, SrcAlpha One

        Pass //Black1
        {
            //Blend SrcAlpha OneMinusSrcAlpha
            //Blend Zero Zero
            CGPROGRAM
            #pragma vertex vertex_shader
            #pragma geometry geometry_shader
            #pragma fragment fragment_shader
            #pragma multi_compile_instancing
            #define UNITY_INSTANCING_ENABLED
            #include "UnityCG.cginc"

            UNITY_INSTANCING_BUFFER_START(Props)
            UNITY_INSTANCING_BUFFER_END(Props)

            struct appdata_unity
            {
                fixed4 vertex : POSITION;
                fixed4 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct appdata_vertex
            {
                fixed4 vertex : VERTEX;
                fixed4 screen : SV_POSITION;
                fixed4 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct appdata_geometry
            {
                fixed4 vertex : SV_POSITION;
                fixed4 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct appdata_fragment
            {
                fixed4 chroma : SV_TARGET;
                fixed depth : SV_DEPTH;
            };

            appdata_vertex vertex_shader(appdata_unity input)
            {
                appdata_vertex output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                output.vertex = input.vertex;
                output.screen = output.vertex;
                output.uv = input.uv;
                return output;
            }

            [maxvertexcount(4)] void geometry_shader(triangle appdata_vertex input[3], inout TriangleStream<appdata_geometry> triangles)
            {
                appdata_geometry geometry[4];

                UNITY_SETUP_INSTANCE_ID(input[0]);
                UNITY_TRANSFER_INSTANCE_ID(input[0], geometry[0]);
                UNITY_TRANSFER_INSTANCE_ID(input[0], geometry[1]);
                UNITY_TRANSFER_INSTANCE_ID(input[0], geometry[2]);
                UNITY_TRANSFER_INSTANCE_ID(input[0], geometry[3]);

                geometry[0].vertex = fixed4(-1.0,  1.0, 0.0, 1.0);
                geometry[1].vertex = fixed4(-1.0, -1.0, 0.0, 1.0);
                geometry[2].vertex = fixed4( 1.0,  1.0, 0.0, 1.0);
                geometry[3].vertex = fixed4( 1.0, -1.0, 0.0, 1.0);

                geometry[0].uv = fixed4(0.0, 0.0, 0.0, 1.0);
                geometry[1].uv = fixed4(0.0, 1.0, 0.0, 1.0);
                geometry[2].uv = fixed4(1.0, 0.0, 0.0, 1.0);
                geometry[3].uv = fixed4(1.0, 1.0, 0.0, 1.0);

                triangles.Append(geometry[0]);
                triangles.Append(geometry[1]);
                triangles.Append(geometry[2]);
                triangles.Append(geometry[3]);
            }

            appdata_fragment fragment_shader(appdata_geometry input)
            {
                appdata_fragment output;
                UNITY_SETUP_INSTANCE_ID(input);
                output.chroma = fixed4(0.0, 0.0, 0.0, 1.0);
                output.depth = UNITY_GET_INSTANCE_ID(input);
                return output;
            }
            ENDCG
        }

        Pass //Clipping1
        {
            CGPROGRAM
            #pragma vertex vertex_shader
            #pragma fragment fragment_shader
            #pragma multi_compile_instancing
            #define UNITY_INSTANCING_ENABLED
            #include "UnityCG.cginc"

            UNITY_INSTANCING_BUFFER_START(Props)
                UNITY_DEFINE_INSTANCED_PROP(fixed4, _Color)
            UNITY_INSTANCING_BUFFER_END(Props)

            struct appdata_unity
            {
                fixed4 vertex : POSITION;
                fixed4 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct appdata_vertex
            {
                fixed4 vertex : VERTEX;
                fixed4 screen : SV_POSITION;
                fixed4 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct appdata_fragment
            {
                fixed4 chroma : SV_TARGET;
                fixed depth : SV_DEPTH;
            };

            appdata_vertex vertex_shader(appdata_unity input)
            {
                appdata_vertex output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                output.vertex = input.vertex;
                output.screen = UnityObjectToClipPos(output.vertex);
                output.uv = input.uv;
                return output;
            }

            appdata_fragment fragment_shader(appdata_vertex input)
            {
                appdata_fragment output;
                UNITY_SETUP_INSTANCE_ID(input);
                output.chroma = UNITY_ACCESS_INSTANCED_PROP(Props, _Color);
                output.depth = UNITY_GET_INSTANCE_ID(input);
                return output;
            }
            ENDCG
        }

        GrabPass { "_Clipping1" }

        Pass //Black2
        {
            CGPROGRAM
            #pragma vertex vertex_shader
            #pragma geometry geometry_shader
            #pragma fragment fragment_shader
            #pragma multi_compile_instancing
            #define UNITY_INSTANCING_ENABLED
            #include "UnityCG.cginc"

            UNITY_INSTANCING_BUFFER_START(Props)
            UNITY_INSTANCING_BUFFER_END(Props)

            struct appdata_unity
            {
                fixed4 vertex : POSITION;
                fixed4 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct appdata_vertex
            {
                fixed4 vertex : VERTEX;
                fixed4 screen : SV_POSITION;
                fixed4 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct appdata_geometry
            {
                fixed4 vertex : SV_POSITION;
                fixed4 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct appdata_fragment
            {
                fixed4 chroma : SV_TARGET;
                fixed depth : SV_DEPTH;
            };

            appdata_vertex vertex_shader(appdata_unity input)
            {
                appdata_vertex output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                output.vertex = input.vertex;
                output.screen = output.vertex;
                output.uv = input.uv;
                return output;
            }

            [maxvertexcount(4)] void geometry_shader(triangle appdata_vertex input[3], inout TriangleStream<appdata_geometry> triangles)
            {
                appdata_geometry geometry[4];

                UNITY_SETUP_INSTANCE_ID(input[0]);
                UNITY_TRANSFER_INSTANCE_ID(input[0], geometry[0]);
                UNITY_TRANSFER_INSTANCE_ID(input[0], geometry[1]);
                UNITY_TRANSFER_INSTANCE_ID(input[0], geometry[2]);
                UNITY_TRANSFER_INSTANCE_ID(input[0], geometry[3]);

                geometry[0].vertex = fixed4(-1.0,  1.0, 0.0, 1.0);
                geometry[1].vertex = fixed4(-1.0, -1.0, 0.0, 1.0);
                geometry[2].vertex = fixed4( 1.0,  1.0, 0.0, 1.0);
                geometry[3].vertex = fixed4( 1.0, -1.0, 0.0, 1.0);

                geometry[0].uv = fixed4(0.0, 0.0, 0.0, 1.0);
                geometry[1].uv = fixed4(0.0, 1.0, 0.0, 1.0);
                geometry[2].uv = fixed4(1.0, 0.0, 0.0, 1.0);
                geometry[3].uv = fixed4(1.0, 1.0, 0.0, 1.0);

                triangles.Append(geometry[0]);
                triangles.Append(geometry[1]);
                triangles.Append(geometry[2]);
                triangles.Append(geometry[3]);
            }

            appdata_fragment fragment_shader(appdata_geometry input)
            {
                appdata_fragment output;
                UNITY_SETUP_INSTANCE_ID(input);
                output.chroma = fixed4(0.0, 0.0, 0.0, 1.0);
                output.depth = UNITY_GET_INSTANCE_ID(input);
                return output;
            }
            ENDCG
        }

        Pass //Clipping2
        {
            CGPROGRAM
            #pragma vertex vertex_shader
            #pragma fragment fragment_shader
            #pragma multi_compile_instancing
            #define UNITY_INSTANCING_ENABLED
            #include "UnityCG.cginc"

            UNITY_INSTANCING_BUFFER_START(Props)
                UNITY_DEFINE_INSTANCED_PROP(fixed4, _Color)
                UNITY_DEFINE_INSTANCED_PROP(fixed, _Thickness)
            UNITY_INSTANCING_BUFFER_END(Props)

            struct appdata_unity
            {
                fixed4 vertex : POSITION;
                fixed4 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct appdata_vertex
            {
                fixed4 vertex : VERTEX;
                fixed4 screen : SV_POSITION;
                fixed4 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct appdata_fragment
            {
                fixed4 chroma : SV_TARGET;
                fixed depth : SV_DEPTH;
            };

            appdata_vertex vertex_shader(appdata_unity input)
            {
                appdata_vertex output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                output.vertex = input.vertex * (1.1 * UNITY_ACCESS_INSTANCED_PROP(Props, _Thickness));
                output.screen = UnityObjectToClipPos(output.vertex);
                output.uv = input.uv;
                return output;
            }

            appdata_fragment fragment_shader(appdata_vertex input)
            {
                appdata_fragment output;
                UNITY_SETUP_INSTANCE_ID(input);
                output.chroma = UNITY_ACCESS_INSTANCED_PROP(Props, _Color);
                output.depth = UNITY_GET_INSTANCE_ID(input);
                return output;
            }
            ENDCG
        }

        GrabPass { "_Clipping2" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vertex_shader
            #pragma geometry geometry_shader
            #pragma fragment fragment_shader
            #pragma multi_compile_instancing
            #define UNITY_INSTANCING_ENABLED
            #include "UnityCG.cginc"
/*
            UNITY_INSTANCING_BUFFER_START(Props)
                UNITY_DEFINE_INSTANCED_PROP(Texture2D, _Background)
                UNITY_DEFINE_INSTANCED_PROP(SamplerState, sampler_Background)
                UNITY_DEFINE_INSTANCED_PROP(fixed4, _Background_ST)

                UNITY_DEFINE_INSTANCED_PROP(Texture2D, _Clipping1)
                UNITY_DEFINE_INSTANCED_PROP(SamplerState, sampler_Clipping1)
                UNITY_DEFINE_INSTANCED_PROP(fixed4, _Clipping1_ST)

                UNITY_DEFINE_INSTANCED_PROP(Texture2D, _Clipping2)
                UNITY_DEFINE_INSTANCED_PROP(SamplerState, sampler_Clipping2)
                UNITY_DEFINE_INSTANCED_PROP(fixed4, _Clipping2_ST)
            UNITY_INSTANCING_BUFFER_END(Props)

            UNITY_INSTANCING_CBUFFER_START(Props)
                UNITY_DEFINE_INSTANCED_PROP(sampler2D, _Background)
                UNITY_DEFINE_INSTANCED_PROP(fixed4, _Background_ST)

                //UNITY_DEFINE_INSTANCED_PROP(sampler2D, _Clipping1)
                UNITY_DEFINE_INSTANCED_PROP(fixed4, _Clipping1_ST)

                //UNITY_DEFINE_INSTANCED_PROP(sampler2D, _Clipping2)
                UNITY_DEFINE_INSTANCED_PROP(fixed4, _Clipping2_ST)
            UNITY_INSTANCING_CBUFFER_END(Props)
*/
            //UNITY_DECLARE_TEX2DARRAY(_Background);
            //UNITY_DECLARE_TEX2DARRAY(_Clipping1);
            //UNITY_DECLARE_TEX2DARRAY(_Clipping2);

            //Texture2D _Background;
            //SamplerState sampler_Background;

            //Texture2D _Clipping1;
            //SamplerState sampler_Clipping1;

            //Texture2D _Clipping2;
            //SamplerState sampler_Clipping2;

            sampler2D _Background;
            sampler2D _Clipping1;
            sampler2D _Clipping2;

            struct appdata_unity
            {
                fixed4 vertex : POSITION;
                fixed4 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct appdata_vertex
            {
                fixed4 vertex : VERTEX;
                fixed4 screen : SV_POSITION;
                fixed4 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct appdata_geometry
            {
                fixed4 vertex : SV_POSITION;
                fixed4 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct appdata_fragment
            {
                fixed4 chroma : SV_TARGET;
                fixed depth : SV_DEPTH;
            };

            appdata_vertex vertex_shader(appdata_unity input)
            {
                appdata_vertex output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                output.vertex = input.vertex;
                output.screen = output.vertex;
                output.uv = input.uv;
                return output;
            }

            [maxvertexcount(4)] void geometry_shader(triangle appdata_vertex input[3], inout TriangleStream<appdata_geometry> triangles)
            {
                appdata_geometry geometry[4];

                UNITY_SETUP_INSTANCE_ID(input[0]);
                UNITY_TRANSFER_INSTANCE_ID(input[0], geometry[0]);
                UNITY_TRANSFER_INSTANCE_ID(input[0], geometry[1]);
                UNITY_TRANSFER_INSTANCE_ID(input[0], geometry[2]);
                UNITY_TRANSFER_INSTANCE_ID(input[0], geometry[3]);

                geometry[0].vertex = fixed4(-1.0,  1.0, 0.0, 1.0);
                geometry[1].vertex = fixed4(-1.0, -1.0, 0.0, 1.0);
                geometry[2].vertex = fixed4( 1.0,  1.0, 0.0, 1.0);
                geometry[3].vertex = fixed4( 1.0, -1.0, 0.0, 1.0);

                geometry[0].uv = fixed4(0.0, 0.0, 0.0, 1.0);
                geometry[1].uv = fixed4(0.0, 1.0, 0.0, 1.0);
                geometry[2].uv = fixed4(1.0, 0.0, 0.0, 1.0);
                geometry[3].uv = fixed4(1.0, 1.0, 0.0, 1.0);

                triangles.Append(geometry[0]);
                triangles.Append(geometry[1]);
                triangles.Append(geometry[2]);
                triangles.Append(geometry[3]);
            }

            appdata_fragment fragment_shader(appdata_geometry input)
            {
                appdata_fragment output;
                UNITY_SETUP_INSTANCE_ID(input);
                //output.chroma = UNITY_ACCESS_INSTANCED_PROP(Props, _Background).Sample(UNITY_ACCESS_INSTANCED_PROP(Props, sampler_Background), input.uv);
                //fixed4 clipping1 = UNITY_ACCESS_INSTANCED_PROP(Props, _Clipping1).Sample(UNITY_ACCESS_INSTANCED_PROP(Props, sampler_Clipping1), input.uv);
                //fixed4 clipping2 = UNITY_ACCESS_INSTANCED_PROP(Props, _Clipping2).Sample(UNITY_ACCESS_INSTANCED_PROP(Props, sampler_Clipping2), input.uv);
                //output.chroma = tex2DUNITY_ACCESS_INSTANCED_PROP(Props, _Background), input.uv);
                //fixed4 clipping1 = tex2D(UNITY_ACCESS_INSTANCED_PROP(Props, _Clipping1), input.uv);
                //fixed4 clipping2 = tex2D(UNITY_ACCESS_INSTANCED_PROP(Props, _Clipping2), input.uv);
                //output.chroma = UNITY_SAMPLE_TEX2DARRAY(_Background, input.uv);
                //fixed4 clipping1 = UNITY_SAMPLE_TEX2DARRAY(_Clipping1, input.uv);
                //fixed4 clipping2 = UNITY_SAMPLE_TEX2DARRAY(_Clipping2, input.uv);
                //output.chroma = _Background.Sample(sampler_Background, input.uv);
                //fixed4 clipping1 = _Clipping1.Sample(sampler_Clipping1, input.uv);
                //fixed4 clipping2 = _Clipping2.Sample(sampler_Clipping2, input.uv);
                output.chroma = tex2D(_Background, input.uv);
                fixed4 clipping1 = tex2D(_Clipping1, input.uv);
                fixed4 clipping2 = tex2D(_Clipping2, input.uv);
                fixed4 clipping3 = clipping2 - clipping1;
                if ((clipping3.r == 0.0)
                &&  (clipping3.g == 0.0)
                &&  (clipping3.b == 0.0)
                &&  (clipping3.a == 0.0)) { output.chroma.a = 0.0; }
                //else if ((clipping3.r != 1.0)
                //     &&  (clipping3.g != 1.0)
                //     &&  (clipping3.b != 1.0)) { output.chroma.a = 0.0; }
                else { output.chroma = clipping2; }
                output.depth = UNITY_GET_INSTANCE_ID(input);
if (output.depth == 1)
{
    output.chroma = tex2D(_Background, input.uv);
}
output.depth = 0;
                return output;
            }
            ENDCG
        }
    }
}
