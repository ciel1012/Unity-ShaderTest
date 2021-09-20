Shader "Ciel/MirrorReflection/VF"
{
    Properties
    {
        _MainTex ("基础贴图", 2D) = "white" {}
        _Color ("偏色", Color) = (1,1,1,1)
        _Noise ("扰动纹理", 2D) = "white" {}
        _distortFactorTime("扰动速度",Range(0,5)) = 0.5
        _distortFactor("扰动大小",Range(0.04,1)) = 0
        _LerpTex ("插值贴图", 2D) = "Gray" {}
        [HideInInspector] _ReflectionTex ("", 2D) = "white" {}
    }
    SubShader
    {
        Tags  { "RenderType"="Opaque" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata_t
            {
                float2 uv : TEXCOORD0;
                float4 refl : TEXCOORD1;
                float4 pos : POSITION;
                float4 col: COLOR;
            };
            struct v2f
            {
                half2 uv : TEXCOORD0;
                float4 refl : TEXCOORD1;
                float4 pos : SV_POSITION;
            };
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            sampler2D _LerpTex;
            float4 _LerpTex_ST;
            sampler2D _ReflectionTex;
            sampler2D _Noise;
            fixed _distortFactorTime;
            fixed _distortFactor;

            v2f vert(appdata_t i)
            {
                v2f o;
                o.pos = UnityObjectToClipPos (i.pos);
                o.uv = TRANSFORM_TEX(i.uv, _MainTex);

                o.refl = ComputeScreenPos (o.pos);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 bias = tex2D(_Noise, i.uv+_Time.xy*_distortFactorTime);
                fixed4 tex = tex2D(_MainTex, i.uv+bias.xy*_distortFactor) * _Color;
                fixed4 refl = tex2Dproj(_ReflectionTex, UNITY_PROJ_COORD(i.refl+bias*_distortFactor));
                fixed4 lerpvalue = tex2D(_LerpTex,i.uv);
                fixed4 col = lerp(refl,tex,lerpvalue.r);
                return col;
            }
            ENDCG
        }
    }
}