// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/1 - Vertex Displacement/World Space"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}

		_Speed("Speed",Range(0.1,4)) = 1
		_Amount("Amount", Range(0.1,10)) = 3
		_Distance("Distance", Range( 0, 2 )) = 0.3
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
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			half _Speed;
			half _Amount;
			half _Distance;
			
			v2f vert (appdata v)
			{
				v2f o;

				// Takes the mesh's verts and turns it into a point in world space
				// this is the equivalent of Transform.TransformPoint on the scripting side
				float4 worldSpaceVertex = mul( unity_ObjectToWorld, v.vertex );

				// Takes the x position of each vert as it was authored and moves it along the object's x-axis
				// The amount it's moved used a sine wave to have a nice wave shape to it
				// The vertex's y position is used otherwise all verts will be moved uniformly
				worldSpaceVertex.x += sin( _Time.y * _Speed + worldSpaceVertex.y * _Amount ) * _Distance;

				// takes the new modified position of the vert in world space and then puts it back in local space
				v.vertex = mul( unity_WorldToObject, worldSpaceVertex );

				// This line takes our mesh's vertices and turns them into screen positions that the fragment shader can fill in
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}
	}
}
