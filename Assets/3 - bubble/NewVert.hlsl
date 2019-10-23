
        #include "UnityCG.cginc"
        #include "./noise/SimplexNoise3D.hlsl"

        float3 getNewVertPosition( float3 v, float ampp, float3 time )
        {

            float3 vv = v.xyz;
            float amp = length(vv);
            float radX = (-atan2(vv.z+0.001, vv.x) + 3.1415 * 0.5); //+ vv.y * sin(_count) * nejireX;//横方向の角度
            float radY = asin(vv.y / amp);

            float dAmp	= snoise( vv.xyz*1.3 + time ) * ampp;
            
            amp += dAmp;// * step(_Th,dAmp);// * _DeformRatio;

            ////to xy coodinate
            vv.x = amp * sin( radX ) * cos( radY );//横
            vv.y = amp * sin( radY );//縦
            vv.z = amp * cos( radX ) * cos( radY );//横

            v.xyz = vv.xyz;

            return v;

        }


        float3 getNewNormal(float3 vertex, float3 normal, float3 tangent, float ampp, float3 time){

            float3 vertPosition = getNewVertPosition( vertex, ampp, time );

            // calculate the bitangent (sometimes called binormal) from the cross product of the normal and the tangent
            float3 bitangent = cross( normal, tangent );

            // how far we want to offset our vert position to calculate the new normal
            float vertOffset = 0.01;

            float3 v1 = getNewVertPosition( vertex + tangent * vertOffset,ampp,time );
            float3 v2 = getNewVertPosition( vertex + bitangent * vertOffset,ampp,time );

            // now we can create new tangents and bitangents based on the deformed positions
            float3 newTangent = v1 - vertPosition;
            float3 newBitangent = v2 - vertPosition;
            
            //v.normal = cross( newTangent, newBitangent );
            float3 outNormal = cross(newTangent,newBitangent);//cross( newTangent, newBitangent );
            
            return outNormal;
        }        