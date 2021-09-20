// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Ciel/Snow/Common_ASE"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,0)
		_MainTex("MainTex", 2D) = "white" {}
		_Metallic("Metallic", Range( 0 , 1)) = 0.13
		_BumpMap("BumpMap", 2D) = "bump" {}
		_SpecGlossMap("SpecGlossMap", 2D) = "white" {}
		_SnowColor("Snow Color", Color) = (0.7647059,0.7647059,0.7647059,0)
		_SnowAlbedo("Snow Albedo", 2D) = "white" {}
		_SnowNormal("Snow Normal", 2D) = "bump" {}
		_SnowDirection("Snow Direction", Vector) = (0,1,0,0)
		_SnowAttenuation("Snow Attenuation", Range( 0 , 5)) = 0.2
		_SnowAmount("SnowAmount", Range( 0 , 5)) = 2
		_SnowSmoothness("Snow Smoothness", Range( 0 , 1)) = 0
		_BumpMaoScale("BumpMaoScale", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform float _BumpMaoScale;
		uniform sampler2D _BumpMap;
		uniform float4 _BumpMap_ST;
		uniform sampler2D _SnowNormal;
		uniform float4 _SnowNormal_ST;
		uniform float3 _SnowDirection;
		uniform float _SnowAttenuation;
		uniform float _SnowAmount;
		uniform float4 _Color;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform sampler2D _SnowAlbedo;
		uniform float4 _SnowAlbedo_ST;
		uniform float4 _SnowColor;
		uniform float _Metallic;
		uniform sampler2D _SpecGlossMap;
		uniform float4 _SpecGlossMap_ST;
		uniform float _SnowSmoothness;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_BumpMap = i.uv_texcoord * _BumpMap_ST.xy + _BumpMap_ST.zw;
			float3 tex2DNode5 = UnpackScaleNormal( tex2D( _BumpMap, uv_BumpMap ), _BumpMaoScale );
			float2 uv_SnowNormal = i.uv_texcoord * _SnowNormal_ST.xy + _SnowNormal_ST.zw;
			float dotResult17 = dot( _SnowDirection , (WorldNormalVector( i , tex2DNode5 )) );
			float temp_output_6_0 = saturate( ( ( dotResult17 - _SnowAttenuation ) * _SnowAmount ) );
			float3 lerpResult7 = lerp( tex2DNode5 , UnpackNormal( tex2D( _SnowNormal, uv_SnowNormal ) ) , temp_output_6_0);
			o.Normal = lerpResult7;
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float2 uv_SnowAlbedo = i.uv_texcoord * _SnowAlbedo_ST.xy + _SnowAlbedo_ST.zw;
			float4 lerpResult27 = lerp( ( _Color * tex2D( _MainTex, uv_MainTex ) ) , ( tex2D( _SnowAlbedo, uv_SnowAlbedo ) * _SnowColor ) , temp_output_6_0);
			o.Albedo = lerpResult27.rgb;
			float lerpResult31 = lerp( _Metallic , 0.0 , temp_output_6_0);
			o.Metallic = lerpResult31;
			float2 uv_SpecGlossMap = i.uv_texcoord * _SpecGlossMap_ST.xy + _SpecGlossMap_ST.zw;
			float lerpResult43 = lerp( ( 1.0 - tex2D( _SpecGlossMap, uv_SpecGlossMap ).r ) , _SnowSmoothness , temp_output_6_0);
			o.Smoothness = lerpResult43;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16200
2057;-6;1906;1124;3675.62;1744.768;2.590456;True;True
Node;AmplifyShaderEditor.RangedFloatNode;48;-2706.094,-169.1473;Float;False;Property;_BumpMaoScale;BumpMaoScale;12;0;Create;True;0;0;False;0;1;0.194;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;-2369.845,-216.0841;Float;True;Property;_BumpMap;BumpMap;3;0;Create;True;0;0;False;0;None;62ef3e806d485564a8e4276b04a98397;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;2;-2019.616,-575.8794;Float;True;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;18;-1989.359,-734.5054;Float;False;Property;_SnowDirection;Snow Direction;8;0;Create;True;0;0;False;0;0,1,0;4.94,1.61,1.21;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;40;-1703.165,-450.597;Float;False;Property;_SnowAttenuation;Snow Attenuation;9;0;Create;True;0;0;False;0;0.2;0.18;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;17;-1551.377,-584.2099;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1;-1704.674,-281.4226;Float;False;Property;_SnowAmount;SnowAmount;10;0;Create;True;0;0;False;0;2;1.72;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;39;-1335.984,-501.7063;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;21;-988.689,-1165.408;Float;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;False;0;None;d7a06e3e3df8f6f4aa76f2341f944ac3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;24;-913.6063,-1390.484;Float;False;Property;_Color;Color;0;0;Create;True;0;0;False;0;1,1,1,0;0.8823529,0.8823529,0.8823529,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;-1052.852,-406.3575;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;30;-700.2428,176.5342;Float;True;Property;_SpecGlossMap;SpecGlossMap;4;0;Create;True;0;0;False;0;None;ffe25d29093806f42a09e15488cdca65;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;22;-922.2872,-688.0103;Float;False;Property;_SnowColor;Snow Color;5;0;Create;True;0;0;False;0;0.7647059,0.7647059,0.7647059,0;0.764151,0.764151,0.764151,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;23;-970.287,-880.0103;Float;True;Property;_SnowAlbedo;Snow Albedo;6;0;Create;True;0;0;False;0;7d897d65b2e34784d9ab31e4444405eb;4112a019314dad94f9ffc2f8481f31bc;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;32;-394.8768,191.37;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-460.2114,-313.6306;Float;False;Constant;_Float0;Float 0;8;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-548.3871,-387.9538;Float;False;Property;_Metallic;Metallic;2;0;Create;True;0;0;False;0;0.13;0.43;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-677.6084,441.6665;Float;False;Property;_SnowSmoothness;Snow Smoothness;11;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-554.2864,-688.0103;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-580.9996,-1241.518;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;6;-881.5991,-405.7725;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;4;-1384.76,104.9892;Float;True;Property;_SnowNormal;Snow Normal;7;0;Create;True;0;0;False;0;16d3ea22d601f7146bedf37fd1e1793b;16d3ea22d601f7146bedf37fd1e1793b;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;31;-244.041,-287.5381;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;46;-1475.359,-886.1558;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;7;-970.8569,47.86283;Float;True;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;43;-100.7139,185.3415;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;27;-175.8514,-573.6964;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;223.679,-207.6605;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Test/snow_ase;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;5;5;48;0
WireConnection;2;0;5;0
WireConnection;17;0;18;0
WireConnection;17;1;2;0
WireConnection;39;0;17;0
WireConnection;39;1;40;0
WireConnection;42;0;39;0
WireConnection;42;1;1;0
WireConnection;32;0;30;1
WireConnection;25;0;23;0
WireConnection;25;1;22;0
WireConnection;26;0;24;0
WireConnection;26;1;21;0
WireConnection;6;0;42;0
WireConnection;31;0;28;0
WireConnection;31;1;29;0
WireConnection;31;2;6;0
WireConnection;46;0;17;0
WireConnection;7;0;5;0
WireConnection;7;1;4;0
WireConnection;7;2;6;0
WireConnection;43;0;32;0
WireConnection;43;1;44;0
WireConnection;43;2;6;0
WireConnection;27;0;26;0
WireConnection;27;1;25;0
WireConnection;27;2;6;0
WireConnection;0;0;27;0
WireConnection;0;1;7;0
WireConnection;0;3;31;0
WireConnection;0;4;43;0
ASEEND*/
//CHKSM=2B879D763A1019C4469E8A1F589DDF439210B66C