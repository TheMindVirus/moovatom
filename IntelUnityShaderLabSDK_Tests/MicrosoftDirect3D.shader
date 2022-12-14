// Compiled shader for PC, Mac & Linux Standalone

//////////////////////////////////////////////////////////////////////////
// 
// NOTE: This is *not* a valid shader file, the contents are provided just
// for information and for debugging purposes only.
// 
//////////////////////////////////////////////////////////////////////////
// Skipping shader variants that would not be included into build of current scene.

Shader "Custom/Textured" {
Properties {
 _MainTex ("Albedo (RGB)", 2D) = "white" { }
}
SubShader { 
 Tags { "RenderType"="Opaque" "LightingMode"="ALWAYS" }


 // Stats for Vertex shader:
 //        d3d11: 8 math
 // Stats for Fragment shader:
 //        d3d11: 4 math, 1 texture
 Pass {
  Tags { "RenderType"="Opaque" "LightingMode"="ALWAYS" }
  Blend SrcAlpha OneMinusSrcAlpha
  //////////////////////////////////
  //                              //
  //      Compiled programs       //
  //                              //
  //////////////////////////////////
//////////////////////////////////////////////////////
Global Keywords: <none>
Local Keywords: <none>
-- Hardware tier variant: Tier 1
-- Vertex shader for "d3d11":
// Stats: 8 math, 2 temp registers
Uses vertex data channel "Vertex"
Uses vertex data channel "Tangent"
Uses vertex data channel "Normal"
Uses vertex data channel "TexCoord0"
Uses vertex data channel "TexCoord1"
Uses vertex data channel "TexCoord2"
Uses vertex data channel "TexCoord3"
Uses vertex data channel "Color"

Constant Buffer "UnityPerDraw" (176 bytes) on slot 0 {
  Matrix4x4 unity_ObjectToWorld at 0
}
Constant Buffer "UnityPerFrame" (368 bytes) on slot 1 {
  Matrix4x4 unity_MatrixVP at 272
}

Shader Disassembly:
//
// Generated by Microsoft (R) D3D Shader Disassembler
//
//
// Input signature:
//
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// POSITION                 0   xyzw        0     NONE   float   xyz 
// TANGENT                  0   xyzw        1     NONE   float   xyzw
// NORMAL                   0   xyz         2     NONE   float   xyz 
// TEXCOORD                 0   xyzw        3     NONE   float   xyzw
// TEXCOORD                 1   xyzw        4     NONE   float   xyzw
// TEXCOORD                 2   xyzw        5     NONE   float   xyzw
// TEXCOORD                 3   xyzw        6     NONE   float   xyzw
// COLOR                    0   xyzw        7     NONE   float   xyzw
//
//
// Output signature:
//
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// SV_Position              0   xyzw        0      POS   float   xyzw
// TANGENT                  0   xyzw        1     NONE   float   xyzw
// NORMAL                   0   xyz         2     NONE   float   xyz 
// TEXCOORD                 0   xyzw        3     NONE   float   xyzw
// TEXCOORD                 1   xyzw        4     NONE   float   xyzw
// TEXCOORD                 2   xyzw        5     NONE   float   xyzw
// TEXCOORD                 3   xyzw        6     NONE   float   xyzw
// COLOR                    0   xyzw        7     NONE   float   xyzw
//
      vs_4_0
      dcl_constantbuffer CB0[4], immediateIndexed
      dcl_constantbuffer CB1[21], immediateIndexed
      dcl_input v0.xyz
      dcl_input v1.xyzw
      dcl_input v2.xyz
      dcl_input v3.xyzw
      dcl_input v4.xyzw
      dcl_input v5.xyzw
      dcl_input v6.xyzw
      dcl_input v7.xyzw
      dcl_output_siv o0.xyzw, position
      dcl_output o1.xyzw
      dcl_output o2.xyz
      dcl_output o3.xyzw
      dcl_output o4.xyzw
      dcl_output o5.xyzw
      dcl_output o6.xyzw
      dcl_output o7.xyzw
      dcl_temps 2
   0: mul r0.xyzw, v0.yyyy, cb0[1].xyzw
   1: mad r0.xyzw, cb0[0].xyzw, v0.xxxx, r0.xyzw
   2: mad r0.xyzw, cb0[2].xyzw, v0.zzzz, r0.xyzw
   3: add r0.xyzw, r0.xyzw, cb0[3].xyzw
   4: mul r1.xyzw, r0.yyyy, cb1[18].xyzw
   5: mad r1.xyzw, cb1[17].xyzw, r0.xxxx, r1.xyzw
   6: mad r1.xyzw, cb1[19].xyzw, r0.zzzz, r1.xyzw
   7: mad o0.xyzw, cb1[20].xyzw, r0.wwww, r1.xyzw
   8: mov o1.xyzw, v1.xyzw
   9: mov o2.xyz, v2.xyzx
  10: mov o3.xyzw, v3.xyzw
  11: mov o4.xyzw, v4.xyzw
  12: mov o5.xyzw, v5.xyzw
  13: mov o6.xyzw, v6.xyzw
  14: mov o7.xyzw, v7.xyzw
  15: ret 
// Approximately 0 instruction slots used


-- Hardware tier variant: Tier 1
-- Fragment shader for "d3d11":
// Stats: 4 math, 2 temp registers, 1 textures
Set 2D Texture "_MainTex" to slot 0

Constant Buffer "$Globals" (80 bytes) on slot 0 {
  Vector4 _LightColor0 at 32
}

Shader Disassembly:
//
// Generated by Microsoft (R) D3D Shader Disassembler
//
//
// Input signature:
//
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// SV_Position              0   xyzw        0      POS   float       
// TANGENT                  0   xyzw        1     NONE   float       
// NORMAL                   0   xyz         2     NONE   float   xyz 
// TEXCOORD                 0   xyzw        3     NONE   float   xy  
// TEXCOORD                 1   xyzw        4     NONE   float       
// TEXCOORD                 2   xyzw        5     NONE   float       
// TEXCOORD                 3   xyzw        6     NONE   float       
// COLOR                    0   xyzw        7     NONE   float       
//
//
// Output signature:
//
// Name                 Index   Mask Register SysValue  Format   Used
// -------------------- ----- ------ -------- -------- ------- ------
// SV_TARGET                0   xyzw        0   TARGET   float   xyzw
//
      ps_4_0
      dcl_constantbuffer CB0[3], immediateIndexed
      dcl_sampler s0, mode_default
      dcl_resource_texture2d (float,float,float,float) t0
      dcl_input_ps linear v2.xyz
      dcl_input_ps linear v3.xy
      dcl_output o0.xyzw
      dcl_temps 2
   0: dp3 r0.x, v2.xyzx, l(1.000000, 1.000000, 1.000000, 0.000000)
   1: mul r0.xyz, r0.xxxx, cb0[2].xyzx
   2: sample r1.xyzw, v3.xyxx, t0.xyzw, s0
   3: mul o0.xyz, r0.xyzx, r1.xyzx
   4: mul o0.w, r1.w, cb0[2].w
   5: ret 
// Approximately 0 instruction slots used


 }
}
}