//#define half3 Vector3

using UnityEngine;

public class CableCollider : MonoBehaviour
{
    //typedef half3 Vector3;

    private Vector4 _Position1 = new Vector4(-0.5f, -0.5f, -0.5f, 1.0f);
    private Vector4 _Position2 = new Vector4(0.5f, 0.5f, 0.5f, 1.0f);
    private int _Scale = 256;
    private float _Size = 1.0f;
    private float _Sag = 1.0f;

    private GameObject go = null;
    private Mesh prim = null;
    private Mesh blank = null;
    private CombineInstance[] combine = null;
    private Matrix4x4 origin = new Matrix4x4();
    private Vector3 position = new Vector3(0.0f, 0.0f, 0.0f);
    private Vector3 position1 = new Vector3(0.0f, 0.0f, 0.0f);
    private Vector3 position2 = new Vector3(0.0f, 0.0f, 0.0f);
    private Vector3 size = new Vector3(0.0f, 0.0f, 0.0f);
    private uint scale = 1;

    Vector3 interpolation(Vector3 start, Vector3 end, float pos, float scale)
    {
        pos /= (scale - 1.0f);
        end -= start;
        start += (end * pos);
        pos -= 0.5f;
        pos *= 2.0f;
        pos = 1.0f - Mathf.Pow(Mathf.Abs(pos), 2.0f);
        start.y -= pos * _Sag;
        return start;
    }

    void Start()
    {
        go = GameObject.CreatePrimitive(PrimitiveType.Sphere);
        //go = GameObject.CreatePrimitive(PrimitiveType.Cube);
        prim = go.GetComponent<MeshFilter>().sharedMesh;
        GameObject.DestroyImmediate(go);
        blank = new Mesh();
    }

    void Update()
    {
        MeshRenderer r = GetComponent<MeshRenderer>();
        MeshCollider c = GetComponent<MeshCollider>();
        Material s = r.sharedMaterial;
        Mesh m = c.sharedMesh;

        _Position1 = s.GetVector("_Position1");
        _Position2 = s.GetVector("_Position2");
        _Scale = s.GetInt("_Scale");
        _Size = s.GetFloat("_Size");
        _Sag = s.GetFloat("_Sag");

        position1 = new Vector3(_Position1[0], _Position1[1], _Position1[2]);
        position2 = new Vector3(_Position2[0], _Position2[1], _Position2[2]);
        size = new Vector3(_Size, _Size, _Size) * 0.15f;
        scale = (_Scale >= 1) ? (uint)_Scale : 1;
        scale = 100; //override for sphere

        //c.sharedMesh = prim;
        c.sharedMesh = blank;
        combine = new CombineInstance[scale];

        for (uint i = 0; i < scale; ++i)
        {
            combine[i].mesh = prim;
            position = interpolation(position1, position2, (float)i, (float)scale);
            origin = r.localToWorldMatrix;
            origin *= Matrix4x4.Translate(position);
            origin *= Matrix4x4.Scale(size);
            combine[i].transform = origin;
        }
        c.sharedMesh.CombineMeshes(combine);
    }
}
