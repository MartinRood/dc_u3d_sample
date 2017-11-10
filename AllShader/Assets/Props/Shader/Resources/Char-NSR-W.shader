Shader "BNN/Charactors/Char-NSR-W"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_NormalTex("Normal", 2D) = "bump" {}
		_ReflectTex("ReflectMap", CUBE) = "" {}
		_SRSTex("SRSMap", 2D) = "white" {}

		_Light1Direction("Light Direction", Vector) = (0, 0, 0, 1)
		_Light1Color("Light Color", Color) = (1, 1, 1, 1)
		_DarkColor("Dark Color", Color) = (0, 0, 0, 1)
		_ADSRIntensity("Ambient Diffuse Specular Reclection Intensity", Vector) = (0.5, 0.5, 1, 1)
		_SCXX("Smoothness CutAlpha", Vector) = (0.7, 0.2, 0, 0)

		[HideInInspector] _SpecCtrlTex("高光控制贴图", 2D) = "white" {}
		[HideInInspector] _ReflectCtrlTex("反射控制贴图", 2D) = "white" {}
		[HideInInspector] _SmoothCtrlTex("光滑控制贴图", 2D) = "white" {}
		[HideInInspector] _RKACtrlTex("反射去底控制贴图", 2D) = "black" {}

		// Blending state
		[HideInInspector] _Mode("__mode", Float) = 0.0
		[HideInInspector] _LightMode("__lightMode", Float) = 0.0
		[HideInInspector] _SrcBlend("__src", Float) = 1.0
		[HideInInspector] _DstBlend("__dst", Float) = 0.0
		[HideInInspector] _DevMode("__dev", Float) = 0.0
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
			Tags{ "LightMode" = "ForwardBase" }
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma multi_compile_fog
#pragma multi_compile __ RIM_ON
#pragma multi_compile __ DEV_MODE_ON
#pragma multi_compile __ LIGHT_FOLLOW_VIEW
#pragma shader_feature _TRANSPARENT_MODE

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
				fixed4 pos : SV_POSITION;
				fixed2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
					half3 tspace0 : TEXCOORD2;
				half3 tspace1 : TEXCOORD3;
				half3 tspace2 : TEXCOORD4;
				float3 posWorld : TEXCOORD5;
			};

			sampler2D unity_NHxRoughness;

			sampler2D _MainTex;
			sampler2D _NormalTex;
			samplerCUBE _ReflectTex;
#ifndef DEV_MODE_ON
			sampler2D _SRSTex;
#else
			sampler2D _SpecCtrlTex;
			sampler2D _ReflectCtrlTex;
			sampler2D _SmoothCtrlTex;
			sampler2D _RKACtrlTex;
#endif

			fixed3 _Light1Color;
			fixed3 _DarkColor;
			half3 _Light1Direction;
			fixed4 _ADSRIntensity;
			fixed4 _SCXX;

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;

				o.posWorld = mul(unity_ObjectToWorld, v.vertex).xyz;

				half3 normal = UnityObjectToWorldNormal(v.normal);
				half3 tangent = UnityObjectToWorldDir(v.tangent.xyz);
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 bitangent = cross(normal, tangent) * tangentSign;

				o.tspace0 = half3(tangent.x, bitangent.x, normal.x);
				o.tspace1 = half3(tangent.y, bitangent.y, normal.y);
				o.tspace2 = half3(tangent.z, bitangent.z, normal.z);

				UNITY_TRANSFER_FOG(o, o.pos);
				return o;
			}

			inline half2 Pow4(half2 x) { return x*x*x*x; }

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 c = tex2D(_MainTex, i.uv);
#ifdef _TRANSPARENT_MODE
				clip(c.a - _SCXX.g);
#endif
				fixed3 n = UnpackNormal(tex2D(_NormalTex, i.uv));

				half3 normal;
				normal.x = dot(i.tspace0, n);
				normal.y = dot(i.tspace1, n);
				normal.z = dot(i.tspace2, n);

				normal = normalize(normal);
				half3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.posWorld));
				half3 lightDir = normalize(_Light1Direction);
				fixed3 lightColor = _Light1Color;

				half3 viewNormal = mul((float3x3) UNITY_MATRIX_V, normal);
				half3 viewDir = mul((float3x3) UNITY_MATRIX_V, worldViewDir);


#ifndef DEV_MODE_ON
				fixed4 srse = tex2D(_SRSTex, i.uv);
#else
				fixed4 srse = fixed4(tex2D(_SpecCtrlTex, i.uv).r, tex2D(_ReflectCtrlTex, i.uv).r, tex2D(_SmoothCtrlTex, i.uv).r, tex2D(_RKACtrlTex, i.uv).r);
#endif
				half smoothness = _SCXX.x * srse.b;
				half roughness = 1 - smoothness;
				half reflIntensity = srse.g;
				half oneMinusReflectivity = 1 - reflIntensity * srse.a/* * _ADSRIntensity.w*/;

				half3 reflDir = reflect(viewDir, viewNormal);
#ifdef LIGHT_FOLLOW_VIEW
				half invLdN = -dot(lightDir, viewNormal);
#else
				half invLdN = -dot(lightDir, normal);
#endif
				half specIntensity = dot(worldViewDir, reflect(lightDir, normal)) * step(0.0, invLdN);
				specIntensity = max(0.0, specIntensity);

				half nv = saturate(dot(viewNormal, viewDir));
				half2 rlPow4AndFresnelTerm = Pow4(half2(dot(reflDir, lightDir), 1 - nv));
				half rlPow4 = rlPow4AndFresnelTerm.x;
				half fresnelTerm = rlPow4AndFresnelTerm.y;
				half grazingTerm = saturate(smoothness + reflIntensity);

				//处理高光始终面向摄像机
				half LUT_RANGE = 16.0;
				half specularFaceToCamera = tex2D(unity_NHxRoughness, half2(rlPow4, roughness)).UNITY_ATTEN_CHANNEL * LUT_RANGE;

				fixed3 dlc = c.rgb * lightColor;
				fixed3 diffuse = dlc * (_ADSRIntensity.x + _ADSRIntensity.y * saturate(invLdN));
				diffuse += c.rgb * _DarkColor * saturate(-invLdN);//背光补充，直接在主光的反方向补偿背光
				fixed3 spec = lightColor * specIntensity * specularFaceToCamera * srse.r * _ADSRIntensity.z;

				half3 reflUVW = reflect(-worldViewDir, normal);
				fixed3 env = texCUBE(_ReflectTex, reflUVW).rgb;
				fixed3 gi = env * lerp(reflIntensity, grazingTerm, fresnelTerm) * _ADSRIntensity.w * max(dlc, srse.a);

				c.rgb = diffuse * oneMinusReflectivity + spec + gi;

				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, c);
				return c;
			}
		ENDCG
		}
	}
	CustomEditor "CharShaderEditor"
}
