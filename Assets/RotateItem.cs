using UnityEngine;
using UnityEngine.InputSystem;

public class RTRotation : MonoBehaviour
{
    [Tooltip("Pr�dko�� obrotu w stopniach na sekund�")]
    public float speed = 90f;

    [Header("Co rotowa�")]
    public Transform target;

    [Header("O� obrotu")]
    public Vector3 axis = Vector3.up;

    [Tooltip("true = obr�t w przestrzeni �wiata, false = w lokalnej")]
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
