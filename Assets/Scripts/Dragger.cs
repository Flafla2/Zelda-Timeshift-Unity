using UnityEngine;
using System.Collections;

public class Dragger : MonoBehaviour {
	
	// Update is called once per frame
	void FixedUpdate () {
		bool mouse = Input.GetMouseButton(0);
		if(mouse && Input.mousePosition.y < Screen.height-60) {
			Plane plane = new Plane(new Vector3(0,0,1),new Vector3(0,0,0));
			Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
			float d;
			plane.Raycast(ray,out d);
			//if(Input.GetMouseButtonDown(0))
			//	rigidbody.position = ray.GetPoint(d);
			//else
				rigidbody.velocity = -(rigidbody.position-ray.GetPoint(d))/Time.deltaTime/10f;
		}
	}
}
