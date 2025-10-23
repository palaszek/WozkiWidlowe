using UnityEngine;
using UnityEngine.InputSystem;

public class WASDPlain : MonoBehaviour
{
    [Tooltip("Pr�dko�� ruchu w m/s")]
    public float speed = 5f;
    [Header("Co sterowa�")]
    public Transform target;
    void Update()
    {
        Vector3 dir = Vector3.zero;

        var kb = Keyboard.current;
        if (kb != null)
        {
            if (kb.aKey.isPressed) dir.x -= 1f; // lewo
            if (kb.dKey.isPressed) dir.x += 1f; // prawo
            if (kb.wKey.isPressed) dir.z += 1f; // dalej
            if (kb.sKey.isPressed) dir.z -= 1f; // bli�ej
        }

            if (dir.sqrMagnitude > 1f) dir.Normalize(); // sta�a pr�dko�� po skosie

        // ruch po �wiecie 3D, bez zmiany Y
        if (target) target.Translate(dir * speed * Time.deltaTime, Space.World);
        else
            transform.Translate(dir * speed * Time.deltaTime, Space.World);
    }
}
