using UnityEditor;
using UnityEngine;

namespace HoyoToon
{
    public class HoyoToonManager
    {
        #region Quick Access Buttons

        [MenuItem("Assets/HoyoToon/Full Setup", priority = 0)]
        private static void FullSetup()
        {
            HoyoToonMaterialManager.GenerateMaterialsFromJson();
            SetupFBX();
            GameObject selectedObject = HoyoToonSceneManager.AddSelectedObjectToScene();
            if (selectedObject != null)
            {
                HoyoToonMeshManager.GenTangents(selectedObject);
            }

        }

        [MenuItem("Assets/HoyoToon/Mesh/Setup FBX", priority = 10)]
        private static void SetupFBX()
        {
            HoyoToonMeshManager.SetFBXImportSettings(HoyoToonParseManager.GetAssetSelectionPaths());
        }

        [MenuItem("GameObject/HoyoToon/Mesh/Generate Tangents", priority = 21)]
        private static void GenerateTangents()
        {
            GameObject selectedObject = Selection.activeGameObject;
            if (selectedObject == null)
            {
                EditorUtility.DisplayDialog("Error", "No Model selected. Please select a Model to generate tangents.", "OK");
                HoyoToonLogs.WarningDebug("No Model selected. Please select a Model to generate tangents.");
                return;
            }

            HoyoToonMeshManager.GenTangents(selectedObject);
        }

        [MenuItem("HoyoToon/Socials/Twitter", priority = 21)]
        static void MenuHoyoToonTwitter()
        {
            Application.OpenURL("https://www.twitter.com/Meliodas7DL");
        }

        [MenuItem("HoyoToon/Socials/Discord", priority = 20)]
        static void MenuHoyoToonDiscord()
        {
            Application.OpenURL("https://discord.gg/meliverse");
        }

        // [MenuItem("HoyoToon/Resources/Documentation", priority = 10)]
        // private static void OpenDocumentation()
        // {
        //     Application.OpenURL("https://docs.hoyotoon.com");
        // }

        [MenuItem("HoyoToon/Resources/Asset Repo", priority = 11)]
        private static void OpenAssetRepo()
        {
            Application.OpenURL("https://github.com/Melioli/HoyoToon-Assets");
        }

        #endregion
    }
}