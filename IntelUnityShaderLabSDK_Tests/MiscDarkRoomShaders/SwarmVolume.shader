Shader "VolumeRendering/SwarmVolumeShader"
{
    Properties
    {
        _Color("Colour", Color) = (1,1,1,1)
        _Texture("Texture", 3D) = ""
        _Steps("Steps", Float) = 512 //reduce to 100 for mobile devices
        _Frame("Frame", Float) = 0
        _DebugOrigin("DebugOrigin", Vector) = (0,0,0,0)
        _DebugDirection("DebugDirection", Vector) = (0,0,0,0)
        _DebugScale("DebugScale", Vector) = (1,1,1,1)
        _DebugView("DebugView", Vector) = (1,1,1,1)
        _DebugAlpha("DebugAlpha", Vector) = (0.5,0.5,1.0,1.0)
    }
    SubShader //Input Vertex Data is Wildly Offset by known value...Per Particle Position...
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Opaque" } //Contradictory
        Blend SrcAlpha OneMinusSrcAlpha //Required for Transparency
        Cull Front //Required to render on the inside of the cube
        ZWrite Off //Required to remove border Alpha glitches
        ZTest LEqual //NotEqual

        //RenderAlignment of particles must be = "World", Custom Vertex Streams = Off, Enable Mesh GPU Instancing = On
        //3D Start Position and 3D Start Rotation are ideal, under Renderer select "Mesh" instead of "Billboard"
        //and apply the new material

        Pass
        {
            CGPROGRAM
            #pragma exclude_renderers gles //This had better compile on WebGL though, unity will complain if you remove this
            #pragma target 4.0
            #pragma vertex vertex_shader
            #pragma fragment fragment_shader
            #pragma multi_compile_instancing //This defines INSTANCING_ON which breaks positioning
            #pragma instancing_options procedural:vertInstancingSetup
            #define UNITY_PARTICLE_INSTANCE_DATA particle
            struct particle
            {
                float3x4 transform;
                uint color;
                float speed; //known as animFrame
            };
            #define UNITY_PARTICLE_INSTANCE_DATA_NO_ANIM_FRAME
            #include "UnityCG.cginc"
            #include "UnityStandardParticleInstancing.cginc" //Must be this way round
            //#include "Lighting.cginc"
            //#include "AutoLight.cginc" //Combine with LitVolume from PixelFire to get pre-traced Scene Lighting

            float4 _Color;
            sampler3D _Texture;
            uint _Steps;
            uint _Frame;
            float4 _DebugOrigin;
            float4 _DebugDirection;
            float4 _DebugScale;
            float4 _DebugView;
            float4 _DebugAlpha;

            struct supplicant //ideally use appdata_full
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
                float4 texcoord1 : TEXCOORD1;
                float4 texcoord2 : TEXCOORD2;
                float4 texcoord3 : TEXCOORD3;
                float4 color : COLOR;
                #if defined(UNITY_PARTICLE_INSTANCING_ENABLED)
                UNITY_VERTEX_INPUT_INSTANCE_ID
                #endif
                uint id : SV_VERTEXID;
            };

            struct data
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float3 binormal : TEXCOORD23;
                float4 texcoord : TEXCOORD0;
                float4 texcoord1 : TEXCOORD1;
                float4 texcoord2 : TEXCOORD2;
                float4 texcoord3 : TEXCOORD3;
                float3 unmodified : TEXCOORD21;
                float3 world : TEXCOORD22;
                float3 object : TEXCOORD25;
                float4 color : INSTANCED0;
                #if defined(UNITY_PARTICLE_INSTANCING_ENABLED)
                float3 blend : TEXCOORD20;
                UNITY_PARTICLE_INSTANCE_DATA data : TEXCOORD4;
                #endif
                float3 offset : TEXCOORD24;
            };
/*
D3D11 provides particle vertices in local position, this is the correct input for the shader.
WEBGL provides particle vertices in world position, this is the incorrect input for the shader. WorldToLocal is Required.
In terms of ModelView and Projection, if ModelView = Object/Self and Projection = World,
D3D11 needs to be able to convert its local position into a world position: mul object to world or particle instancing transform
WEBGL needs to be able to convert its world position into a local position: tex3D on a custom supplied local space texture map
*/
            data vertex_shader(supplicant input)
            {
                data output;
                output.unmodified = input.vertex.xyz;
                output.world = mul(unity_ObjectToWorld, float4(0.0, 0.0, 0.0, 1.0)).xyz;
                output.object = mul(unity_WorldToObject, float4(input.vertex.xyz, 1.0)).xyz;
                output.texcoord = input.texcoord;
                output.texcoord1 = input.texcoord1;
                output.texcoord2 = input.texcoord2;
                output.texcoord3 = input.texcoord3;
                #if defined(UNITY_PARTICLE_INSTANCING_ENABLED)
                UNITY_SETUP_INSTANCE_ID(input);
                vertInstancingColor(input.color);
                vertInstancingUVs(input.texcoord.xy, output.texcoord.xy, output.blend);
                output.data = unity_ParticleInstanceData[unity_InstanceID];
                #endif
                output.vertex = UnityObjectToClipPos(input.vertex);
                output.normal = UnityObjectToWorldNormal(input.normal);
                output.tangent = input.tangent;
                output.binormal = cross(input.normal, input.tangent.xyz) * input.tangent.w;
                output.color = input.color;

                output.offset = float3(0.0, 0.0, 0.0); //Interpolate this for local vertex position given only world position
                input.id = input.id % 24; //This only works on Unity 2021 Default Cube to circumvent WebGL Batching
                //if ((input.id == 7) || (input.id == 19)) { output.offset = float3(0.5, 0.5, 0.5); } //Is this what a real Quaternion is?
                //if ((input.id ==  0) || (input.id == 13) || (input.id == 23)) { output.offset = float3( 0.5, -0.5,  0.5); } //Magenta Corner
                //if ((input.id ==  1) || (input.id == 14) || (input.id == 16)) { output.offset = float3(-0.5, -0.5,  0.5); } //Blue Corner
                //if ((input.id ==  2) || (input.id ==  8) || (input.id == 22)) { output.offset = float3( 0.5,  0.5,  0.5); } //Most Significant Bit
                //if ((input.id ==  3) || (input.id ==  9) || (input.id == 17)) { output.offset = float3(-0.5,  0.5,  0.5); } //Cyan Corner
                //if ((input.id ==  4) || (input.id == 10) || (input.id == 21)) { output.offset = float3( 0.5,  0.5, -0.5); } //Yellow Corner
                //if ((input.id ==  5) || (input.id == 11) || (input.id == 18)) { output.offset = float3(-0.5,  0.5, -0.5); } //Green Corner
                //if ((input.id ==  6) || (input.id == 12) || (input.id == 20)) { output.offset = float3( 0.5, -0.5, -0.5); } //Red Corner
                //if ((input.id ==  7) || (input.id == 15) || (input.id == 19)) { output.offset = float3(-0.5, -0.5, -0.5); } //Least Significant Bit
                return output;
            }

            float4 fragment_shader(data input) : COLOR
            {
                float4 output;
                int tmp = _Steps; if (tmp < 0) { tmp = 0; }
                uint steps = tmp;
                const float stride = 2.0 / steps;

                float3 input_vertex = input.unmodified;
                float3 correction_factor = float3(0.0, 0.0, 0.0);
                float3 world_view = float3(0.0, 0.0, 0.0);
                #if SHADER_API_D3D11 && defined(UNITY_PARTICLE_INSTANCING_ENABLED)
                correction_factor = float3(input.data.transform[0].w * _DebugView.x * _DebugView.w,
                                           input.data.transform[1].w * _DebugView.y * _DebugView.w,
                                           input.data.transform[2].w * _DebugView.z * _DebugView.w);
                world_view = input_vertex + correction_factor;
                #endif
                #if !SHADER_API_D3D11
                input_vertex = input_vertex; //world to local transformation required
                world_view = input.unmodified;
                #endif

                float3 origin = input_vertex + float3(0.5, 0.5, 0.5) + _DebugOrigin;
                float3 direction = ObjSpaceViewDir(float4(world_view, 1.0)) * _DebugDirection;

                origin += direction * stride;

                for (uint i = 0; i < steps; ++i)
                {
                    float3 position = origin + direction * (i * stride);
                    if (position.x < 0.0
                    ||  position.x > 1.0
                    ||  position.y < 0.0
                    ||  position.y > 1.0
                    ||  position.z < 0.0
                    ||  position.z > 1.0) { break; } //should be continue or flag for compatibility on some systems

                    float4 source = tex3Dlod(_Texture, float4(position.x, position.y, position.z, _Frame));
                    output.rgb = (source.rgb * _DebugAlpha.x) + (1.0 - (source.a * _DebugAlpha.z)) * (output.rgb);
                    output.a = (source.a * _DebugAlpha.y) + (1.0 - (source.a * _DebugAlpha.w)) * output.a;
                }
                //#if defined(UNITY_PARTICLE_INSTANCING_ENABLED)
                //return output;
                //return float4(correction_factor, 0.5);
                //#else
                //return output;
                //return float4(correction_factor, 0.5);
                //#endif

                ////#if defined(UNITY_WEBGL) //<-- this is a C# define, not a ShaderLab define
                //#if !SHADER_API_D3D11 //<-- works instead providing the development platform uses D3D11
                //return float4(0.0, 1.0, 0.0, 1.0);
                //#else
                //return float4(1.0, 0.0, 0.0, 1.0);
                //#endif

                #if SHADER_API_D3D11
                //return float4(correction_factor, 0.5);
                return float4(input.unmodified, 0.5);
                //return float4(input.offset, 0.5);
                #else
                return float4(input.offset, 0.5);
                #endif
            }
            ENDCG
        }
    }
}
