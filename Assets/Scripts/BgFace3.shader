Shader "face/BgFace3" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

        _Amount ("_Amount", Range(0,1)) = 0.5
        _Amount2 ("_Amount2", Range(0,10)) = 0
        
        _Detail ("_Detail", Range(0,2)) = 0.5
        _Detail2 ("_Detail2", Range(0,30)) = 0.5
        _Voxel ("_Voxel", Range(2,100)) = 10
        _Limit ("_Limit", Range(0,10)) = 1
        _Sphere ("_Sphere", Range(0,1)) = 0
        _RotAmount ("_RotAmount", Range(0,1)) = 0

        _Clip ("_Clip", Range(0,10)) = 0
        _IsClip ("_IsClip", float) = 1

        _offsetY ("_offsetY", float) = 0

        _Th ("_Th", float) = 1 

        _vertOffset ("_vertOffset", float) = 0.01
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200
        cull off
        ZWrite On

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard addshadow vertex:vert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input {
            float2 uv_MainTex;
            float3 worldPos;
            float isClip;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

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
        float _offsetY;
        float _vertOffset;
        //float _params[16];

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_CBUFFER_START(Props)
            UNITY_DEFINE_INSTANCED_PROP(fixed4, _ColorA) // Make _Color an instanced property (i.e. an array)
        UNITY_INSTANCING_CBUFFER_END


        #include "./noise/SimplexNoise3D.hlsl"

        float4 getNewVertPosition( float4 v )
		{

            //_Detail = 
            


            float3 vv = v.xyz;
			float amp = length(vv);
			float radX = (-atan2(vv.z, vv.x) + 3.1415 * 0.5); //+ vv.y * sin(_count) * nejireX;//横方向の角度
			float radY = asin(vv.y / amp);

			float dAmp	= snoise( vv.xyz*_Detail + _Time.y ) * _Amount;            
			float dRadX	= sin( vv.y*_Detail2 + _Time.z) * _RotAmount;//横方向の角度
			
			amp += dAmp;// * step(_Th,dAmp);// * _DeformRatio;

            amp = lerp(amp,_Limit,_Sphere);
			radX 	+= dRadX;

			////to xy coodinate
			vv.x = amp * sin( radX ) * cos( radY );//横
			vv.y = amp * sin( radY );//縦
			vv.z = amp * cos( radX ) * cos( radY );//横

            v.xyz = vv.xyz;
            //v.vertex.y += _Sphere*_offsetY;

            v.xyz = round( v.xyz * _Voxel ) / _Voxel;

            return v;       
		}


        void vert(inout appdata_full v, out Input o )
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            
            UNITY_SETUP_INSTANCE_ID (v);

            fixed4 col = UNITY_ACCESS_INSTANCED_PROP(_ColorA);
            
            _Detail = col.x;
            _Voxel = col.y;
            _RotAmount = col.z;
            _IsClip = col.w;

			float4 vertPosition = getNewVertPosition( v.vertex );

			// calculate the bitangent (sometimes called binormal) from the cross product of the normal and the tangent
			float4 bitangent = float4( cross( v.normal, v.tangent ), 0 );

			// how far we want to offset our vert position to calculate the new normal
			float vertOffset = _vertOffset;

			float4 v1 = getNewVertPosition( v.vertex + v.tangent * vertOffset );
			float4 v2 = getNewVertPosition( v.vertex + bitangent * vertOffset );

			// now we can create new tangents and bitangents based on the deformed positions
			float4 newTangent = v1 - vertPosition;
			float4 newBitangent = v2 - vertPosition;

			// recalculate the normal based on the new tangent & bitangent
            if(_Voxel>30){
    			v.normal = cross( newTangent, newBitangent );
            }
			v.vertex = vertPosition;

            o.isClip = _IsClip;
            //float4 vertPosition = getNewVertPosition( v.vertex );
            //v.vertex = vertPosition;

            //v.vertex.xyz += snoise( v.vertex.xyz*_Detail + _Time.y ) * _Amount;
        }

        void surf (Input IN, inout SurfaceOutputStandard o) {

            // Albedo comes from a texture tinted by color
            _IsClip = IN.isClip;

            clip (frac((IN.worldPos.y*_Clip+IN.worldPos.x*_Clip+IN.worldPos.z*_Clip) * 5 + _Time.y) - 0.5 + _IsClip);
            //clip (frac((IN.worldPos.y*_Clip) * 5) - 0.5 + _IsClip);
            
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            //c.r *= 2;
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