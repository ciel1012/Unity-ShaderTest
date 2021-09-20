// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Ciel/OutLine/VF"
{
	Properties
	{
		_Width("Width",Float) = 0.1
		_Color("Color",Color) = (0,1,1,1)
		_MainTex ("Main Texture", 2D) = "white" {}
	}
	SubShader
	{
		//描边渲染pass
		Pass
		{
			Cull Front 
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			half _Width;
			half4 _Color;

			struct v2f
			{
				float4 vertex : SV_POSITION;
			};
			
			v2f vert (appdata_full v)
			{
				v2f o;

				float3 view_vertex = UnityObjectToViewPos(v.vertex);//顶点转到视图空间
                float3 view_normal = mul(UNITY_MATRIX_IT_MV,v.normal);//法向量转到视图空间
                view_vertex += normalize(view_normal) * _Width;
                o.vertex = mul(UNITY_MATRIX_P,float4(view_vertex,1.0));
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return _Color;
			}
			ENDCG
		}
		//主纹理渲染pass
		Pass { 
			Tags { "LightMode"="ForwardBase" "RenderType"="Opaque"}
		
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv:TEXCOORD0;
				float3 worldNormal : TEXCOORD1;

			};
			
			v2f vert(a2v v) {
				v2f o;
				// Transform the vertex from object space to projection space
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				// Transform the normal from object space to world space
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {
				// Get ambient term
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				// Get the normal in world space
				fixed3 worldNormal = normalize(i.worldNormal);
				// Get the light direction in world space
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.pos));
			
				float3 diffuse =  _LightColor0.rgb * tex2D(_MainTex,i.uv).rgb * max(0,dot(worldNormal,worldLightDir));
				
				fixed3 color = ambient + diffuse;
				
				return fixed4(color, 1.0);
			}
			
			ENDCG
		}
	}
	Fallback "Diffuse"
}
