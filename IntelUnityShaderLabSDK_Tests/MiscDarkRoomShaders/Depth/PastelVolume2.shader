// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Random/PastelVolume2"
{
    Properties { _Debug("Debug", Vector) = (-0.33, -0.20, 0.0, 1.0) }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Opaque" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Front

        Pass
        {
            CGPROGRAM
            #pragma vertex vertex_shader
            #pragma fragment fragment_shader
            #include "UnityCG.cginc"

            half4 _Debug;

            struct appdata
            {
                half3 vertex : VERTEX;
                half4 screen : SV_POSITION;
                half4 center : TEXCOORD10;
                half3 middle : TEXCOORD11;
                half3 viewport : TEXCOORD12;
            };

            half3 rotate(half3 pos, half3 value, half3 pivot = half3(0.0, 0.0, 0.0))
            {
                half3 remap = half3(value.x, value.y, value.z);
                half3 moved = pos - pivot;
                half3x3 _matrix;
                _matrix[0].x = cos(remap.x) * cos(remap.z);
                _matrix[0].y = (-1.0 * cos(remap.y) * sin(remap.z)) + (sin(remap.y) * sin(remap.x) * cos(remap.z));
                _matrix[0].z = (sin(remap.y) * sin(remap.z)) + (cos(remap.y) * sin(remap.x) * cos(remap.z));
                _matrix[1].x = cos(remap.x) * sin(remap.z);
                _matrix[1].y = (cos(remap.y) * cos(remap.z)) + (sin(remap.y) * sin(remap.x) * sin(remap.z));
                _matrix[1].z = (-1.0 * sin(remap.y) * cos(remap.z)) + (cos(remap.y) * sin(remap.x) * sin(remap.z));
                _matrix[2].x = (-1.0 * sin(remap.x));
                _matrix[2].y = sin(remap.y) * cos(remap.x);
                _matrix[2].z = cos(remap.y) * cos(remap.x);
                half3 rotated = half3((moved.x * _matrix[0].x) + (moved.y * _matrix[0].y) + (moved.z * _matrix[0].z),
                                      (moved.x * _matrix[1].x) + (moved.y * _matrix[1].y) + (moved.z * _matrix[1].z),
                                      (moved.x * _matrix[2].x) + (moved.y * _matrix[2].y) + (moved.z * _matrix[2].z));
                return rotated + pivot;
            }

            appdata vertex_shader(appdata_full input)
            {
                appdata output;
                output.vertex = input.vertex;
                //output.screen = UnityObjectToClipPos(output.vertex);
                //output.viewport = half3(UnityObjectToClipPos(output.vertex).xy, 0.0f);
                output.viewport = UnityObjectToClipPos(half3(0.0, 0.0, 0.0));
/*
                half4 matmv = half4
                (
                    UNITY_MATRIX_V[0].w + input.vertex.x,
                    UNITY_MATRIX_V[1].w + input.vertex.y,
                    UNITY_MATRIX_V[2].w + input.vertex.z,
                    UNITY_MATRIX_V[3].w + input.vertex.w
                );
*/
                //Skyscraper Helicopter View
                //half4 matmv = mul(UNITY_MATRIX_V, half4(0.0f, 0.0f, 0.0f, 1.0f)) + half4(input.vertex.xy, -input.vertex.z, 0.0f);
                
                //Skewed Double Direction View
                //half4 matmv = mul(UNITY_MATRIX_V, half4(0.0f, 0.0f, 0.0f, 1.0f)) + half4(input.vertex.xyz, 0.0f);
                
                //Circular Billboard View
                //half4 matmv = mul(UNITY_MATRIX_V, half4(0.0f, 0.0f, 0.0f, 1.0f)) + half4(input.vertex.xy, 0.0f, 0.0f);

                //Experimental View 1
                //half4 matmv = mul(UNITY_MATRIX_V, half4(0.0f, 0.0f, 0.0f, 2.0f)) + half4(input.vertex.xy * 2.0f, input.vertex.z, 0.0f);

                //Experimental View 2
                //half multiplier = 0.000001f;
                //half4 matmv = mul(UNITY_MATRIX_V, half4(0.0f, 0.0f, 0.0f, multiplier)) + half4(input.vertex.xy * multiplier, input.vertex.z * multiplier, 0.0f);

                //Experimental View 3
                half3 inter = rotate(input.vertex.xyz, half3(output.viewport.x * (_Debug.x * _Debug.w), output.viewport.y * (_Debug.y * _Debug.w), (_Debug.z * _Debug.w)));
                half4 matmv = mul(UNITY_MATRIX_V, half4(0.0f, 0.0f, 0.0f, 1.0f)) + half4(inter, 0.0f);

                output.screen = mul(UNITY_MATRIX_P, matmv);
                //output.screen = mul(UNITY_MATRIX_P, mul(UNITY_MATRIX_M, matmv));

                output.center = half4(0.0f, 0.0f, 0.0f, 0.0f);
                output.middle = UnityObjectToClipPos(output.center);
                return output;
            }

            half4 fragment_shader(appdata input) : SV_TARGET
            {
                half4 output = half4(0.0f, 0.0f, 0.0f, 0.5f);
                half3 dir = input.vertex;

                //output.rgb = dir;
                output.rgb = dir > 0.0f ? 1.0f : 0.0f;
                //output.rgb = input.viewport.x; //(UnityObjectToClipPos(input.vertex).xy / _ScreenParams.xy, 0.0f);

                //output.rgb = half3(1.0f, 0.0f, 0.25f); //abs(dir + 0.5f);
                //output.rgb *= output.rgb;
                //half rad = sqrt((dir.x * dir.x) + (dir.y * dir.y));
                //output.a = rad * rad;
                //output.a = 0.5f - (rad * rad);
/*
                uint interval = 100.0f;
                half stepping = 1.0f / interval; //1.0f would instead be _Color.a (input alpha)
                half4 output = half4(0.0f, 0.0f, 0.0f, 0.0f);
                half3 origin = -input.vertex;
                half3 direction = ObjSpaceViewDir(half4(origin, 1.0f)) / (interval * 0.5f);
                half3 position = origin;
                for (uint i = 0; i < interval; ++i)
                {
                    half radius = sqrt(sqrt((position.x * position.x)
                                          + (position.y * position.y))
                                          + (position.z * position.z));
                    if (radius < 0.5f) { output = half4(1.0f, 0.0f, 0.0f, 0.5f); }

                    half radius = sqrt(sqrt((position.x * position.x)
                                          + (position.y * position.y))
                                          + (position.z * position.z));
                    if (radius > 0.7f) { break; }

                    //essentially a sampler3D, for given radius, sample between range -r and +r
                    //and in 3D this becomes between -x,+x, -y,+y, -z,+z
                    //multiplied by triangular components of the view direction

                    //or more simply put, instead of rendering dotted surfels,
                    //start drawing layered ovals at where you think the back of the sphere is.
                    //move the oval layer towards the camera until the oval reaches full size.
                    //keep moving the oval layer towards the camera until it reaches 0 again.
                    //at each <stepping>, this contributes <interval> to the average alpha.

                    //Practical examples (providing that you have arms):
                    //Before each of the following steps: point at your screen from the middle of your eyesight.
                    //1) start moving your hand to the top left of your eyesight while still pointing to the same place on the screen. <-- that's what unity perspective was doing.
                    //2) start moving your hand to the top left of your eyesight but this time point towards the new direction of your arm. <-- that's what I'm doing.
                    //3) start moving your hand to the top left of your eyesight but this time point twice as much as the new direction of your arm. <-- that's what unity billboards were doing.
                    //4) start moving your hand to the top left of your eyesight but this time maintain the same direction your hand is pointing. <-- that's what unity orthographic/isometric camera was doing.
                    //5) start moving your hand to any corner of your eyesight and this time you can choose exactly which way your hand is pointing. <-- that's creative freedom.

                    half4 source = half4(0.0f, 0.0f, 0.0f, 0.0f);
                    source.rgb = abs(input.vertex);
                    source.a = stepping;

                    output.rgb = (source.rgb * 0.5f) + (1.0f - source.a) * (output.rgb);
                    output.a = (source.a * 0.5f) + (1.0f - source.a) * output.a;
                    position += direction;
                }
*/
                return output;
            }
            ENDCG
        }
    }
}
