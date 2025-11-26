using UnityEngine;

public class DayNightController : MonoBehaviour
{
    public Light swiatloSlonca;          // directional light
    public float predkoscObrotu = 10f;   // stopnie na sekundê

    [SerializeField] private Material targetMaterial;
    [Range(0f, 5f)] public float maxIntensity = 1f;

    private static readonly int BlendId = Shader.PropertyToID("_Blend");

    public float angleX; // 0..360

    private void Update()
    {
        if (!targetMaterial || !swiatloSlonca) return;

        // 1. aktualizacja k¹ta 0..360
        angleX += predkoscObrotu * Time.deltaTime;
        angleX = Mathf.Repeat(angleX, 360f);

        // 2. obrót œwiat³a
        swiatloSlonca.transform.rotation = Quaternion.Euler(angleX, 0f, 0f);

        // 3. ile jest "dnia" (0 = noc, 1 = max dzieñ)
        // sin(0°) = 0, sin(90°) = 1, sin(180°) = 0, sin(>180) < 0
        float dayFactor = Mathf.Sin(angleX * Mathf.Deg2Rad);
        dayFactor = Mathf.Clamp01(dayFactor);   // obcinamy wartoœci <0 do 0

        // 4. ustaw intensywnoœæ s³oñca
        swiatloSlonca.intensity = maxIntensity * dayFactor;

        // 5. blend materia³u (np. 0 = dzieñ, 1 = noc)
        float blend = 1f - dayFactor;          // im ciemniej, tym wiêkszy blend
        targetMaterial.SetFloat(BlendId, blend);
    }
}
