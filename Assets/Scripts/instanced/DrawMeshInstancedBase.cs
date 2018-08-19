using UnityEngine;
using System.Collections;
using UnityEngine.Rendering;

public class DrawMeshInstancedBase : MonoBehaviour {

    [SerializeField] protected Mesh _mesh;
    [SerializeField] protected Material _mat;
    protected Matrix4x4[] _matrices;
    protected Vector4[] _colors;
    protected Vector4[] _uv;

    protected MaterialPropertyBlock _propertyBlock;
    [SerializeField] protected int _count = 10;
    
    protected void Init(){

    }

    protected void DrawMesh(){

        Graphics.DrawMeshInstanced(
                _mesh, 
                0, 
                _mat, 
                _matrices, 
                _count, 
                _propertyBlock, 
                ShadowCastingMode.Off, 
                false,
                gameObject.layer
        );

    }

}