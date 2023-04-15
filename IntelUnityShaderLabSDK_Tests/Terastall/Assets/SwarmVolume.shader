Shader "Swarm/Volume"
{
    Properties
    {
        [HDR] _Color("Colour", Color) = (1,1,1,1)
        _Texture("Texture", 3D) = ""
        _Steps("Steps", Float) = 512
        _DebugOrigin("DebugOrigin", Vector) = (0,0,0,0)
        _DebugDirection("DebugDirection", Vector) = (0,0,0,0)
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Opaque" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Front
        ZWrite Off
        ZTest LEqual

        Pass
        {
            CGPROGRAM
            #pragma target 4.0
            #pragma vertex vertex_shader
            #pragma fragment fragment_shader
            #include "UnityCG.cginc"
            #include "UnityStandardParticleInstancing.cginc"

            float4 _Color;
            sampler3D _Texture;
            uint _Steps;
            float4 _DebugOrigin;
            float4 _DebugDirection;

            struct supplied
            {
                float3 vertex : POSITION;
                uint id : SV_VERTEXID;
            };

            struct data
            {
                float3 vertex : AV_VERTEX;
                float4 screen : SV_POSITION;
                float3 local : AV_LOCAL;
                float3 world : AV_WORLD;
                float3 center : AV_CENTER;

                float3 position : UNITY_POSITION;
                float3 id : AV_ID;
            };

            data vertex_shader(supplied input)
            {
                data output;
                output.vertex = input.vertex;
                output.screen = UnityObjectToClipPos(input.vertex);
                output.local = float3(0.0, 0.0, 0.0);
                input.id = input.id % 24; //Only works on Unity 2021 Default Cube to circumvent WebGL Batching
                if ((input.id ==  0) || (input.id == 13) || (input.id == 23)) { output.local = float3( 0.5, -0.5,  0.5); } //Magenta Corner
                if ((input.id ==  1) || (input.id == 14) || (input.id == 16)) { output.local = float3(-0.5, -0.5,  0.5); } //Blue Corner
                if ((input.id ==  2) || (input.id ==  8) || (input.id == 22)) { output.local = float3( 0.5,  0.5,  0.5); } //Most Significant Bit
                if ((input.id ==  3) || (input.id ==  9) || (input.id == 17)) { output.local = float3(-0.5,  0.5,  0.5); } //Cyan Corner
                if ((input.id ==  4) || (input.id == 10) || (input.id == 21)) { output.local = float3( 0.5,  0.5, -0.5); } //Yellow Corner
                if ((input.id ==  5) || (input.id == 11) || (input.id == 18)) { output.local = float3(-0.5,  0.5, -0.5); } //Green Corner
                if ((input.id ==  6) || (input.id == 12) || (input.id == 20)) { output.local = float3( 0.5, -0.5, -0.5); } //Red Corner
                if ((input.id ==  7) || (input.id == 15) || (input.id == 19)) { output.local = float3(-0.5, -0.5, -0.5); } //Least Significant Bit
                output.position = float3(unity_ObjectToWorld[0].w,
                                         unity_ObjectToWorld[1].w,
                                         unity_ObjectToWorld[2].w); //But not for particles...
                output.world = output.vertex + output.position; //This will probably break when they fix this
                output.center = (output.world - output.local);
                output.id = input.id;
                return output;
            }

            float3 sq_rt(float3 value)
            {
                return float3((value.r >= 0.0) ? pow(value.r, 0.5) : -pow(-value.r, 0.5),
                              (value.g >= 0.0) ? pow(value.g, 0.5) : -pow(-value.g, 0.5),
                              (value.b >= 0.0) ? pow(value.b, 0.5) : -pow(-value.b, 0.5));
            }

            float3 cb_rt(float3 value)
            {
                float onethird = 1.0 / 3.0;
                return float3((value.r >= 0.0) ? pow(value.r, onethird) : -pow(-value.r, onethird),
                              (value.g >= 0.0) ? pow(value.g, onethird) : -pow(-value.g, onethird),
                              (value.b >= 0.0) ? pow(value.b, onethird) : -pow(-value.b, onethird));
            }

            float3 radius(float3 value) { return sq_rt(pow(value.r, 2) + pow(value.g, 2) + pow(value.b, 2)); }
            float3 inv_radius(float3 value) { return 1.0 - sq_rt(pow(value.r, 2) + pow(value.g, 2) + pow(value.b, 2)); }

            float3 rotate(float3 pos, float3 value, float3 pivot = float3(0.0, 0.0, 0.0))
            {
                float3 remap = float3(value.y, value.x, value.z);
                float3 moved = pos - pivot;
                float3x3 _matrix;
                _matrix[0].x = cos(remap.x) * cos(remap.z);
                _matrix[0].y = (-1.0 * cos(remap.y) * sin(remap.z)) + (sin(remap.y) * sin(remap.x) * cos(remap.z));
                _matrix[0].z = (sin(remap.y) * sin(remap.z)) + (cos(remap.y) * sin(remap.x) * cos(remap.z));
                _matrix[1].x = cos(remap.x) * sin(remap.z);
                _matrix[1].y = (cos(remap.y) * cos(remap.z)) + (sin(remap.y) * sin(remap.x) * sin(remap.z));
                _matrix[1].z = (-1.0 * sin(remap.y) * cos(remap.z)) + (cos(remap.y) * sin(remap.x) * sin(remap.z));
                _matrix[2].x = (-1.0 * sin(remap.x));
                _matrix[2].y = sin(remap.y) * cos(remap.x);
                _matrix[2].z = cos(remap.y) * cos(remap.x);
                float3 rotated = float3((moved.x * _matrix[0].x) + (moved.y * _matrix[0].y) + (moved.z * _matrix[0].z),
                                        (moved.x * _matrix[1].x) + (moved.y * _matrix[1].y) + (moved.z * _matrix[1].z),
                                        (moved.x * _matrix[2].x) + (moved.y * _matrix[2].y) + (moved.z * _matrix[2].z));
                return rotated + pivot;
            }

            float4 fragment_shader(data input) : COLOR
            {
                float3 input_local = input.local;
                float3 input_world = input.world;
                float input_alpha = 0.00002;
                #if !SHADER_API_D3D11
                input_local = input.local;
                input_world = input.vertex;
                #endif

                float4 output;
                float3 origin = input_local + 0.5 + _DebugOrigin;
                float3 direction = normalize(_WorldSpaceCameraPos.xyz - input_world + _DebugDirection);

                int tmp = _Steps; if (tmp < 0) { tmp = 0; }
                uint steps = tmp;
                const float stride = 2.0 / steps;

                float3 position = float3(0.0, 0.0, 0.0);
                origin += direction * stride;

                for (uint i = 0; i < steps; ++i)
                {
                    position = origin + (direction * (i * stride));
                    if ((position.x < 0.0 || position.x > 1.0)
                    ||  (position.y < 0.0 || position.y > 1.0)
                    ||  (position.z < 0.0 || position.z > 1.0)) { break; }

                    float4 source = tex3Dlod(_Texture, float4(position.x, position.y, position.z, 0.0)) * _Color;
                    source.a = inv_radius(position - 0.5 + _DebugOrigin.w).x * (input_alpha + (_DebugDirection.w * 0.00001));
                    output.rgb = (output.rgb * (1.0 - source.a)) + (source.rgb * 0.5);
                    output.a = (output.a * (1.0 - source.a)) + (source.a * 0.5);
                }
                return output;
            }
            ENDCG
        }
    }
}
