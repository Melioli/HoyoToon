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
            string selectedAssetPath = AssetDatabase.GetAssetPath(Selection.activeObject);

            if (Selection.activeObject is GameObject gameObject)
            {
                MeshFilter[] meshFilters = gameObject.GetComponentsInChildren<MeshFilter>();
                SkinnedMeshRenderer[] skinnedMeshRenderers = gameObject.GetComponentsInChildren<SkinnedMeshRenderer>();

                Mesh mesh = null;

                if (meshFilters.Length > 0)
                {
                    mesh = meshFilters[0].sharedMesh;
                }
                else if (skinnedMeshRenderers.Length > 0)
                {
                    mesh = skinnedMeshRenderers[0].sharedMesh;
                }

                if (mesh == null)
                {
                    throw new MissingComponentException("The GameObject or its children must have a MeshFilter or SkinnedMeshRenderer component.");
                }

                selectedAssetPath = AssetDatabase.GetAssetPath(mesh);
            }
            else
            {
                selectedAssetPath = AssetDatabase.GetAssetPath(Selection.activeObject);
            }

            string directoryPath = Path.GetDirectoryName(selectedAssetPath);
            if (Path.GetExtension(selectedAssetPath) == ".json")
            {
                directoryPath = Directory.GetParent(directoryPath).FullName;
            }
            string texturesPath = Directory.GetDirectories(directoryPath, "Textures", SearchOption.AllDirectories)
                .FirstOrDefault(path => path.Equals("Textures", StringComparison.OrdinalIgnoreCase)
                           || path.Contains("Texture", StringComparison.OrdinalIgnoreCase)
                           || path.Contains("Tex", StringComparison.OrdinalIgnoreCase));

            if (Directory.Exists(texturesPath))
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
            else
            {
                string validFolderNames = string.Join(", ", new[] { "Textures", "Texture", "Tex" });
                EditorUtility.DisplayDialog("Error", $"Textures folder path does not exist. Ensure your textures are in a folder named {validFolderNames}.", "OK");
                HoyoToonLogs.ErrorDebug("You need to have a Textures folder matching the valid names (e.g., 'Textures', 'Texture', 'Tex') and have all the textures inside of them.");
            }
            HoyoToonLogs.LogDebug($"Current Body Type: {currentBodyType}");
        }

        #endregion
    }
}
#endif