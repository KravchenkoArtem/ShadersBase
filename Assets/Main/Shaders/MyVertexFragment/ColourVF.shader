Shader "Custom/VF/ColourVF"
{      
	Properties {
		_VertColorRange ("VertColorRange", Range (0.01, 10.0)) = 5.0
	}

	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		Cull Off
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			half _VertColorRange;

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 color : COLOR;
			};

			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color.r = (v.vertex.x + _VertColorRange) / (_VertColorRange * 2);
				o.color.g = (v.vertex.z + _VertColorRange) / (_VertColorRange * 2);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = i.color;
				/*col.r = (i.vertex.x) / (_VertColorRange * 100);
				col.g = (i.vertex.y) / (_VertColorRange * 100);*/
				return col;
			}
			ENDCG
		}
	}
}
