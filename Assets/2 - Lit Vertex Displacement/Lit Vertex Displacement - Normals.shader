Shader "Custom/2 - Lit Vertex Displacement/Normals" {
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

		#pragma surface surf Standard fullforwardshadows vertex:vert addshadow

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

		float4 getNewVertPosition( float4 p )
		{
			p.x += sin( _Time.y * _Speed + p.y * _Amount ) * _Distance;
			return p;
		}

		void vert( inout appdata_full v )
		{
			float4 vertPosition = getNewVertPosition( v.vertex );

			// calculate the bitangent (sometimes called binormal) from the cross product of the normal and the tangent
			float4 bitangent = float4( cross( v.normal, v.tangent ), 0 );

			// how far we want to offset our vert position to calculate the new normal
			float vertOffset = 0.01;

			float4 v1 = getNewVertPosition( v.vertex + v.tangent * vertOffset );
			float4 v2 = getNewVertPosition( v.vertex + bitangent * vertOffset );

			// now we can create new tangents and bitangents based on the deformed positions
			float4 newTangent = v1 - vertPosition;
			float4 newBitangent = v2 - vertPosition;

			// recalculate the normal based on the new tangent & bitangent
			v.normal = cross( newTangent, newBitangent );

			v.vertex = vertPosition;
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
