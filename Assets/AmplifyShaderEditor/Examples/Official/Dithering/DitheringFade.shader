// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ASESampleShaders/DitheringFade"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.74
		_StartDitheringFade("Start Dithering Fade", Float) = 0
		_EndDitheringFade("End Dithering Fade", Float) = 1
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf StandardSpecular keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			fixed eyeDepth;
			fixed4 screenPosition;
		};

		uniform fixed _StartDitheringFade;
		uniform fixed _EndDitheringFade;
		uniform float _Cutoff = 0.74;


		inline float Dither8x8Bayer( int x, int y )
		{
			const float dither[ 64 ] = {
				 1, 49, 13, 61,  4, 52, 16, 64,
				33, 17, 45, 29, 36, 20, 48, 32,
				 9, 57,  5, 53, 12, 60,  8, 56,
				41, 25, 37, 21, 44, 28, 40, 24,
				 3, 51, 15, 63,  2, 50, 14, 62,
				35, 19, 47, 31, 34, 18, 46, 30,
				11, 59,  7, 55, 10, 58,  6, 54,
				43, 27, 39, 23, 42, 26, 38, 22};
			int r = y * 8 + x;
			return dither[r] / 64;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
			float4 ase_screenPos = ComputeScreenPos( UnityObjectToClipPos( v.vertex ) );
			o.screenPosition = ase_screenPos;
		}

		void surf( Input i , inout SurfaceOutputStandardSpecular o )
		{
			o.Alpha = 1;
			float temp_output_65_0 = ( _StartDitheringFade + _ProjectionParams.y );
			float4 ase_screenPos = i.screenPosition;
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 clipScreen26 = ase_screenPosNorm.xy * _ScreenParams.xy;
			float dither26 = Dither8x8Bayer( fmod(clipScreen26.x, 8), fmod(clipScreen26.y, 8) );
			clip( ( ( ( i.eyeDepth + -temp_output_65_0 ) / ( _EndDitheringFade - temp_output_65_0 ) ) - dither26 ) - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15001
952;92;484;650;-463.3459;464.4836;1.421302;False;False
Node;AmplifyShaderEditor.CommentaryNode;36;-622.9761,91.39496;Float;False;1047.541;403.52;Scale depth from start to end;8;30;65;28;29;34;31;33;15;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;37;-609.7847,546.5101;Float;False;297.1897;243;Correction for near plane clipping;1;19;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ProjectionParams;19;-537.0848,595.81;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;30;-584.0002,374.09;Float;False;Property;_StartDitheringFade;Start Dithering Fade;1;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;65;-298.5083,377.6221;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SurfaceDepthNode;15;-557.4172,189.5072;Float;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;33;-107.1209,253.7414;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-117.5356,335.0947;Float;False;Property;_EndDitheringFade;End Dithering Fade;2;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;29;99.26421,348.9946;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;28;101.9639,194.1952;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DitheringNode;26;480,336;Float;False;1;2;0;FLOAT;0;False;1;SAMPLER2D;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;34;285.764,250.6948;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;27;736,256;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;999.2003,-69.70003;Fixed;False;True;2;Fixed;ASEMaterialInspector;0;0;StandardSpecular;ASESampleShaders/DitheringFade;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;3;False;-1;False;0;0;False;0;Masked;0.74;True;True;0;False;TransparentCutout;;AlphaTest;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;4;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;65;0;30;0
WireConnection;65;1;19;2
WireConnection;33;0;65;0
WireConnection;29;0;31;0
WireConnection;29;1;65;0
WireConnection;28;0;15;0
WireConnection;28;1;33;0
WireConnection;34;0;28;0
WireConnection;34;1;29;0
WireConnection;27;0;34;0
WireConnection;27;1;26;0
WireConnection;0;10;27;0
ASEEND*/
//CHKSM=38A77476719260FA38BF86BF432FF7267D9A8C42