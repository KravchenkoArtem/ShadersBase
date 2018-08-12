Shader "Custom/Hologram" {
	Properties {
		[HDR]_RimColor ("Rim Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_AlbColor ("Albedo Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_RimPower ("RimPower", Range(0.5, 8.0)) = 3.0
		_HoloTexture ("Hologram Texure", 2D) = "white" {}
		_OffsetSpeedY ("OffsetSpeedY", Range(0, 4)) = 0
	}
	SubShader {
		Tags { "RenderType"="Transparent" }
		LOD 200

		Pass {
			ZWrite On
			ColorMask 0 
		}

		CGPROGRAM
		#pragma surface surf Lambert alpha:fade
		#pragma target 3.0

		struct Input {
			float3 viewDir;
			float2 uv_HoloTexture;
		};

		fixed4 _RimColor;
		fixed4 _AlbColor;
		half _RimPower;
		sampler2D _HoloTexture;
		half _OffsetSpeedY;

		float rand(float n){return frac(sin(n) * 43758.5453123);}

		void surf (Input IN, inout SurfaceOutput o) {
			o.Albedo = _AlbColor;
			half time = _Time;
			fixed offsetY = time * _OffsetSpeedY;
			fixed2 newOffsetUV = IN.uv_HoloTexture + fixed2(0, offsetY);
			half rim = 1.0 - saturate(dot(normalize(IN.viewDir), o.Normal));
			fixed4 c = tex2D(_HoloTexture, newOffsetUV);
			half randomMultipiler = rand(time) > 0.8 ? 1.0 : 0.8;
			o.Emission = (_RimColor.rgb * pow(rim, _RimPower) * 10) * randomMultipiler;
			o.Alpha = c;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
