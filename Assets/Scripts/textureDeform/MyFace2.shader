Shader "Unlit/MyFace2"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_MainTex2 ("Texture", 2D) = "white" {}

		_Amp ("_Amp", Range(0,100)) = 30
		
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
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			#include "../noise/SimplexNoise3D.hlsl"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			sampler2D _MainTex2;
			float4 _MainTex_ST;
			float _Amp;

			v2f vert (appdata v)
			{
				v2f o;


            float3 vv = v.vertex.xyz;
			float amp = length(vv);
			float radX = (-atan2(vv.z, vv.x) + 3.1415 * 0.5); //+ vv.y * sin(_count) * nejireX;//横方向の角度
			float radY = asin(vv.y / amp);

			float dAmp	= snoise( vv.xyz * 0.006 + _Time.y ) * _Amp;            
			float dRadX	= sin( vv.y + _Time.z) * 0.1;// * _RotAmount;//横方向の角度
			
			amp += dAmp;// * step(_Th,dAmp);// * _DeformRatio;
			//radX 	+= dRadX;

            //amp = lerp(amp,_Limit,_Sphere);
			
			////to xy coodinate
			vv.x = amp * sin( radX ) * cos( radY );//横
			vv.y = amp * sin( radY );//縦
			vv.z = amp * cos( radX ) * cos( radY );//横

				v.vertex.xyz = vv;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv + float2(dAmp*0.01,dRadX*0.01);//TRANSFORM_TEX(v.uv, _MainTex);
				o.uv.x = frac(o.uv.x);
				o.uv2.x = dAmp;
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col1 = tex2D(_MainTex, i.uv);
				fixed4 col2 = tex2D(_MainTex2, i.uv*(10+i.uv2.x*0.05));

				fixed4 col = lerp(col1,col2,(i.uv2.x));

				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
