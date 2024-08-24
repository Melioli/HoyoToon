using UnityEditor;
using UnityEngine;

namespace HoyoToon
{
    [CustomEditor(typeof(HoyoToonPostProcess))]
    public class HoyoToonPostProcessEditor : Editor
    {
        private bool ShowPresets = true;
        private bool showBloomSettings = true;
        private bool showColorGrading = true;
        private bool showToneMapping = true;
        public static string bgPathProperty = "UI/background";
        public static string logoPathProperty = "UI/postlogo";


        public override void OnInspectorGUI()
        {
            HoyoToonPostProcess script = (HoyoToonPostProcess)target;

            // Record the target object before making changes
            Undo.RecordObject(script, "Modify HoyoToonPostProcess");

            // Load and draw logo;
            Rect bgRect = GUILayoutUtility.GetRect(GUIContent.none, GUIStyle.none, GUILayout.ExpandWidth(true), GUILayout.Height(145.0f));
            bgRect.x = 0;
            bgRect.width = EditorGUIUtility.currentViewWidth;
            Rect logoRect = new Rect(bgRect.width / 2 - 375f, bgRect.height / 2 - 65f, 750f, 130f);

            if (!string.IsNullOrEmpty(bgPathProperty))
            {
                Texture2D bg = Resources.Load<Texture2D>(bgPathProperty);

                if (bg != null)
                {
                    GUI.DrawTexture(bgRect, bg, ScaleMode.ScaleAndCrop);
                }
            }

            if (!string.IsNullOrEmpty(logoPathProperty))
            {
                Texture2D logo = Resources.Load<Texture2D>(logoPathProperty);

                if (logo != null)
                {
                    GUI.DrawTexture(logoRect, logo, ScaleMode.ScaleToFit);
                }
            }

            // Preset settings
            ShowPresets = EditorGUILayout.BeginFoldoutHeaderGroup(ShowPresets, "Preset Settings");
            if (ShowPresets)
            {
                EditorGUI.indentLevel++;

                script.gameMode = (HoyoToonPostProcess.GameMode)EditorGUILayout.EnumPopup("Game Mode", script.gameMode);
                if (script.gameMode == HoyoToonPostProcess.GameMode.Genshin)
                {
                    script.bloomMode = HoyoToonPostProcess.BloomMode.Color;
                    script.bloomColor = new Color(1.0f, 1.0f, 1.0f, 1.0f);
                    script.exposure = 1.05f;
                    script.toneMode = HoyoToonPostProcess.ToneMode.GenshinCustom;
                }
                else if (script.gameMode == HoyoToonPostProcess.GameMode.StarRail)
                {
                    script.bloomMode = HoyoToonPostProcess.BloomMode.Brightness;
                    script.bloomColor = new Color(1.0f, 0.5801887f, 0.5801887f, 0f);
                    script.toneMode = HoyoToonPostProcess.ToneMode.StarRail;
                    script.exposure = 1.05f;
                    script.ACESParamA = 2.80f;
                    script.ACESParamB = 0.40f;
                    script.ACESParamC = 2.10f;
                    script.ACESParamD = 0.5f;
                    script.ACESParamE = 1.5f;
                }
                else if (script.gameMode == HoyoToonPostProcess.GameMode.WutheringWaves)
                {
                    script.bloomMode = HoyoToonPostProcess.BloomMode.Color;
                    script.bloomColor = new Color(1.0f, 0.5801887f, 0.5801887f, 0f);
                    script.toneMode = HoyoToonPostProcess.ToneMode.StarRail;
                    script.exposure = 1.3f;
                    script.ACESParamA = 2.80f;
                    script.ACESParamB = 0.50f;
                    script.ACESParamC = 2.50f;
                    script.ACESParamD = 0.5f;
                    script.ACESParamE = 1.5f;
                }
                else if (script.gameMode == HoyoToonPostProcess.GameMode.Custom)

                    EditorGUI.indentLevel++;
                EditorGUILayout.EndFoldoutHeaderGroup();
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
                script.blurSamples = EditorGUILayout.FloatField("Blur Samples", script.blurSamples);
                script.blurWeight = EditorGUILayout.FloatField("Blur Weight", script.blurWeight);
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
}