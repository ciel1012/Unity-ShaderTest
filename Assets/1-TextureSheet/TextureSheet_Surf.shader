Shader "Ciel/TextureSheet/Surface" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Row("row",Int) = 3
		_Col("col",Int) = 3
		_Speed("Speed",Float) = 1.0 
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		fixed4 _Color;
		int _Col;
		int _Row;
		float _Speed;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf (Input IN, inout SurfaceOutputStandard o) {

		int totaltile = _Col * _Row;
		float colsoffset = 1.0f/_Col;
		float rowsoffset = 1.0f/_Row;
		float speed = _Time.y*_Speed;
		float2 tiling = float2(colsoffset,rowsoffset);

		float currenttileindex = round(fmod(speed,totaltile));
		//currenttileindex += (currenttileindex < 0) ? currenttileindex : 0;

		float indextox = round(fmod(currenttileindex,_Col));
		float offsetx = indextox*colsoffset;

		float indextoy = round(fmod((currenttileindex - indextox)/_Col,_Row));
		indextoy = _Row - 1 - indextoy;
		float offsety = indextoy*rowsoffset;

		float2 offset = float2(offsetx,offsety);
		float2 uv = IN.uv_MainTex *  tiling + offset;

		// Albedo comes from a texture tinted by color
		fixed4 c = tex2D (_MainTex, uv) * _Color;
		o.Albedo = c.rgb;
		o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
