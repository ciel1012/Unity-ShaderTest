//*** 序列帧uv动画 ***
Shader "Ciel/TextureSheet/VF"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Row("row",Int) = 3
		_Col("col",Int) = 3
		_Speed("speed",Float) = 3.0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			int _Row;
			int _Col;
			float _Speed;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				//*** 开始计算 ***
				float2 totaltile = _Col*_Row;
				float coloffset = 1.0f/_Col;
				float rowoffset = 1.0f/_Row;
				float2 tiling = float2(coloffset,rowoffset);
				//计算行列数
				float currentindex = round(fmod(_Time.y*_Speed,totaltile));
				//计算列偏移
				float indextox = round(fmod(currentindex,_Col));
				float offsetx = indextox*coloffset;
				//计算行偏移
				float indextoy = round(fmod((currentindex - indextox)/_Col,_Row));
				indextoy = _Row - 1 - indextoy;			//将左下角开始变为左上角开始，偏移index从0开始
				float offsety = indextoy*rowoffset;
				//对uv进行偏移
				o.uv = o.uv*tiling+float2(offsetx,offsety);
				//*** 结束计算 ***
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
