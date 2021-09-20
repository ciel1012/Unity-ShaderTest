Shader "Ciel/RimLight/Surface" {
	Properties {
		_RimColor ("RimColor", Color) = (1,1,1,1)
		_RimPower ("RimPower",Range(0,10)) = 0
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Normal ("Normal",2D) = "bump" {}
		
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		Cull Back 

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _Normal;
		float4 _Normal_ST;
		half4 _RimColor;
		half _RimPower;

		struct Input {
			float2 uv_MainTex;
			float3 viewDir;			
		};

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb;
			o.Normal = UnpackNormal(tex2D(_Normal,IN.uv_MainTex));
			half rim = 1.0 - saturate(dot(normalize(IN.viewDir),o.Normal));
			o.Emission = pow(rim,_RimPower)*_RimColor.rgb;

		}
		ENDCG
	}
	FallBack "Diffuse"
}
