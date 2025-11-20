using UnityEngine;

public class ROTATONE : MonoBehaviour
{
    public GameObject obracaj;
    public float predkoscObrotu = 100f;

    public void obracanie()
    {
        obracaj.transform.Rotate(predkoscObrotu * Time.deltaTime, 0, 0);
    }

    void Update()
    {
        obracanie();
    }

}
