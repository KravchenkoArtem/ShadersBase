﻿Shader "Custom/CustomLightingModel/ToonLighting" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_RampTex ("Main Texure", 2D) = "white" {}
	}
	SubShader {
		Tags { "RenderType"="Geometry" }

		CGPROGRAM
		#pragma surface surf ToonRemap

		fixed3 _Color;
		sampler2D _RampTex;

		half4 LightingToonRemap (SurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
		{
			half diff = dot(s.Normal, lightDir); 
			float h = diff * 0.5 + 0.5;
			float2 rh = h;
			float3 ramp = tex2D(_RampTex, rh).rgb;

			half4 c;
			c.rgb = s.Albedo * _LightColor0.rgb * (ramp);
			c.a = s.Alpha;
			return c;
		}  

		struct Input
		{
			float2 uv_MainTex;
			float3 viewDir;
		};

		void surf (Input IN, inout SurfaceOutput o) {
			float diff = dot (o.Normal, IN.viewDir);
			float h = diff * 0.5 + 0.5;
			float2 rh = h;
			o.Albedo = tex2D(_RampTex, rh).rgb;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
