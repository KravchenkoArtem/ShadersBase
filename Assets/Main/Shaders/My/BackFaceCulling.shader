Shader "Custom/BackFaceCulling" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "black" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		Cull Off
		// Pass {
		// 	Blend SrcAlpha OneMinusSrcAlpha
		// 	SetTexture [_MainTex] {combine texture  }
		// }

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
