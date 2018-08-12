Shader "Custom/CustomLightingModel/BasicLambert" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
	}
	SubShader {
		Tags { "RenderType"="Geometry" }

		CGPROGRAM
		#pragma surface surf BasicLambert

		half4 LightingBasicLambert (SurfaceOutput s, half3 lightDir, half atten)
		{
			half NdotL = dot(s.Normal, lightDir);
			half4 c;
			c.rgb = s.Albedo * _LightColor0 * (NdotL * atten);
			c.a = s.Alpha;
			return c;
		}  

		fixed3 _Color;

		struct Input
		{
			float2 uv_MainTex;
		};

		void surf (Input IN, inout SurfaceOutput o) {
			o.Albedo = _Color.rgb;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
