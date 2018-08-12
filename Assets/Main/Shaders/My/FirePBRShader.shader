Shader "Custom/FirePBRShader" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_BumpTexture ("Bump Texutre", 2D) = "bump" {}
		_SpecTexure ("Specular  Texure", 2D) = "white" {}
		_NoramalStength ("NoramalStength", Range (0.01, 1)) = 0.5
		_MaskTexure ("Mask Texure", 2D) = "white" {}
		_TileableTexure ("Tileable Texure", 2D) = "white" {}
		_FireIntencity ("FireIntencity", Range(0, 2)) = 0
		_TileSpeed("TileSpeed", Vector) = (0,0,0,0)
	}
	SubShader {
		Tags{ "RenderType" = "Opaque" }  //"Queue" = "Geometry+0" "IsEmissive" = "true"  
		// Cull Back
		// ZTest LEqual

		CGPROGRAM
		#pragma surface surf StandardSpecular keepalpha vertex:vertexDataFunc 
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _BumpTexture;
		sampler2D _MaskTexure;
		sampler2D _TileableTexure;
		sampler2D _SpecTexure;
		half _NoramalStength;
		half _FireIntencity;
		fixed4 _TileSpeed;

		struct Input
		{
			float2 texcoord_0;
		};

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			o.texcoord_0.xy = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
		}

		/*struct Input {
			float2 uv_MainTex;
			float2 uv_BumpTexture;
			float2 uv_MaskTexture;
			float2 uv_TileableTexture;
			float2 uv_SpecTexture;
		};*/

		void surf (Input IN, inout SurfaceOutputStandardSpecular o) {
			float3 normalTex = UnpackNormal(tex2D(_BumpTexture, IN.texcoord_0));
			o.Normal = lerp(normalTex, fixed3 (0,0,1), -_NoramalStength + 1);
			fixed4 c = tex2D (_MainTex, IN.texcoord_0);
			o.Albedo = c.rgb;
			float2 panner = (IN.texcoord_0 + _Time.x * _TileSpeed);			
			o.Specular = (tex2D(_SpecTexure, IN.texcoord_0)).rgb; 
			o.Emission = ((tex2D(_MaskTexure, IN.texcoord_0) * tex2D (_TileableTexure, panner)) * (_FireIntencity * (_SinTime.w + 1.5))).rgb;
			o.Alpha = 1;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
