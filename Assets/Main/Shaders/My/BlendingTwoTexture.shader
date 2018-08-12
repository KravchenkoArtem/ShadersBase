Shader "Custom/BlendingTwoTexture" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_DecalTex ("Decal Texure", 2D) = "white" {}
		[Toggle] _ShowDecal ("Show Decal", Float) = 0
	}
	SubShader {
		Tags { "RenderType"="Geometry" }
		LOD 200

		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _DecalTex;
		float _ShowDecal;

		struct Input {
			float2 uv_MainTex;
			float2 uv_DecalTex;
		};


		void surf (Input IN, inout SurfaceOutputStandard o) {
			fixed4 a = tex2D (_MainTex, IN.uv_MainTex);
			fixed4 b = tex2D (_DecalTex, IN.uv_DecalTex) * _ShowDecal;
			//o.Albedo = a.rgb * b.rgb; // Черный не транспарент, все остальные смешиваються
			//o.Albedo = a.rgb + b.rgb; // Черный транспарент, все остальные смешиваються
			o.Albedo = b.a > 0.9 ? b.rgb : a.rgb; // Черный транспарент, текстура отрисовуется поверх основной

		}
		ENDCG
	}
	FallBack "Diffuse"
}
