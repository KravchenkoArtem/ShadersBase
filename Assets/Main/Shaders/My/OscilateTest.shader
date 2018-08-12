﻿Shader "Custom/OscilateTest" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_SpeedOscilate ("SpeedOscilate", Range(0,50)) = 0.5
		//_Metallic ("Metallic", Range(0,1)) = 0.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		half _SpeedOscilate;
		//half _Metallic;
		fixed4 _Color;

		half oscilate (float time, float speed, float scale)
		{
			return cos(time * speed / 3.14) * scale;
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			half smoothPower = sin(_SpeedOscilate * _Time);
			o.Smoothness = smoothPower;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
