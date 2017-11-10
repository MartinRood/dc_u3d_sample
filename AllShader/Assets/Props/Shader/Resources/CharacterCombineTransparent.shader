// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "YuLongZhi/CharacterCombineTransparent"
{
	Properties
	{
		_MainTex ("Main", 2D) = "white" {}
		_MainTex2 ("Main2", 2D) = "white" {}
		_Color("Color", Color) = (1, 1, 1, 1)
	}

	CGINCLUDE
		#include "UnityCG.cginc"

		struct appdata
		{
			fixed4 vertex : POSITION;
			fixed4 color : COLOR;
			fixed2 uv : TEXCOORD0;
		};

		struct v2f
		{
			fixed4 vertex : SV_POSITION;
			fixed4 color : COLOR;
			fixed2 uv : TEXCOORD0;
		};

		sampler2D _MainTex;
		sampler2D _MainTex2;
		fixed4 _Color;

		v2f vert (appdata v)
		{
			v2f o;
			o.vertex = UnityObjectToClipPos(v.vertex);
			o.color = v.color;
			o.uv = v.uv;
			return o;
		}
			
		fixed4 frag (v2f i) : SV_Target
		{
			int index = ceil(i.color.r * 255);

			fixed4 col;
			if(index == 0) {
				col = tex2D(_MainTex, i.uv);
			}
			else {
				col = tex2D(_MainTex2, i.uv);
			}

			return col * _Color;
		}
	ENDCG

	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
		}

		Pass
		{
			ColorMask 0

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}

		Pass
		{
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}
