Shader "Hidden/Terastallisation2"
{
    Properties
    {
        _Color("Chroma", Color) = (1.0, 1.0, 1.0, 1.0)
        _MainTex("Texture", 2D) = "" {}
        _Alpha("Alpha", Range(0.0, 1.0)) = 1.0
        _Transmission("Transmission", Color) = (0.0, 0.0, 0.0, 1.0) //Volume tex3D()?

        _Metallic("Metallic", Range(0.0, 1.0)) = 1.0
        _Smoothness("Smoothness", Range(0.0, 1.0)) = 1.0
        _ReflectionMap("Reflection Map", 2D) = "" {}
        _EmissionMap("Emission Map", 2D) = "" {}
        [HDR] _Emission("Emission", Color) = (0.0, 0.0, 0.0, 0.0)

        _HeightMap("Height Map", 2D) = "" {}
        _Height("Height", Vector) = (1.0, 1.0, 1.0, 1.0) 
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Opaque" }
        Blend SrcAlpha OneMinusSrcAlpha //Blend One One
        Cull Off ZWrite Off ZTest Always

        CGINCLUDE
        #define ONE_THIRD (1.0 / 3.0)

        fixed4 blend(fixed4 dst, fixed4 src)
        {
            fixed4 output = fixed4(0.0, 0.0, 0.0, 0.0);
            output.rgb = (src.rgb * src.a) + (dst.rgb * (1.0 - src.a));
            output.a = (src.a) + (dst.a * (1.0 - src.a)); //(src.a * src.a) + (dst.a * (1.0 - src.a));
            return output;
        }

        fixed4 noise(sampler2D map, fixed4 offset, fixed4 scale, fixed4 normal)
        {
            fixed4 simple = (tex2Dlod(map, offset) * 2.0) - 1.0; //sample
            return normal * simple * scale;
        }
        ENDCG

        Pass
        {
            CGPROGRAM
            #pragma vertex vertex
            #pragma fragment fragment
            #include "UnityCG.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            fixed4 _MainTex_ST;
            fixed _Alpha;

            fixed4 _Transmission;

            fixed4 _Height;
            sampler2D _HeightMap;
            fixed4 _HeightMap_ST;

            struct appdata_custom
            {
                fixed4 vertex   : VERTEX;
                fixed4 normal   : NORMAL;
                fixed4 position : SV_POSITION;
                fixed4 texcoord : TEXCOORD0;
                fixed4 chroma   : COLOR;
            };

            appdata_custom vertex(appdata_full input)
            {
                appdata_custom output;
                output.vertex = input.vertex;
                output.normal = fixed4(UnityObjectToWorldNormal(input.normal), 1.0);

                fixed4 v_offset = fixed4(((input.texcoord.xy * _HeightMap_ST.xy) + _HeightMap_ST.zw), 0.0, 0.0);
                fixed4 v_scale = fixed4(_Height.xyz * _Height.w, 1.0);
                fixed4 v_normal = fixed4(input.normal.xyz, 1.0);
                output.vertex.xyz += noise(_HeightMap, v_offset, v_scale, v_normal);
                output.vertex.xyz *= ONE_THIRD;

                output.position = UnityObjectToClipPos(output.vertex);
                output.texcoord = input.texcoord;
                output.chroma = _Color;
                return output;
            }

            fixed4 fragment(appdata_custom input) : SV_Target
            {
                fixed4 base = input.chroma;
                fixed4 tex = tex2D(_MainTex, (input.texcoord.xy * _MainTex_ST.xy) + _MainTex_ST.zw);
                fixed4 output = fixed4(0.0, 0.0, 0.0, 0.0);
                tex.a *= _Alpha;
                output = blend(output, base);
                output = blend(output, _Transmission);
                output = blend(output, tex);
                return output;
            } 
            ENDCG
        }

        Blend SrcAlpha DstAlpha //Blend One One

        CGPROGRAM
        #pragma surface surface Standard fullforwardshadows alpha:blend vertex:vertex

        fixed _Metallic;
        fixed _Smoothness;

        fixed4 _Emission;
        sampler2D _EmissionMap;
        fixed4 _EmissionMap_ST;

        sampler2D _ReflectionMap;
        fixed4 _ReflectionMap_ST;

        sampler2D _HeightMap;
        fixed4 _HeightMap_ST;
        fixed4 _Height;

        struct Input { fixed2 uv_MainTex; };

        void vertex(inout appdata_full output, out Input result)
        {
            result.uv_MainTex = output.texcoord;

            fixed4 v_offset = fixed4(((output.texcoord.xy * _HeightMap_ST.xy) + _HeightMap_ST.zw), 0.0, 0.0);
            fixed4 v_scale = fixed4(_Height.xyz * _Height.w, 1.0);
            fixed4 v_normal = fixed4(output.normal.xyz, 1.0);
            output.vertex.xyz += noise(_HeightMap, v_offset, v_scale, v_normal);
            output.vertex.xyz *= ONE_THIRD;

            ////data.vertex = UnityObjectToClipPos(data.vertex);
        }

        void surface(Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = fixed4(1.0, 1.0, 1.0, 0.5); //not 1.0 alpha
            o.Albedo = c.rgb;
            o.Alpha = c.a;
            o.Metallic = _Metallic;
            o.Smoothness = _Smoothness;
            fixed4 e = tex2D(_EmissionMap, (IN.uv_MainTex * _EmissionMap_ST.xy) + _EmissionMap_ST.zw);
            o.Emission = e.rgb * e.a *_Emission;
            o.Normal = tex2D(_ReflectionMap, (IN.uv_MainTex * _ReflectionMap_ST.xy) + _ReflectionMap_ST.zw);
            //o.Occlusion = -1.0;
        }
        ENDCG
    }
}
