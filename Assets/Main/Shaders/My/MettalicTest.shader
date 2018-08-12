Shader "Custom/MettalicTest" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MetallicTex ("Albedo (RGB)", 2D) = "white" {}
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_SpecColor("Specular", Color) = (1,1,1,1)
		//_Range ("Range", Range(0.0, 1.0)) = 1.0
	}
	SubShader {
		Tags { "RenderType"="Geometry" }
		LOD 200

		CGPROGRAM
		#pragma surface surf StandardSpecular // для металика Standard fullforwardshadows
		#pragma target 3.0

		sampler2D _MetallicTex;

		struct Input {
			float2 uv_MetallicTex;
		};

		half _Metallic;
		fixed4 _Color;
		//half _Range;

		void surf (Input IN, inout SurfaceOutputStandardSpecular o) { // для металика SurfaceOutputStandard o
			o.Albedo = _Color.rgb;
			o.Smoothness = 0.9 - tex2D(_MetallicTex, IN.uv_MetallicTex).r; 
			o.Specular = _SpecColor.rgb;  // для металика o.Metallic = _Metallic
		}
		ENDCG
	}
	FallBack "Diffuse"
}
