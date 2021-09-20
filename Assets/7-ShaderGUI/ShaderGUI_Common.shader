Shader "Ciel/ShaderGUI/Common" {
    Properties {
        _MainTex ("Base (RGB)", 2D) = "white" {}

        [NoKeywordToggle] _Normal ("Normal",Float) = 0
        [Foldout] _NormalLayerShown ("",Float) = 1
        [NoScaleOffset] _BumpMap ("Normal Map", 2D) = "bump" {}

        [NoKeywordToggle] _Emission("Emission",Float) = 0
        [Foldout] _EmissionLayerShown ("", Float) = 1
        [NoScaleOffset] _MaskTex ("Mask (RGB)",2D) = "White" {}
        _EmissionColor ("Emission Color",Color) = (1,1,1,1)
        _Strength ("Emission Strength",Range(0,3)) = 1
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 150

        CGPROGRAM
        #pragma surface surf Lambert noforwardadd
        #pragma shader_feature _NORMAL_ON
        #pragma shader_feature _EMISSION_ON

        sampler2D _MainTex;

        #if _NORMAL_ON
        sampler2D _BumpMap;
        #endif

        #if _EMISSION_ON
        uniform sampler2D _MaskTex;
        uniform float4 _EmissionColor;
        uniform float _Strength;
        #endif

        uniform float _LightIntensity;
        struct Input {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutput o) {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            #if _NORMAL_ON
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
            #endif
            #if _EMISSION_ON
            fixed4 m = tex2D(_MaskTex, IN.uv_MainTex);
            o.Emission = m.r*_EmissionColor.rgb*_Strength;
            #endif
            o.Alpha = c.a;
        }
        ENDCG
    }
    Fallback "Mobile/VertexLit"
    CustomEditor "CommonGUI"
}
