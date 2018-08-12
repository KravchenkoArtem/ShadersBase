Shader "Custom/Disslove" {
	Properties {
		_NoiseTex ("Noise Texture", 2D) = "white" {}
		[HDR] _DissolveColor ("Dissolve Color", Color) = (0,0,0,0)
		_AlbedoTex ("Albedo Texture", 2D) = "white" {}
		_DissolveWidth ("Dissolve Width", Range(0.01, 0.1)) = 0.025
		//_BurnRamp("Burn Ramp", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows 
		#pragma target 3.0

		sampler2D _NoiseTex;
		float4 _NoiseTex_ST;
		sampler2D _AlbedoTex;
		float4 _AlbedoTex_ST;
		float4 _DissolveColor;
		half _DissolveWidth;
		//sampler2D _BurnRamp;

		struct Input {
			float2 uv_texcoord;
			float2 uv_BurnRamp;
		};

		half Remap(half value, half inMin, half inMax, half outMin, half outMax)
    	{
    	return	outMin + (value - inMin) * (outMax - outMin) / (inMax - inMin);
    	}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			float2 uv_NoiseTex = IN.uv_texcoord * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
			fixed4 c = tex2D (_NoiseTex, uv_NoiseTex);
			float2 uv_Albedo = IN.uv_texcoord * _AlbedoTex_ST.xy + _AlbedoTex_ST.zw;
			o.Albedo = tex2D(_AlbedoTex, uv_Albedo).rgb;
			float _remapClipAlpha = Remap(_SinTime.w, -1, 1, 0, 1);
			fixed4 steps = step(c, _remapClipAlpha + _DissolveWidth);
			o.Emission = steps *_DissolveColor.rgb;

			/*float temp_output_73_0 = ( (-0.6 + (( 1.0 - _remapClipAlpha ) - 0) * (0.6 - -0.6) / (1 - 0)) + tex2D(_NoiseTex, uv_NoiseTex).r );
			float clampResult113 = clamp( (-4 + (temp_output_73_0 - 0) * (4 - -4) / (1 - 0)) , 0 , 1 );
			float temp_output_130_0 = ( 1.0 - clampResult113 );
			float2 appendResult115 = (float2(temp_output_130_0 , 0));
			o.Emission = ( temp_output_130_0 * tex2D( _BurnRamp, appendResult115)).rgb;*/
			//o.Alpha = 0;
			clip( c - _remapClipAlpha);

		}
		ENDCG
	}
	FallBack "Diffuse"
}
