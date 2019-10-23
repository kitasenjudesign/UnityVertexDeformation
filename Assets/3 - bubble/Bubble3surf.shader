// Upgrade NOTE: upgraded instancing buffer 'Props' to new syntax.

Shader "custom/Bubble3surf" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_Amount ("_Amount", Range(0,5)) = 0.0
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
		#pragma surface surf Standard addshadow vertex:vert

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		//fixed4 _Color;
		float _Amount;
        sampler2D _GrabPassTexture;

        void vert(inout appdata_full v, out Input o )
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
		
            //頂点シェーダーで入力構造体から出力構造体へインスタンス ID をコピーします。
            //フラグメントシェーダーでは、インスタンスごとのデータにアクセスするときのみ必要です
            //UNITY_TRANSFER_INSTANCE_ID (v, o);            

			//頂点をてきとうに、ごちゃごちゃする、ここではノーマル方向に値を足してる
			//v.vertex.xyz += v.normal.xyz * _Amount;
            
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {

            //UNITY_SETUP_INSTANCE_ID (IN);

            fixed4 col = fixed4(1,1,1,1);

			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_GrabPassTexture, IN.uv_MainTex) * col;
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