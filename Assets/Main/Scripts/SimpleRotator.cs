using UnityEngine;

namespace Main.Scripts
{
	public class SimpleRotator : MonoBehaviour {

		[SerializeField, Range(1f, 10f)]
		private float _mSpeed = 1.0f;

		private void FixedUpdate () {
			transform.Rotate(new Vector3(1, 0, 0) * _mSpeed);
		}  
	}
}
