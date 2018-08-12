Shader "Custom/FullTextureShaderBunny"
{
	Properties
	{
		_MainTex ("Diffuse Texture", 2D) = "white" {}
		_EmissiveTex ("Emissive Texture", 2D) = "white" {}
        [HDR]_MainColor ("MainColor", Color) = (1,1,1,1)
		_OcclusionTex ("Occlusion Texture", 2D) = "white" {}
		_SpecularTex ("Specular Texture", 2D) = "white" {}
		_SpecularColor("Specular Color", Color) = (1,1,1,1)
		_NormalTex ("Normal Texture", 2D) = "bump" {}
		_NoramalStength("Normal Strength", Range(0.01, 10)) = 1
		//_myBright ("Brightness", Range(0,10)) = 1
		
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }

			CGPROGRAM
            #pragma surface surf StandardSpecular fullforwardshadows
            #pragma target 3.0
            
            struct Input{
                float2 uv_MainTex;
                float2 uv_EmissiveTex;
                float2 uv_NormalTex;
                float2 uv_OcclusionTex;
                float2 uv_SpecularTex;
            };
            
            sampler2D _EmissiveTex;
            sampler2D _MainTex;
            sampler2D _NormalTex;
            sampler2D _OcclusionTex;
            sampler2D _SpecularTex;
            fixed4 _SpecularColor;
            fixed4 _MainColor;
            half _NoramalStength;
            //half _myBright;
            
            void surf (Input IN, inout SurfaceOutputStandardSpecular o)
            {
                o.Albedo = tex2D(_MainTex, IN.uv_MainTex);
                o.Emission = tex2D (_EmissiveTex, IN.uv_EmissiveTex) * _MainColor;
                o.Occlusion = tex2D(_OcclusionTex, IN.uv_OcclusionTex).rgb;
                o.Specular = tex2D(_SpecularTex, IN.uv_SpecularTex) * _SpecularColor;
                //float3 normalTex = UnpackNormal(tex2D(_NormalTex, IN.uv_NormalTex)); Alternative Strength
			    //o.Normal = lerp(normalTex, fixed3 (0,0,1), -_NoramalStength + 1);
			    o.Normal = UnpackNormal(tex2D(_NormalTex, IN.uv_NormalTex));//* _myBright;
			    o.Normal *= float3(_NoramalStength, _NoramalStength, 1);
                o.Alpha = 1;
            }
			ENDCG
		}
        Fallback "Diffuse"
	}
