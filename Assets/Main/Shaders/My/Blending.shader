Shader "Custom/Blending" {
	Properties 
	{
		_MainTint ("Diffuse Tint", Color) = (1,1,1,1)

		_ColorA ("Terrain Color A", Color) = (1,1,1,1)
		_ColorB ("Terrain Color B", Color) = (1,1,1,1)

		
		_RTexture ("Red Channel Texture", 2D) = "" {}
		_GTexture ("Green Channel Texture", 2D) = "" {}
		_BTexture ("Blue Channel Texture", 2D) = "" {}
		//_ATexture ("Alpha Channel Texture", 2D) = "" {}
		 
		_BlendTex ("Blend Texture", 2D) = "" {}
	}
		SubShader
	{
			Tags { "RenderType" = "Opaque" }
			LOD 200

		CGPROGRAM
		#pragma surface surf Lambert
		#pragma target 3.0


		float4 _MainTint;
		float4 _ColorA;
		float4 _ColorB;

		sampler2D _RTexture, _GTexture, _BTexture, _ATexture, _BlendTex;

		struct Input 
		{
			float2 uv_RTexture;
			float2 uv_GTexture;
			float2 uv_BTexture;
			//float2 uv_ATexture;
			float2 uv_BlendTex;
		};
		
		
		float4 blendingColor(Input IN)
		{

			float4 blendData = tex2D(_BlendTex, IN.uv_BlendTex);

			float4 rTexData = tex2D(_RTexture, IN.uv_RTexture);
			float4 gTexData = tex2D(_GTexture, IN.uv_GTexture);
			float4 bTexData = tex2D(_BTexture, IN.uv_BTexture);
			//float4 aTexData = tex2D(_ATexture, IN.uv_ATexture);
			
		        
			float4 finalColor; //= rTexData * blendData.r + gTexData * blendData.g + aTexData * blendData.a; // + bTexData * blendData.b;
			finalColor = lerp(rTexData, gTexData, blendData.g);
			finalColor = lerp(finalColor, bTexData, blendData.b);
			//finalColor = lerp(finalColor, aTexData, blendData.a);
			finalColor.a = 1.0;
			

			float4 blendingLayers = lerp(_ColorA, _ColorB, blendData.r);
			finalColor *= blendingLayers;
			finalColor = saturate(finalColor);
			
			return finalColor;
		}
		
		void surf (Input IN, inout SurfaceOutput o) 
		{
			o.Albedo = blendingColor(IN).rgb * _MainTint.rgb;
			o.Alpha = blendingColor(IN).a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
