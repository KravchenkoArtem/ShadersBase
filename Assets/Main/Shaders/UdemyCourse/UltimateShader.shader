Shader "Custom/UltimateShader" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_BumpMap ("Normal Map", 2D) = "bump" {}
		_BumpScale ("Normal Scale", Range(0,1)) = 1
		_HeightMap ("Height Map", 2D) = "white" {}
		_HeightScale ("HeightMap Scale", Range(0,1)) = 1
		
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		#pragma surface surf StandardSpecular fullforwardshadows
        #pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		void surf (Input IN, inout SurfaceOutputStandardSpecular o)
        {
                
        }
		ENDCG
	}
	FallBack "Diffuse"
}
