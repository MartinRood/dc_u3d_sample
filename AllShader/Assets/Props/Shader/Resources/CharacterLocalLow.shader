// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "YuLongZhi/CharacterLocalLow"
{
	Properties
	{
		_MainTex ("Main", 2D) = "white" {}

		_Light1Color ("Light1 Color", Color) = (1, 1, 1, 1)
		_Intensity1 ("Light1 Intensity", Range(0, 10)) = 0
		_Light1Direction ("Light1 Direction", Vector) = (0, 0, 0, 1)
		_Light2Color ("Light2 Color", Color) = (1, 1, 1, 1)
		_Intensity2 ("Light2 Intensity", Range(0, 10)) = 0
		_Light2Direction ("Light2 Direction", Vector) = (0, 0, 0, 1)

		_TransColor ("Transparent Color", Color) = (1, 1, 1, 1)

		[HideInInspector] _RimColor ("Rim Color", Color) = (1, 1, 1, 1)
		[HideInInspector] _RimPow ("Rim Pow", Range(0, 10)) = 1

		[HideInInspector] _HighLight ("High Light", Range(0, 1)) = 0
	}
	SubShader
	{
		Tags
		{
			"RenderType" = "Opaque"
			"Queue" = "AlphaTest+1"
		}
		
		Pass
		{
			Cull Front
			ZTest Greater
			ZWrite Off
			Blend SrcAlpha One

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			fixed4 _TransColor;

			struct appdata {
				fixed4 vertex : POSITION;
				fixed3 normal : NORMAL;
			};

			struct v2f {
				fixed4 vertex : SV_POSITION;
				fixed3 normal : TEXCOORD0;
				fixed3 viewDir : TEXCOORD1;
			};

			v2f vert(appdata v) {
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.normal = UnityObjectToWorldNormal(v.normal);

				fixed3 posWorld = mul(unity_ObjectToWorld, v.vertex);
				o.viewDir = normalize(posWorld - _WorldSpaceCameraPos.xyz);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target {
				half rim = 1.0 - saturate(dot(normalize(i.viewDir), i.normal));
				return _TransColor * rim;
			}

			ENDCG
		}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			#pragma multi_compile __ RIM_ON

			#include "UnityCG.cginc"

			struct appdata
			{
				fixed4 vertex : POSITION;
				fixed2 uv : TEXCOORD0;
				fixed3 normal : NORMAL;
			};

			struct v2f
			{
				fixed4 vertex : SV_POSITION;
				fixed2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				half3 worldNormal : TEXCOORD2;
				float3 worldPos : TEXCOORD3;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float3 _Light1Direction;
			float3 _Light1Color;
			float _Intensity1;
			float3 _Light2Direction;
			float3 _Light2Color;
			float _Intensity2;
			
#ifdef RIM_ON
			float3 _RimColor;
			float _RimPow;
#endif

			float _HighLight;

			v2f vert (appdata v)
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f, o);
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				UNITY_TRANSFER_FOG(o,o.vertex);

				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);

				half3 worldNormal = normalize(i.worldNormal);
				half3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				half3 viewNormal = mul((float3x3) UNITY_MATRIX_V, worldNormal);

				fixed3 ld1 = normalize(_Light1Direction);//假灯1
				fixed diff1 = max(0, dot(viewNormal, ld1));
	
				fixed3 ld2 = normalize(_Light2Direction);//假灯2
				fixed diff2 = max(0, dot(viewNormal, ld2));

				col.rgb = 0.5 * col.rgb + col.rgb * _Light1Color * diff1 * _Intensity1 + col.rgb * _Light2Color * diff2 * _Intensity2;

#ifdef RIM_ON
				fixed3 rim = pow(1.0 - max(0, dot(worldNormal, worldViewDir)), _RimPow) * _RimColor;
				col.rgb += rim;
#endif

				col.rgb += _HighLight;

				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}