Shader "Custom/DebugShader" {
	Properties {
		[Toggle(SWITCH_DEBUG)]
		_SwitchDbug ("Switch Debug", FLoat) = 0
		//_BumpMap ("Normal Map", 2D) = "bump" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows
		#pragma target 3.0
		#pragma  shader_feature  SWITCH_DEBUG 

		int _SwitchSlider;
		//sampler2D _BumpMap;

		struct Input {
			float3 worldRefl;
			//float2 uv_BumpMap;
		};

		void surf (Input IN, inout SurfaceOutputStandard o) {
            //float3 norm = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
            #ifdef SWITCH_DEBUG
            	o.Albedo = IN.worldRefl;
            #else
            	o.Albedo = o.Normal;
			#endif            	
		}
		ENDCG
	}
	FallBack "Diffuse"
}
