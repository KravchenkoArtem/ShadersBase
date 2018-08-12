Shader "Custom/StandartTranslucent" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_Distortion ("Distortion", Range(0.0, 1.0)) = 1.0
		_Power ("Power", Range(0.0, 1.0)) = 1.0
		_Scale ("Scale", Range(0.0, 1.0)) = 1.0
	}
	SubShader {
		Tags { "RenderType"="Transparent" }
		LOD 200

		CGPROGRAM
		#pragma surface surf StandardTranslucent fullforwardshadows
		#pragma target 3.0

		sampler2D _MainTex;

		half _Distortion;
		half _Power;
		half _Scale;

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		#include "UnityPBSLighting.cginc"
		inline fixed4 LightingStandardTranslucent (SurfaceOutputStandard s, fixed3 viewDir, UnityGI gi)
		{
			// Original colour
			fixed4 pbr = LightingStandard(s, viewDir, gi);
			//Translucency Formul
			float3 L = gi.light.dir;
			float3 V = viewDir;
			float3 N = s.Normal;

			float3 H = normalize(L+N * _Distortion);
			float I = pow(saturate(dot(V,-H)), _Power) * _Scale;
			// Calculate intensity of backlight(light translucent)
			pbr.rgb = pbr.rgb + gi.light.color * I;
			return pbr;
		}

		struct Input {
			float2 uv_MainTex;
		};

		void LightingStandardTranslucent_GI(SurfaceOutputStandard s, UnityGIInput data, inout UnityGI gi)
		{
			LightingStandard_GI(s, data, gi); 
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
