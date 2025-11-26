using UnityEngine;

public class DayNightController : MonoBehaviour
{
    public GameObject obracaj;
    public float predkoscObrotu = 10f; // stopnie na sekundê

    [SerializeField] private Material targetMaterial;

    private static readonly int BlendId = Shader.PropertyToID("_Blend");

    public float angleX;

    private void Update()
    {
        if (!targetMaterial || !obracaj) return;

        obracanie();

        // K¹t w zakresie 0–360
        angleX = obracaj.transform.eulerAngles.x;

        // Przekszta³camy na zakres -180..180
        float signedAngleX = (angleX <= 180f) ? angleX : angleX - 360f;

        float blend;
        if (signedAngleX >= 0f)
            blend = 0f;
        else
            blend = 1f;

        targetMaterial.SetFloat(BlendId, blend);
    }


    private void obracanie()
    {
        obracaj.transform.Rotate(predkoscObrotu * Time.deltaTime, 0f, 0f);
    }
}
