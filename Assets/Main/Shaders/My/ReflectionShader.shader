﻿// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/ReflectionShader" {
	Properties {
		_Cube("Reflection Map", Cube) = "white"{}
	}
	SubShader {
		Pass {

		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag 

		#include "UnityCG.cginc"

		uniform samplerCUBE _Cube;

		struct vertexInput
		{
			float4 vertex : POSITION;
			float3 normal : NORMAL;
		};

		struct vertexOutput
		{
			float4 pos : SV_POSITION;
			float3 normalDir : TEXCOORD0;
			float3 viewDir : TEXCOORD1;
			 
		};

		vertexOutput vert (vertexInput input)
		{
			vertexOutput output;
			float4x4 modelMatrix = unity_ObjectToWorld;
			float4x4 modelMatrixInverse = unity_WorldToObject;

			output.viewDir = mul(modelMatrix, input.vertex).xyz - _WorldSpaceCameraPos;
			output.normalDir = normalize(mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);
			output.pos = UnityObjectToClipPos(input.vertex);
			return output;
		}

		float4 frag(vertexOutput input) : COLOR
		{
			float3 reflectionDir = reflect(input.viewDir, normalize(input.normalDir));
			return texCUBE(_Cube, reflectionDir);
		}

		ENDCG
		}
	}
	FallBack "Diffuse"
}
