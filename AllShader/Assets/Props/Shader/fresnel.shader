// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Shader created with Shader Forge Beta 0.35 
// Shader Forge (c) Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:0.35;sub:START;pass:START;ps:flbk:,lico:1,lgpr:1,nrmq:1,limd:1,uamb:True,mssp:True,lmpd:False,lprd:False,enco:False,frtr:True,vitr:True,dbil:False,rmgx:True,rpth:0,hqsc:True,hqlp:False,tesm:0,blpr:2,bsrc:0,bdst:0,culm:0,dpts:2,wrdp:True,ufog:True,aust:True,igpj:False,qofs:0,qpre:2,rntp:3,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,ofsf:0,ofsu:0,f2p0:False;n:type:ShaderForge.SFN_Final,id:1,x:32679,y:32706|emission-607-OUT,clip-476-OUT;n:type:ShaderForge.SFN_Fresnel,id:2,x:34217,y:32242;n:type:ShaderForge.SFN_Add,id:3,x:33986,y:32175|A-5-OUT,B-2-OUT;n:type:ShaderForge.SFN_Slider,id:5,x:34150,y:32150,ptlb:fresnel_1,ptin:_fresnel_1,min:0,cur:0.4686216,max:1;n:type:ShaderForge.SFN_Power,id:6,x:33807,y:32091|VAL-3-OUT,EXP-10-OUT;n:type:ShaderForge.SFN_ValueProperty,id:10,x:34153,y:32076,ptlb:fresnel,ptin:_fresnel,glob:False,v1:20;n:type:ShaderForge.SFN_Color,id:11,x:34077,y:32327,ptlb:node_11,ptin:_node_11,glob:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Multiply,id:12,x:33621,y:32375|A-6-OUT,B-11-RGB;n:type:ShaderForge.SFN_Tex2d,id:434,x:35028,y:33493,ptlb:mask,ptin:_mask,tex:c91c1dc92f455e34098d8941c0d3e09e,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Slider,id:436,x:34958,y:33920,ptlb:alpha,ptin:_alpha,min:0,cur:1.372233,max:8;n:type:ShaderForge.SFN_ComponentMask,id:470,x:34377,y:33827,cc1:0,cc2:-1,cc3:-1,cc4:-1|IN-826-OUT;n:type:ShaderForge.SFN_If,id:471,x:33973,y:33470|A-470-OUT,B-1565-OUT,GT-475-OUT,EQ-475-OUT,LT-472-OUT;n:type:ShaderForge.SFN_Vector1,id:472,x:34431,y:33713,v1:0;n:type:ShaderForge.SFN_Vector1,id:473,x:34527,y:33678,v1:0.3;n:type:ShaderForge.SFN_Vector1,id:475,x:34326,y:33639,v1:1;n:type:ShaderForge.SFN_If,id:476,x:33985,y:33795|A-470-OUT,B-473-OUT,GT-475-OUT,EQ-475-OUT,LT-472-OUT;n:type:ShaderForge.SFN_Subtract,id:491,x:33743,y:33309|A-476-OUT,B-471-OUT;n:type:ShaderForge.SFN_Multiply,id:492,x:33675,y:33066|A-783-OUT,B-491-OUT;n:type:ShaderForge.SFN_Multiply,id:494,x:33436,y:32861|A-1578-RGB,B-492-OUT;n:type:ShaderForge.SFN_Add,id:607,x:33110,y:32747|A-12-OUT,B-1605-OUT;n:type:ShaderForge.SFN_Vector1,id:783,x:34355,y:33279,v1:1;n:type:ShaderForge.SFN_Multiply,id:826,x:34827,y:33451|A-434-RGB,B-436-OUT;n:type:ShaderForge.SFN_ValueProperty,id:1565,x:34368,y:33461,ptlb:subtact,ptin:_subtact,glob:False,v1:0.35;n:type:ShaderForge.SFN_Color,id:1578,x:33609,y:32761,ptlb:node_1578,ptin:_node_1578,glob:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_Multiply,id:1605,x:33245,y:32925|A-494-OUT,B-1606-OUT;n:type:ShaderForge.SFN_ValueProperty,id:1606,x:33508,y:33020,ptlb:light,ptin:_light,glob:False,v1:5;proporder:5-10-11-434-436-1565-1578-1606;pass:END;sub:END;*/

Shader "Shader Forge/fresnel"
{
    Properties
	{
        _fresnel_1 ("fresnel_1", Range(0, 1)) = 0.4686216
        _fresnel ("fresnel", Float ) = 20
        _node_11 ("node_11", Color) = (0.5,0.5,0.5,1)
        _mask ("mask", 2D) = "white" {}
        _alpha ("alpha", Range(0, 8)) = 1.372233
        _subtact ("subtact", Float ) = 0.35
        _node_1578 ("node_1578", Color) = (1,1,1,1)
        _light ("light", Float ) = 5
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader
	{
        Tags
		{
            "Queue"="Transparent+200"
            "RenderType"="Transparent"
        }
        Pass
		{
            Name "ForwardBase"
            Tags
			{
                "LightMode"="ForwardBase"
            }
            Blend One One
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // #define UNITY_PASS_FORWARDBASE							// Our proj is force forward base.
            #include "UnityCG.cginc"
            // #pragma multi_compile_fwdbase_fullshadows				// Shadow is not allowed.
            // #pragma exclude_renderers xbox360 ps3 flash d3d11_9x 	// Should compile for all the platforms
            // #pragma target 3.0										// Target 3.0 is not fully supported by OpenGL ES 2.0
			
			uniform float4 _node_11;
			uniform float4 _mask_ST;
			uniform float4 _node_1578;
            uniform float _fresnel_1;
            uniform float _fresnel;
            uniform float _alpha;
            uniform float _subtact;
            uniform float _light;
			
			uniform sampler2D _mask;
			
            struct VertexInput
			{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
            };
			
            struct VertexOutput
			{
                float4 pos : SV_POSITION;
				float4 posWorld : TEXCOORD1;
				float3 normalDir : TEXCOORD2;
                float2 uv0 : TEXCOORD0;
            };
			
            VertexOutput vert (VertexInput v)
			{
                VertexOutput o;
                o.uv0 = v.texcoord0;
                o.normalDir = mul(float4(v.normal,0), unity_WorldToObject).xyz;
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }
			
            fixed4 frag(VertexOutput i) : COLOR
			{
                i.normalDir = normalize(i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
/////// Normals:
                float3 normalDirection =  i.normalDir;
                float2 node_1619 = i.uv0;
                float node_470 = (tex2D(_mask,TRANSFORM_TEX(node_1619.rg, _mask)).rgb*_alpha).r;
                float node_476_if_leA = step(node_470,0.3);
                float node_476_if_leB = step(0.3,node_470);
                float node_472 = 0.0;
                float node_475 = 1.0;
                float node_476 = lerp((node_476_if_leA*node_472)+(node_476_if_leB*node_475),node_475,node_476_if_leA*node_476_if_leB);
                clip(node_476 - 0.5);
////// Lighting:
////// Emissive:
                float node_471_if_leA = step(node_470,_subtact);
                float node_471_if_leB = step(_subtact,node_470);
                float3 emissive = ((pow((_fresnel_1+(1.0-max(0,dot(normalDirection, viewDirection)))),_fresnel)*_node_11.rgb)+((_node_1578.rgb*(1.0*(node_476-lerp((node_471_if_leA*node_472)+(node_471_if_leB*node_475),node_475,node_471_if_leA*node_471_if_leB))))*_light));
                float3 finalColor = emissive;
/// Final Color:
                return fixed4(finalColor,1);
            }
			
            ENDCG
        }
		
		
        /* Shadow is not needed.
		Pass {
            Name "ShadowCollector"
            Tags {
                "LightMode"="ShadowCollector"
            }
            
            Fog {Mode Off}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_SHADOWCOLLECTOR
            #define SHADOW_COLLECTOR_PASS
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcollector
            #pragma exclude_renderers xbox360 ps3 flash d3d11_9x 
            #pragma target 3.0
            uniform sampler2D _mask; uniform float4 _mask_ST;
            uniform float _alpha;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                V2F_SHADOW_COLLECTOR;
                float2 uv0 : TEXCOORD5;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o;
                o.uv0 = v.texcoord0;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                TRANSFER_SHADOW_COLLECTOR(o)
                return o;
            }
            fixed4 frag(VertexOutput i) : COLOR {
                float2 node_1620 = i.uv0;
                float node_470 = (tex2D(_mask,TRANSFORM_TEX(node_1620.rg, _mask)).rgb*_alpha).r;
                float node_476_if_leA = step(node_470,0.3);
                float node_476_if_leB = step(0.3,node_470);
                float node_472 = 0.0;
                float node_475 = 1.0;
                float node_476 = lerp((node_476_if_leA*node_472)+(node_476_if_leB*node_475),node_475,node_476_if_leA*node_476_if_leB);
                clip(node_476 - 0.5);
                SHADOW_COLLECTOR_FRAGMENT(i)
            }
            ENDCG
        }
        Pass {
            Name "ShadowCaster"
            Tags {
                "LightMode"="ShadowCaster"
            }
            Cull Off
            Offset 1, 1
            
            Fog {Mode Off}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_SHADOWCASTER
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma exclude_renderers xbox360 ps3 flash d3d11_9x 
            #pragma target 3.0
            uniform sampler2D _mask; uniform float4 _mask_ST;
            uniform float _alpha;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                V2F_SHADOW_CASTER;
                float2 uv0 : TEXCOORD1;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o;
                o.uv0 = v.texcoord0;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                TRANSFER_SHADOW_CASTER(o)
                return o;
            }
            fixed4 frag(VertexOutput i) : COLOR {
                float2 node_1621 = i.uv0;
                float node_470 = (tex2D(_mask,TRANSFORM_TEX(node_1621.rg, _mask)).rgb*_alpha).r;
                float node_476_if_leA = step(node_470,0.3);
                float node_476_if_leB = step(0.3,node_470);
                float node_472 = 0.0;
                float node_475 = 1.0;
                float node_476 = lerp((node_476_if_leA*node_472)+(node_476_if_leB*node_475),node_475,node_476_if_leA*node_476_if_leB);
                clip(node_476 - 0.5);
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
		*/
    }
    FallBack "Diffuse"
    // CustomEditor "ShaderForgeMaterialInspector" // Can not be opened by this editor.
}
