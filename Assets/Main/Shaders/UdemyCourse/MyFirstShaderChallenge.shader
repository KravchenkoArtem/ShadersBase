Shader "Holistic/FirstShaderChallenge" {
	
	Properties {
         _myTexture ("Example Texture", 2D) =  "white" {}
	     _myNormal ("Example Normal", 2D) =  "bump" {}
	     _NoramalStength("Normal Strength", Range (0.01, 1)) = 0.5
	     //_myEmission ("Example Emission", Color) = (1,1,1,1)
	}
	
	SubShader {
		Tags {"RenderType" = "Opaque"}
		CGPROGRAM
			#pragma surface surf Lambert

			struct Input {
				float2 uv_myTexture;
				float2 uv_myNormal;
			};

			//fixed4 _myEmission;
			sampler2D _myNormal;
			sampler2D _myTexture;
			half _NoramalStength;
			
			void surf (Input IN, inout SurfaceOutput o){
			    //o.Emission = _myEmission.rgb;
			    o.Albedo = tex2D(_myTexture, IN.uv_myTexture).rgb;
			    float3 normalTex = UnpackNormal(tex2D(_myNormal, IN.uv_myNormal));
			    o.Normal = lerp(normalTex, fixed3 (0,0,1), -_NoramalStength + 1);
			}
		
		ENDCG
	}
	
	FallBack "Diffuse"
}