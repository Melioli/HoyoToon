#if UNITY_EDITOR
using UnityEngine;
using UnityEditor;
using UnityEditor.PackageManager;
using UnityEditor.PackageManager.Requests;
using System;
using System.IO;
using System.Linq;
using Newtonsoft.Json.Linq;


namespace HoyoToon
{
    public static class HoyoToonParseManager
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

            string materialsPath = FindMaterialsFolder(directoryPath);

            if (Directory.Exists(materialsPath))
            {
                DetermineBodyTypeFromJson(materialsPath);
            }
            else
            {
                string validFolderNames = string.Join(", ", new[] { "Materials", "Material", "Mat" });
                EditorUtility.DisplayDialog("Error", $"Materials folder path does not exist. Ensure your materials are in a folder named {validFolderNames}.", "OK");
                HoyoToonLogs.ErrorDebug("You need to have a Materials folder matching the valid names (e.g., 'Materials', 'Material', 'Mat') and have all the materials inside of them.");
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


        private static string FindMaterialsFolder(string startPath)
        {
            string[] validFolderNames = { "Materials", "Material", "Mat" };

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

        public static void DetermineBodyTypeFromJson(string jsonPath)
        {
            HoyoToonLogs.LogDebug($"Searching for JSON files in: {jsonPath}");
            string[] jsonFiles = Directory.GetFiles(jsonPath, "*Face.json");
            HoyoToonLogs.LogDebug($"Found {jsonFiles.Length} JSON files");

            bool bodyTypeSet = false;

            foreach (string jsonFile in jsonFiles)
            {
                HoyoToonLogs.LogDebug($"Processing file: {jsonFile}");
                string jsonContent = File.ReadAllText(jsonFile);
                JObject jsonObject = JObject.Parse(jsonContent);

                if (TryGetTextureNameFromJson(jsonObject, "_FaceExpression", out string expressionMapName))
                {
                    HoyoToonLogs.LogDebug($"Found _FaceExpression: {expressionMapName}");
                    SetHSRBodyType(expressionMapName, ref bodyTypeSet);
                }
                else if (TryGetTextureNameFromJson(jsonObject, "_FaceMapTex", out string faceMapName))
                {
                    HoyoToonLogs.LogDebug($"Found _FaceMapTex: {faceMapName}");
                    SetGIBodyType(faceMapName, ref bodyTypeSet);
                }
                else if (jsonObject["m_SavedProperties"]?["m_Floats"]?["_SPCubeMapIntensity"] != null)
                {
                    HoyoToonLogs.LogDebug("Found _SPCubeMapIntensity");
                    currentBodyType = BodyType.HI3P1;
                    bodyTypeSet = true;
                }
                else if (TryGetTextureNameFromJson(jsonObject, "_MetalMapGrp", out _) || TryGetTextureNameFromJson(jsonObject, "_MicsGrp", out _))
                {
                    HoyoToonLogs.LogDebug("Found _MetalMapGrp or _MicsGrp");
                    currentBodyType = BodyType.Hi3P2;
                    bodyTypeSet = true;
                }
                else
                {
                    HoyoToonLogs.LogDebug("No matching json properties found in this file");
                }

                if (bodyTypeSet) break;
            }

            if (!bodyTypeSet)
            {
                currentBodyType = BodyType.WuWa;
                HoyoToonLogs.LogDebug($"No specific match found. Setting BodyType to WuWa");
            }

            HoyoToonLogs.LogDebug($"Determined BodyType: {currentBodyType}");
        }

        private static bool TryGetTextureNameFromJson(JObject jsonObject, string key, out string textureName)
        {
            textureName = null;
            var texEnvs = jsonObject["m_SavedProperties"]?["m_TexEnvs"];
            if (texEnvs == null)
            {
                HoyoToonLogs.LogDebug("m_SavedProperties or m_TexEnvs not found in JSON");
                return false;
            }

            foreach (var prop in texEnvs.Children<JProperty>())
            {
                if (prop.Name == key)
                {
                    textureName = prop.Value["m_Texture"]?["Name"]?.ToString();
                    if (!string.IsNullOrEmpty(textureName))
                    {
                        return true;
                    }
                }
            }

            HoyoToonLogs.LogDebug($"Texture name not found for key '{key}'");
            return false;
        }

        private static void SetHSRBodyType(string expressionMapName, ref bool bodyTypeSet)
        {
            if (expressionMapName.Contains("Maid")) { currentBodyType = BodyType.HSRMaid; bodyTypeSet = true; }
            else if (expressionMapName.Contains("Lady")) { currentBodyType = BodyType.HSRLady; bodyTypeSet = true; }
            else if (expressionMapName.Contains("Girl")) { currentBodyType = BodyType.HSRGirl; bodyTypeSet = true; }
            else if (expressionMapName.Contains("Kid")) { currentBodyType = BodyType.HSRKid; bodyTypeSet = true; }
            else if (expressionMapName.Contains("Lad")) { currentBodyType = BodyType.HSRLad; bodyTypeSet = true; }
            else if (expressionMapName.Contains("Male")) { currentBodyType = BodyType.HSRMale; bodyTypeSet = true; }
            else if (expressionMapName.Contains("Boy")) { currentBodyType = BodyType.HSRBoy; bodyTypeSet = true; }
            else if (expressionMapName.Contains("Miss")) { currentBodyType = BodyType.HSRMiss; bodyTypeSet = true; }
        }

        private static void SetGIBodyType(string faceMapName, ref bool bodyTypeSet)
        {
            if (faceMapName.Contains("Boy")) { currentBodyType = BodyType.GIBoy; bodyTypeSet = true; }
            else if (faceMapName.Contains("Girl")) { currentBodyType = BodyType.GIGirl; bodyTypeSet = true; }
            else if (faceMapName.Contains("Lady")) { currentBodyType = BodyType.GILady; bodyTypeSet = true; }
            else if (faceMapName.Contains("Male")) { currentBodyType = BodyType.GIMale; bodyTypeSet = true; }
            else if (faceMapName.Contains("Loli")) { currentBodyType = BodyType.GILoli; bodyTypeSet = true; }
            else
            {
                currentBodyType = BodyType.HI3P1;
                bodyTypeSet = true;
                HoyoToonLogs.LogDebug($"Matched texture: {faceMapName} with BodyType.Hi3P1");
            }
        }

        #endregion
    }
}
#endif
