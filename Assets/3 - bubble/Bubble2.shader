Shader "Custom/Shader_Glass05" {
	Properties {
		_Color       ("Color"             , Color      ) = (1, 1, 1, 1)
		_Smoothness  ("Smoothness"        , Range(0, 1)) = 1
		_AlphaF      ("Alpha (Face)"      , Range(0, 1)) = 0
		_AlphaE      ("Alpha (Edge)"      , Range(0, 1)) = 0
		_AlphaR      ("Alpha (Rim)"       , Range(0, 1)) = 0
		_DistortionF ("Distortion (Face)" , Range(0, 1)) = 0
		_DistortionE ("Distortion (Edge)" , Range(0, 1)) = 0
	}

	SubShader {
		Tags {
			"Queue"      = "Transparent"
			"RenderType" = "Transparent"
		}

		// 屈折を入れる場合はシェーダー内で乗算させるので「通常の重ね設定」
		Blend SrcAlpha OneMinusSrcAlpha

		// 背景画をテクスチャとして取得
		GrabPass{ "" }

		Cull off
		
		Pass {
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"
				
				sampler2D _GrabTexture;
				half3 _Color;
				half _AlphaF;
				half _AlphaE;
				half _DistortionF;
				half _DistortionE;

				struct appdata {
					float4 vertex : POSITION;
					half   color  : COLOR;
					float3 normal : NORMAL;
				};

				struct v2f {
					float4 vertex    : SV_POSITION;
					half   color     : COLOR;
					float3 VSnormal  : TEXCOORD0;
					float4 screenPos : TEXCOORD1;
					float  distance  : TEXCOORD2;
				};
				
				v2f vert (appdata v) {
					v2f o;

					o.vertex    = UnityObjectToClipPos(v.vertex);
					o.color     = v.color;
					o.VSnormal  = COMPUTE_VIEW_NORMAL;
					o.screenPos = ComputeScreenPos(o.vertex);
					o.distance  = distance(v.vertex, _WorldSpaceCameraPos);

					return o;
				}
				
				fixed4 frag (v2f i) : SV_Target {
					// 擬似屈折を入れる
					half3 offset = i.VSnormal;// * (lerp(_DistortionF, _DistortionE, i.color) * (1 / i.distance));
					half3 grab = tex2D(_GrabTexture, (i.screenPos.xy / i.screenPos.w) + offset);

					return fixed4(grab * lerp(lerp(_Color, 0, _AlphaF), lerp(_Color, 0, _AlphaE), i.color), 1);
				}
			ENDCG
		}
		
        Cull off
		//Cull Front
		//Cull Front

		Pass {
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"
				
				half3 _Color;
				half _AlphaF;
				half _AlphaE;

				struct appdata {
					float4 vertex : POSITION;
					half   color  : COLOR;
				};

				struct v2f {
					float4 vertex : SV_POSITION;
					half   color  : COLOR;
				};
				
				v2f vert (appdata v) {
					v2f o;

					o.vertex = UnityObjectToClipPos(v.vertex);
					o.color  = v.color;

					return o;
				}
				
				fixed4 frag (v2f i) : SV_Target {
					// 透明度だけ描画
					// 方向の違いによる厚みに大きな差が無いので側面不透明度はいらない
					return fixed4(0, 0, 0, lerp(_AlphaF, _AlphaE, i.color));
				}
			ENDCG
		}
		
		// 擬似屈折で内面が見えないので、表面のみ描画
		//Cull Front
        Cull off

		// V/FシェーダーはReflection Probeに反応しないので
		// 反射だけを描画するSurface Shaderを追記する
		CGPROGRAM
			#pragma target 3.0
			#pragma surface surf Standard alpha

			half _Smoothness;
			half _AlphaR;
			
			struct Input {
				float3 viewDir;
			};

			void surf (Input IN, inout SurfaceOutputStandard o) {
				o.Smoothness = _Smoothness;
				o.Alpha      =  0;
			}
		ENDCG
	}

	FallBack "Standard"
}