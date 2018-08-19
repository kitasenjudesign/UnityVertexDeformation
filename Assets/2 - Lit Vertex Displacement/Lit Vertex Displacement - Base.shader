Shader "Custom/2 - Lit Vertex Displacement/Base" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0


		_Speed("Speed",Range(0.1,4)) = 1
		_Amount("Amount", Range(0.1,10)) = 3
		_Distance("Distance", Range( 0, 2 )) = 0.3
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM

		// add "vertex:vert" to intercept the mesh before unity runs its lighting passes
		// "vert" is just the name of the function below

		#pragma surface surf Standard fullforwardshadows vertex:vert
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		half _Speed;
		half _Amount;
		half _Distance;

		// our vert modification function
		void vert( inout appdata_full v )
		{
			v.vertex.x += sin( _Time.y * _Speed + v.vertex.y * _Amount ) * _Distance;
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
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
