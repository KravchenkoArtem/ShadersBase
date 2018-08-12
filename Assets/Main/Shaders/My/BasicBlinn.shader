Shader "Custom/CustomLightingModel/BasicBlinn" {
	Properties {
		[HDR] _Color ("Color", Color) = (1,1,1,1)
		_MainTexure ("Main Texure", 2D) = "white" {}
	}
	SubShader {
		Tags { "RenderType"="Geometry" }

		CGPROGRAM
		#pragma surface surf BasicBlinn

		half4 LightingBasicBlinn (SurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
		{
			half3 h = normalize(lightDir + viewDir); // half Vector
			half diff = max(0, dot(s.Normal, lightDir)); 

			float nh = max(0, dot(s.Normal, h));
			float spec = pow(nh, 48.0);

			half4 c;
			c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0 * spec) * atten * _SinTime;
			c.a = s.Alpha;
			return c;
		}  

		fixed3 _Color;
		sampler2D _MainTexure;

		struct Input
		{
			float2 uv_MainTexure;
		};

		void surf (Input IN, inout SurfaceOutput o) {
			o.Albedo = tex2D(_MainTexure, IN.uv_MainTexure).rgb * _Color;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
