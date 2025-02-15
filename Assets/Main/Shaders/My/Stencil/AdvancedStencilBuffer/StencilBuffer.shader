﻿Shader "Custom/StencilBuffer" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_SRef("Stencil Ref", Float) = 1
		[Enum(UnityEngine.Rendering.CompareFunction)] _SComp("Stencil Compare", Float) = 8
		[Enum(UnityEngine.Rendering.StencilOp)] _SOp ("Stencil Operator", Float) = 2
	}
	SubShader {
		Tags { "RenderType"="Geometry-1" }

		ZWrite off
		ColorMask 0

		Stencil
		{
			Ref[_SRef]
			Comp[_SComp]
			Pass[_SOp]
		} 

		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		void surf (Input IN, inout SurfaceOutputStandard o) {
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
			o.Albedo = c.rgb;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
