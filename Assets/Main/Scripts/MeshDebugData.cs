using UnityEngine;

namespace Main.Scripts
{
	public class MeshDebugData : MonoBehaviour {
		private void Start () {
			MeshFilter mesh = GetComponent<MeshFilter>();
			Vector3[] v = mesh.mesh.vertices;
			for (int i = 0; i < v.Length; i++) {
				Debug.Log(v[i]);
			}
		}
	
	}
}
