// Upgrade NOTE: upgraded instancing buffer 'Props' to new syntax.

Shader "custom/Bubble3surf3" {

	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_Amount ("_Amount", Range(0,5)) = 0.0

	    _Cube ("Cubemap", CUBE) = "" {}
        _RelativeRefractionIndex("Relative Refraction Index", Range(0.0, 1.0)) = 0.67
        [PowerSlider(5)]_Distance("Distance", Range(0.0, 100.0)) = 10.0		
	}
	SubShader {

        Tags {"Queue"="Transparent" "RenderType"="Transparent" }
        
        Cull Back 
        ZWrite On
        ZTest LEqual
        ColorMask RGB

        GrabPass { "_GrabPassTexture" }


		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		//#pragma surface surf Standard fullforwardshadows
		#pragma surface surf Standard addshadow vertex:vert alpha:fade
		//#pragma surface surf Standard fullforwardshadows vertex:vert alpha:fade


		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

        #include "UnityCG.cginc"
		#include "NewVert.hlsl"

		sampler2D _MainTex;

		struct Input {

            float2 uv_MainTex;
			//float2 samplingViewportPos;
            float3 viewDir;
			float3 reflectDir;
			
		};

		half _Glossiness;
		half _Metallic;
		//fixed4 _Color;
		float _Amount;
        sampler2D _GrabPassTexture;
		float _RelativeRefractionIndex;
		float _Distance;
		
    	samplerCUBE _Cube;

        void vert(inout appdata_full v, out Input o )
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
		
            //頂点シェーダーで入力構造体から出力構造体へインスタンス ID をコピーします。
            //フラグメントシェーダーでは、インスタンスごとのデータにアクセスするときのみ必要です
            //UNITY_TRANSFER_INSTANCE_ID (v, o);            

			//頂点をてきとうに、ごちゃごちゃする、ここではノーマル方向に値を足してる
			float3 gp = mul(unity_ObjectToWorld, float3(0,0,0)) + _Time.y;
			float3 pos = v.vertex.xyz;
			v.vertex.xyz = getNewVertPosition(pos,_Amount,gp);
            v.normal.xyz = getNewNormal(pos,v.normal,v.tangent,_Amount,gp);


			//////
			//ワールド座標
                float3 worldPos         = mul(unity_ObjectToWorld, v.vertex);
                //ワールドノーマル
                half3 worldNormal       = UnityObjectToWorldNormal(v.normal);
                //カメラからのディレクション
                half3 viewDir           = normalize(worldPos - _WorldSpaceCameraPos.xyz);

                // 屈折方向を求める
                //https://wgld.org/d/webgl/w046.html
                //reflect(I, N)	- Nを法線として、Iの反射方向をIと同じ型で返す(＞反射)
                //refract(I, N, eta) - Nを法線、eta（常にfloat型）を屈折率として、Iの屈折方向をIと同じ型で返す(＞屈折)
                //http://asawicki.info/news_1301_reflect_and_refract_functions.html
                half3 refractDir        = refract(viewDir, worldNormal, _RelativeRefractionIndex);
                half3 reflectDir		= reflect(viewDir, worldNormal);
                
				// 屈折方向の先にある位置をサンプリング位置とする
                half3 samplingPos       = worldPos + refractDir * _Distance;
                
                // サンプリング位置をプロジェクション変換
                half4 samplingScreenPos = mul(UNITY_MATRIX_VP, half4(samplingPos, 1.0));
                
                // ビューポート座標系に変換
                //o.samplingViewportPos   = (samplingScreenPos.xy / samplingScreenPos.w) * 0.5 + 0.5;
                #if UNITY_UV_STARTS_AT_TOP
                    //o.samplingViewportPos.y     = 1.0 - o.samplingViewportPos.y;
                #endif

				o.viewDir = viewDir;
				o.reflectDir = reflectDir;
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {

            //UNITY_SETUP_INSTANCE_ID (IN);

            fixed4 col = texCUBE (_Cube, IN.reflectDir);//tex2D (_MainTex, IN.uv_MainTex);

			float2 uvv = frac( IN.uv_MainTex + float2(_Time.x,0) );
			fixed4 rainbow = tex2D (_MainTex, uvv);

			// Albedo comes from a texture tinted by color
			fixed4 c = max( col,rainbow );//,tex2D (_GrabPassTexture, IN.samplingViewportPos) );
			o.Albedo = c.rgb * 0.1;
			o.Emission = c.rgb * 0.9;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			
			//o.Alpha = c.a;
			o.Alpha = 1 - dot(IN.viewDir, o.Normal);
			
			//o.Alpha=0.9;
		}

		ENDCG
	}
	FallBack "Diffuse"
}