Shader "Custom/ReflectionWithNormals" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		[Normal]_BumpTexure ("Bump Texure", 2D) = "bump" {}
		_CubemapTexure ("Cubemap Texure", CUBE) = "" {}
		_ReflMaskTexure ("ReflMask Texure", 2D) = "white" {}
		_ReflAmout ("ReflAmout", Range(0.0, 1.0)) = 0.5
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows
		#pragma target 3.0

		sampler2D _MainTex;
		samplerCUBE _CubemapTexure;
		sampler2D _BumpTexure;
		sampler2D _ReflMaskTexure;
		fixed4 _Color;
		half _ReflAmout;


		struct Input {
			float2 uv_MainTex;
			float2 uv_BumpTexure;
			float3 worldRefl;
			INTERNAL_DATA 
		};

		void surf (Input IN, inout SurfaceOutputStandard o) {
			half4 c = tex2D(_MainTex, IN.uv_MainTex);
			float3 normals = UnpackNormal(tex2D(_BumpTexure, IN.uv_BumpTexure)).rgb;
			float4 reflMask = tex2D(_ReflMaskTexure, IN.uv_MainTex);

			o.Normal = normals;
			o.Albedo = c.rgb * _Color;
			o.Emission = (texCUBE(_CubemapTexure, WorldReflectionVector (IN, o.Normal)).rgb * reflMask.r) * _ReflAmout;
			o.Albedo = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
