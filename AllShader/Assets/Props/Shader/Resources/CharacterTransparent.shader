// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "YuLongZhi/CharacterTransparent"
{
	Properties
	{
		_MainTex ("Main", 2D) = "white" {}
		_Color ("Color", Color) = (1, 1, 1, 1)
	}

	CGINCLUDE
		#include "UnityCG.cginc"

		struct appdata
		{
			fixed4 vertex : POSITION;
			fixed2 uv : TEXCOORD0;
		};

		struct v2f
		{
			fixed4 vertex : SV_POSITION;
			fixed2 uv : TEXCOORD0;
		};

		sampler2D _MainTex;
		fixed4 _Color;

		v2f vert (appdata v)
		{
			v2f o;
			o.vertex = UnityObjectToClipPos(v.vertex);
			o.uv = v.uv;
			return o;
		}
			
		fixed4 frag (v2f i) : SV_Target
		{
			fixed4 col = tex2D(_MainTex, i.uv) * _Color;
			return col;
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
