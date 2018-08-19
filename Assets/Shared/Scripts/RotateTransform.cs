using UnityEngine;
using System.Collections;

public class RotateTransform : MonoBehaviour {
	
	public Vector3 m_Rotation = new Vector3( 0f, 360f, 0f );
	public float m_Duration = 1f;

	private void Update ()
	{
		transform.rotation *= Quaternion.Euler( m_Rotation * Time.deltaTime / m_Duration );
	}
}
