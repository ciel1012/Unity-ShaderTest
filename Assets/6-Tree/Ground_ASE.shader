// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Ciel/Ground"
{
	Properties
	{
		_GroundTiling("Ground Tiling", Float) = 4
		[NoScaleOffset]_Albedo("Albedo", 2D) = "white" {}
		[NoScaleOffset]_Normal("Normal", 2D) = "bump" {}
		[NoScaleOffset]_Metallic("Metallic", 2D) = "black" {}
		[NoScaleOffset]_Roughness("Roughness", 2D) = "white" {}
		[NoScaleOffset]_AO("AO", 2D) = "white" {}
		_AO_Strength("AO_Strength", Range( 0 , 1)) = 0.5
		_RippleAreaTiling("Ripple Area Tiling", Float) = 0
		_RippleTiling("Ripple Tiling", Float) = 0
		_RippleBumpiness("Ripple Bumpiness", Float) = 0
		_Area("Area", Range( 0.001 , 1)) = 0.001
		_RippleSpeed("Ripple Speed", Float) = 0
		_RippleNormal("Ripple Normal", 2D) = "bump" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 4.6
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _RippleNormal;
		uniform float _RippleAreaTiling;
		uniform float _RippleBumpiness;
		uniform float _Area;
		uniform sampler2D _Roughness;
		uniform float _GroundTiling;
		uniform float _RippleTiling;
		uniform float _RippleSpeed;
		uniform sampler2D _Normal;
		uniform sampler2D _Albedo;
		uniform sampler2D _Metallic;
		uniform sampler2D _AO;
		uniform half _AO_Strength;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 temp_cast_0 = (_RippleAreaTiling).xx;
			float2 uv_TexCoord39 = i.uv_texcoord * temp_cast_0;
			float2 panner41 = ( 1.0 * _Time.y * float2( 0,0 ) + uv_TexCoord39);
			float simplePerlin2D44 = snoise( panner41 );
			float2 temp_cast_1 = (_RippleAreaTiling).xx;
			float2 uv_TexCoord40 = i.uv_texcoord * temp_cast_1 + float2( 1,1 );
			float2 panner42 = ( 1.0 * _Time.y * float2( 0,0 ) + uv_TexCoord40);
			float simplePerlin2D45 = snoise( panner42 );
			float2 temp_cast_2 = (_GroundTiling).xx;
			float2 uv_TexCoord26 = i.uv_texcoord * temp_cast_2;
			float2 GroundTiling27 = uv_TexCoord26;
			float Smoothness50 = ( 1.0 - tex2D( _Roughness, GroundTiling27 ).r );
			float temp_output_3_0_g1 = ( _Area - Smoothness50 );
			float WaterArea56 = saturate( ( temp_output_3_0_g1 / (fwidth( temp_output_3_0_g1 )+ 0.001) ));
			float RippleArea59 = ( saturate( pow( ( simplePerlin2D44 + simplePerlin2D45 ) , 1.0 ) ) * _RippleBumpiness * ( 1.0 - WaterArea56 ) );
			float RippleTiling63 = _RippleTiling;
			float2 temp_cast_3 = (( RippleTiling63 / 0.2 )).xx;
			float2 uv_TexCoord79 = i.uv_texcoord * temp_cast_3;
			float temp_output_4_0_g6 = 2.0;
			float temp_output_5_0_g6 = 1.0;
			float2 appendResult7_g6 = (float2(temp_output_4_0_g6 , temp_output_5_0_g6));
			float totalFrames39_g6 = ( temp_output_4_0_g6 * temp_output_5_0_g6 );
			float2 appendResult8_g6 = (float2(totalFrames39_g6 , temp_output_5_0_g6));
			float mulTime70 = _Time.y * _RippleSpeed;
			float clampResult42_g6 = clamp( 1.0 , 0.0001 , ( totalFrames39_g6 - 1.0 ) );
			float temp_output_35_0_g6 = frac( ( ( mulTime70 + clampResult42_g6 ) / totalFrames39_g6 ) );
			float2 appendResult29_g6 = (float2(temp_output_35_0_g6 , ( 1.0 - temp_output_35_0_g6 )));
			float2 temp_output_15_0_g6 = ( ( frac( uv_TexCoord79 ) / appendResult7_g6 ) + ( floor( ( appendResult8_g6 * appendResult29_g6 ) ) / appendResult7_g6 ) );
			float2 temp_cast_4 = (( RippleTiling63 / 0.4 )).xx;
			float2 uv_TexCoord66 = i.uv_texcoord * temp_cast_4;
			float temp_output_4_0_g5 = 4.0;
			float temp_output_5_0_g5 = 2.0;
			float2 appendResult7_g5 = (float2(temp_output_4_0_g5 , temp_output_5_0_g5));
			float totalFrames39_g5 = ( temp_output_4_0_g5 * temp_output_5_0_g5 );
			float2 appendResult8_g5 = (float2(totalFrames39_g5 , temp_output_5_0_g5));
			float clampResult42_g5 = clamp( 2.0 , 0.0001 , ( totalFrames39_g5 - 1.0 ) );
			float temp_output_35_0_g5 = frac( ( ( mulTime70 + clampResult42_g5 ) / totalFrames39_g5 ) );
			float2 appendResult29_g5 = (float2(temp_output_35_0_g5 , ( 1.0 - temp_output_35_0_g5 )));
			float2 temp_output_15_0_g5 = ( ( frac( uv_TexCoord66 ) / appendResult7_g5 ) + ( floor( ( appendResult8_g5 * appendResult29_g5 ) ) / appendResult7_g5 ) );
			float2 temp_cast_5 = (( RippleTiling63 / 0.6 )).xx;
			float2 uv_TexCoord81 = i.uv_texcoord * temp_cast_5;
			float temp_output_4_0_g7 = 6.0;
			float temp_output_5_0_g7 = 3.0;
			float2 appendResult7_g7 = (float2(temp_output_4_0_g7 , temp_output_5_0_g7));
			float totalFrames39_g7 = ( temp_output_4_0_g7 * temp_output_5_0_g7 );
			float2 appendResult8_g7 = (float2(totalFrames39_g7 , temp_output_5_0_g7));
			float clampResult42_g7 = clamp( 3.0 , 0.0001 , ( totalFrames39_g7 - 1.0 ) );
			float temp_output_35_0_g7 = frac( ( ( mulTime70 + clampResult42_g7 ) / totalFrames39_g7 ) );
			float2 appendResult29_g7 = (float2(temp_output_35_0_g7 , ( 1.0 - temp_output_35_0_g7 )));
			float2 temp_output_15_0_g7 = ( ( frac( uv_TexCoord81 ) / appendResult7_g7 ) + ( floor( ( appendResult8_g7 * appendResult29_g7 ) ) / appendResult7_g7 ) );
			float3 RippleNormal92 = BlendNormals( BlendNormals( UnpackScaleNormal( tex2D( _RippleNormal, temp_output_15_0_g6 ), RippleArea59 ) , UnpackScaleNormal( tex2D( _RippleNormal, temp_output_15_0_g5 ), RippleArea59 ) ) , UnpackScaleNormal( tex2D( _RippleNormal, temp_output_15_0_g7 ), RippleArea59 ) );
			o.Normal = BlendNormals( RippleNormal92 , UnpackNormal( tex2D( _Normal, GroundTiling27 ) ) );
			o.Albedo = tex2D( _Albedo, GroundTiling27 ).rgb;
			o.Metallic = tex2D( _Metallic, GroundTiling27 ).r;
			o.Smoothness = Smoothness50;
			o.Occlusion = ( ( tex2D( _AO, GroundTiling27 ).r * _AO_Strength ) + ( 1.0 - _AO_Strength ) );
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16200
7;7;1906;1124;4327.29;2136.234;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;36;-3956.335,-2480.718;Float;False;889.9094;210.0688;UV;3;25;26;27;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-3906.335,-2408.253;Float;False;Property;_GroundTiling;Ground Tiling;0;0;Create;True;0;0;False;0;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;26;-3588.049,-2426.649;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;52;-3950.049,-2127.411;Float;False;1196.609;330.8066;Smoothness;4;32;11;12;50;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;27;-3309.426,-2430.717;Float;False;GroundTiling;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;32;-3900.049,-2053.913;Float;False;27;GroundTiling;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;61;-3984.342,-1012.942;Float;False;2174.271;702.448;RippleArea;14;45;41;37;46;42;47;48;58;49;39;59;95;57;40;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;11;-3575.791,-2077.411;Float;True;Property;_Roughness;Roughness;4;1;[NoScaleOffset];Create;True;0;0;False;0;None;14d03511afaadab4f9b0a8b4b28c677e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;12;-3189.688,-2049.604;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-3918.906,-784.9238;Float;False;Property;_RippleAreaTiling;Ripple Area Tiling;7;0;Create;True;0;0;False;0;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;60;-3940.811,-1707.695;Float;False;845.0354;385.8215;WaterArea;4;56;54;53;55;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;40;-3618.649,-573.3992;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;1,1;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;39;-3629.976,-926.1299;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;50;-2996.44,-2052.974;Float;False;Smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-3898.81,-1597.916;Float;False;Property;_Area;Area;10;0;Create;True;0;0;False;0;0.001;0.9;0.001;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;53;-3812,-1507.295;Float;True;50;Smoothness;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;42;-3316.371,-568.5351;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;64;-2662.166,-2461.679;Float;False;477.8296;166.35;Ripple Tiling;2;62;63;;1,1,1,1;0;0
Node;AmplifyShaderEditor.PannerNode;41;-3330.313,-928.3184;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;55;-3561.113,-1574.874;Float;True;Step Antialiasing;-1;;1;2a825e80dfb3290468194f83380797bd;0;2;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-2612.166,-2410.328;Float;False;Property;_RippleTiling;Ripple Tiling;8;0;Create;True;0;0;False;0;0;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;45;-3057.745,-568.4949;Float;True;Simplex2D;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;44;-3071.743,-932.8409;Float;True;Simplex2D;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;93;-3968.399,-155.0862;Float;False;2985.208;1451.213;RippleNormal;27;70;85;79;77;67;83;68;91;89;81;82;65;86;84;66;74;69;76;75;72;90;80;73;87;92;96;88;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;56;-3338.775,-1580.816;Float;False;WaterArea;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;63;-2427.336,-2411.678;Float;False;RippleTiling;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;46;-2824.529,-784.6851;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;80;-3918.398,309.2127;Float;False;63;RippleTiling;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;47;-2630.084,-785.6202;Float;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;65;-3899.268,568.8735;Float;False;63;RippleTiling;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;57;-2719.614,-510.8029;Float;False;56;WaterArea;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;48;-2473.584,-784.4856;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;95;-2468.833,-522.7509;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;83;-3675.91,312.9597;Float;False;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;96;-3652.919,577.1581;Float;False;2;0;FLOAT;0;False;1;FLOAT;0.4;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-2563.688,-630.4624;Float;False;Property;_RippleBumpiness;Ripple Bumpiness;9;0;Create;True;0;0;False;0;0;0.12;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;82;-3886.641,1086.535;Float;False;63;RippleTiling;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;88;-3628.826,1089.865;Float;False;2;0;FLOAT;0;False;1;FLOAT;0.6;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;66;-3515.891,565.4838;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;79;-3511.659,289.3714;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;69;-3668.013,816.3916;Float;False;Property;_RippleSpeed;Ripple Speed;11;0;Create;True;0;0;False;0;0;12;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-2270.302,-673.5007;Float;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;67;-3225.806,564.3925;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FractNode;84;-3175.903,293.0451;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;59;-2053.074,-675.5685;Float;False;RippleArea;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;70;-3457.201,823.1731;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;81;-3434.85,1071.693;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;72;-2884.526,-70.54903;Float;True;Property;_RippleNormal;Ripple Normal;12;0;Create;True;0;0;False;0;None;b52ab7450ea1ef943b2bc8f832e01bb7;True;bump;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.FunctionNode;76;-2934.69,600.5392;Float;False;Flipbook;-1;;5;53c2488c220f6564ca6c90721ee16673;2,71,0,68,0;8;51;SAMPLER2D;0.0;False;13;FLOAT2;0,0;False;4;FLOAT;4;False;5;FLOAT;2;False;24;FLOAT;2;False;2;FLOAT;0;False;55;FLOAT;0;False;70;FLOAT;0;False;5;COLOR;53;FLOAT2;0;FLOAT;47;FLOAT;48;FLOAT;62
Node;AmplifyShaderEditor.GetLocalVarNode;86;-2367.892,553.309;Float;False;59;RippleArea;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;91;-3174.959,1074.591;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;85;-2376.013,243.5959;Float;False;59;RippleArea;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;68;-2923.925,225.4294;Float;False;Flipbook;-1;;6;53c2488c220f6564ca6c90721ee16673;2,71,0,68,0;8;51;SAMPLER2D;0.0;False;13;FLOAT2;0,0;False;4;FLOAT;2;False;5;FLOAT;1;False;24;FLOAT;1;False;2;FLOAT;0;False;55;FLOAT;0;False;70;FLOAT;0;False;5;COLOR;53;FLOAT2;0;FLOAT;47;FLOAT;48;FLOAT;62
Node;AmplifyShaderEditor.FunctionNode;77;-2921.312,896.6995;Float;False;Flipbook;-1;;7;53c2488c220f6564ca6c90721ee16673;2,71,0,68,0;8;51;SAMPLER2D;0.0;False;13;FLOAT2;0,0;False;4;FLOAT;6;False;5;FLOAT;3;False;24;FLOAT;3;False;2;FLOAT;0;False;55;FLOAT;0;False;70;FLOAT;0;False;5;COLOR;53;FLOAT2;0;FLOAT;47;FLOAT;48;FLOAT;62
Node;AmplifyShaderEditor.SamplerNode;74;-2128.563,360.383;Float;True;Property;_TextureSample1;Texture Sample 1;14;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;87;-2363.075,1045.53;Float;False;59;RippleArea;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;73;-2168.757,69.4126;Float;True;Property;_TextureSample0;Texture Sample 0;13;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendNormalsNode;89;-1757.115,246.7056;Float;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;75;-2127.528,822.8921;Float;True;Property;_TextureSample2;Texture Sample 2;14;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;35;-894.1097,127.1128;Float;False;1542.084;588.8456;AO;6;33;2;3;6;9;1;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;33;-844.1107,197.7694;Float;False;27;GroundTiling;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BlendNormalsNode;90;-1467.532,462.9514;Float;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;92;-1226.188,461.2151;Float;False;RippleNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;2;-496.0036,177.1127;Float;True;Property;_AO;AO;5;1;[NoScaleOffset];Create;True;0;0;False;0;None;2d79f0f4144b3a545b1af7c419ad4bdb;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;1;-574.6794,461.6458;Half;True;Property;_AO_Strength;AO_Strength;6;0;Create;True;0;0;False;0;0.5;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;30;-670.4651,-532.6216;Float;False;27;GroundTiling;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;8;-319.9238,-557.6595;Float;True;Property;_Normal;Normal;2;1;[NoScaleOffset];Create;True;0;0;False;0;None;8936a062e8e0d0d4188209288e034650;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;3;-52.88258,489.2685;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-5.598549,245.7062;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;31;-505.0507,-265.7064;Float;False;27;GroundTiling;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;29;-367.294,-1133.044;Float;False;27;GroundTiling;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;94;-354.183,-802.4135;Float;False;92;RippleNormal;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;4;-128.5188,-290.3878;Float;True;Property;_Metallic;Metallic;3;1;[NoScaleOffset];Create;True;0;0;False;0;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;9;229.1668,288.1472;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;51;-46.10801,-19.72439;Float;False;50;Smoothness;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;78;37.34431,-666.3092;Float;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;28;-1.280947,-1158.614;Float;True;Property;_Albedo;Albedo;1;1;[NoScaleOffset];Create;True;0;0;False;0;None;3be3b5b97c212404cadef1f59eb2f6d9;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;649.9179,-427.9916;Float;False;True;6;Float;ASEMaterialInspector;0;0;Standard;Test/Ground;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;26;0;25;0
WireConnection;27;0;26;0
WireConnection;11;1;32;0
WireConnection;12;0;11;1
WireConnection;40;0;37;0
WireConnection;39;0;37;0
WireConnection;50;0;12;0
WireConnection;42;0;40;0
WireConnection;41;0;39;0
WireConnection;55;1;53;0
WireConnection;55;2;54;0
WireConnection;45;0;42;0
WireConnection;44;0;41;0
WireConnection;56;0;55;0
WireConnection;63;0;62;0
WireConnection;46;0;44;0
WireConnection;46;1;45;0
WireConnection;47;0;46;0
WireConnection;48;0;47;0
WireConnection;95;0;57;0
WireConnection;83;0;80;0
WireConnection;96;0;65;0
WireConnection;88;0;82;0
WireConnection;66;0;96;0
WireConnection;79;0;83;0
WireConnection;58;0;48;0
WireConnection;58;1;49;0
WireConnection;58;2;95;0
WireConnection;67;0;66;0
WireConnection;84;0;79;0
WireConnection;59;0;58;0
WireConnection;70;0;69;0
WireConnection;81;0;88;0
WireConnection;76;13;67;0
WireConnection;76;2;70;0
WireConnection;91;0;81;0
WireConnection;68;13;84;0
WireConnection;68;2;70;0
WireConnection;77;13;91;0
WireConnection;77;2;70;0
WireConnection;74;0;72;0
WireConnection;74;1;76;0
WireConnection;74;5;86;0
WireConnection;73;0;72;0
WireConnection;73;1;68;0
WireConnection;73;5;85;0
WireConnection;89;0;73;0
WireConnection;89;1;74;0
WireConnection;75;0;72;0
WireConnection;75;1;77;0
WireConnection;75;5;87;0
WireConnection;90;0;89;0
WireConnection;90;1;75;0
WireConnection;92;0;90;0
WireConnection;2;1;33;0
WireConnection;8;1;30;0
WireConnection;3;0;1;0
WireConnection;6;0;2;1
WireConnection;6;1;1;0
WireConnection;4;1;31;0
WireConnection;9;0;6;0
WireConnection;9;1;3;0
WireConnection;78;0;94;0
WireConnection;78;1;8;0
WireConnection;28;1;29;0
WireConnection;0;0;28;0
WireConnection;0;1;78;0
WireConnection;0;3;4;1
WireConnection;0;4;51;0
WireConnection;0;5;9;0
ASEEND*/
//CHKSM=EE7C5E19DC18A4241E6BF767F6955C5AFE7BFF86