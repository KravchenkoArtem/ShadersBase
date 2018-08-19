using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MeshDebugData : MonoBehaviour {

	void Start () {
        MeshFilter mesh = GetComponent<MeshFilter>();
        Vector3[] v = mesh.mesh.vertices;
        for (int i = 0; i < v.Length; i++) {
            Debug.Log(v[i]);
        }
	}
	
}
