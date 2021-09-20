Shader "Ciel/Snow/Common_Surf" {  
    Properties {  
        _MainTex ("Base (RGB)", 2D) = "white" {}  
        _Bump ("Bump", 2D) = "bump" {}  
        _Snow ("Snow Level", Range(0,1) ) = 0  
        _SnowColor ("Snow Color", Color) = (1.0,1.0,1.0,1.0)  
        _SnowDirection ("Snow Direction", Vector) = (0,1,0)  
        _SnowDepth ("Snow Depth", Range(0,0.2)) = 0.1  
        _Wetness ("Wetness", Range(0, 0.5)) = 0.3  
    }  
    SubShader {  
        Tags { "RenderType"="Opaque" }  
        LOD 200  
   
        CGPROGRAM  
        #pragma surface surf Lambert vertex:vert  
   
        sampler2D _MainTex;  
        sampler2D _Bump;  
        float _Snow;  
        float4 _SnowColor;  
        float4 _SnowDirection;  
        float _SnowDepth;  
        float _Wetness;  
   
        struct Input {  
            float2 uv_MainTex;  
            float2 uv_Bump;  
            float3 worldNormal;  
            INTERNAL_DATA  
        };  
   
         void vert (inout appdata_full v) {  
            // 通过【模型到视角的逆转置矩阵】将【积雪方向】转换到【模型坐标系】中  
            float4 sn = mul(UNITY_MATRIX_IT_MV, _SnowDirection);  
            // 计算当前【点的法线方向】和【下雪反方向】的点乘[-1,1]  
            // 如果顶点点乘大于设置的_Snow值，那么该点就往【点的法线方向】和【下雪反方向】之和的方向挤出  
            // 如果雪量_Snow为0.5，那么模型法线为up的点挤出最多  
            if(dot(v.normal, sn.xyz) >= lerp(1,-1, _Snow))  
            {  
                v.vertex.xyz += (sn.xyz + v.normal) * _SnowDepth * _Snow;  
            }  
        }  
   
        void surf (Input IN, inout SurfaceOutput o) {  
            half4 c = tex2D (_MainTex, IN.uv_MainTex);  
            o.Normal = UnpackNormal (tex2D (_Bump, IN.uv_Bump));  
            // _Snow为0.5时，diff值域【-1,1】  
            half difference = dot(WorldNormalVector(IN, o.Normal), _SnowDirection.xyz) - lerp(1,-1,_Snow);  
            // 当_Wetness为0.3时，要控制diff的最终值域为【0,1】，那么就有 0 < diff < 0.3。  
            // 可以得出【法线方向】和【积雪方向】夹角为73-90度之间时，就会有【雪】与【地面】材质叠加的效果  
            // 而小于73度的，都是积雪；大于90度的没有积雪  
            difference = saturate(difference / _Wetness);  
            o.Albedo = difference*_SnowColor.rgb + (1-difference) *c;  
            o.Alpha = c.a;  
        }  
        ENDCG  
    }  
    FallBack "Diffuse"  
}  