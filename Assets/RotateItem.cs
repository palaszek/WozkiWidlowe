using UnityEngine;
using UnityEngine.InputSystem;

public class RTRotation : MonoBehaviour
{
    [Tooltip("Prêdkoœæ obrotu w stopniach na sekundê")]
    public float speed = 90f;

    [Header("Co rotowaæ")]
    public Transform target;

    [Header("Oœ obrotu")]
    public Vector3 axis = Vector3.up;

    [Tooltip("true = obrót w przestrzeni œwiata, false = w lokalnej")]
    public bool worldSpace = false;

    void Update()
    {
        var t = target ? target : transform;

        float dir = 0f;
        var kb = Keyboard.current;
        if (kb != null)
        {
            if (kb.rKey.isPressed) dir -= 1f;
            if (kb.tKey.isPressed) dir += 1f;
        }

        if (Mathf.Abs(dir) > 0f)
        {
            float angle = dir * speed * Time.deltaTime;
            t.Rotate(axis, angle, worldSpace ? Space.World : Space.Self);
        }
    }
}
