using UnityEngine;

public class BillboardTorch : MonoBehaviour
{
    private Camera cam;

    private void Start()
    {
        cam = Camera.main;
    }

    private void LateUpdate()
    {
        if (!cam) return;

        Vector3 dir = transform.position - cam.transform.position;

        dir.y = 0f;

        if (dir.sqrMagnitude > 0.0001f)
        {
            transform.rotation = Quaternion.LookRotation(dir);
        }
    }
}
