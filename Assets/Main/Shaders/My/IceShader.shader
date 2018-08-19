// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/IceShader" {
	Properties {
		_AlbedoColor ("Color", Color) = (1,1,1,1)
		_FresnelStrength ("Fresnel Strength", Range(0.1, 5)) = 1
		_CubeMapTexture ("CubeMap Texure", Cube) = "white" {}
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_NormalTexure ("Normal Texure", 2D) = "bump" {}
		_NormalStrength ("Normal Strength", Range(0.01, 2.0)) = 1.0
		_Opacity ("Opacity", Range(0.0, 1.0)) = 1.0
	}
	SubShader {
		Tags {"RenderType"="Transparent" "Queue"="Transparent"}
		LOD 200

		Pass {
			ZWrite On
			ColorMask 0

			CGPROGRAM
			#pragma vertex vert;
			#pragma fragment frag;  

			#include "UnityCG.cginc"

			struct vertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD3;
			};

			struct vertexOutput {
				float4 pos : SV_POSITION;
				float3 normalDir : TEXCOORD0;
				float3 viewDir : TEXCOORD1;
				float2 uv : TEXCOORD3;
			};

			half _NormalStrength;
			sampler2D _NormalTexure;
			float4 _NormalTexure_ST;

			vertexOutput vert (vertexInput input) {
				vertexOutput output;
 
            	float4x4 modelMatrix = unity_ObjectToWorld;
            	float4x4 modelMatrixInverse = unity_WorldToObject; 
 
            	output.viewDir = mul(modelMatrix, input.vertex).xyz - _WorldSpaceCameraPos;
            	output.normalDir = normalize( mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);
            	output.uv = TRANSFORM_TEX(input.uv, _NormalTexure);
            	output.pos = UnityObjectToClipPos(input.vertex);
            	return output;
			}

			float4 frag(vertexOutput input) : COLOR
			{
				float3 normal = UnpackNormal(tex2D(_NormalTexure, input.uv)) * (fixed3 (0,0,1), - _NormalStrength);
				
				float4 refractedDir = refract
			}

			ENDCG
		}

		CGPROGRAM
		#pragma surface surf BlinnPhong alpha:fade
		#pragma target 3.0

		sampler2D _MainTex;
		samplerCUBE  _CubeMapTexture;
		//sampler2D _NormalTexure;
		//half _NormalStrength;
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
			half fresnel = 1.0 - saturate(dot(normalize(IN.viewDir), o.Normal));
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
