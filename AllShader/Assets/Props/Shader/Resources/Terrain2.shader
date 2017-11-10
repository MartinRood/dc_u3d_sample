Shader "YuLongZhi/Terrain2" {
	Properties {
		_Splat0 ("Layer 1", 2D) = "white" {}
		_Splat1 ("Layer 2", 2D) = "white" {}
		_Control ("Control (RGBA)", 2D) = "white" {}
	}

	SubShader {
		Tags {
		   "RenderType" = "Opaque"
		}

		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			#pragma multi_compile __ BRIGHTNESS_ON

			#include "UnityCG.cginc"

			struct v2f {
				float4 pos : SV_POSITION;
				float4 pack0 : TEXCOORD0; // _Control _Splat0
				float4 pack1 : TEXCOORD1; // _Splat1 lm
				UNITY_FOG_COORDS(2)
			};

			sampler2D _Control;
			sampler2D _Splat0, _Splat1;
			float4 _Control_ST;
			float4 _Splat0_ST;
			float4 _Splat1_ST;

#ifdef BRIGHTNESS_ON
			fixed3 _Brightness;
#endif

			v2f vert(appdata_full v) {
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f, o);
				o.pos = UnityObjectToClipPos(v.vertex);
				o.pack0.xy = TRANSFORM_TEX(v.texcoord, _Control);
				o.pack0.zw = TRANSFORM_TEX(v.texcoord, _Splat0);
				o.pack1.xy = TRANSFORM_TEX(v.texcoord, _Splat1);
				o.pack1.zw = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				
				UNITY_TRANSFER_FOG(o,o.pos);
				return o;
			}

			fixed4 frag (v2f IN) : SV_Target {
				float2 uv_Control = IN.pack0.xy;
				float2 uv_Splat0 = IN.pack0.zw;
				float2 uv_Splat1 = IN.pack1.xy;

				fixed4 c = 0;
				fixed4 splat_control = tex2D(_Control, uv_Control);
				
				fixed3 lay1 = tex2D(_Splat0, uv_Splat0);
				fixed3 lay2 = tex2D(_Splat1, uv_Splat1);
				c.a = 1.0;
				c.rgb = (lay1 * splat_control.r + lay2 * splat_control.g + lay1 * splat_control.b + lay1 * splat_control.a);

				float2 uv_Lightmap = IN.pack1.zw;
				fixed3 lm = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, uv_Lightmap));
				c.rgb *= lm;

#ifdef BRIGHTNESS_ON
				c.rgb = c.rgb * _Brightness * 2;
#endif

				// apply fog
				UNITY_APPLY_FOG(IN.fogCoord, c);
				return c;
			}

			ENDCG 
		}
	}
}
