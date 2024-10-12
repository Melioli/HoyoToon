#if UNITY_EDITOR
using UnityEngine;
using UnityEditor;
using UnityEditor.PackageManager;
using UnityEditor.PackageManager.Requests;
using System;
using System.IO;
using System.Linq;


namespace HoyoToon
{
    public class HoyoToonParseManager
    {
        public enum BodyType
        {
            GIBoy,
            GIGirl,
            GILady,
            GIMale,
            GILoli,
            HSRMaid,
            HSRKid,
            HSRLad,
            HSRMale,
            HSRLady,
            HSRGirl,
            HSRBoy,
            HSRMiss,
            HI3P1,
            Hi3P2,
            WuWa
        }
        public static BodyType currentBodyType;

        #region Parsing

        public static string[] GetAssetSelectionPaths()
        {
            return Selection.assetGUIDs.Select(AssetDatabase.GUIDToAssetPath).ToArray();
        }

        public static string GetPackagePath(string packageName)
        {
            ListRequest request = Client.List(true);
            while (!request.IsCompleted) { }

            if (request.Status == StatusCode.Success)
            {
                foreach (var package in request.Result)
                {
                    if (package.name == packageName)
                    {
                        return package.resolvedPath;
                    }
                }
            }
            else if (request.Status >= StatusCode.Failure)
            {
                HoyoToonLogs.ErrorDebug(request.Error.message);
            }

            return null;
        }

        public static void DetermineBodyType()
        {
            GameObject selectedGameObject = Selection.activeGameObject;
            string selectedAssetPath = "";

            if (selectedGameObject != null)
            {
                Mesh mesh = FindMeshInGameObject(selectedGameObject);
                if (mesh != null)
                {
                    selectedAssetPath = AssetDatabase.GetAssetPath(mesh);
                }
                else
                {
                    HoyoToonLogs.WarningDebug("No mesh found in the selected GameObject or its children.");
                    return;
                }
            }
            else
            {
                selectedAssetPath = AssetDatabase.GetAssetPath(Selection.activeObject);
            }

            if (string.IsNullOrEmpty(selectedAssetPath))
            {
                HoyoToonLogs.WarningDebug("No valid asset selected.");
                return;
            }

            string directoryPath = Path.GetDirectoryName(selectedAssetPath);
            if (Path.GetExtension(selectedAssetPath) == ".json")
            {
                directoryPath = Directory.GetParent(directoryPath).FullName;
            }

            string texturesPath = FindTexturesFolder(directoryPath);

            if (Directory.Exists(texturesPath))
            {
                DetermineBodyTypeFromTextures(texturesPath);
            }
            else
            {
                string validFolderNames = string.Join(", ", new[] { "Textures", "Texture", "Tex" });
                EditorUtility.DisplayDialog("Error", $"Textures folder path does not exist. Ensure your textures are in a folder named {validFolderNames}.", "OK");
                HoyoToonLogs.ErrorDebug("You need to have a Textures folder matching the valid names (e.g., 'Textures', 'Texture', 'Tex') and have all the textures inside of them.");
                currentBodyType = BodyType.WuWa;
            }

            HoyoToonLogs.LogDebug($"Current Body Type: {currentBodyType}");
        }

        private static Mesh FindMeshInGameObject(GameObject obj)
        {
            MeshFilter meshFilter = obj.GetComponent<MeshFilter>();
            if (meshFilter != null && meshFilter.sharedMesh != null)
            {
                return meshFilter.sharedMesh;
            }

            SkinnedMeshRenderer skinnedMeshRenderer = obj.GetComponent<SkinnedMeshRenderer>();
            if (skinnedMeshRenderer != null && skinnedMeshRenderer.sharedMesh != null)
            {
                return skinnedMeshRenderer.sharedMesh;
            }

            // If not found in the current GameObject, search in children
            foreach (Transform child in obj.transform)
            {
                Mesh childMesh = FindMeshInGameObject(child.gameObject);
                if (childMesh != null)
                {
                    return childMesh;
                }
            }

            return null;
        }

        private static string FindTexturesFolder(string startPath)
        {
            string[] validFolderNames = { "Textures", "Texture", "Tex" };

            // Search in the current directory and up to 3 levels up
            for (int i = 0; i < 4; i++)
            {
                foreach (string folderName in validFolderNames)
                {
                    string path = Path.Combine(startPath, folderName);
                    if (Directory.Exists(path))
                    {
                        return path;
                    }
                }
                startPath = Directory.GetParent(startPath)?.FullName;
                if (startPath == null) break;
            }

            return null;
        }

        private static void DetermineBodyTypeFromTextures(string texturesPath)
        {
            string[] textureFiles = Directory.GetFiles(texturesPath, "*.png");
            bool bodyTypeSet = false;

            foreach (string textureFile in textureFiles)
            {
                string textureName = Path.GetFileNameWithoutExtension(textureFile);

                if (!bodyTypeSet && textureName.ToLower().Contains("hair_mask".ToLower()))
                {
                    currentBodyType = BodyType.Hi3P2;
                    bodyTypeSet = true;
                    HoyoToonLogs.LogDebug($"Matched texture: {textureName} with BodyType.Hi3P2");
                }
                else if (!bodyTypeSet && textureName.ToLower().Contains("expressionmap".ToLower()))
                {
                    if (textureFile.Contains("Lady")) { currentBodyType = BodyType.HSRLady; bodyTypeSet = true; }
                    else if (textureName.Contains("Maid")) { currentBodyType = BodyType.HSRMaid; bodyTypeSet = true; }
                    else if (textureName.Contains("Girl")) { currentBodyType = BodyType.HSRGirl; bodyTypeSet = true; }
                    else if (textureName.Contains("Kid")) { currentBodyType = BodyType.HSRKid; bodyTypeSet = true; }
                    else if (textureName.Contains("Lad")) { currentBodyType = BodyType.HSRLad; bodyTypeSet = true; }
                    else if (textureName.Contains("Male")) { currentBodyType = BodyType.HSRMale; bodyTypeSet = true; }
                    else if (textureName.Contains("Boy")) { currentBodyType = BodyType.HSRBoy; bodyTypeSet = true; }
                    else if (textureName.Contains("Miss")) { currentBodyType = BodyType.HSRMiss; bodyTypeSet = true; }
                }
                else if (!bodyTypeSet && textureName.ToLower().Contains("lightmap".ToLower()))
                {
                    if (textureName.Contains("Boy")) { currentBodyType = BodyType.GIBoy; bodyTypeSet = true; }
                    else if (textureName.Contains("Girl")) { currentBodyType = BodyType.GIGirl; bodyTypeSet = true; }
                    else if (textureName.Contains("Lady")) { currentBodyType = BodyType.GILady; bodyTypeSet = true; }
                    else if (textureName.Contains("Male")) { currentBodyType = BodyType.GIMale; bodyTypeSet = true; }
                    else if (textureName.Contains("Loli")) { currentBodyType = BodyType.GILoli; bodyTypeSet = true; }
                    else if (!textureName.ToLower().Contains("boy") && !textureName.ToLower().Contains("girl")
                    && !textureName.ToLower().Contains("lady") && !textureName.ToLower().Contains("male") && !textureName.ToLower().Contains("loli"))
                    {
                        currentBodyType = BodyType.HI3P1;
                        bodyTypeSet = true;
                        HoyoToonLogs.LogDebug($"Matched texture: {textureName} with BodyType.Hi3P1");
                    }
                }
            }
            if (!bodyTypeSet)
            {
                currentBodyType = BodyType.WuWa;
                HoyoToonLogs.LogDebug($"No specific match found. Setting BodyType to WuWa");
            }
        }

        #endregion
    }
}
#endif
