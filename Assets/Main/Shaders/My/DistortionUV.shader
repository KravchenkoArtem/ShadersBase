Shader "Custom/DistortionUV" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_NoiseRGBTexure ("NoiseRGB Texure", 2D) = "white" {}
		_DisortionAMtX ("DisortionAMtX", Range(0.0, 1.0)) = 1.0
		_DisortionAMtY ("DisortionAMtY", Range(0.0, 1.0)) = 1.0
		[HDR]
		_Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		Pass 
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment  frag 

			#include "UNityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _NoiseRGBTexure;
			//float4 _NoiseRGBTexure_ST;
			half _DisortionAMtX;
			half _DisortionAMtY;
			fixed4 _Color;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0; 
			};

			struct  v2f
			{
				float2 uv : TEXCOORD0; 
				float4 vertex : SV_POSITION;
				float4 Color  : COLOR; 
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 noise = tex2D(_NoiseRGBTexure, i.uv);
				fixed2 distX = ((noise.b *_DisortionAMtX) + i.uv.x);
				fixed2 distY = ((noise.g *_DisortionAMtY) + i.uv.y);
				fixed2 fin = distX * distY;
				fixed4 col = tex2D(_MainTex, fin) * _Color;
				return col;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
