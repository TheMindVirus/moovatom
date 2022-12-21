Shader "Custom/OutlineSurfaceClipping"
{
    Properties
    {
        _Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _Thickness("Thickness", Float) = 1.0
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Opaque" }
        Cull Off

        //Grab Background

        GrabPass { "_Background" }

        //CTB (Clear to Black)

        Pass 
        {
            CGPROGRAM
            #pragma vertex vertex_shader
            #pragma geometry geometry_shader
            #pragma fragment fragment_shader
            struct appdata_unity { fixed4 vertex : POSITION; fixed4 uv : TEXCOORD0; };
            struct appdata_vertex { fixed4 vertex : VERTEX; fixed4 screen : SV_POSITION; fixed4 uv : TEXCOORD0; };
            struct appdata_geometry { fixed4 vertex : VERTEX; fixed4 screen : SV_POSITION; fixed4 uv : TEXCOORD0; };
            struct appdata_fragment { fixed4 chroma : COLOR; fixed depth : DEPTH; };
            appdata_vertex vertex_shader(appdata_unity input) { appdata_vertex output; output.vertex = input.vertex; output.screen = output.vertex; output.uv = input.uv; return output; }
            [maxvertexcount(4)] void geometry_shader(triangle appdata_vertex input[3], inout TriangleStream<appdata_geometry> triangles) { appdata_geometry geometry[4]; geometry[0].vertex = geometry[0].screen = fixed4(-1.0,  1.0, 0.0, 1.0); geometry[1].vertex = geometry[1].screen = fixed4(-1.0, -1.0, 0.0, 1.0); geometry[2].vertex = geometry[2].screen = fixed4( 1.0,  1.0, 0.0, 1.0); geometry[3].vertex = geometry[3].screen = fixed4( 1.0, -1.0, 0.0, 1.0); geometry[0].uv = fixed4(0.0, 0.0, 0.0, 1.0); geometry[1].uv = fixed4(0.0, 1.0, 0.0, 1.0); geometry[2].uv = fixed4(1.0, 0.0, 0.0, 1.0); geometry[3].uv = fixed4(1.0, 1.0, 0.0, 1.0); triangles.RestartStrip(); triangles.Append(geometry[0]); triangles.Append(geometry[1]); triangles.Append(geometry[2]); triangles.Append(geometry[3]); }
            appdata_fragment fragment_shader() { appdata_fragment output; output.depth = 0; output.chroma = fixed4(0.0, 0.0, 0.0, 0.0); return output; }
            ENDCG
        }

        //Surface Clipping

        CGPROGRAM
        #pragma surface surface_shader Flat vertex:vertex_shader alpha:blend noshadow noambient nolightmap
        #include "UnityCG.cginc"

        struct Input { fixed4 screenPos; };

        fixed4 LightingFlat(SurfaceOutput s, fixed3 viewDir, fixed atten)
        {
            return fixed4(1.0, 1.0, 1.0, 1.0);
        }

        void vertex_shader(inout appdata_full INOUT)
        {
            INOUT.vertex.xyz *= 1.0;
        }

        void surface_shader(Input IN, inout SurfaceOutput OUT) { }

        ENDCG

        //Grab Surface

        GrabPass { "_Clipping1" }

        //CTB (Clear to Black)

        Pass 
        {
            CGPROGRAM
            #pragma vertex vertex_shader
            #pragma geometry geometry_shader
            #pragma fragment fragment_shader
            struct appdata_unity { fixed4 vertex : POSITION; fixed4 uv : TEXCOORD0; };
            struct appdata_vertex { fixed4 vertex : VERTEX; fixed4 screen : SV_POSITION; fixed4 uv : TEXCOORD0; };
            struct appdata_geometry { fixed4 vertex : VERTEX; fixed4 screen : SV_POSITION; fixed4 uv : TEXCOORD0; };
            struct appdata_fragment { fixed4 chroma : COLOR; fixed depth : DEPTH; };
            appdata_vertex vertex_shader(appdata_unity input) { appdata_vertex output; output.vertex = input.vertex; output.screen = output.vertex; output.uv = input.uv; return output; }
            [maxvertexcount(4)] void geometry_shader(triangle appdata_vertex input[3], inout TriangleStream<appdata_geometry> triangles) { appdata_geometry geometry[4]; geometry[0].vertex = geometry[0].screen = fixed4(-1.0,  1.0, 0.0, 1.0); geometry[1].vertex = geometry[1].screen = fixed4(-1.0, -1.0, 0.0, 1.0); geometry[2].vertex = geometry[2].screen = fixed4( 1.0,  1.0, 0.0, 1.0); geometry[3].vertex = geometry[3].screen = fixed4( 1.0, -1.0, 0.0, 1.0); geometry[0].uv = fixed4(0.0, 0.0, 0.0, 1.0); geometry[1].uv = fixed4(0.0, 1.0, 0.0, 1.0); geometry[2].uv = fixed4(1.0, 0.0, 0.0, 1.0); geometry[3].uv = fixed4(1.0, 1.0, 0.0, 1.0); triangles.RestartStrip(); triangles.Append(geometry[0]); triangles.Append(geometry[1]); triangles.Append(geometry[2]); triangles.Append(geometry[3]); }
            appdata_fragment fragment_shader() { appdata_fragment output; output.depth = 0; output.chroma = fixed4(0.0, 0.0, 0.0, 0.0); return output; }
            ENDCG
        }

        //Surface Clipping

        CGPROGRAM
        #pragma surface surface_shader Flat vertex:vertex_shader alpha:blend noshadow noambient nolightmap
        #include "UnityCG.cginc"

        struct Input { fixed4 screenPos; };

        fixed4 LightingFlat(SurfaceOutput s, fixed3 viewDir, fixed atten)
        {
            return fixed4(1.0, 1.0, 1.0, 1.0);
        }

        void vertex_shader(inout appdata_full INOUT)
        {
            INOUT.vertex.xyz *= 1.1;
        }

        void surface_shader(Input IN, inout SurfaceOutput OUT) { }

        ENDCG

        //Grab Surface

        GrabPass { "_Clipping2" }

        //CTB (Clear to Black)

        Pass 
        {
            CGPROGRAM
            #pragma vertex vertex_shader
            #pragma geometry geometry_shader
            #pragma fragment fragment_shader
            struct appdata_unity { fixed4 vertex : POSITION; fixed4 uv : TEXCOORD0; };
            struct appdata_vertex { fixed4 vertex : VERTEX; fixed4 screen : SV_POSITION; fixed4 uv : TEXCOORD0; };
            struct appdata_geometry { fixed4 vertex : VERTEX; fixed4 screen : SV_POSITION; fixed4 uv : TEXCOORD0; };
            struct appdata_fragment { fixed4 chroma : COLOR; fixed depth : DEPTH; };
            appdata_vertex vertex_shader(appdata_unity input) { appdata_vertex output; output.vertex = input.vertex; output.screen = output.vertex; output.uv = input.uv; return output; }
            [maxvertexcount(4)] void geometry_shader(triangle appdata_vertex input[3], inout TriangleStream<appdata_geometry> triangles) { appdata_geometry geometry[4]; geometry[0].vertex = geometry[0].screen = fixed4(-1.0,  1.0, 0.0, 1.0); geometry[1].vertex = geometry[1].screen = fixed4(-1.0, -1.0, 0.0, 1.0); geometry[2].vertex = geometry[2].screen = fixed4( 1.0,  1.0, 0.0, 1.0); geometry[3].vertex = geometry[3].screen = fixed4( 1.0, -1.0, 0.0, 1.0); geometry[0].uv = fixed4(0.0, 0.0, 0.0, 1.0); geometry[1].uv = fixed4(0.0, 1.0, 0.0, 1.0); geometry[2].uv = fixed4(1.0, 0.0, 0.0, 1.0); geometry[3].uv = fixed4(1.0, 1.0, 0.0, 1.0); triangles.RestartStrip(); triangles.Append(geometry[0]); triangles.Append(geometry[1]); triangles.Append(geometry[2]); triangles.Append(geometry[3]); }
            appdata_fragment fragment_shader() { appdata_fragment output; output.depth = 0; output.chroma = fixed4(0.0, 0.0, 0.0, 0.0); return output; }
            ENDCG
        }

        //Recombinant Surface Pass

        CGPROGRAM
        #pragma surface surface_shader Flat vertex:vertex_shader alpha:blend noshadow noambient nolightmap
        #include "UnityCG.cginc"

        fixed4 _Color;
        fixed _Thickness;

        sampler2D _Background;
        sampler2D _Clipping1;
        sampler2D _Clipping2;

        struct Input
        {
            fixed4 screenPos;
            fixed2 actualPos;
            fixed4 background;
            fixed4 clipping1;
            fixed4 clipping2;
            fixed4 clipping3;
        };

        fixed4 LightingFlat(SurfaceOutput s, fixed3 viewDir, fixed atten)
        {
            return fixed4(s.Albedo, s.Alpha);
        }

        void vertex_shader(inout appdata_full INOUT)
        {
            INOUT.vertex.xyz *= (1.1 * _Thickness);
        }

        void surface_shader(Input IN, inout SurfaceOutput OUT)
        {
            IN.actualPos = IN.screenPos.xy / IN.screenPos.w;

            IN.background = tex2D(_Background, IN.actualPos);
            IN.clipping1 = tex2D(_Clipping1, IN.actualPos);
            IN.clipping2 = tex2D(_Clipping2, IN.actualPos);
            IN.clipping3 = IN.clipping2 - IN.clipping1;
            IN.clipping3.a = 1.0;

            OUT.Albedo = IN.background.rgb;
            OUT.Alpha = IN.background.a;

            if ((IN.clipping3.r == 1.0)
            &&  (IN.clipping3.g == 1.0)
            &&  (IN.clipping3.b == 1.0))
            {
                OUT.Albedo = IN.clipping3.rgb * _Color.rgb;
                OUT.Alpha = IN.clipping3.a * _Color.a;
            }
        }

        ENDCG
    }
}
