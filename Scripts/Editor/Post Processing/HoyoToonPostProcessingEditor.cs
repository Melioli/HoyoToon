using UnityEngine;
using UnityEditor;

namespace HoyoToon
{
    [CustomEditor(typeof(HoyoToonPostProcessing))]
    public class HoyoToonPostProcessingEditor : Editor
    {
        private HoyoToonPostProcessing _target;
        private SerializedProperty _gameType;
        private SerializedProperty _Layer;
        private SerializedProperty _bloomColor;
        private SerializedProperty _bloomThreshold;
        private SerializedProperty _bloomIntensity;
        private SerializedProperty _bloomScalar;
        private SerializedProperty _bloomRadius;
        private SerializedProperty _blurLevelWeights;
        private SerializedProperty _starRailLUT;
        private SerializedProperty _wuwaLUT;
        private SerializedProperty _lut2DTexParam;
        private SerializedProperty _exposure;
        private SerializedProperty _sharpening;
        private SerializedProperty _vignetteColor;
        private SerializedProperty _vignetteParams;
        private SerializedProperty _useDepthBuffer;

        private bool _showBloomSettings = true;
        private bool _showBlurLayerWeights = true;
        private bool _showTonemappingSettings = true;
        private bool _showLUTSettings = true;
        private bool _showSharpeningSettings = true;
        private bool _showVignetteSettings = true;

        private void OnEnable()
        {
            _target = (HoyoToonPostProcessing)target; 
            FindProperties();
        }

        private void FindProperties()
        {
            _gameType = serializedObject.FindProperty("gameType");
            _Layer = serializedObject.FindProperty("Layer");
            _bloomColor = serializedObject.FindProperty("bloomColor");
            _bloomThreshold = serializedObject.FindProperty("bloomThreshold");
            _bloomIntensity = serializedObject.FindProperty("bloomIntensity");
            _bloomScalar = serializedObject.FindProperty("bloomScalar");
            _bloomRadius = serializedObject.FindProperty("bloomRadius");
            _blurLevelWeights = serializedObject.FindProperty("blurLevelWeights");
            _starRailLUT = serializedObject.FindProperty("_starRailLUT");
            _wuwaLUT = serializedObject.FindProperty("_wuwaLUT");
            _lut2DTexParam = serializedObject.FindProperty("lut2DTexParam");
            _exposure = serializedObject.FindProperty("exposure");
            _sharpening = serializedObject.FindProperty("sharpening");
            _vignetteColor = serializedObject.FindProperty("vignetteColor");
            _vignetteParams = serializedObject.FindProperty("vignetteParams");
            _useDepthBuffer = serializedObject.FindProperty("useDepthBuffer");
        }

        public override void OnInspectorGUI()
        {
            serializedObject.Update();

            DrawLogo();

            EditorGUILayout.Space(10);
            EditorGUILayout.Space(5);

            EditorGUILayout.PropertyField(_Layer);
            DrawGameTypeSelector();

            if (!((HoyoToonPostProcessing)target).IsGameTypeOff())
            {
                EditorGUILayout.Space(10);

                DrawBloomSettings();
                DrawTonemappingSettings();
                DrawSharpeningSettings();
                DrawVignetteSettings();
            }

            serializedObject.ApplyModifiedProperties();
        }

        private void DrawGameTypeSelector()
        {
            EditorGUILayout.PropertyField(_gameType, new GUIContent("Game Type"));
        }

        private void DrawBloomSettings()
        {
            _showBloomSettings = EditorGUILayout.Foldout(_showBloomSettings, "Bloom Settings", true);
            if (_showBloomSettings)
            {
                EditorGUI.indentLevel++;
                if (!((HoyoToonPostProcessing)target).IsGameTypeGenshin())
                {
                    EditorGUILayout.PropertyField(_bloomColor, new GUIContent("Color"));
                }
                EditorGUILayout.PropertyField(_bloomThreshold, new GUIContent("Threshold"));
                EditorGUILayout.PropertyField(_bloomIntensity, new GUIContent("Intensity"));
                EditorGUILayout.PropertyField(_bloomScalar, new GUIContent("Scalar"));
                EditorGUILayout.PropertyField(_bloomRadius, new GUIContent("Radius"));

                _showBlurLayerWeights = EditorGUILayout.Foldout(_showBlurLayerWeights, "Blur Layer Weights", true);
                if (_showBlurLayerWeights)
                {
                    EditorGUI.indentLevel++;
                    EditorGUILayout.PropertyField(_blurLevelWeights.FindPropertyRelative("x"), new GUIContent("Base"));
                    EditorGUILayout.PropertyField(_blurLevelWeights.FindPropertyRelative("y"), new GUIContent("Layer 1"));
                    EditorGUILayout.PropertyField(_blurLevelWeights.FindPropertyRelative("z"), new GUIContent("Layer 2"));
                    EditorGUILayout.PropertyField(_blurLevelWeights.FindPropertyRelative("w"), new GUIContent("Layer 3"));
                    EditorGUI.indentLevel--;
                }
                EditorGUI.indentLevel--;
            }
        }

        private void DrawTonemappingSettings()
        {
            _showTonemappingSettings = EditorGUILayout.Foldout(_showTonemappingSettings, "Tonemapping Settings", true);
            if (_showTonemappingSettings)
            {
                EditorGUI.indentLevel++;
                
                EditorGUILayout.PropertyField(_exposure, new GUIContent("Exposure"));
                
                if (!((HoyoToonPostProcessing)target).IsGameTypeGenshin())
                {
                    HoyoToonPostProcessing postProcessing = (HoyoToonPostProcessing)target;

                    EditorGUI.indentLevel++;
                    _showLUTSettings = EditorGUILayout.Foldout(_showLUTSettings, "LUT 2D Parameters", true);  
                    if (_showLUTSettings)
                    {
                        EditorGUI.indentLevel++;
                        EditorGUILayout.PropertyField(_lut2DTexParam.FindPropertyRelative("x"), new GUIContent("Red Range"));
                        EditorGUILayout.PropertyField(_lut2DTexParam.FindPropertyRelative("y"), new GUIContent("Blue Range"));
                        EditorGUILayout.PropertyField(_lut2DTexParam.FindPropertyRelative("z"), new GUIContent("Tile Count"));
                        EditorGUI.indentLevel--;
                    }
                    EditorGUI.indentLevel--;

                    if (postProcessing.IsGameTypeStarRail() || postProcessing.IsGameTypeWutheringWaves())
                    {
                        EditorGUILayout.PropertyField(
                            postProcessing.IsGameTypeStarRail() ? _starRailLUT : _wuwaLUT, 
                            new GUIContent("LUT Texture")
                        );
                    }
                }

                EditorGUI.indentLevel--;
            }
        }

        private void DrawSharpeningSettings()
        {
            _showSharpeningSettings = EditorGUILayout.Foldout(_showSharpeningSettings, "Sharpening Settings", true);
            if (_showSharpeningSettings)
            {
                EditorGUI.indentLevel++;
                EditorGUILayout.PropertyField(_sharpening);
                EditorGUI.indentLevel--;
            }
        }

        private void DrawVignetteSettings()
        {
            _showVignetteSettings = EditorGUILayout.Foldout(_showVignetteSettings, "Vignette Settings", true);
            if (_showVignetteSettings)
            {
                EditorGUI.indentLevel++;
                EditorGUILayout.PropertyField(_vignetteColor);
                EditorGUILayout.PropertyField(_vignetteParams.FindPropertyRelative("x"), new GUIContent("Vignette Center X"));
                EditorGUILayout.PropertyField(_vignetteParams.FindPropertyRelative("y"), new GUIContent("Vignette Center Y"));
                EditorGUILayout.PropertyField(_vignetteParams.FindPropertyRelative("z"), new GUIContent("Vignette Intensity"));
                EditorGUILayout.PropertyField(_vignetteParams.FindPropertyRelative("w"), new GUIContent("Vignette Smoothness"));
                EditorGUI.indentLevel--;
            }
        }

        private void DrawLogo()
        {
            // Load and draw logo
            Rect bgRect = GUILayoutUtility.GetRect(GUIContent.none, GUIStyle.none, GUILayout.ExpandWidth(true), GUILayout.Height(145.0f));
            bgRect.x = 0;
            bgRect.width = EditorGUIUtility.currentViewWidth;
            Rect logoRect = new Rect(bgRect.width / 2 - 375f, bgRect.height / 2 - 65f, 750f, 130f);

            string bgPathProperty = "UI/background";
            string logoPathProperty = "UI/postlogo";

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
        }
    }
}