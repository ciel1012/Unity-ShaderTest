Shader "Ciel/Water/Common_VF"
{
    Properties
    {
        _Foam("效果贴图:R深浅(黑浅白深)，G边缘泡沫，B细节扰动", 2D) = "white" {}
        _DeepColor("深水区颜色", Color) = (0,0,0,0)
        _ShalowColor("浅水区颜色", Color) = (1,1,1,0)

        [Space(20)]
        _WaterNormal("波纹法线贴图", 2D) = "bump" {}
        _NormalScale("法线强度", Range(0,1)) = 0.3
        _WaveParams ("水浪偏移速度：xy速度1，zw速度2", vector) = (-0.04,-0.02,-0.02,-0.04)

        [Space(20)]
        _WaterSpecular("高光强度", Range(0,1)) = 0.8
        _WaterSmoothness("高光衰减", Range(0,10)) = 8
        _LightColor ("高光颜色", color) = (1,1,1,1)
        _LightDir("光照方向", vector) = (0, 0, 0, 0)
        _RimPower ("菲涅尔强度", Range(0,20)) = 8

        [Space(20)]
        _FoamColor("泡沫颜色", Color) = (1,1,1,1)
        _FoamDepth("泡沫范围", Range(-2,10)) = 0.5
        _FoamFactor("泡沫衰减",Range(0,10)) = 0.2
        _FoamOffset("XY:泡沫速度,Z:泡沫强度,W:泡沫扰动", vector) = (-0.01,0.01, 2, 0.01)

        [Space(20)]
        _DetailColor("细节颜色", Color) = (1,1,1,1)
        _WaterWave("细节扰动强度",Range(0,0.1)) = 0.02

        [Space(20)]
        _Frequency("波动频率", Range(0,100)) = 10
        _Amplitude("波动幅度", Range(0,1)) = 0.1
        _Speed("波动速度", Range(0,10)) = 1

        [Space(40)]
        _AlphaWidth("边缘透明宽度",Range(-1,1)) = 0
    }

    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" "IgnoreProjector" = "true"}
        LOD 500
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 uv_Tex : TEXCOORD0;
                float4 worldPos : TEXCOORD1;
                float4 TW0:TEXCOORD2;
                float4 TW1:TEXCOORD3;
                float4 TW2:TEXCOORD4;
                float4 screenPos : TEXCOORD5;
                UNITY_FOG_COORDS(6)
            };

            uniform sampler2D _Foam;
            uniform float4 _Foam_ST;
            uniform half4 _DeepColor;
            uniform half4 _ShalowColor;

            uniform sampler2D _WaterNormal;
            uniform float4 _WaterNormal_ST;
            uniform half _NormalScale;
            uniform half4 _WaveParams;

            uniform half _WaterSpecular;
            uniform half _WaterSmoothness;
            uniform half4 _LightDir;
            uniform half4 _LightColor;

            uniform half _RimPower;

            uniform half4 _FoamColor;
            uniform half _FoamDepth;
            uniform half _FoamFactor;
            uniform half4 _FoamOffset;
            uniform sampler2D _CameraDepthTexture;

            uniform half _WaterWave;
            uniform half4 _DetailColor;

            uniform half _Frequency;
            uniform half _Amplitude;
            uniform half _Speed;

            uniform half _AlphaWidth;

            v2f vert (appdata_full v)
            {
                v2f o;
                float time = _Time.y * _Speed;
                float waveValueA = sin(time + v.vertex.x *_Frequency)* _Amplitude;
                v.vertex.xyz = float3(v.vertex.x, v.vertex.y + waveValueA, v.vertex.z);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv_Tex.xy= TRANSFORM_TEX(v.texcoord,_Foam);
                o.uv_Tex.zw = TRANSFORM_TEX(v.texcoord, _WaterNormal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;

                o.TW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, o.worldPos.x);
                o.TW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, o.worldPos.y);
                o.TW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, o.worldPos.z);

                o.screenPos = ComputeScreenPos(o.vertex);

                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half2 panner1 = ( _Time.y * _WaveParams.xy + i.uv_Tex.zw);
                half2 panner2 = ( _Time.y * _WaveParams.zw + i.uv_Tex.zw);
                half3 worldNormal = BlendNormals(UnpackNormal(tex2D( _WaterNormal, panner1)) , UnpackNormal(tex2D(_WaterNormal, panner2)));

                half3 water = tex2D(_Foam,i.uv_Tex.xy/_Foam_ST.xy);
                half3 foam1 = tex2D(_Foam,i.uv_Tex.xy + worldNormal.xy*_FoamOffset.w);
                half3 foam2 = tex2D(_Foam, _Time.y * _FoamOffset.xy + i.uv_Tex.xy + worldNormal.xy*_FoamOffset.w);
                half2 detailpanner = (i.uv_Tex.xy/_Foam_ST.xy + worldNormal.xy*_WaterWave);

                worldNormal = lerp(half3(0, 0, 1), worldNormal, _NormalScale);
                worldNormal = normalize(fixed3(dot(i.TW0.xyz, worldNormal), dot(i.TW1.xyz, worldNormal), dot(i.TW2.xyz, worldNormal)));

                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float NdotV = saturate(dot(worldNormal,viewDir));
                fixed3 worldLightDir = _LightDir.xyz;
                fixed3 halfDir = normalize(worldLightDir + viewDir);
                     
                half4 diffuse = lerp(_ShalowColor, _DeepColor, water.r);
                fixed3 specular = _LightColor.rgb * _WaterSpecular * pow(max(0, dot(worldNormal, halfDir)), _WaterSmoothness*256.0);
                fixed3 rim = pow(1-saturate(NdotV),_RimPower)*_LightColor;
                half4 detail = tex2D(_Foam,detailpanner).b * _DetailColor;
                
                half4 screenPos = float4( i.screenPos.xyz , i.screenPos.w);
                half eyeDepth = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD( screenPos ))));
                half eyeDepthSubScreenPos = abs( eyeDepth - screenPos.w );
                half depthMask = 1-eyeDepthSubScreenPos + _FoamDepth;

                float temp_output = ( saturate( (foam1.g + foam2.g ) * depthMask * water.g  -_FoamFactor));
                diffuse = lerp( diffuse , _FoamColor * _FoamOffset.z , temp_output);

                half alpha = saturate(eyeDepthSubScreenPos-_AlphaWidth);

                fixed4 col = fixed4( diffuse * NdotV * 0.5 +specular + rim*0.2 + diffuse.rgb * detail.rgb * 0.5 ,alpha);
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }

    SubShader
    {
        Tags { "RenderType"="Opaque"}
        LOD 400
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 uv_Tex : TEXCOORD0;
                float4 worldPos : TEXCOORD1;
                float4 TW0:TEXCOORD2;
                float4 TW1:TEXCOORD3;
                float4 TW2:TEXCOORD4;
                float4 screenPos : TEXCOORD5;
                UNITY_FOG_COORDS(6)
            };

            uniform sampler2D _Foam;
            uniform float4 _Foam_ST;
            uniform half4 _DeepColor;
            uniform half4 _ShalowColor;

            uniform sampler2D _WaterNormal;
            uniform float4 _WaterNormal_ST;
            uniform half _NormalScale;
            uniform half4 _WaveParams;

            uniform half _WaterSpecular;
            uniform half _WaterSmoothness;
            uniform half4 _LightDir;
            uniform half4 _LightColor;

            uniform half _RimPower;

            uniform half4 _FoamColor;
            uniform half _FoamDepth;
            uniform half _FoamFactor;
            uniform half4 _FoamOffset;
            uniform sampler2D _CameraDepthTexture;

            uniform half _WaterWave;
            uniform half4 _DetailColor;

            v2f vert (appdata_full v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv_Tex.xy= TRANSFORM_TEX(v.texcoord,_Foam);
                o.uv_Tex.zw = TRANSFORM_TEX(v.texcoord, _WaterNormal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;

                o.TW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, o.worldPos.x);
                o.TW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, o.worldPos.y);
                o.TW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, o.worldPos.z);

                o.screenPos = ComputeScreenPos(o.vertex);

                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half2 panner1 = ( _Time.y * _WaveParams.xy + i.uv_Tex.zw);
                half2 panner2 = ( _Time.y * _WaveParams.zw + i.uv_Tex.zw);
                half3 worldNormal = BlendNormals(UnpackNormal(tex2D( _WaterNormal, panner1)) , UnpackNormal(tex2D(_WaterNormal, panner2)));

                half3 water = tex2D(_Foam,i.uv_Tex.xy/_Foam_ST.xy);
                half3 foam1 = tex2D(_Foam,i.uv_Tex.xy + worldNormal.xy*_FoamOffset.w);
                half3 foam2 = tex2D(_Foam, _Time.y * _FoamOffset.xy + i.uv_Tex.xy + worldNormal.xy*_FoamOffset.w);
                half2 detailpanner = (i.uv_Tex.xy/_Foam_ST.xy + worldNormal.xy*_WaterWave);

                worldNormal = lerp(half3(0, 0, 1), worldNormal, _NormalScale);
                worldNormal = normalize(fixed3(dot(i.TW0.xyz, worldNormal), dot(i.TW1.xyz, worldNormal), dot(i.TW2.xyz, worldNormal)));

                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float NdotV = saturate(dot(worldNormal,viewDir));
                fixed3 worldLightDir = _LightDir.xyz;
                fixed3 halfDir = normalize(worldLightDir + viewDir);
                     
                half4 diffuse = lerp(_ShalowColor, _DeepColor, water.r);
                fixed3 specular = _LightColor.rgb * _WaterSpecular * pow(max(0, dot(worldNormal, halfDir)), _WaterSmoothness*256.0);
                fixed3 rim = pow(1-saturate(NdotV),_RimPower)*_LightColor;
                half4 detail = tex2D(_Foam,detailpanner).b * _DetailColor;
                
                half4 screenPos = float4( i.screenPos.xyz , i.screenPos.w);
                half eyeDepth = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD( screenPos ))));
                half eyeDepthSubScreenPos = abs( eyeDepth - screenPos.w );
                half depthMask = 1-eyeDepthSubScreenPos + _FoamDepth;
                
                float temp_output = ( saturate( (foam1.g + foam2.g ) * depthMask * water.g  -_FoamFactor));
                diffuse = lerp( diffuse , _FoamColor * _FoamOffset.z , temp_output);

                fixed4 col = fixed4( diffuse * NdotV * 0.5 +specular + rim*0.2 + diffuse.rgb * detail.rgb * 0.5 ,1);
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }

    SubShader
    {
        Tags { "RenderType"="Opaque"}
        LOD 300
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 uv_Tex : TEXCOORD0;
                float4 worldPos : TEXCOORD1;
                float4 TW0:TEXCOORD2;
                float4 TW1:TEXCOORD3;
                float4 TW2:TEXCOORD4;
                float4 screenPos : TEXCOORD5;
                UNITY_FOG_COORDS(6)
            };

            uniform sampler2D _Foam;
            uniform float4 _Foam_ST;
            uniform half4 _DeepColor;
            uniform half4 _ShalowColor;

            uniform sampler2D _WaterNormal;
            uniform float4 _WaterNormal_ST;
            uniform half _NormalScale;
            uniform half4 _WaveParams;

            uniform half _WaterSpecular;
            uniform half _WaterSmoothness;
            uniform half4 _LightDir;
            uniform half4 _LightColor;
            uniform half _RimPower;

            uniform half4 _FoamColor;
            uniform half _FoamDepth;
            uniform half _FoamFactor;
            uniform half4 _FoamOffset;
            uniform sampler2D _CameraDepthTexture;

            v2f vert (appdata_full v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv_Tex.xy= TRANSFORM_TEX(v.texcoord,_Foam);
                o.uv_Tex.zw = TRANSFORM_TEX(v.texcoord, _WaterNormal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;

                o.TW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, o.worldPos.x);
                o.TW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, o.worldPos.y);
                o.TW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, o.worldPos.z);

                o.screenPos = ComputeScreenPos(o.vertex);

                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half2 panner1 = ( _Time.y * _WaveParams.xy + i.uv_Tex.zw);
                half2 panner2 = ( _Time.y * _WaveParams.zw + i.uv_Tex.zw);

                half3 worldNormal = BlendNormals(UnpackNormal(tex2D( _WaterNormal, panner1)) , UnpackNormal(tex2D(_WaterNormal, panner2)));

                half3 water = tex2D(_Foam,i.uv_Tex.xy/_Foam_ST.xy);
                half3 foam1 = tex2D(_Foam,i.uv_Tex.xy + worldNormal.xy*_FoamOffset.w);
                half3 foam2 = tex2D(_Foam, _Time.y * _FoamOffset.xy + i.uv_Tex.xy + worldNormal.xy*_FoamOffset.w);

                worldNormal = lerp(half3(0, 0, 1), worldNormal, _NormalScale);
                worldNormal = normalize(fixed3(dot(i.TW0.xyz, worldNormal), dot(i.TW1.xyz, worldNormal), dot(i.TW2.xyz, worldNormal)));

                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float NdotV = saturate(dot(worldNormal,viewDir));
                fixed3 worldLightDir = _LightDir.xyz;
                fixed3 halfDir = normalize(worldLightDir + viewDir);
                     
                half4 diffuse = lerp(_ShalowColor, _DeepColor, water.r);
                fixed3 specular = _LightColor.rgb * _WaterSpecular * pow(max(0, dot(worldNormal, halfDir)), _WaterSmoothness*256.0);
                fixed3 rim = pow(1-saturate(NdotV),_RimPower)*_LightColor;

                half4 screenPos = float4( i.screenPos.xyz , i.screenPos.w);
                half eyeDepth = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD( screenPos ))));
                half eyeDepthSubScreenPos = abs( eyeDepth - screenPos.w );
                half depthMask = 1-eyeDepthSubScreenPos + _FoamDepth;
                
                float temp_output = ( saturate( (foam1.g + foam2.g ) * depthMask * water.g  -_FoamFactor));
                diffuse = lerp( diffuse , _FoamColor * _FoamOffset.z , temp_output);

                fixed4 col = fixed4(diffuse.rgb*NdotV+specular+rim*0.2,1);
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }

    SubShader
    {
        Tags { "RenderType"="Opaque"}
        LOD 200
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 uv_Tex : TEXCOORD0;
                float4 worldPos : TEXCOORD1;
                float4 TW0:TEXCOORD2;
                float4 TW1:TEXCOORD3;
                float4 TW2:TEXCOORD4;
                UNITY_FOG_COORDS(5)
            };

            uniform sampler2D _Foam;
            uniform float4 _Foam_ST;
            uniform half4 _DeepColor;
            uniform half4 _ShalowColor;

            uniform sampler2D _WaterNormal;
            uniform float4 _WaterNormal_ST;
            uniform half _NormalScale;
            uniform half4 _WaveParams;

            uniform half _WaterSpecular;
            uniform half _WaterSmoothness;
            uniform half4 _LightDir;
            uniform half4 _LightColor;
            uniform half _RimPower;

            v2f vert (appdata_full v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv_Tex.xy= TRANSFORM_TEX(v.texcoord,_Foam);
                o.uv_Tex.zw = TRANSFORM_TEX(v.texcoord, _WaterNormal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;

                o.TW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, o.worldPos.x);
                o.TW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, o.worldPos.y);
                o.TW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, o.worldPos.z);

                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half2 panner1 = ( _Time.y * _WaveParams.xy + i.uv_Tex.zw);
                half2 panner2 = ( _Time.y * _WaveParams.zw + i.uv_Tex.zw);

                half3 worldNormal = BlendNormals(UnpackNormal(tex2D( _WaterNormal, panner1)) , UnpackNormal(tex2D(_WaterNormal, panner2)));
                worldNormal = lerp(half3(0, 0, 1), worldNormal, _NormalScale);
                worldNormal = normalize(fixed3(dot(i.TW0.xyz, worldNormal), dot(i.TW1.xyz, worldNormal), dot(i.TW2.xyz, worldNormal)));

                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float NdotV = saturate(dot(worldNormal,viewDir));
                fixed3 worldLightDir = _LightDir.xyz;
                fixed3 halfDir = normalize(worldLightDir + viewDir);
                half degree = tex2D(_Foam,i.uv_Tex.xy/_Foam_ST.xy).r;
                half4 diffuse = lerp(_ShalowColor, _DeepColor, degree);
                diffuse *= NdotV;
                fixed3 specular = _LightColor.rgb * _WaterSpecular * pow(max(0, dot(worldNormal, halfDir)), _WaterSmoothness*256.0);
                fixed3 rim = pow(1-saturate(NdotV),_RimPower)*_LightColor;

                fixed4 col = fixed4(diffuse.rgb+specular+rim*0.2,1);
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }

    SubShader
    {
        Tags { "RenderType"="Opaque"}
        LOD 100
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv_Tex : TEXCOORD0;
                UNITY_FOG_COORDS(1)
            };

            uniform sampler2D _Foam;
            uniform float4 _Foam_ST;
            uniform half4 _DeepColor;
            uniform half4 _ShalowColor;
            uniform half _RimPower;

            v2f vert (appdata_full v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv_Tex = TRANSFORM_TEX(v.texcoord,_Foam);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                half degree = tex2D(_Foam,i.uv_Tex/_Foam_ST.xy).r;
                half4 diffuse = lerp(_ShalowColor, _DeepColor, degree);
                fixed4 col = fixed4(diffuse.rgb,1);
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
