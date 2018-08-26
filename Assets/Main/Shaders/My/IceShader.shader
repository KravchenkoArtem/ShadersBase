// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/IceShader" {
	Properties {
		_AlbedoColor ("Color", Color) = (1,1,1,1)
		_FresnelStrength ("Fresnel Strength", Range(0.1, 5)) = 1
		_CubeMapTexture ("CubeMap Texure", Cube) = "white" {}
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_NormalTexure ("Normal Texure", 2D) = "bump" {}
		_NormalStrength ("Normal Strength", Range(0.01, 20.0)) = 1.0
		_Opacity ("Opacity", Range(0.0, 1.0)) = 1.0
	}
	SubShader {
		Tags {"RenderType"="Transparent" "Queue"="Transparent"}
		GrabPass{ }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 uvgrab : TEXCOORD1;
				float2 uvbump : TEXCOORD2;
				float4 vertex : SV_POSITION;
			};

			sampler2D _GrabTexture;
			//float4 _GrabTexture_TexelSize; // Размер пикселя
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _NormalTexure;
			float4 _NormalTexure_ST;
			half _NormalStrength;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uvgrab.xy = (float2(o.vertex.x, -o.vertex.y) + o.vertex.w) * 0.5;
				o.uvgrab.zw = o.vertex.zw;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uvbump = TRANSFORM_TEX(v.uv, _NormalTexure);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				half2 bump = UnpackNormal(tex2D(_NormalTexure, i.uvbump)).rg;
				float2 offset = bump * _NormalStrength /** _GrabTexture_TexelSize.xy*/;
				i.uvgrab.xy = offset * i.uvgrab.z + i.uvgrab.xy;

				fixed4 col = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(i.uvgrab));
				fixed4 tint = tex2D(_MainTex, i.uv);
				col *= tint;
				return col;
			}
			ENDCG
		}

		CGPROGRAM
		#pragma surface surf BlinnPhong alpha:fade
		#pragma target 3.0

		sampler2D _MainTex;
		samplerCUBE  _CubeMapTexture;
		sampler2D _NormalTexure;
		half _NormalStrength;
		half _FresnelStrength;
		half _Opacity;

		struct Input {
			float3 viewDir;
			float2 uv_MainTex;
			float3 worldRefl;
			INTERNAL_DATA 
		};

		fixed4 _AlbedoColor;

		void surf (Input IN, inout SurfaceOutput o) {
			half fresnel = 1.0 - saturate(dot(normalize(IN.viewDir), o.Normal)); //dot(normalize(IN.viewDir),o.Normal); 
			fixed4 mainTex = tex2D(_MainTex, IN.uv_MainTex);
			/*float3 normalTex = UnpackNormal(tex2D(_NormalTexure, IN.uv_MainTex));
		    o.Normal = normalTex * (fixed3 (0,0,1), - _NormalStrength);*/
			float3 cubeMapTex = texCUBE(_CubeMapTexture, WorldReflectionVector (IN, o.Normal)).rgb;
			fixed3 emis = saturate(mainTex.rgb * cubeMapTex.rgb * (saturate(1 - (pow(fresnel, _FresnelStrength)))));
			o.Emission = emis;
			o.Albedo = _AlbedoColor.rgb;
			o.Alpha = _Opacity;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
