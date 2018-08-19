  Shader "face/BgFace" {
      Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _Amount ("Extrusion Amount", Range(0,1)) = 0.5
        _Amount2 ("_Amount2", Range(0,10)) = 0
        
        _Detail ("_Detail", Range(0,2)) = 0.5
        _Detail2 ("_Detail2", Range(0,30)) = 0.5
        _Voxel ("_Voxel", Range(2,100)) = 10
        _Limit ("_Limit", Range(0,10)) = 1
        _Sphere ("_Sphere", Range(0,1)) = 0
        _RotAmount ("_RotAmount", Range(0,1)) = 0

        _Clip ("_Clip", Range(0,0.3)) = 0
        _IsClip ("_IsClip", float) = 1

        _Th ("_Th", float) = 1 
      }
      SubShader {

        Tags { "RenderType" = "Opaque" }
        Cull off

        CGPROGRAM
        #pragma surface surf Lambert vertex:vert
        //#pragma surface surf Standard fullforwardshadows vertex vert

        #include "./noise/SimplexNoise3D.hlsl"
        
        //Cull off

        struct Input {
            float2 uv_MainTex;
            float3 worldPos;
        };
        float _Amount;
        float _Amount2;
        float _Detail;
        float _Detail2;
        float _Voxel;
        float _Limit;
        float _Sphere;
        float _RotAmount;
        float _Clip;
        float _IsClip;
        float _Th;

        void vert (inout appdata_full v) {
            
            v.vertex.xyz += snoise_grad(v.vertex.xyz*_Detail2 + _Time.z ).xyz * _Amount2;
            
			float3 vv = v.vertex.xyz;

			////to polar
			float amp = length(vv);
			float radX = (-atan2(vv.z, vv.x) + 3.1415 * 0.5); //+ vv.y * sin(_count) * nejireX;//横方向の角度
			float radY = asin(vv.y / amp);

			float dAmp	= snoise( vv.xyz*_Detail + _Time.y ) * _Amount;
			float dRadX	= sin( vv.y*_Detail*0.5 + _Time.z) * _RotAmount;//横方向の角度
			

			amp += dAmp * step(_Th,dAmp);// * _DeformRatio;

            amp = lerp(amp,_Limit,_Sphere);
			radX 	+= dRadX;

			////to xy coodinate
			vv.x = amp * sin( radX ) * cos( radY );//横
			vv.y = amp * sin( radY );//縦
			vv.z = amp * cos( radX ) * cos( radY );//横

            v.vertex.xyz = vv.xyz;

            v.vertex.xyz = round( v.vertex.xyz * _Voxel ) / _Voxel;

            //v.vertex.z *= 0.1;
            //v.vertex.xyz += v.normal*_Normal;
            

            //v.vertex.xyz += v.normal.xyz * _Amount;
            

        }
        sampler2D _MainTex;
        void surf (Input IN, inout SurfaceOutput o) {

            //clip (frac((IN.worldPos.y+IN.worldPos.z*0.1) * 5) - 0.5);
            clip (frac((IN.worldPos.y*_Clip+IN.worldPos.x*_Clip+IN.worldPos.z*_Clip) * 5) - 0.5 + _IsClip);
            
            //clip(v.vertex.z);
            o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb;

        }
        ENDCG

      }
      Fallback "Diffuse"
    }