Shader "Ciel/OutLine/Surface" {
	Properties {
		_Width("Width",Float) = 0.1
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		
	}
	SubShader {
		//绘制外描边
		Tags{}
		Cull Front
		CGPROGRAM
		#pragma target 3.0
		#pragma surface outlineSurf Outline vertex:outlineVertexDataFunc

		struct Input{
			half filler;
		};

		half4 _Color;
		half _Width;
		//自定义顶点函数
		void outlineVertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			v.vertex.xyz += ( v.normal * _Width );
		}
		//自定义光照模型
		inline half4 LightingOutline( SurfaceOutput s, half3 lightDir, half atten ) 
		{
			return half4 ( 0,0,0, s.Alpha);
		}
		//表面着色器
		void outlineSurf( Input i, inout SurfaceOutput o )
		{
			o.Emission = _Color.rgb;
			o.Alpha = 1;
		}
		ENDCG 

		//绘制主纹理
		Tags { "RenderType"="Opaque" }
		Cull Back 
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
