using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotater : MonoBehaviour {

	// Use this for initialization
	private Vector3 _rot;
	public Vector3 rotV = Vector3.zero;

	void Start () {
		_rot = transform.rotation.eulerAngles;

	}
	
	// Update is called once per frame
	void Update () {
		_rot += rotV;
		transform.rotation = Quaternion.Euler(_rot.x,_rot.y,_rot.z);

	}
}
