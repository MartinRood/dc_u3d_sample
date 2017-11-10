Shader "YuLongZhi/UIParticlesAdditive" {
Properties {
	_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
	_MainTex ("Particle Texture", 2D) = "white" {}
	_Mask ("Mask", Vector) = (-1, -1, 1, 1)
}

Category {
	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
	Blend SrcAlpha One
	ColorMask RGB
	Cull Off Lighting Off ZWrite Off
	
	SubShader {
		Pass {
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			#pragma multi_compile_particles
			#pragma multi_compile_fog

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _TintColor;
			float4 _Mask;

			struct appdata_t {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 pos : TEXCOORD2;
			};

			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
				o.pos = o.vertex / o.vertex.w;
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = 2.0f * i.color * _TintColor * tex2D(_MainTex, i.texcoord);

				col.a *= (i.pos.x >= _Mask.x);
				col.a *= (i.pos.y >= _Mask.y);
				col.a *= (i.pos.x <= _Mask.z);
				col.a *= (i.pos.y <= _Mask.w);

				UNITY_APPLY_FOG_COLOR(i.fogCoord, col, fixed4(0,0,0,0)); // fog towards black due to our blend mode
				return col;
			}
			ENDCG 
		}
	}	
}
}
