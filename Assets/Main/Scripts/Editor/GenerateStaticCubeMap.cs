using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class GenerateStaticCubeMap : ScriptableWizard {
    public Transform renderPosition;
    public Cubemap cubemap;


    private void OnWizardUpdate()
    {
        helpString = "Select transform to render " + "from and cubemap to render into";
        if (renderPosition != null && cubemap != null)
        {
            isValid = true;
        }
        else
        {
            isValid = false;
        }
    }

    private void OnWizardCreate()
    {
        GameObject go = new GameObject("CubeCam", typeof(Camera));

        go.transform.position = renderPosition.position;
        go.transform.rotation = Quaternion.identity;

        go.GetComponent<Camera>().RenderToCubemap(cubemap);

        DestroyImmediate(go);
    }

    [MenuItem("GameObject/Rendere into Cubemap")]
    static void RenderCubemap()
    {
        ScriptableWizard.DisplayWizard<GenerateStaticCubeMap>(
          "Render cubemap", "Render!");
    }
}
