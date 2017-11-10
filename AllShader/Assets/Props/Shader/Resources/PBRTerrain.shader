Shader "YuLongZhi/PBRTerrain"
{
	Properties
	{
		_Splat0 ("Layer 0", 2D) = "white" {}
		_Normal0 ("Normal 0", 2D) = "bump" {}
		_Splat1 ("Layer 1", 2D) = "white" {}
		_Normal1 ("Normal 1", 2D) = "bump" {}
		_Control ("Control (RGBA)", 2D) = "white" {}
		_CubeMap ("CubeMap", CUBE) = "" {}
		_Spec0 ("Spec 0", Color) = (1, 1, 1, 1)
		_Spec1 ("Spec 1", Color) = (1, 1, 1, 1)
		_Smoothness ("Smoothness", Vector) = (0.5, 0.5, 0.5, 0.5)

		[HideInInspector] _Shadow ("Shadow", 2D) = "black" {}
		[HideInInspector] _ShadowFade ("ShadowFade", 2D) = "black" {}
		[HideInInspector] _ShadowStrength ("ShadowStrength", Range(0, 1)) = 1
	}

	SubShader
	{
		Pass
		{
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			#pragma multi_compile __ SHADOW_ON
			#pragma multi_compile __ BRIGHTNESS_ON
            #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 pack0 : TEXCOORD0; // _Control _Splat0
				float4 pack1 : TEXCOORD1; // _Splat1 lm
				half3 tspace0 : TEXCOORD2;
				half3 tspace1 : TEXCOORD3;
				half3 tspace2 : TEXCOORD4;
				float3 posWorld : TEXCOORD5;
				UNITY_FOG_COORDS(6)
#ifdef SHADOW_ON
				float2 shadow_uv : TEXCOORD7;
#endif
			};

			//sampler2D unity_NHxRoughness;

			sampler2D _Control;
			sampler2D _Splat0, _Splat1;
			sampler2D _Normal0, _Normal1;
			float4 _Control_ST;
			float4 _Splat0_ST;
			float4 _Splat1_ST;

			samplerCUBE _CubeMap;
			fixed3 _Spec0;
			fixed3 _Spec1;
			half4 _Smoothness;

#ifdef SHADOW_ON
			sampler2D _Shadow, _ShadowFade;
			float4x4 shadow_projector;
			float _ShadowStrength;
			float4 _Shadow_TexelSize;
#endif

#ifdef BRIGHTNESS_ON
			fixed3 _Brightness;
#endif

			v2f vert (appdata v)
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f, o);
				o.pos = UnityObjectToClipPos(v.vertex);
				
				half3 normal = UnityObjectToWorldNormal(v.normal);
                half3 tangent = UnityObjectToWorldDir(v.tangent.xyz);
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 bitangent = cross(normal, tangent) * tangentSign;

				o.tspace0 = half3(tangent.x, bitangent.x, normal.x);
                o.tspace1 = half3(tangent.y, bitangent.y, normal.y);
                o.tspace2 = half3(tangent.z, bitangent.z, normal.z);
				o.posWorld = mul(unity_ObjectToWorld, v.vertex).xyz;

				o.pack0.xy = TRANSFORM_TEX(v.uv, _Control);
				o.pack0.zw = TRANSFORM_TEX(v.uv, _Splat0);
				o.pack1.xy = TRANSFORM_TEX(v.uv, _Splat1);
				
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
				o.pack1.zw = v.uv2.xy * unity_LightmapST.xy + unity_LightmapST.zw;
#endif

#ifdef SHADOW_ON
				float4 shadow_uv = mul(shadow_projector, mul(unity_ObjectToWorld, v.vertex));
				o.shadow_uv = (shadow_uv.xy / shadow_uv.w + float2(1, 1)) * 0.5;
#endif

				UNITY_TRANSFER_FOG(o, o.pos);
				return o;
			}

			//inline half2 Pow4 (half2 x) { return x*x*x*x; }

			fixed4 frag (v2f i) : SV_Target
			{
				float2 uv_Control = i.pack0.xy;
				float2 uv_Splat0 = i.pack0.zw;
				float2 uv_Splat1 = i.pack1.xy;

				fixed4 c = 0;
				fixed4 splat_control = tex2D(_Control, uv_Control);
				fixed3 lay0 = tex2D(_Splat0, uv_Splat0);
				fixed3 lay1 = tex2D(_Splat1, uv_Splat1);
				fixed3 n0 = UnpackNormal(tex2D(_Normal0, uv_Splat0));
				fixed3 n1 = UnpackNormal(tex2D(_Normal1, uv_Splat1));

				half3 normal0;
                normal0.x = dot(i.tspace0, n0);
                normal0.y = dot(i.tspace1, n0);
                normal0.z = dot(i.tspace2, n0);
				normal0 = normalize(normal0);

				half3 normal1;
                normal1.x = dot(i.tspace0, n1);
                normal1.y = dot(i.tspace1, n1);
                normal1.z = dot(i.tspace2, n1);
				normal1 = normalize(normal1);

				c.a = 1.0;
				c.rgb = (lay0 * splat_control.r + lay1 * splat_control.g + lay0 * splat_control.b + lay0 * splat_control.a);
				
				half3 normal;
				normal = (normal0 * splat_control.r + normal1 * splat_control.g + normal0 * splat_control.b + normal0 * splat_control.a);
				normal = normalize(normal);

				fixed3 _Spec;
				_Spec = (_Spec0 * splat_control.r + _Spec1 * splat_control.g + _Spec0 * splat_control.b + _Spec0 * splat_control.a);

				fixed3 Smoothness;
				Smoothness = (_Smoothness.x * splat_control.r + _Smoothness.y * splat_control.g + _Smoothness.x * splat_control.b + _Smoothness.x * splat_control.a);

				half3 viewDir = normalize(UnityWorldSpaceViewDir(i.posWorld));
				half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 lightColor = _LightColor0;

				fixed3 specColor = _Spec;
				half smoothness = Smoothness;
				half roughness = 1 - smoothness;

				half reflectivity = max(max(specColor.r, specColor.g), specColor.b);
				half oneMinusReflectivity = 1 - reflectivity;

				half3 reflDir = reflect(viewDir, normal);
				half nl = saturate(dot(normal, lightDir));
				half nv = saturate(dot(normal, viewDir));

				half2 rlPow4AndFresnelTerm = Pow4(half2(dot(reflDir, lightDir), 1 - nv));
				half rlPow4 = rlPow4AndFresnelTerm.x;
				half fresnelTerm = rlPow4AndFresnelTerm.y;
				half grazingTerm = saturate(smoothness + reflectivity);

				half LUT_RANGE = 16.0;
				half specular = tex2D(unity_NHxRoughness, half2(rlPow4, 1 - smoothness)).UNITY_ATTEN_CHANNEL * LUT_RANGE;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT * c.rgb;
				fixed3 diffuse = ambient + lightColor * nl * c.rgb;
				fixed3 spec = lightColor * nl * specular * specColor;

				half3 reflUVW = reflect(-viewDir, normal);
				
				//int UNITY_SPECCUBE_LOD_STEPS = 6;
				half mip = roughness * (1.7 - 0.7 * roughness) * UNITY_SPECCUBE_LOD_STEPS;
#if ((SHADER_TARGET < 25) && defined(SHADER_API_D3D9)) || defined(SHADER_API_D3D11_9X)
				fixed3 env = texCUBEbias(_CubeMap, half4(reflUVW, mip)).rgb;
#else
				fixed3 env = texCUBElod(_CubeMap, half4(reflUVW, mip)).rgb;
#endif
				fixed3 gi = env * lerp(specColor, grazingTerm, fresnelTerm);
				
#if !defined(LIGHTMAP_OFF) || defined(LIGHTMAP_ON)
				fixed3 lm = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.pack1.zw));
				diffuse *= lm;
#endif

				c.rgb = diffuse * oneMinusReflectivity + gi + spec;

#ifdef SHADOW_ON
				fixed shadow = 0;
				for(fixed j = -0.5; j <= 0.5; j += 1) {
					for(fixed k = -0.5; k <= 0.5; k += 1) {
						shadow += tex2D(_Shadow, i.shadow_uv + _Shadow_TexelSize.xy * float2(j, k)).r;
					}
				}
				shadow /= 4;

				fixed fade = tex2D(_ShadowFade, i.shadow_uv).r;
				shadow *= fade * _ShadowStrength;
				c.rgb = fixed3(0, 0, 0) * shadow + c.rgb * (1 - shadow);
#endif

#ifdef BRIGHTNESS_ON
				c.rgb = c.rgb * _Brightness * 2;
#endif

				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, c);
				return c;
			}
			ENDCG
		}
	}

	Fallback "YuLongZhi/ShadowTerrain"
}
