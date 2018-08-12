Shader "Custom/Properties Challenge" {
	Properties {
		//_Color ("Color", Color) = (1, 1, 1, 1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Range ("Range", Range(0,5)) = 1
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		#pragma surface surf Lambert
		#pragma target 3.0

		sampler2D _MainTex;
		//fixed4 _Color;
		half _Range;

		struct Input {
			float2 uv_MainTex;
		};

		void surf (Input IN, inout SurfaceOutput o) {
            //o.Albedo = (tex2D(_MainTex, IN.uv_MainTex) * _Range).rgb * _Color; // First Challenge
			//o.Albedo.rb = (tex2D(_MainTex, IN.uv_MainTex) * _Range).rb * _Color.rb; // Second Challenge
			o.Albedo = (tex2D(_MainTex, IN.uv_MainTex).rgb);
			o.Albedo.g = 1;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
