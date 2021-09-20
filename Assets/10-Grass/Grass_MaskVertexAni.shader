Shader "Ciel/Grass/MaskVertexAni_VF"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Diffuse", 2D) = "white" {}
        _Mask ("Mask", 2D) = "white" {}
        _Noise("Noise", 2D) = "black" {}
        _WindControl("Wind(x:XSpeed y:YSpeed z:ZSpeed w:windMagnitude)",vector) = (1,0,1,0.5)
        //前面几个分量表示在各个轴向上自身摆动的速度, w表示摆动的强度
        _WaveControl("Wave(x:XSpeed y:YSpeed z:ZSpeed w:worldSize)",vector) = (1,0,1,1)
        //前面几个分量表示在各个轴向上风浪的速度, w用来模拟地图的大小,值越小草摆动的越凌乱，越大摆动的越整体
    }
    SubShader
    {
        Tags {  "Queue"="AlphaTest"
            "RenderType"="TransparentCutout" 
        }

        Pass
        {
            Tags {
                "LightMode"="ForwardBase"
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 normalDir : TEXCOORD1;
                UNITY_FOG_COORDS(2)
            };

            fixed4 _Color;
            fixed _Cutoff;
            sampler2D _MainTex;
            sampler2D  _Mask;
            sampler2D _Noise;
            half4 _WindControl;
            half4 _WaveControl;

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                float2 samplePos = worldPos.xz / _WaveControl.w;
                samplePos += _Time.x * -_WaveControl.xz;
                fixed waveSample = tex2Dlod(_Noise, float4(samplePos, 0, 0)).r;
                fixed mask = tex2Dlod(_Mask,float4(v.uv, 0, 0)).r;
                worldPos.x += sin(waveSample * _WindControl.x) * _WaveControl.x * _WindControl.w * mask;
                worldPos.z += sin(waveSample * _WindControl.z) * _WaveControl.z * _WindControl.w * mask;
                o.pos = mul(UNITY_MATRIX_VP, worldPos);
                o.uv = v.uv;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float NdotL = max(0.0,dot( normalize(i.normalDir), normalize(_WorldSpaceLightPos0.xyz)));
                fixed4 col = tex2D(_MainTex, i.uv) * _Color;
                col.rgb = col.rgb * max( 0.0, NdotL) *_LightColor0.xyz * 1.2;
                clip(col.a - 0.5);
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }

        Pass
        {
            Name "ShadowCaster"
            //绘制阴影都需要调用ShadowCaster
            Tags { "LightMode"="ShadowCaster" }
 
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
 
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            
            sampler2D _MainTex;
            sampler2D  _Mask;
            sampler2D _Noise;
            half4 _WindControl;
            half4 _WaveControl;
 
            struct a2v {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
 
            struct v2f {
                //定义阴影投射需要的变量
                float2 uv : TEXCOORD0;
                V2F_SHADOW_CASTER;
            };
 
            v2f vert(a2v v) {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                float2 samplePos = worldPos.xz / _WaveControl.w;
                samplePos += _Time.x * -_WaveControl.xz;
                fixed waveSample = tex2Dlod(_Noise, float4(samplePos, 0, 0)).r;
                fixed mask = tex2Dlod(_Mask,float4(v.uv, 0, 0)).r;
                v.vertex.x += sin(waveSample * _WindControl.x) * _WaveControl.x * _WindControl.w * mask;
                v.vertex.z += sin(waveSample * _WindControl.z) * _WaveControl.z * _WindControl.w * mask;
                o.uv = v.uv;
                //使用宏完成阴影偏移
                TRANSFER_SHADOW_CASTER(o)
                return o;
            }
 
            fixed4 frag(v2f i) : SV_Target{
                fixed4 col = tex2D(_MainTex, i.uv);
                clip(col.a - 0.5);
                //使用宏完成阴影投射
                SHADOW_CASTER_FRAGMENT(i);
            }
            ENDCG
        }

    }
}