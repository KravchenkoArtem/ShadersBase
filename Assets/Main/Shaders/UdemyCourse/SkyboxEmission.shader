Shader "Custom/SkyboxEmission" {
	Properties {
		_MyCube ("Skybox", CUBE) = "white" {} 
	}
	SubShader {
		//Tags { "RenderType"="Opaque" }
		//LOD 200

		CGPROGRAM
		#pragma surface surf Lambert
		#pragma target 3.0

		samplerCUBE _MyCube;
		struct Input {
			float3 worldRefl;
		};

        
		
		void surf (Input IN, inout SurfaceOutput o) {
            o.Emission = texCUBE (_MyCube, IN.worldRefl).rgb;			
		}
		ENDCG
	}
	FallBack "Diffuse"
}
