Shader "Custom/FresnelShader" {
	Properties {
		[Toggle(SWITCH_EXTINT)]
		_Switch("Switch EXT/INT", FLoat) = 0
	 	_ShininessFirst ("ShininessFirst", Range (0.01, 1)) = 1

	 	//_MyColor ("Shine Color", Color) = (1,1,1,1)
	 	_CutoffColorFirst ("Cutoff Color First", Color) = (1.0, 1.0, 1.0, 1.0) 
	 	_ShininessSecond ("_ShininessSecond", Range (0.01, 1)) = 1
	 	_CutoffColorSecond ("Cutoff Color Second", Color) = (1.0, 1.0, 1.0, 1.0) 

	 	_CutoffRangeFirst ("Cutoff Range First", Range(0.0, 1)) = 0.5
	 	_CutoffRangeSecond ("Cutoff Range Second", Range(0.0, 1)) = 0.5
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Bump ("Bump", 2D) = "bump" {}

	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		#pragma surface surf Lambert
		#pragma target 3.0
		#pragma  shader_feature SWITCH_EXTINT

		sampler2D _MainTex;
		sampler2D _Bump;
		half _ShininessFirst;
		half _ShininessSecond;
		//fixed4 _MyColor; 
		fixed4 _CutoffColorFirst;
		fixed4 _CutoffColorSecond;

		half _CutoffRangeFirst;
		half _CutoffRangeSecond;

		struct Input {
			float2 uv_MainTex;
			float2 uv_Bump;
			float3 viewDir;
			float3 worldPos;
		};

		void surf (Input IN, inout SurfaceOutput o) {
			half factor;
			half4 c = tex2D (_MainTex, IN.uv_MainTex);
			o.Normal = UnpackNormal(tex2D(_Bump, IN.uv_Bump));
			#ifdef SWITCH_EXTINT
				factor = 1 - saturate(dot(normalize(IN.viewDir),o.Normal));
			#else 
				factor = dot(normalize(IN.viewDir),o.Normal);
			#endif
			o.Albedo = c.rgb; //+_MyColor*(_Shininess-factor*_Shininess);
			//o.Emission.rgb = _MyColor*(_Shininess-factor*_Shininess);
			float3 tempFirst = _CutoffColorFirst.rgb * pow(factor ,_ShininessFirst);
			float3 tempSecond = _CutoffColorSecond.rgb * pow(factor ,_ShininessSecond);
			o.Emission.rgb = factor > _CutoffRangeFirst ? tempFirst : factor > _CutoffRangeSecond ? tempSecond : 0;
			// Test fractional(дробный) in worldPos
			//o.Emission = frac( IN.worldPos.y * 10 * 0.5) > 0.4 ? _CutoffColorFirst * factor : _CutoffColorSecond * factor;
			o.Alpha = c.a;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
