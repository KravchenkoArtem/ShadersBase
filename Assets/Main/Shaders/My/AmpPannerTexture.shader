Shader "CodeAmplify/PannerTexture" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		// _TillingX("Tilling on X", Range(0,10)) = 0
		// _TillingY("Tilling on Y", Range(0,10)) = 0
		// _TillingSpeed("TillingSpeed", Range(0,4)) = 0

		// _OffsetX("Offset on X", Range(0,10)) = 0
		// _OffsetY("Offset on Y", Range(0,10)) = 0
		// _OffsetSpeedX ("OffsetSpeedX", Range(0, 4)) = 0
		// _OffsetSpeedY ("OffsetSpeedY", Range(0, 4)) = 0
		_TileSpeed ("TillingSpeed", Vector) = (0,0,0,0)
		_BumpTexture ("Bump Texure", 2D) = "bump" {}
		_Smoothnes ("Smoothnes", Range(0, 1)) = 0
		_NormalStrength ("NormalStrength", Range(0.01, 1)) = 0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		#pragma surface surf StandardSpecular fullforwardshadows
		#pragma target 3.0

		//uniform float4 _MainTex_ST; // ST для тиллинга
		uniform sampler2D _MainTex;
		uniform sampler2D _BumpTexture;
		//float4 _Time;
		//float4 _SinTime;
		//float4 _CosineTime;
		//float4 unity_DeltaTime;
		/*fixed _TillingX;
		fixed _TillingY;
		half _TillingSpeed;*/

		/*fixed _OffsetX;
		fixed _OffsetY;
		half _OffsetSpeedX;
		half _OffsetSpeedY;*/
		float4 _TileSpeed;
		half _Smoothnes;
		half _NormalStrength;

		struct Input {
			float2 uv_MainTex;
			//float2 uv_BumpTexture;
			//fixed2 uv_texcoord;
		};
        
		
		fixed2 panner(fixed2 tex, half time, fixed4 tileSpeed)
		{
			return tex + time * tileSpeed;
		}


		void surf (Input IN, inout SurfaceOutputStandardSpecular o) {
		    /*fixed offsetX = _OffsetX * (time * _OffsetSpeedX);
		    fixed offsetY = _OffsetY * (time * _OffsetSpeedY);*/
		    /*fixed tillingX = _TillingX * (time * _TillingSpeed);
		    fixed tillingY = _TillingY * (time * _TillingSpeed);*/
		    /*fixed2 offsetUV = fixed2(offsetX, offsetY);*/
			fixed4 c = tex2D (_MainTex, panner(IN.uv_MainTex, _Time.y, _TileSpeed));
			o.Albedo = c.rgb; 
			float3 normalTex = UnpackNormal(tex2D(_BumpTexture, panner(IN.uv_MainTex, _Time.y, _TileSpeed)));
			o.Normal = lerp(normalTex, fixed3 (0,0,1), -_NormalStrength + 1);
			o.Smoothness = _Smoothnes;
			//float2 uv_MainTex = IN.uv_texcoord * (_MainTex_ST.x * offsetX) + (_MainTex_ST.y * offsetY); /*(_MainTex_ST.x * tillingX) + (_MainTex_ST.y * tillingY) + */
			//o.Albedo = tex2D(_MainTex, uv_MainTex).rgb;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
