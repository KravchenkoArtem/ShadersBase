using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

    public class ShaderToggleInspector : MaterialEditor
    {
        public override void OnInspectorGUI()
        {
            // Draw the default inspector.
            base.OnInspectorGUI ();
 
            // If we are not visible, return.
            if (!isVisible)
                return;
 
            // Get the current keywords from the material
            Material targetMat = target as Material;
            string[] keyWords = targetMat.shaderKeywords;
 
            // Check to see if the keyword NORMALMAP_ON is set in the material.
            bool normalEnabled = ((IList) keyWords).Contains ("FEATURE_ON");
            EditorGUI.BeginChangeCheck();
            // Draw a checkbox showing the status of normalEnabled
            normalEnabled = EditorGUILayout.Toggle ("Debug on Normal", normalEnabled);
            // If something has changed, update the material.
            if (EditorGUI.EndChangeCheck())
            {
                // If our normal is enabled, add keyword NORMALMAP_ON, otherwise add NORMALMAP_OFF
                List<string> keywords = new List<string> { normalEnabled ? "FEATURE_ON" : "FEATURE_OFF"};
                targetMat.shaderKeywords = keywords.ToArray ();
                EditorUtility.SetDirty (targetMat);
            }
        }
    }



