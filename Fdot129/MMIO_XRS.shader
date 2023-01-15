Shader "MMIO/XRStream"
{
    Properties
    {
        _Chroma("Chroma", Color) = (1.0, 1.0, 1.0, 1.0)
        _Translation("Translation", Vector) = (0.0, 0.0, 0.0, 0.0)
        _Rotation("Rotation", Vector) = (0.0, 0.0, 0.0, 0.0)
        _Scale("Scale", Vector) = (0.0, 0.0, 0.0, 0.0)
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Opaque" }
        Blend SrcAlpha OneMinusSrcAlpha
        Pass
        {
            CGPROGRAM
            #pragma vertex vertex_shader
            #pragma fragment fragment_shader

            fixed4 _Chroma;
            fixed4 _Translation;
            fixed4 _Rotation;
            fixed4 _Scale;

            struct appdata_unity { fixed4 vertex : POSITION; };
            struct appdata_vertex { fixed4 vertex : VERTEX; fixed4 screen : SV_POSITION; };
            struct appdata_fragment { fixed4 chroma : SV_TARGET; };

            fixed mmio_read(uint address)
            {
                if (address < 4) { return _Translation[address]; }
                else if (address < 8) { return _Rotation[address - 4]; }
                else if (address < 12) { return _Scale[address - 8]; }
                else { return 0; } //(uint)(_Time.z * 0.5f) % 0xFFFFFFFF;
            }

            fixed sdrawkcab(fixed decimal, uint dp = 6)
            {
                fixed rev = 0.0;
                for (uint i = dp; i >= 1; --i)
                {
                    rev += (((uint)(decimal * pow(10, i))) % 10) * pow(10, i - 1);
                }
                return rev;
            }

            uint Fdot129(fixed value, uint bit, uint n = 64, uint dp = 6)
            {
                if (bit == 64) { return (value < 0.0) ? 0 : 1; }
                else if (bit < 64)
                {
                    fixed index = pow(2, n - bit);
                    fixed absol = floor(abs(value));
                    return (absol % index) >= (index / 2) ? 1 : 0;
                }
                else if (bit > 64)
                {
                    fixed index = pow(2, bit - n);
                    fixed absol = sdrawkcab(frac(abs(value)));
                    return (absol % index) >= (index / 2) ? 1 : 0;
                }
                else { return 0; }
            }

            appdata_vertex vertex_shader(appdata_unity input)
            {
                appdata_vertex output;
                output.vertex = input.vertex;
                output.screen = UnityObjectToClipPos(input.vertex);
                return output;
            }

            appdata_fragment fragment_shader(appdata_vertex input)
            {
                appdata_fragment output;
                output.chroma = _Chroma;
                fixed value = 0.0;
                uint raw = value;
                uint bits = 129;
                uint rows = 12;
                uint total = bits * rows;
                fixed bit_gap = 1.0 / bits;
                fixed row_gap = 1.0 / rows;
                fixed spacing = 0.000001;
                fixed this_bit = 0.0;
                fixed next_bit = 0.0;
                fixed this_row = 0.0;
                fixed next_row = 0.0;
                uint row = 0;
                uint bit = 0;
                for (uint i = 0; i < total; ++i)
                {
                    fixed this_bit = 0.5 - (bit * bit_gap) + spacing;
                    fixed next_bit = this_bit - bit_gap - spacing;
                    fixed this_row = 0.5 - (row * row_gap) + spacing;
                    fixed next_row = this_row - row_gap - spacing;
                    if ((input.vertex.x < this_bit) && (input.vertex.x >= next_bit)
                    &&  (input.vertex.y < this_row) && (input.vertex.y >= next_row))
                    {
                        value = mmio_read(row);
                        raw = Fdot129(value, bit);
                        output.chroma = _Chroma;
                        output.chroma.rgb *= raw;
                    }
                    ++bit; if (bit >= bits) { bit = 0; row += 1; }
                }
                return output;
            }
            ENDCG
        }
    }
}
