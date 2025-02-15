﻿Shader "Custom/PacktPractice"
{
	Properties
	{
		_myColour ("Example Colour", Color) = (1,1,1,1)
	}
	SubShader
	{
			CGPROGRAM
			    #pragma surface surf Lambert
			    
			    struct Input{
			        float2 uvMainTex;
			        float3 worldRefl;
			    };
			    fixed4 _myColour;
			    
			    void surf (Input IN, inout SurfaceOutput o){
			        o.Albedo = _myColour.rgb;
			    }
			ENDCG
	}
	FallBack "Diffuse"
}
