using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class DrawMeshInstancedData {

    public Vector3 pos = new Vector3(
        Random.value-0.5f,
        Random.value-0.5f,
        Random.value-0.5f        
    );
    public Quaternion rot =Quaternion.Euler(0,0,0);
    public Vector3 scale = new Vector3(1f,1f,1f);

}