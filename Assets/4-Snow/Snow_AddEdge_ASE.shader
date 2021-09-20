// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Ciel/Snow/AddEdge_ASE"
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
		_SnowSmoothness("Snow Smoothness", Range( 0 , 1)) = 0
		_BumpMapScale("BumpMapScale", Range( 0 , 1)) = 1
		_NoiseTex("NoiseTex", 2D) = "white" {}
		_EdgeColor("Edge Color", Color) = (0.3962264,0.3962264,0.3962264,0)
		_EdgeAttenuation("Edge Attenuation", Range( 0 , 1)) = 0.58
		_EdgePow("EdgePow", Range( 1 , 5)) = 0.88
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

		uniform float _BumpMapScale;
		uniform sampler2D _BumpMap;
		uniform float4 _BumpMap_ST;
		uniform sampler2D _SnowNormal;
		uniform float4 _SnowNormal_ST;
		uniform float3 _SnowDirection;
		uniform float _SnowAttenuation;
		uniform sampler2D _NoiseTex;
		uniform float4 _NoiseTex_ST;
		uniform float4 _Color;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform sampler2D _SnowAlbedo;
		uniform float4 _SnowAlbedo_ST;
		uniform float4 _SnowColor;
		uniform float4 _EdgeColor;
		uniform float _EdgeAttenuation;
		uniform float _EdgePow;
		uniform float _Metallic;
		uniform sampler2D _SpecGlossMap;
		uniform float4 _SpecGlossMap_ST;
		uniform float _SnowSmoothness;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_BumpMap = i.uv_texcoord * _BumpMap_ST.xy + _BumpMap_ST.zw;
			float3 tex2DNode5 = UnpackScaleNormal( tex2D( _BumpMap, uv_BumpMap ), _BumpMapScale );
			float2 uv_SnowNormal = i.uv_texcoord * _SnowNormal_ST.xy + _SnowNormal_ST.zw;
			float dotResult17 = dot( _SnowDirection , (WorldNormalVector( i , tex2DNode5 )) );
			float2 uv_NoiseTex = i.uv_texcoord * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
			float temp_output_55_0 = ( ( dotResult17 - _SnowAttenuation ) + tex2D( _NoiseTex, uv_NoiseTex ).r );
			float temp_output_56_0 = step( 0.05 , temp_output_55_0 );
			float3 lerpResult7 = lerp( tex2DNode5 , UnpackNormal( tex2D( _SnowNormal, uv_SnowNormal ) ) , temp_output_56_0);
			o.Normal = lerpResult7;
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float2 uv_SnowAlbedo = i.uv_texcoord * _SnowAlbedo_ST.xy + _SnowAlbedo_ST.zw;
			float4 lerpResult27 = lerp( ( _Color * tex2D( _MainTex, uv_MainTex ) ) , ( tex2D( _SnowAlbedo, uv_SnowAlbedo ) * _SnowColor ) , temp_output_56_0);
			float4 lerpResult58 = lerp( lerpResult27 , _EdgeColor , pow( saturate( ( temp_output_56_0 - ( _EdgeAttenuation + saturate( temp_output_55_0 ) ) ) ) , _EdgePow ));
			o.Albedo = lerpResult58.rgb;
			float lerpResult31 = lerp( _Metallic , 0.0 , temp_output_56_0);
			o.Metallic = lerpResult31;
			float2 uv_SpecGlossMap = i.uv_texcoord * _SpecGlossMap_ST.xy + _SpecGlossMap_ST.zw;
			float lerpResult43 = lerp( ( 1.0 - tex2D( _SpecGlossMap, uv_SpecGlossMap ).r ) , _SnowSmoothness , temp_output_56_0);
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
2106;20;1830;1116;3264.991;2101.347;2.609127;True;True
Node;AmplifyShaderEditor.RangedFloatNode;48;-2874.385,-232.4104;Float;False;Property;_BumpMapScale;BumpMapScale;11;0;Create;True;0;0;False;0;1;0.239;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;-2484.654,-279.3472;Float;True;Property;_BumpMap;BumpMap;3;0;Create;True;0;0;False;0;None;62ef3e806d485564a8e4276b04a98397;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;18;-2139.87,-971.249;Float;False;Property;_SnowDirection;Snow Direction;8;0;Create;True;0;0;False;0;0,1,0;3.52,2.4,3.01;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;2;-2126.461,-769.2642;Float;True;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;17;-1753.691,-864.9258;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-1906.425,-648.1196;Float;False;Property;_SnowAttenuation;Snow Attenuation;9;0;Create;True;0;0;False;0;0.2;1.21;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;54;-1803.209,-427.3875;Float;True;Property;_NoiseTex;NoiseTex;12;0;Create;True;0;0;False;0;None;16d574e53541bba44a84052fa38778df;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;39;-1589.391,-813.3553;Float;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;55;-1451.082,-491.4087;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;86;-1381.297,-985.5078;Float;False;Property;_EdgeAttenuation;Edge Attenuation;14;0;Create;True;0;0;False;0;0.58;0.538;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;83;-1290.536,-771.9053;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;56;-1160.196,-514.9827;Float;True;2;0;FLOAT;0.05;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;85;-1083.696,-932.4081;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;24;-1646.043,-1899.85;Float;False;Property;_Color;Color;0;0;Create;True;0;0;False;0;1,1,1,0;0.8823529,0.8823529,0.8823529,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;23;-1704.206,-1499.303;Float;True;Property;_SnowAlbedo;Snow Albedo;6;0;Create;True;0;0;False;0;7d897d65b2e34784d9ab31e4444405eb;4112a019314dad94f9ffc2f8481f31bc;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;82;-850.136,-784.2053;Float;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;21;-1658.652,-1714.185;Float;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;False;0;None;d7a06e3e3df8f6f4aa76f2341f944ac3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;22;-1677.003,-1315.66;Float;False;Property;_SnowColor;Snow Color;5;0;Create;True;0;0;False;0;0.7647059,0.7647059,0.7647059,0;0.745283,0.745283,0.745283,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-1291.959,-1629.584;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;87;-613.496,-789.0078;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;89;-690.1921,-553.6436;Float;False;Property;_EdgePow;EdgePow;15;0;Create;True;0;0;False;0;0.88;1;1;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;30;-700.2428,314.8226;Float;True;Property;_SpecGlossMap;SpecGlossMap;4;0;Create;True;0;0;False;0;None;ffe25d29093806f42a09e15488cdca65;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-1229.168,-1271.225;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;32;-394.8768,329.6584;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-677.6084,579.9548;Float;False;Property;_SnowSmoothness;Snow Smoothness;10;0;Create;True;0;0;False;0;0;0.375;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;4;-1185.76,103.3027;Float;True;Property;_SnowNormal;Snow Normal;7;0;Create;True;0;0;False;0;16d3ea22d601f7146bedf37fd1e1793b;16d3ea22d601f7146bedf37fd1e1793b;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;57;-692.3548,-1303.774;Float;False;Property;_EdgeColor;Edge Color;13;0;Create;True;0;0;False;0;0.3962264,0.3962264,0.3962264,0;0.4339621,0.4339621,0.4339621,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;28;-548.3871,-387.9538;Float;False;Property;_Metallic;Metallic;2;0;Create;True;0;0;False;0;0.13;0.43;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;88;-393.1921,-786.6436;Float;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;27;-927.757,-1571.168;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-460.2114,-313.6306;Float;False;Constant;_Float0;Float 0;8;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;43;-100.7139,323.6299;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;58;-291.1712,-1326.4;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;31;-234.8374,-270.5066;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;7;-711.1442,68.1002;Float;True;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;221.9115,-207.6605;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Test/snow_ase;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;5;5;48;0
WireConnection;2;0;5;0
WireConnection;17;0;18;0
WireConnection;17;1;2;0
WireConnection;39;0;17;0
WireConnection;39;1;40;0
WireConnection;55;0;39;0
WireConnection;55;1;54;1
WireConnection;83;0;55;0
WireConnection;56;1;55;0
WireConnection;85;0;86;0
WireConnection;85;1;83;0
WireConnection;82;0;56;0
WireConnection;82;1;85;0
WireConnection;26;0;24;0
WireConnection;26;1;21;0
WireConnection;87;0;82;0
WireConnection;25;0;23;0
WireConnection;25;1;22;0
WireConnection;32;0;30;1
WireConnection;88;0;87;0
WireConnection;88;1;89;0
WireConnection;27;0;26;0
WireConnection;27;1;25;0
WireConnection;27;2;56;0
WireConnection;43;0;32;0
WireConnection;43;1;44;0
WireConnection;43;2;56;0
WireConnection;58;0;27;0
WireConnection;58;1;57;0
WireConnection;58;2;88;0
WireConnection;31;0;28;0
WireConnection;31;1;29;0
WireConnection;31;2;56;0
WireConnection;7;0;5;0
WireConnection;7;1;4;0
WireConnection;7;2;56;0
WireConnection;0;0;58;0
WireConnection;0;1;7;0
WireConnection;0;3;31;0
WireConnection;0;4;43;0
ASEEND*/
//CHKSM=9E48C7C9AA55624144EE0BE1A7DC589512D9F0D5