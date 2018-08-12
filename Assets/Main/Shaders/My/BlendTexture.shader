Shader "Custom/BlendTexture" {
	Properties {
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("SrcBlend", Float) = 1.0
		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("DstBlend", Float) = 0.0
		_ZWrite ("ZWrite", Float) = 1.0
		_MainTex ("Albedo (RGB)", 2D) = "black" {}
	}

	//Самые распространенные смешивания.
	//Blend SrcAlpha OneMinusSrcAlpha // Traditional transparency
	//Blend One OneMinusSrcAlpha // Premultiplied transparency
	//Blend One One // Additive
	//Blend OneMinusDstColor One // Soft Additive
	//Blend DstColor Zero // Multiplicative
	//Blend DstColor SrcColor // 2x Multiplicative

	SubShader {
		Tags { "Queue"="Transparent" }
		Pass {
			Blend [_SrcBlend] [_DstBlend]
			ZWrite [_ZWrite] 
			SetTexture [_MainTex] {combine texture  }
		}
	}
}
