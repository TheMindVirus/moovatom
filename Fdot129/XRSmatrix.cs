using UnityEngine;

public class XRSmatrix : MonoBehaviour
{
    void Update()
    {
        GetComponent<Renderer>().sharedMaterial.SetVector("_Translation", transform.position);
        GetComponent<Renderer>().sharedMaterial.SetVector("_Rotation", transform.rotation.eulerAngles);
        GetComponent<Renderer>().sharedMaterial.SetVector("_Scale", transform.localScale);
    }
}