#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;

namespace HoyoToon
{
    public class HoyoToonAssetBuilder
    {
        [MenuItem("Assets/HoyoToon/Build AssetBundle")]
        static void BuildAssetBundleFromSelectedPrefab()
        {
            // Get the selected prefab
            Object selectedObject = Selection.activeObject;
            if (selectedObject == null || !(selectedObject is GameObject))
            {
                Debug.LogError("Please select a prefab to build an AssetBundle.");
                return;
            }

            // Set the output directory
            string outputPath = "Assets/AssetBundles";

            // Ensure the output directory exists
            if (!System.IO.Directory.Exists(outputPath))
            {
                System.IO.Directory.CreateDirectory(outputPath);
            }

            // Get the path of the selected prefab
            string assetPath = AssetDatabase.GetAssetPath(selectedObject);

            // Assign the selected prefab to a new AssetBundle
            string assetBundleName = selectedObject.name.ToLower() + ".bundle";
            AssetImporter.GetAtPath(assetPath).assetBundleName = assetBundleName;

            // Create an array of AssetBundleBuild
            AssetBundleBuild[] buildMap = new AssetBundleBuild[1];
            buildMap[0] = new AssetBundleBuild
            {
                assetBundleName = assetBundleName,
                assetNames = new[] { assetPath }
            };

            // Build the AssetBundle
            AssetBundleManifest manifest = BuildPipeline.BuildAssetBundles(outputPath, buildMap, BuildAssetBundleOptions.None, BuildTarget.StandaloneWindows);

            // Check if the build was successful
            if (manifest == null)
            {
                Debug.LogError("AssetBundle build failed.");
                return;
            }

            // Clear the AssetBundle assignment after building
            AssetImporter.GetAtPath(assetPath).assetBundleName = null;

            // Refresh the AssetDatabase to ensure the AssetBundle is updated in Unity
            AssetDatabase.Refresh();

            Debug.Log("AssetBundle built successfully at: " + outputPath);
        }
    }
}
#endif