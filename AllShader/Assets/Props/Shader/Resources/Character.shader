// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "YuLongZhi/Character"
{
	Properties
	{
		_MainTex ("Main", 2D) = "white" {}
		_Bump ("Bump", 2D) = "bump" {}
		_RefMap ("Ref", 2D) = "white" {}
		_CubeMap ("Sky", CUBE) = "" {}
		_RefIntensity ("Ref Intensity", Range(0, 10)) = 0
		_Metallic ("Metallic", Range(0, 1)) = 0

		_Light1Color ("Light1 Color", Color) = (1, 1, 1, 1)
		_Intensity1 ("Light1 Intensity", Range(0, 10)) = 0
		_Light1Direction ("Light1 Direction", Vector) = (0, 0, 0, 1)
		_Light2Color ("Light2 Color", Color) = (1, 1, 1, 1)
		_Intensity2 ("Light2 Intensity", Range(0, 10)) = 0
		_Light2Direction ("Light2 Direction", Vector) = (0, 0, 0, 1)

		[HideInInspector] _RimColor ("Rim Color", Color) = (1, 1, 1, 1)
		[HideInInspector] _RimPow ("Rim Pow", Range(0, 10)) = 1
		[HideInInspector] _HighLight ("High Light", Range(0, 1)) = 0
		[HideInInspector] _DissolveTex ("Dissolve Tex", 2D) = "white" {}
		[HideInInspector] _Dissolve ("Dissolve", Range(0, 1)) = 0
	}

	SubShader
	{
		Tags
		{
			"RenderType" = "Opaque"
			"Queue" = "AlphaTest+2"
		}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			#pragma multi_compile __ RIM_ON
			#pragma multi_compile __ DISSOLVE_ON

			#include "UnityCG.cginc"

			struct appdata
			{
				fixed4 vertex : POSITION;
				fixed2 uv : TEXCOORD0;
				fixed3 normal : NORMAL;
				fixed4 tangent : TANGENT;
			};

			struct v2f
			{
				fixed4 vertex : SV_POSITION;
				fixed2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				half3 tspace0 : TEXCOORD2;
				half3 tspace1 : TEXCOORD3;
				half3 tspace2 : TEXCOORD4;
				float3 worldPos : TEXCOORD5;
			};

			sampler2D _MainTex;
			sampler2D _Bump;
			sampler2D _RefMap;
			float3 _Light1Direction;
			float3 _Light1Color;
			float _Intensity1;
			float3 _Light2Direction;
			float3 _Light2Color;
			float _Intensity2;
			samplerCUBE  _CubeMap;
			float _RefIntensity;
			float _Metallic;

#ifdef RIM_ON
			float3 _RimColor;
			float _RimPow;
#endif

			float _HighLight;

#ifdef DISSOLVE_ON
			sampler2D _DissolveTex;
			float _Dissolve;
#endif

			v2f vert (appdata v)
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f, o);
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				UNITY_TRANSFER_FOG(o,o.vertex);

				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				half3 wNormal = UnityObjectToWorldNormal(v.normal);
                half3 wTangent = UnityObjectToWorldDir(v.tangent.xyz);
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 wBitangent = cross(wNormal, wTangent) * tangentSign;

				o.tspace0 = half3(wTangent.x, wBitangent.x, wNormal.x);
                o.tspace1 = half3(wTangent.y, wBitangent.y, wNormal.y);
                o.tspace2 = half3(wTangent.z, wBitangent.z, wNormal.z);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
#ifdef DISSOLVE_ON
				float4 dissolve = tex2D(_DissolveTex, i.uv);
				float dis = _Dissolve * 1.05;
				float dis_width = 0.03;
				float dis_param_a = 0.0;
                float dis_param_b = 1.0;
                float dis_step_a = step((dissolve.r + dis_width), dis);
                float dis_step_b = step(dis, (dissolve.r + dis_width));
                float dis_lerp_a = lerp((dis_step_a * dis_param_a) + (dis_step_b * dis_param_b), dis_param_a, dis_step_a * dis_step_b);
                clip(dis_lerp_a - 0.5);
#endif

				fixed4 col = tex2D(_MainTex, i.uv);
				fixed3 n = UnpackNormal(tex2D(_Bump, i.uv));
				fixed4 refW = tex2D(_RefMap, i.uv);

				half3 worldNormal;
                worldNormal.x = dot(i.tspace0, n);
                worldNormal.y = dot(i.tspace1, n);
                worldNormal.z = dot(i.tspace2, n);

				half3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				half3 viewNormal = mul((float3x3) UNITY_MATRIX_V, worldNormal);

				fixed3 ld1 = normalize(_Light1Direction);//假灯1
				fixed diff1 = max(0, dot(viewNormal, ld1));
	
				fixed3 ld2 = normalize(_Light2Direction);//假灯2
				fixed diff2 = max(0, dot(viewNormal, ld2));

				fixed3 refd1 = reflect(-worldViewDir, worldNormal);
				fixed4 refcol = texCUBE(_CubeMap, refd1);
				refcol = refcol * _RefIntensity * refW.r;

				fixed4 resultRGBnl = col;
				fixed3 CubemapM = col * refcol;
				fixed3 CubemapN = lerp(refcol, col + refcol * unity_ColorSpaceDielectricSpec.rgb, col.a);
				refcol = fixed4(lerp(CubemapN, CubemapM, _Metallic).rgb, col.a + refcol.a);

				col = lerp(resultRGBnl, refcol, refW.r);//反光效果

				col.rgb = col.rgb + col.rgb * _Light1Color * diff1 * _Intensity1 + col.rgb * _Light2Color * diff2 * _Intensity2;

#ifdef RIM_ON
				fixed3 rim = pow(1.0 - max(0, dot(worldNormal, worldViewDir)), _RimPow) * _RimColor;
				col.rgb += rim;
#endif

				col.rgb += _HighLight;

#ifdef DISSOLVE_ON
				float dis_border = 3.32;
				float3 dis_c = float3(1, 0.424, 0.047);
				float dis_step_c = step(dissolve.r, dis);
                float dis_step_d = step(dis, dissolve.r);
                col.rgb = (col.rgb + ((dis_c * (dis_lerp_a - lerp((dis_step_c * dis_param_a) + (dis_step_d * dis_param_b), dis_param_a, dis_step_c * dis_step_d))) * dis_border));
#endif

				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}