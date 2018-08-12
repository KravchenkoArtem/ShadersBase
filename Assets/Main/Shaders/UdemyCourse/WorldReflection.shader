Shader "Custom/WorldReflection" {
	Properties {
		_MainTexure ("Main Texure", 2D) = "white" {}
		_BumpTexure ("Bump Texure", 2D) = "white" {}
		_Brightness ("Brightness", Range(0.0, 10.0)) = 1
		_BumpAmount ("Bump Amount", Range(0.0, 10.0)) = 1
		_Cube("Cube Map", CUBE) = "white" {}

	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		#pragma surface surf Lambert
		#pragma target 3.0

		sampler2D _MainTexure;
		sampler2D _BumpTexure;
		samplerCUBE _Cube;
		half _Brightness;
		half _BumpAmount;

		struct Input {
			float2 uv_MainTexure;
			float2 uv_BumpTexure;
			float3 worldRefl; INTERNAL_DATA 
		};



		void surf (Input IN, inout SurfaceOutput o)
		{
			o.Albedo = tex2D(_MainTexure, IN.uv_MainTexure).rgb;
			o.Normal = UnpackNormal(tex2D(_BumpTexure, IN.uv_BumpTexure)) * _Brightness;
			//o.Normal = UnpackNormal(tex2D(_BumpTexure, IN.uv_BumpTexure)) * 0.3; // Tasks Refl
			o.Normal *= float3(_BumpAmount, _BumpAmount, 1);
			o.Emission = texCUBE(_Cube, WorldReflectionVector(IN, o.Normal)).rgb;
		} 
		ENDCG
	}
	FallBack "Diffuse"
}
