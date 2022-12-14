Shader "Custom/Template"
{
    Properties
    {
        _Chroma("Chroma", Color) = (1.0, 0.0, 0.3, 1.0)
        [HDR] _Emission("Emission", Color) = (2.0, 0.0, 0.6, 1.0)
        _ChromaMap("Chroma Map", 2D) = "" {}
        [HDR] _EmissionMap("Emission Map", 2D) = "" {}
        //_ChromaVolume("Chroma Volume", 3D) = "" {}
        //[HDR] _EmissionVolume("Emission Volume", 3D) = "" {}
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Opaque" "LightMode" = "Always" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off
        ZWrite Off

        Pass
        {
            CGPROGRAM

            #pragma vertex vertex_shader
            //#pragma patch patch_shader
            ////#pragma hull hull_shader
            ////#pragma domain domain_shader
            //#pragma geometry geometry_shader
            #pragma fragment fragment_shader

            #define AV_POINTS POSITION
            #define AV_VERTEX VERTEX
            #define AV_NORMAL NORMAL
            #define AV_TEXTURE TEXCOORD0
            #define AV_SCREEN SV_POSITION
            #define AV_CHROMA SV_TARGET
            #define AV_DEPTH SV_DEPTH
            #define AV_ID1 SV_VERTEXID
            #define AV_ID2 VERTEXID
            #define AV_DOMAIN SV_DOMAINLOCATION
            #define AV_DIVIDE SV_TESSFACTOR
            #define AV_INSIDE SV_INSIDETESSFACTOR
            #define AV_HULL SV_OUTPUTCONTROLPOINTID
            #define AV_PRIMITIVE SV_PRIMITIVEID
            #define AV_VPOS VPOS //Badly Defined
            #define AV_VFACE VFACE

            #define NV_GARBAGE1 TANGENT
            #define NV_GARBAGE2 TEXCOORD
            #define NV_GARBAGE3 TANUCORNER
            #define NV_GARBAGE4 TANVCORNER
            #define NV_GARBAGE5 TANWEIGHTS

            #define GV_TOPOLOGY "quad"
            #define GV_POLYGONS 100
            #define GV_NPOLYGON 4

            #define DATA struct
            #define SHARD(NAME) appdata_##NAME
            #define SHADER(NAME) NAME##_shader

            #define VERTEX_SHADER SHARD(vertex) SHADER(vertex)(SHARD(unity) input, out fixed4 screen : AV_SCREEN)            
            #define VERTEX_STREAM SHARD(vertex) output;
            #define VERTEX_RETURN return output;

            #define PATCH(ES) #ES
            #define PATCH_SHADER SHARD(tessel) SHADER(patch)(InputPatch<SHARD(vertex), GV_NPOLYGON> patch)
            #define PATCH_STREAM SHARD(tessel) the;
            #define PATCH_RETURN return the;

            #define HULL_SHADER [domain(GV_TOPOLOGY)] [outputcontrolpoints(GV_NPOLYGON)] [outputtopology("triangle_cw")] [partitioning("integer")] [patchconstantfunc(PATCH(SHADER(patch)))] SHARD(vertex) SHADER(hull)(InputPatch<SHARD(vertex), GV_NPOLYGON> patch, uint id : AV_HULL, uint pid : AV_PRIMITIVE)
            #define HULL_STREAM
            #define HULL_RETURN return patch[id];

            #define DOMAIN_SHADER [domain(GV_TOPOLOGY)] SHARD(vertex) SHADER(domain)(SHARD(tessel) input, const OutputPatch<SHARD(vertex), GV_NPOLYGON> patch, fixed2 domain : AV_DOMAIN)
            #define DOMAIN_STREAM SHARD(vertex) output;
            #define DOMAIN_RETURN return output;

            #define GEOMETRY_SHADER [maxvertexcount(GV_POLYGONS)] void SHADER(geometry)(point SHARD(vertex) input[1], inout TriangleStream<SHARD(vertex)> patch)
            #define GEOMETRY_STREAM
            #define GEOMETRY_RETURN

            #define FRAGMENT_SHADER SHARD(fragment) SHADER(fragment)(UNITY_VPOS_TYPE vpos : AV_VPOS, SHARD(vertex) input, fixed facing : AV_VFACE)
            #define FRAGMENT_STREAM SHARD(fragment) output;
            #define FRAGMENT_RETURN return output;

            fixed4 _Chroma;
            fixed4 _Emission;

            sampler2D _ChromaMap;
            fixed4 _ChromaMap_ST;
            sampler2D _EmissionMap;
            fixed4 _EmissionMap_ST;

            //sampler3D _ChromaVolume;
            //fixed4 _ChromaVolume_ST;
            //sampler3D _EmissionVolume;
            //fixed4 _EmissionVolume_ST;

            DATA SHARD(unity)
            {
                fixed4 points : AV_POINTS;
                fixed4 normal : AV_NORMAL;
                fixed4 uv : AV_TEXTURE;
                uint id : AV_ID1;
            };

            DATA SHARD(vertex)
            {
                fixed4 vertex : AV_VERTEX;
                fixed4 normal : AV_NORMAL;
                fixed4 uv : AV_TEXTURE;
                uint id : AV_ID2;
            };

            DATA SHARD(tessel)
            {
                fixed edge[GV_NPOLYGON] : AV_DIVIDE;
                //fixed inside : AV_INSIDE;
                fixed inside[2] : AV_INSIDE;
//Unneeded Garbage///////////////////////////
fixed3 vTangent[GV_NPOLYGON]    : NV_GARBAGE1;
fixed2 vUV[GV_NPOLYGON]         : NV_GARBAGE2;
fixed3 vTanUCorner[GV_NPOLYGON] : NV_GARBAGE3;
fixed3 vTanVCorner[GV_NPOLYGON] : NV_GARBAGE4;
fixed4 vCWts                    : NV_GARBAGE5;
//MicrosoftNVidia////////////////////////////
            };

            DATA SHARD(fragment)
            {
                fixed4 chroma : AV_CHROMA;
                fixed depth : AV_DEPTH;
            };

            VERTEX_SHADER
            {
                VERTEX_STREAM
                screen = UnityObjectToClipPos(input.points);
                //output.normal = UnityObjectToWorldNormal(input.points);
                output.normal = input.normal;
                output.vertex = input.points;
                output.uv = input.uv;
                output.id = input.id;
                VERTEX_RETURN
            }

            PATCH_SHADER
            {
                PATCH_STREAM
                the.edge[0] = 1;
                the.edge[1] = 1;
                the.edge[2] = 1;
                  the.edge[3] = 1;
                  //the.inside = 1;
                the.inside[0] = 1;
                the.inside[1] = 1;
//Unneeded Garbage/////////////////
fixed2 f2 = fixed2(0.0, 0.0);
fixed3 f3 = fixed3(0.0, 0.0, 0.0);
fixed4 f4 = fixed4(0.0, 0.0, 0.0, 0.0);
the.vTangent[0] = f3; the.vTangent[1] = f3; the.vTangent[2] = f3; the.vTangent[3] = f3;
the.vUV[0] = f2; the.vUV[1] = f2; the.vUV[2] = f2; the.vUV[3] = f2;
the.vTanUCorner[0] = f3; the.vTanUCorner[1] = f3; the.vTanUCorner[2] = f3; the.vTanUCorner[3] = f3;
the.vTanVCorner[0] = f3; the.vTanVCorner[1] = f3; the.vTanVCorner[2] = f3; the.vTanVCorner[3] = f3;
the.vCWts = f4;
//QualcommArm//////////////////////
                PATCH_RETURN
            }

            HULL_SHADER
            {
                HULL_STREAM
                HULL_RETURN
            }

            DOMAIN_SHADER
            {
                DOMAIN_STREAM
                uint did = 0;
                output.vertex = patch[did].vertex;
                output.normal = patch[did].normal;
                output.uv = patch[did].uv;
                output.id = patch[did].id;
                DOMAIN_RETURN
            }

            GEOMETRY_SHADER
            {
                GEOMETRY_STREAM
                GEOMETRY_RETURN
            }

            FRAGMENT_SHADER
            {
                FRAGMENT_STREAM
                output.chroma = (_Chroma * tex2D(_ChromaMap, (input.uv * _ChromaMap_ST.xy) + _ChromaMap_ST.zw))
                              + (_Emission * tex2D(_EmissionMap, (input.uv * _EmissionMap_ST.xy) + _EmissionMap_ST.zw));
                output.depth = 0;
                FRAGMENT_RETURN
            }

            ENDCG
        }
    }
}
