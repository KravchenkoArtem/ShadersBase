using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SimpleRotator : MonoBehaviour {

    [SerializeField, Range(1f, 10f)]
    private float m_Speed = 1.0f;

	void FixedUpdate () {
        transform.Rotate(new Vector3(1, 0, 0) * m_Speed);
	}
}
