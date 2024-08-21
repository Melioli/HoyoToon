using UnityEditor;
using UnityEngine;

namespace HoyoToon
{
    public class HoyoToonSceneManager
    {
        [MenuItem("GameObject/HoyoToon/Scene/Add AvatarLight", priority = 0)]
        private static void AddAvatarLight()
        {
            var selectedObject = Selection.activeGameObject;
            if (selectedObject == null)
            {
                EditorUtility.DisplayDialog("Error", "No Model selected. Please select a Model to add AvatarLight.", "OK");
                HoyoToonLogs.WarningDebug("No Model selected. Please select a Model to add AvatarLight.");
                return;
            }

            var avatarLightPrefab = Resources.Load<GameObject>("Prefabs/AvatarLight");
            if (avatarLightPrefab == null)
            {
                EditorUtility.DisplayDialog("Error", "AvatarLight prefab not found in Resources/Prefabs.", "OK");
                HoyoToonLogs.WarningDebug("AvatarLight prefab not found in Resources/Prefabs.");
                return;
            }

            var avatarLight = UnityEngine.Object.Instantiate(avatarLightPrefab, selectedObject.transform);
            avatarLight.name = "AvatarLight";
            avatarLight.transform.SetPositionAndRotation(Vector3.zero, Quaternion.identity);
            avatarLight.transform.localScale = Vector3.one;

            Undo.RegisterCreatedObjectUndo(avatarLight, "Add AvatarLight");
            Selection.activeGameObject = avatarLight;
            EditorGUIUtility.PingObject(avatarLight);
        }

        [MenuItem("GameObject/HoyoToon/Scene/Add Post Processing", priority = 1)]
        private static void AddPostProcessing()
        {
            Camera[] cameras = UnityEngine.Object.FindObjectsOfType<Camera>();
            if (cameras.Length > 1)
            {
                EditorUtility.DisplayDialog("Multiple Cameras Detected", "Multiple cameras detected in the scene. Post-processing will be added to the first camera: " + cameras[0].name, "OK");
                AttachPostProcessing(cameras[0]);
            }
            else if (cameras.Length == 1)
            {
                AttachPostProcessing(cameras[0]);
            }
            else
            {
                EditorUtility.DisplayDialog("Error", "No cameras found in the scene. Please make sure you have at least one camera in your scene.", "OK");
                HoyoToonLogs.ErrorDebug("No cameras found in the scene. Please make sure you have at least one camera in your scene.");
            }
        }

        private static void AttachPostProcessing(Camera camera)
        {
            HoyoToonPostProcess postProcessing = camera.gameObject.GetComponent<HoyoToonPostProcess>();
            if (postProcessing == null)
            {
                postProcessing = camera.gameObject.AddComponent<HoyoToonPostProcess>();
                Undo.RegisterCreatedObjectUndo(postProcessing, "Add PostProcessing");
                Selection.activeGameObject = postProcessing.gameObject;
                EditorGUIUtility.PingObject(postProcessing);
            }
            else
            {
                EditorUtility.DisplayDialog("Error", $"HoyoToon Post Processing is already attached to the selected camera: {camera.name}", "OK");
                HoyoToonLogs.ErrorDebug("HoyoToon Post Processing is already attached to the selected camera.");
            }
        }

        public static GameObject AddSelectedObjectToScene()
        {
            GameObject selectedObject = Selection.activeObject as GameObject;
            if (selectedObject != null)
            {
                GameObject instance = GameObject.Instantiate(selectedObject);
                instance.name = selectedObject.name;
                Undo.RegisterCreatedObjectUndo(instance, "Add Selected Object to Scene");
                return instance;
            }
            else
            {
                EditorUtility.DisplayDialog("Error", "No valid model selected. Please select a model to add to the scene.", "OK");
                HoyoToonLogs.ErrorDebug("No valid model selected. Please select a model to add to the scene.");
                return null;
            }
        }
    }
}