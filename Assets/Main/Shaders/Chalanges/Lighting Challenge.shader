Shader "Custom/Challenge/Lighting Challenge" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MetTexure ("Mettalic Texure", 2D) = "white" {}
		_MetallicRange ("Mettalic", Range(0.0, 5.0)) = 1.0
		_EmissionRange ("Emission", Range(0.0, 5.0)) = 1.0
	}
	SubShader {
		Tags { "RenderType"="Geometry" }
		LOD 200

		CGPROGRAM
		#pragma surface surf Standard 
		#pragma target 3.0

		sampler2D _MetTexure;

		struct Input {
			float2 uv_MetTexure;
		};

		half _MetallicRange;
		half _EmissionRange;
		fixed4 _Color;
		//half _Range;

		void surf (Input IN, inout SurfaceOutputStandard o) { 
			o.Albedo = _Color.rgb;
			//fixed3 metTex = tex2D(_MetTexure, IN.uv_MetTexure).rgb;
			o.Smoothness = tex2D(_MetTexure, IN.uv_MetTexure).r;
			o.Metallic = _MetallicRange;
			o.Emission = tex2D(_MetTexure, IN.uv_MetTexure).r * _EmissionRange;  
		}
		ENDCG
	}
	FallBack "Diffuse"
}
