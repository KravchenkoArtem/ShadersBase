Shader "Custom/RippleShader" {
	Properties
	{
		_MainTexure ("Main Texure", 2D) = "white" {}
		_DistortionScale("DistortionScale", Range( 0 , 1)) = 0
		_RippleSpeed("RippleSpeed", Range( 0 , 1)) = 0
		_RippleScale("RippleScale", Range( 0 , 20)) = 0
		_Blending("Blending", Range( 0 , 1)) = 1
		_DistortionMap("DistortionMap", 2D) = "bump" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull Back
		GrabPass{ }
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha noshadow 
		struct Input
		{
			float4 screenPos;
			float2 uv_MainTexture;

		};

		uniform sampler2D _MainTexure;
		uniform sampler2D _GrabTexture;
		uniform sampler2D _DistortionMap;
		uniform float _RippleScale;
		uniform float _RippleSpeed;
		uniform float _DistortionScale;
		uniform float _Blending;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 c = tex2D(_MainTexure, i.uv_MainTexture);
			o.Albedo = c.rgb;
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPos9 = ase_screenPos;
			#if UNITY_UV_STARTS_AT_TOP
			float scale9 = -1.0;
			#else
			float scale9 = 1.0;
			#endif
			float halfPosW9 = ase_screenPos9.w * 0.5;
			ase_screenPos9.y = ( ase_screenPos9.y - halfPosW9 ) * _ProjectionParams.x* scale9 + halfPosW9;
			ase_screenPos9.xyzw /= ase_screenPos9.w;
			float4 screenColor4 = tex2Dproj( _GrabTexture, UNITY_PROJ_COORD( ( float4( ( UnpackNormal( tex2D( _DistortionMap, ( _RippleScale * (( ( _Time.y * _RippleSpeed ) + ase_screenPos9 )).xyz ).xy ) ) * _DistortionScale ) , 0.0 ) + ase_screenPos9 ) ) );
			//float4 temp_cast_2 = (1.0).xxxx;
			float4 lerpResult5 = lerp( screenColor4 , c, _Blending);
			o.Emission = lerpResult5.rgb;
			o.Metallic = lerpResult5.r;
			o.Smoothness = lerpResult5.r;
			o.Alpha = 1;
		}

		ENDCG
	}
	FallBack "Diffuse"
}
