Shader "Ciel/Ice/Common_VF1" {
	Properties{
			_Color("Main Color", Color) = (1,1,1,1)
			[HDR]_ReflectColor("Reflection Color", Color) = (1,1,1,0.5)
			_MainTex("Base (RGB) Emission Tex (A)", 2D) = "white" {}
			_Cube("Reflection Cubemap", Cube) = "" {}
			_BumpMap("Normalmap", 2D) = "bump" {}
			_Cutoff("Cutoff", Range(0, 1)) = 0.5
			_Alpha ("Alpha",range(0,1)) = 0
	}
 
	   SubShader{
				Pass{
				Tags{ "Queue" = "Transparent"  }
					Blend SrcAlpha OneMinusSrcAlpha
					Cull Back
					ZWrite Off
 
				CGPROGRAM
 
 
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"
				struct appdata_t {
				float4 vertex : POSITION;
				float2 texcoord: TEXCOORD0;
				half4 color : COLOR;
				float3 normal : NORMAL;
				
			};
 
			struct v2f {
				float4 vertex : SV_POSITION;
				float2 uv_Main : TEXCOORD0;
				float2 uv_Bump : TEXCOORD1;
				float3 refl : TEXCOORD3;
			};
 
				sampler2D _MainTex;
				sampler2D _BumpMap;
				float4 _MainTex_ST;
				float4 _BumpMap_ST;
				samplerCUBE _Cube;
				half4 _Color;
				half4 _ReflectColor;
				half _Cutoff;
				float _Alpha;
 
			v2f vert(appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv_Main = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv_Bump = TRANSFORM_TEX(v.texcoord, _BumpMap);
				float3 viewDir = mul(unity_ObjectToWorld, v.vertex).xyz - _WorldSpaceCameraPos;
				float3 normalDir = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
				o.refl = reflect(viewDir, normalDir);
				return o;
			}
 
			half4 frag(v2f i) : SV_Target
			{
				half3 bump = UnpackNormal(tex2D(_BumpMap, i.uv_Bump));
				half4 col = tex2D(_MainTex, i.uv_Main );
				half reflcol = dot(texCUBE(_Cube, i.refl*(bump*2-1)), 0.33);
				reflcol *= col.a;
				col.rgb = col.rgb * _Color + reflcol * _ReflectColor.rgb * col * 4;
				col.a = col.a * saturate(step(1 - col.a, _Cutoff))*_Alpha;
				return col;
			}
			ENDCG
			
		}
	}
 
}
