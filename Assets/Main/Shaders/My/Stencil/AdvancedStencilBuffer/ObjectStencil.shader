Shader "Custom/ObjectStencil" {
	Properties {
		//[HDR]_Color ("Color", Color) = (1,1,1,1)
		[HDR]_EmissionColor ("Emission Color", Color) = (1, 1, 1, 1)
		_EmissionRange ("EmissionRange", Range(0.0, 1.0)) = 1.0
		[NoScaleOffset]_EmmisionMask ("Emmision Mask", 2D) = "white" {}
		//_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0

		_SRef("Stencil Ref", Float) = 1
		[Enum(UnityEngine.Rendering.CompareFunction)] _SComp("Stencil Compare", Float) = 8
		[Enum(UnityEngine.Rendering.StencilOp)] _SOp ("Stencil Operator", Float) = 2
	}
	SubShader {
		Tags { "RenderType"="Opaque" }

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
		sampler2D _EmmisionMask;

		struct Input {
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		half _EmissionRange;
		fixed4 _EmissionColor;
		fixed4 _Color;

		void surf (Input IN, inout SurfaceOutputStandard o) {
			fixed4 mask = tex2D (_EmmisionMask, IN.uv_MainTex);
			//fixed4 c = (tex2D (_MainTex, IN.uv_MainTex) * mask.r) * _Color;
			//o.Albedo = c.rgb;
			o.Metallic = _Metallic;
			o.Emission = (_EmissionColor.rgb * mask.r) * _EmissionRange;
			o.Smoothness = _Glossiness;
			//o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
