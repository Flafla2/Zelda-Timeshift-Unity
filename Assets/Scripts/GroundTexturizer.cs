using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class GroundTexturizer : MonoBehaviour {

	public GameObject[] objectsToUpdate;
	public float radius = 5;
	public float borderWidth = 0.1f;
	public Color borderColor;
	public bool cylindrical = false;

	// Update is called once per frame
	void Update () {
		foreach(GameObject o in objectsToUpdate) {
			o.renderer.sharedMaterial.SetVector("_LightPos",transform.position);
			o.renderer.sharedMaterial.SetFloat("_LightRad",radius);
			o.renderer.sharedMaterial.SetColor("_BorderColor",borderColor);
			o.renderer.sharedMaterial.SetFloat("_BorderWidth",borderWidth);
			o.renderer.sharedMaterial.SetFloat("_Cylindrical",cylindrical ? 1 : 0);
		}
	}

	void OnGUI() {
		radius = GUI.HorizontalSlider(new Rect(10,10,200,40),radius,0,10);
	}
}
