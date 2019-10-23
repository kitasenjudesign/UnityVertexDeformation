Shader "custom/Bubble3v" 
{
    Properties 
    {
        _RelativeRefractionIndex("Relative Refraction Index", Range(0.0, 1.0)) = 0.67

        _vertOffset ("_vertOffset", float) = 0.01
        _amp ("_amp", float) = 0.01

        [PowerSlider(5)]_Distance("Distance", Range(0.0, 100.0)) = 10.0
    }
    
    SubShader 
    {
        Tags {"Queue"="Transparent" "RenderType"="Transparent" }
        
        Cull Back 
        ZWrite On
        ZTest LEqual
        ColorMask RGB

        GrabPass { "_GrabPassTexture" }

        Pass {

            CGPROGRAM
           #pragma vertex vert
           #pragma fragment frag
            
           #include "UnityCG.cginc"
           #include "./noise/SimplexNoise3D.hlsl"

            struct appdata {
                half4 vertex                : POSITION;
                half4 texcoord              : TEXCOORD0;
                half3 normal                : NORMAL;
                half4 tangent               : TANGENT;
            };
                
            struct v2f {
                half4 vertex                : SV_POSITION;
                half2 samplingViewportPos   : TEXCOORD0;
            };
            
            sampler2D _GrabPassTexture;
            float _RelativeRefractionIndex;
            float _Distance;
            float _vertOffset;
            float _amp;

            float4 getNewVertPosition( float4 v )
            {

                float3 vv = v.xyz;
                float amp = length(vv);
                float radX = (-atan2(vv.z, vv.x) + 3.1415 * 0.5); //+ vv.y * sin(_count) * nejireX;//横方向の角度
                float radY = asin(vv.y / amp);

                float dAmp	= snoise( vv.xyz*1.3 + _Time.y ) * _amp;
                
                amp += dAmp;// * step(_Th,dAmp);// * _DeformRatio;

                ////to xy coodinate
                vv.x = amp * sin( radX ) * cos( radY );//横
                vv.y = amp * sin( radY );//縦
                vv.z = amp * cos( radX ) * cos( radY );//横

                v.xyz = vv.xyz;

                return v;       
            }

            float3 getNewNormal(appdata v){

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
                
                //v.normal = cross( newTangent, newBitangent );
                float3 outNormal = cross(newTangent,newBitangent);//cross( newTangent, newBitangent );
                
                return outNormal;
            }

            v2f vert (appdata v)
            {
                
                v2f o                   = (v2f)0;
                o.vertex                = UnityObjectToClipPos(
                    getNewVertPosition( v.vertex )
                );

                //ワールド座標
                float3 worldPos         = mul(unity_ObjectToWorld, o.vertex );
                
                //ワールドノーマル
                half3 worldNormal       = UnityObjectToWorldNormal( 
                    getNewNormal( v ) //v.normal
                );

                //カメラからのディレクション
                half3 viewDir           = normalize(worldPos - _WorldSpaceCameraPos.xyz);

                // 屈折方向を求める
                //https://wgld.org/d/webgl/w046.html
                //reflect(I, N)	- Nを法線として、Iの反射方向をIと同じ型で返す(＞反射)
                //refract(I, N, eta) - Nを法線、eta（常にfloat型）を屈折率として、Iの屈折方向をIと同じ型で返す(＞屈折)
                //http://asawicki.info/news_1301_reflect_and_refract_functions.html
                half3 refractDir        = refract(viewDir, worldNormal, _RelativeRefractionIndex);
                
                // 屈折方向の先にある位置をサンプリング位置とする
                half3 samplingPos       = worldPos + refractDir * _Distance;
                
                // サンプリング位置をプロジェクション変換
                half4 samplingScreenPos = mul(UNITY_MATRIX_VP, half4(samplingPos, 1.0));
                
                // ビューポート座標系に変換
                o.samplingViewportPos   = (samplingScreenPos.xy / samplingScreenPos.w) * 0.5 + 0.5;
                #if UNITY_UV_STARTS_AT_TOP
                    o.samplingViewportPos.y     = 1.0 - o.samplingViewportPos.y;
                #endif

                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                return tex2D(_GrabPassTexture, i.samplingViewportPos);
            }
            
            ENDCG
        }
    }
}