using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

//葉っぱたち

public class Cats : DrawMeshInstancedBase {

    private DrawMeshInstancedData[] _data;

    [SerializeField] private int _W=10;
    [SerializeField] private int _H=10;
    
    [SerializeField] private Vector4[] _colors2;

    private int _numChange = 0;
    private float _tgtAmount = 0;
    private float _amount = 0;

    void Start(){

        _count = _W * _H;

        _propertyBlock = new MaterialPropertyBlock();
        _matrices = new Matrix4x4[_count];
        _data = new DrawMeshInstancedData[_count];

        _colors = new Vector4[_count];
        _colors2 = new Vector4[_count];

        int idx = 0;
        float space = 5.5f;
        for (int i = 0; i < _W; i++)
        {
            for(int j = 0; j < _H; j++){
                

                _matrices[idx] = Matrix4x4.identity;
                _data[idx] = new DrawMeshInstancedData();//
                _data[idx].rot = Quaternion.Euler(0,180f,0);
                _data[idx].pos.x = (float)i / (_W-1f) * space - space*0.5f + (j%2)*space/(_W-1f)*0.5f;
                _data[idx].pos.y = 0;
                _data[idx].pos.z = (float)j / (_H-1f) * space - space*0.5f;
                _data[idx].scale.Set(0.1f,0.1f,0.1f);

                idx++;

            }
        }


        _change();
    }

    void _change(){
        int idx =0;
        

        for (int i = 0; i < _W; i++)
        {
            for(int j = 0; j < _H; j++){

                if(_numChange%6!=0){
                    
                    _colors[idx].x = Random.value < 0.1f ? 6f*Random.value : 1.3f*Random.value;
                    _colors[idx].y = Random.value<0.25 ? 0.5f+5f*Random.value : 1000f;
                    _colors[idx].z = Random.value < 0.5f ? (Random.value-0.5f)*16f : 0;//rot
                    
                    _colors[idx].w = Random.value < 0.2f ? -0.2f + 0.4f * Random.value : 4f;//isClip
                    _colors2[idx].w = _colors[idx].w;

                    //_mat.SetFloat("_Amount", 1.4f+0.1f*Random.value );
                    _tgtAmount=1.4f+0.1f*Random.value;
                }else{

                    //_Detail = col.x;
                    //_Voxel = col.y;
                    //_RotAmount = col.z;
                    //_IsClip = col.w;

                    //_colors[idx].x = Random.value;
                    _colors[idx].y = 1000f;
                    _colors[idx].z = 0;
                    _colors[idx].w = 40f;
                    _colors2[idx].w = 40f;

			        //_mat.SetFloat("_Amount", 0 );
                    _tgtAmount=0;
                }
                idx++;
            }
        }

        _numChange++;
        Invoke("_change",5f);
    }

    void Update(){

        for (int i = 0; i < _count; i++)
        {
            _matrices[i].SetTRS( 
                _data[i].pos,
                _data[i].rot,
                _data[i].scale
            );
            _matrices[i] = transform.localToWorldMatrix * _matrices[i];

            _colors2[i] += (_colors[i]-_colors2[i])/10f;
        }

        _amount+=(_tgtAmount-_amount)/8f;
        _mat.SetFloat("_Amount",_amount);

        _propertyBlock.SetVectorArray("_ColorA", _colors2);

        Graphics.DrawMeshInstanced(
            _mesh, 
            0, 
            _mat, 
            _matrices, 
            _count, 
            _propertyBlock, 
            ShadowCastingMode.On,
            true,                
            gameObject.layer
        );

    }

}