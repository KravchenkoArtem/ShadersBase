Shader "Custom/Lighting/BasicBlinn" {
	Properties {
		_MainTex ("Main Texure", 2D) = "white" {}
		[HDR] _Color ("Color", Color) = (1,1,1,1)
		[HDR] _SpecColor("Specular Color", Color ) = (1,1,1,1)
		_Specular ("Specular", Range(0.0, 1)) = 0.5
		_Glossiness ("Smoothness", Range(0,1)) = 0.5

	}
	SubShader {
		Tags { "RenderType"="Geometry" }
		LOD 200

		CGPROGRAM
		#pragma surface surf BlinnPhong
		#pragma target 3.0

		fixed3 _Color;
		half _Specular;
		half _Glossiness;
		sampler2D _MainTex;

		struct Input
		{
			float2 uv_MainTex;
		};

		void surf (Input IN, inout SurfaceOutput o) {
			o.Albedo = tex2D(_MainTex, IN.uv_MainTex) * _Color.rgb;
			o.Specular = _Specular;
			o.Gloss  = _Glossiness;  
		}
		ENDCG
	}
	FallBack "Diffuse"
}
