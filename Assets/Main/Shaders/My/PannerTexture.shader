Shader "Custom/TillingTexture" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		// _TillingX("Tilling on X", Range(0,10)) = 0
		// _TillingY("Tilling on Y", Range(0,10)) = 0
		// _TillingSpeed("TillingSpeed", Range(0,4)) = 0

		_OffsetX("Offset on X", Range(0,10)) = 0
		_OffsetY("Offset on Y", Range(0,10)) = 0
		_OffsetSpeedX ("OffsetSpeedX", Range(0, 4)) = 0
		_OffsetSpeedY ("OffsetSpeedY", Range(0, 4)) = 0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows
		#pragma target 3.0

		//uniform float4 _MainTex_ST; // ST для тиллинга
		uniform sampler2D _MainTex;
		//float4 _Time;
		//float4 _SinTime;
		//float4 _CosineTime;
		//float4 unity_DeltaTime;
		/*fixed _TillingX;
		fixed _TillingY;
		half _TillingSpeed;*/

		fixed _OffsetX;
		fixed _OffsetY;
		half _OffsetSpeedX;
		half _OffsetSpeedY;

		struct Input {
			float2 uv_MainTex;
			//fixed2 uv_texcoord;
		};
        
        
        //float4 = 

		void surf (Input IN, inout SurfaceOutputStandard o) {
			half time = _Time.y;
		    fixed offsetX = _OffsetX * (time * _OffsetSpeedX);
		    fixed offsetY = _OffsetY * (time * _OffsetSpeedY);
		    /*fixed tillingX = _TillingX * (time * _TillingSpeed);
		    fixed tillingY = _TillingY * (time * _TillingSpeed);*/
		    fixed2 offsetUV = fixed2(offsetX, offsetY);
		    fixed2 mainUV = IN.uv_MainTex + offsetUV;
			fixed4 c = tex2D (_MainTex, mainUV); 
			o.Albedo = c.rgb; 
			//float2 uv_MainTex = IN.uv_texcoord * (_MainTex_ST.x * offsetX) + (_MainTex_ST.y * offsetY); /*(_MainTex_ST.x * tillingX) + (_MainTex_ST.y * tillingY) + */
			//o.Albedo = tex2D(_MainTex, uv_MainTex).rgb;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
