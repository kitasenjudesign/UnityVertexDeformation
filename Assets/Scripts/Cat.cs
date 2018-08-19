using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Cat : MonoBehaviour {

	[SerializeField] private Material _mat;
	[SerializeField] private Material _mat2;

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {

		

		if(Input.GetKeyDown(KeyCode.RightArrow)){

			Debug.Log("ok");
			_setFloat("_IsClip", Random.value < 0.25f ? -0.2f + 0.4f * Random.value : 4f );
			_setFloat("_Voxel", Random.value<0.25 ? 1f+3f*Random.value : 1000f  );
			_setFloat("_Detail", Random.value   );
			_setFloat("_Detail2", Random.value   );
			_setFloat("_RotAmount", Random.value < 0.4f ? (Random.value-0.5f)*6f : 0   );
			_setFloat("_Amount", 0.8f + Random.value   );
			
			//_mat.SetFloat("_Sphere", Random.value >0.9f ? 0f : 1f );
		}

		if(Input.GetKeyDown(KeyCode.DownArrow)){

			Debug.Log("ok");
			_setFloat("_IsClip", 4f );
			_setFloat("_Voxel", 1000f  );
			_setFloat("_Amount", 0 );
			_setFloat("_RotAmount", 0 );

		}
	}

	void _setFloat(string name, float n){

		_mat.SetFloat(name,n);
		_mat2.SetFloat(name,n);
		
	}
}
