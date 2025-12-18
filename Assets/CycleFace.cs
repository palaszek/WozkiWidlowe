using System.Collections;
using UnityEngine;

public class CycleFace : MonoBehaviour
{

    public SkinnedMeshRenderer eyesRenderer;
    public SkinnedMeshRenderer mouthRenderer;


    public float stepDuration = 2.0f;    
    public float transitionSpeed = 5.0f; 

    private void Start()
    {
        if (eyesRenderer != null && mouthRenderer != null)
        {
            StartCoroutine(CycleExpressions());
        }
    }

    IEnumerator CycleExpressions()
    {
        int totalStates = 4;
        int currentState = 0;

        while (true)
        {
            if (currentState == 0)
            {
                yield return StartCoroutine(FadeToNeutral());
            }
            else
            {
                int shapeIndex = currentState - 1;
                yield return StartCoroutine(FadeToShape(shapeIndex));
            }

            yield return new WaitForSeconds(stepDuration);

            currentState = (currentState + 1) % totalStates;
        }
    }

    IEnumerator FadeToNeutral()
    {
        float elapsed = 0;
        while (elapsed < 1.0f)
        {
            for (int i = 0; i < 3; i++)
            {
                float e = eyesRenderer.GetBlendShapeWeight(i);
                float m = mouthRenderer.GetBlendShapeWeight(i);
                eyesRenderer.SetBlendShapeWeight(i, Mathf.Lerp(e, 0, Time.deltaTime * transitionSpeed));
                mouthRenderer.SetBlendShapeWeight(i, Mathf.Lerp(m, 0, Time.deltaTime * transitionSpeed));
            }
            elapsed += Time.deltaTime;
            yield return null;
        }
    }

    IEnumerator FadeToShape(int index)
    {

        float weight = 0;
        while (weight < 99.5f)
        {
            weight = Mathf.Lerp(weight, 100f, Time.deltaTime * transitionSpeed);


            eyesRenderer.SetBlendShapeWeight(index, weight);
            mouthRenderer.SetBlendShapeWeight(index, weight);


            for (int i = 0; i < 3; i++)
            {
                if (i == index) continue;
                float e = eyesRenderer.GetBlendShapeWeight(i);
                float m = mouthRenderer.GetBlendShapeWeight(i);
                eyesRenderer.SetBlendShapeWeight(i, Mathf.Lerp(e, 0, Time.deltaTime * transitionSpeed));
                mouthRenderer.SetBlendShapeWeight(i, Mathf.Lerp(m, 0, Time.deltaTime * transitionSpeed));
            }
            yield return null;
        }
    }
}