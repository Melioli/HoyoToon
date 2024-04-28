#if UNITY_EDITOR

using UnityEditor;
using UnityEngine;


[CustomEditor(typeof(HoyoToonPostProcess))]
public class HoyoToonPostProcessEditor : Editor
{
    private bool showBloomSettings = true;
    private bool showColorGrading = true;
    private bool showToneMapping = true;


    public override void OnInspectorGUI()
    {
        HoyoToonPostProcess script = (HoyoToonPostProcess)target;

        // Load and draw logo;
        Texture2D logo = Resources.Load<Texture2D>("UI/hoyotoon");
        if (logo != null)
        {
            GUILayout.BeginHorizontal();
            GUILayout.FlexibleSpace();
            GUILayout.Label(logo);
            GUILayout.FlexibleSpace();
            GUILayout.EndHorizontal();
        }

        // Bloom settings
        showBloomSettings = EditorGUILayout.BeginFoldoutHeaderGroup(showBloomSettings, "Bloom Settings");
        if (showBloomSettings)
        {
            EditorGUI.indentLevel++;

            script.bloomMode = (HoyoToonPostProcess.BloomMode)EditorGUILayout.EnumPopup("Bloom Mode", script.bloomMode);
            script.bloomThreshold = EditorGUILayout.FloatField("Bloom Threshold", script.bloomThreshold);
            script.bloomIntensity = EditorGUILayout.FloatField("Bloom Intensity", script.bloomIntensity);
            script.bloomWeights = EditorGUILayout.Vector4Field("Bloom Weights", script.bloomWeights);
            script.bloomColor = EditorGUILayout.ColorField("Bloom Color", script.bloomColor);
            script.downsampleValue = EditorGUILayout.Slider("Downsample Value", script.downsampleValue, 0.1f, 1.0f);

            EditorGUI.indentLevel--;
        }
        EditorGUILayout.EndFoldoutHeaderGroup();

        // Color Grading settings
        showColorGrading = EditorGUILayout.BeginFoldoutHeaderGroup(showColorGrading, "Color Grading Settings");
        if (showColorGrading)
        {
            script.toneMode = (HoyoToonPostProcess.ToneMode)EditorGUILayout.EnumPopup("Tone Mode", script.toneMode);
            script.exposure = EditorGUILayout.FloatField("Exposure", script.exposure);
            script.contrast = EditorGUILayout.Slider("Contrast", script.contrast, 0.0f, 2.0f);
            script.saturation = EditorGUILayout.Slider("Saturation", script.saturation, 0.0f, 2.0f);
        }
        EditorGUILayout.EndFoldoutHeaderGroup();

        if (script.toneMode == HoyoToonPostProcess.ToneMode.StarRail)
        {
            // Tone Mapping settings
            showToneMapping = EditorGUILayout.BeginFoldoutHeaderGroup(showToneMapping, "Tone Mapping Settings");
            if (showToneMapping)
            {
                script.ACESParamA = EditorGUILayout.FloatField("ACES Param A", script.ACESParamA);
                script.ACESParamB = EditorGUILayout.FloatField("ACES Param B", script.ACESParamB);
                script.ACESParamC = EditorGUILayout.FloatField("ACES Param C", script.ACESParamC);
                script.ACESParamD = EditorGUILayout.FloatField("ACES Param D", script.ACESParamD);
                script.ACESParamE = EditorGUILayout.FloatField("ACES Param E", script.ACESParamE);
            }
            EditorGUILayout.EndFoldoutHeaderGroup();
        }
    }
}
#endif