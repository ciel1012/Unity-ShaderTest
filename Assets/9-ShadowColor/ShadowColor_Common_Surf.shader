Shader "Ciel/ShadowColor/Common_Surf"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _ShadowColor("ShadowColor",color) = (1,1,0,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard vertex:myvert finalcolor:mycolor noforwardadd
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0
        #pragma multi_compile_fwdbase
        #include "UnityCG.cginc"
        #include "Lighting.cginc"
        #include "AutoLight.cginc"

        struct Input
        {
            float4 pos : SV_POSITION;
            float2 uv_MainTex : TEXCOORD0;
            SHADOW_COORDS(1)
        };

        sampler2D _MainTex;
        //float4 _MainTex_ST;

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        fixed4 _ShadowColor;

        void myvert(inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            TRANSFER_SHADOW(o)
        }

        void mycolor(Input IN,SurfaceOutputStandard o,inout fixed4 color)
        {
            float attenuation = SHADOW_ATTENUATION(IN);
            color = lerp(color*_ShadowColor,color,attenuation);
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
