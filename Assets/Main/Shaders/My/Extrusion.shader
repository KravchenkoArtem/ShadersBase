
Shader "Custom/Extrusion" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
		_ExtrusionPoint("ExtrusionPoint", Float) = 0
		_ExtrusionAmount("Extrusion Amount", Range( -1 , 20)) = 0.5
	}
	SubShader {
		Tags { "RenderType"="Opaque" "Queue" = "Geometry+0"}
		//LOD 200
		Cull Back
		ZTest LEqual

		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma surface surf Standard fullforwardshadows vertex:vertexDataFunc 
		#pragma target 3.0

		sampler2D _MainTex;
		float4 _MainTex_ST;
		float _ExtrusionPoint;
		float _ExtrusionAmount;

		struct Input {
			float2 uv_texcoord;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		
		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertexNormal = v.normal.xyz;
			float3 ase_vertex3Pos = v.vertex.xyz;
			v.vertex.xyz += ( ase_vertexNormal * max( ( sin( ( (( ase_vertex3Pos.x + _Time.x ) * (ase_vertex3Pos.x + _Time.x)) / _ExtrusionPoint ) ) / _ExtrusionAmount ) , 0.0 ) );
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
		    float2 uv_Albedo = IN.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			fixed4 c = tex2D (_MainTex, uv_Albedo) * _Color;
			o.Albedo = c.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
