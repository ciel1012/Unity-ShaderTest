Shader "Ciel/MotionBlur/VF"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Direction("Direction",vector) = (0,0,0,1)
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
                float4 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Direction;

            v2f vert (appdata v)
            {
                v2f o;
                float4 wPos = mul(unity_ObjectToWorld,v.vertex);
                half3 wNormal = UnityObjectToWorldNormal(v.normal);
                fixed NdotD = max(0,dot(wNormal,_Direction));
                float noise = frac(sin(dot(v.uv.xy, float2(12.9898, 78.233))) * 43758.5453);
                wPos.xyz += _Direction.xyz * _Direction.w * noise * NdotD;
                o.vertex=mul(UNITY_MATRIX_VP,wPos);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
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
