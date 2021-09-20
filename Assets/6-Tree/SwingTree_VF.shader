Shader "Ciel/Tree/VertexAnimation_VF"
{
    Properties {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _BumpScale ("Bump Scale", Float) = 1.0
        _Cutoff("Cut Off",range(0,1)) = 0.5
        _WindDir ("Wind Direction", Vector) = (0.1,0.05,0.05,0)
        _SwayOffset("Sway Offset", range(0,1)) = 0.2
        _SwayDisp ("Sway Displacement", range(0,1)) = 0.3
        _SwaySpeed ("Sway Speed", range(0,10)) = 1
    }
    SubShader {
        Pass { 
            Tags {"RenderType"="TransparentCutout"}

            Cull off
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Lighting.cginc"
            
            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float _BumpScale;
            float _Cutoff;

            float4 _WindDir;;
            float _SwaySpeed;
            float _SwayOffset;
            float _SwayDisp;
            
            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
                float4 color : COLOR;
            };
            
            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 TtoW0 : TEXCOORD1;  
                float4 TtoW1 : TEXCOORD2;  
                float4 TtoW2 : TEXCOORD3; 
            };
            
            v2f vert(a2v v) {
                v2f o;

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;  
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);  
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);  
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w; 
                
                o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

                v.vertex.x += cos(_SwaySpeed*_Time.y+worldPos.x+_SwayOffset)*_SwayDisp*_WindDir.x*v.vertex.x*v.color.a;
                v.vertex.y += cos(_SwaySpeed*_Time.y+worldPos.y+_SwayOffset)*_SwayDisp*_WindDir.y*v.vertex.y*v.color.a;
                v.vertex.z += cos(_SwaySpeed*_Time.y+worldPos.z+_SwayOffset)*_SwayDisp*_WindDir.z*v.vertex.z*v.color.a;

                o.pos = UnityObjectToClipPos(v.vertex);               
                o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                 
                return o;
            }
            
            fixed4 frag(v2f i) : SV_Target {
      
                float3 worldPos = mul (unity_ObjectToWorld, i.pos).xyz;
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));                
                fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv));
                bump.xy *= _BumpScale;
                bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));
                bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
                
                fixed4 albedo = tex2D(_MainTex, i.uv) * _Color;
                clip (albedo.a - _Cutoff);
                
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo * 2;               
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(bump, lightDir));
                
                return fixed4(ambient+diffuse, 1);
            }
            
            ENDCG
        }
    } 
    Fallback "Legacy Shaders/Transparent/Cutout/VertexLit"
}
