using UnityEditor;
using UnityEngine;
using System;
using System.Collections.Generic;
using Newtonsoft.Json.Linq;
using System.IO;
using System.Linq;
using Newtonsoft.Json;



namespace HoyoToon
{
    public class HoyoToonMaterialManager
    {
        #region Constants
        public static readonly string HSRShader = HoyoToonDataManager.HSRShader;
        public static readonly string GIShader = HoyoToonDataManager.GIShader;
        public static readonly string Hi3Shader = HoyoToonDataManager.Hi3Shader;
        public static readonly string Hi3P2Shader = HoyoToonDataManager.Hi3P2Shader;
        public static readonly string WuWaShader = HoyoToonDataManager.WuWaShader;

        #endregion


        #region Material Generation

        [MenuItem("Assets/HoyoToon/Materials/Generate Materials", priority = 20)]
        public static void GenerateMaterialsFromJson()
        {
            HoyoToonParseManager.DetermineBodyType();
            var textureCache = new Dictionary<string, Texture>();
            UnityEngine.Object[] selectedObjects = Selection.objects;
            List<string> loadedTexturePaths = new List<string>();

            foreach (var selectedObject in selectedObjects)
            {
                string selectedPath = AssetDatabase.GetAssetPath(selectedObject);

                if (Path.GetExtension(selectedPath) == ".json")
                {
                    ProcessJsonFile(selectedPath, textureCache, loadedTexturePaths);
                }
                else
                {
                    string directoryName = Path.GetDirectoryName(selectedPath);
                    string materialsFolderPath = new[] { "Materials", "Material", "Mat" }
                        .Select(folder => Path.Combine(directoryName, folder))
                        .FirstOrDefault(path => Directory.Exists(path) && Directory.GetFileSystemEntries(path).Any());

                    if (materialsFolderPath != null)
                    {
                        string[] jsonFiles = Directory.GetFiles(materialsFolderPath, "*.json");
                        foreach (string jsonFile in jsonFiles)
                        {
                            ProcessJsonFile(jsonFile, textureCache, loadedTexturePaths);
                        }
                    }
                    else
                    {
                        string validFolderNames = string.Join(", ", new[] { "Materials", "Material", "Mat" });
                        EditorUtility.DisplayDialog("Error", $"Materials folder path does not exist. Ensure your materials are in a folder named {validFolderNames}.", "OK");
                        HoyoToonLogs.ErrorDebug("Materials folder path does not exist. Ensure your materials are in a folder named 'Materials'.");
                    }
                }
            }

            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
        }

        private static void ProcessJsonFile(string jsonFile, Dictionary<string, Texture> textureCache, List<string> loadedTexturePaths)
        {
            TextAsset jsonTextAsset = AssetDatabase.LoadAssetAtPath<TextAsset>(jsonFile);
            string jsonContent = jsonTextAsset.text;
            JObject jsonObject = JObject.Parse(jsonContent);
            string jsonFileName = Path.GetFileNameWithoutExtension(jsonFile);

            bool isUnrealEngine = jsonObject["Parameters"] != null;
            bool isUnity = jsonObject["m_SavedProperties"] != null;

            var shaderKeywords = HoyoToonDataManager.Data.ShaderKeywords;
            var shaderPaths = HoyoToonDataManager.Data.Shaders;

            Dictionary<string, string> shaderKeys = new Dictionary<string, string>();
            foreach (var shader in shaderKeywords)
            {
                string shaderName = shader.Key;
                foreach (var keyword in shader.Value)
                {
                    shaderKeys[keyword] = shaderName;
                }
            }

            Shader shaderToApply = null;

            JToken shaderToken = jsonObject["m_Shader"];
            if (shaderToken != null && shaderToken["Name"] != null && !string.IsNullOrEmpty(shaderToken["Name"].Value<string>()))
            {
                shaderToApply = Shader.Find(shaderToken["Name"].Value<string>());
                HoyoToonLogs.LogDebug($"Found shader '{shaderToken["Name"].Value<string>()}' in JSON");
            }

            if (shaderToApply == null)
            {
                foreach (var shaderKey in shaderKeys)
                {
                    bool keywordFound = false;

                    // Hoyoverse Shaders
                    if (isUnity)
                    {
                        JToken texEnvsToken = jsonObject["m_SavedProperties"]?["m_TexEnvs"];
                        JToken floatsToken = jsonObject["m_SavedProperties"]?["m_Floats"];

                        bool texEnvsContainsKey = texEnvsToken != null && ContainsKey(texEnvsToken, shaderKey.Key);
                        bool floatsContainsKey = floatsToken != null && ContainsKey(floatsToken, shaderKey.Key);

                        if (texEnvsContainsKey || floatsContainsKey)
                        {
                            keywordFound = true;
                            HoyoToonLogs.LogDebug($"Keyword '{shaderKey.Key}' found in TexEnvs or Floats");

                            if (shaderKey.Value == "Hi3Shader")
                            {
                                bool isPart2Shader = false;
                                HoyoToonLogs.LogDebug("Checking Hi3P2Shader keywords...");
                                foreach (var hi3P2Keyword in shaderKeywords["Hi3P2Shader"])
                                {
                                    HoyoToonLogs.LogDebug($"Checking keyword: {hi3P2Keyword}");
                                    if ((texEnvsToken != null && ContainsKey(texEnvsToken, hi3P2Keyword)) ||
                                        (floatsToken != null && ContainsKey(floatsToken, hi3P2Keyword)))
                                    {
                                        isPart2Shader = true;
                                        HoyoToonLogs.LogDebug($"Part2 keyword '{hi3P2Keyword}' found in TexEnvs or Floats");
                                        break;
                                    }
                                }

                                string shaderKeyToUse = isPart2Shader ? "Hi3P2Shader" : "Hi3Shader";
                                HoyoToonLogs.LogDebug($"Shader key to use: {shaderKeyToUse}");
                                shaderToApply = Shader.Find(shaderPaths[shaderKeyToUse][0]);
                                HoyoToonLogs.LogDebug($"Applying shader '{shaderPaths[shaderKeyToUse][0]}' based on Hoyoverse keyword '{shaderKey.Key}'");
                                HoyoToonLogs.LogDebug($"Shader override: {(isPart2Shader ? "True" : "False")}");
                            }
                            else
                            {
                                shaderToApply = Shader.Find(shaderPaths[shaderKey.Value][0]);
                                HoyoToonLogs.LogDebug($"Applying shader '{shaderPaths[shaderKey.Value][0]}' based on Hoyoverse keyword '{shaderKey.Key}'");
                                HoyoToonLogs.LogDebug("Shader override: False");
                            }
                        }
                    }

                    // KuroGames Shaders
                    if (isUnrealEngine && !keywordFound)
                    {
                        JToken texturesToken = jsonObject["Textures"];
                        JToken scalarsToken = jsonObject["Parameters"]?["Scalars"];
                        JToken switchesToken = jsonObject["Parameters"]?["Switches"];
                        JToken parametersToken = jsonObject["Parameters"];

                        bool texturesContainsKey = texturesToken != null && ContainsKey(texturesToken, shaderKey.Key);
                        bool scalarsContainsKey = scalarsToken != null && ContainsKey(scalarsToken, shaderKey.Key);
                        bool switchesContainsKey = switchesToken != null && ContainsKey(switchesToken, shaderKey.Key);
                        bool parametersContainsKey = parametersToken != null && ContainsKey(parametersToken, shaderKey.Key);

                        if (texturesContainsKey || scalarsContainsKey || switchesContainsKey || parametersContainsKey)
                        {
                            shaderToApply = Shader.Find(shaderPaths[shaderKey.Value][0]);
                            HoyoToonLogs.LogDebug($"Applying shader '{shaderPaths[shaderKey.Value][0]}' based on KuroGames keyword '{shaderKey.Key}'");
                            break;
                        }
                    }

                    if (shaderToApply != null)
                    {
                        break;
                    }
                }
            }

            if (shaderToApply != null)
            {
                HoyoToonLogs.LogDebug($"Final shader to apply: {shaderToApply.name}");
                string materialPath = Path.GetDirectoryName(jsonFile) + "/" + jsonFileName + ".mat";
                Material existingMaterial = AssetDatabase.LoadAssetAtPath<Material>(materialPath);
                Material materialToUpdate;

                if (existingMaterial != null)
                {
                    materialToUpdate = existingMaterial;
                    materialToUpdate.shader = shaderToApply;
                }
                else
                {
                    materialToUpdate = new Material(shaderToApply);
                    materialToUpdate.name = jsonFileName;
                    AssetDatabase.CreateAsset(materialToUpdate, materialPath);
                }

                if (isUnity)
                {
                    ProcessUnityMaterialProperties(jsonObject, materialToUpdate, textureCache, loadedTexturePaths, shaderToApply);
                }
                else if (isUnrealEngine)
                {
                    ProcessUnrealMaterialProperties(jsonObject, materialToUpdate, textureCache, loadedTexturePaths);
                }

                HoyoToonTextureManager.SetTextureImportSettings(loadedTexturePaths);
                ApplyCustomSettingsToMaterial(materialToUpdate, jsonFileName);

                EditorUtility.SetDirty(materialToUpdate);
                AssetDatabase.SaveAssets();
                AssetDatabase.Refresh();
                ApplyScriptedSettingsToMaterial(materialToUpdate, jsonFileName, jsonFile, jsonObject);
            }
            else
            {
                EditorUtility.DisplayDialog("Error", $"No compatible shader found for " + jsonFileName, "OK");
                HoyoToonLogs.ErrorDebug("No compatible shader found for " + jsonFileName);
            }
        }

        private static void ProcessProperties(JToken token, Material material, Action<string, JToken> action)
        {
            if (token is JArray array)
            {
                foreach (var item in array)
                {
                    string propertyName = item["Key"].Value<string>();
                    JToken propertyValue = item["Value"];
                    action(propertyName, propertyValue);
                }
            }
            else if (token is JObject obj)
            {
                foreach (var item in obj)
                {
                    string propertyName = item.Key;
                    JToken propertyValue = item.Value;
                    action(propertyName, propertyValue);
                }
            }
        }

        private static void ProcessUnityMaterialProperties(JObject jsonObject, Material newMaterial, Dictionary<string, Texture> textureCache, List<string> loadedTexturePaths, Shader shaderToApply)
        {
            ProcessProperties(jsonObject["m_SavedProperties"]["m_Floats"], newMaterial, (propertyName, propertyValue) =>
            {
                if (newMaterial.HasProperty(propertyName) && propertyValue.Type == JTokenType.Float)
                {
                    newMaterial.SetFloat(propertyName, propertyValue.Value<float>());
                }
            });

            ProcessProperties(jsonObject["m_SavedProperties"]["m_Colors"], newMaterial, (propertyName, propertyValue) =>
            {
                if (newMaterial.HasProperty(propertyName))
                {
                    JObject colorObject = propertyValue.ToObject<JObject>();
                    Color color = new Color(colorObject["r"].Value<float>(), colorObject["g"].Value<float>(), colorObject["b"].Value<float>(), colorObject["a"].Value<float>());
                    newMaterial.SetColor(propertyName, color);
                }
            });

            ProcessProperties(jsonObject["m_SavedProperties"]["m_TexEnvs"], newMaterial, (propertyName, propertyValue) =>
            {
                if (newMaterial.HasProperty(propertyName))
                {
                    JObject textureObject = propertyValue["m_Texture"].ToObject<JObject>();

                    if (!textureObject.ContainsKey("Name"))
                    {
                        HoyoToonLogs.ErrorDebug("You're using outdated materials. Please download/extract using the latest AssetStudio.");
                        EditorUtility.DisplayDialog("Error", $"You're using outdated materials. Please download/extract using the latest AssetStudio.", "OK");
                    }

                    string textureName = textureObject["Name"].Value<string>();

                    if (string.IsNullOrEmpty(textureName))
                    {
                        HoyoToonTextureManager.HardsetTexture(newMaterial, propertyName, shaderToApply);
                    }
                    else
                    {
                        Texture texture = null;

                        if (textureCache.ContainsKey(textureName))
                        {
                            texture = textureCache[textureName];
                        }
                        else
                        {
                            string[] textureGUIDs = AssetDatabase.FindAssets(textureName + " t:texture");

                            if (textureGUIDs.Length > 0)
                            {
                                string texturePath = AssetDatabase.GUIDToAssetPath(textureGUIDs[0]);
                                texture = AssetDatabase.LoadAssetAtPath<Texture>(texturePath);

                                if (texture != null)
                                {
                                    textureCache.Add(textureName, texture);
                                }
                            }
                        }

                        if (texture != null)
                        {
                            newMaterial.SetTexture(propertyName, texture);
                            string texturePath = AssetDatabase.GetAssetPath(texture);
                            loadedTexturePaths.Add(texturePath);

                            Vector2 scale = new Vector2(propertyValue["m_Scale"]["X"].Value<float>(), propertyValue["m_Scale"]["Y"].Value<float>());
                            Vector2 offset = new Vector2(propertyValue["m_Offset"]["X"].Value<float>(), propertyValue["m_Offset"]["Y"].Value<float>());
                            newMaterial.SetTextureScale(propertyName, scale);
                            newMaterial.SetTextureOffset(propertyName, offset);
                        }
                    }
                }
            });
        }

        private static void ProcessUnrealMaterialProperties(JObject jsonObject, Material newMaterial, Dictionary<string, Texture> textureCache, List<string> loadedTexturePaths)
        {
            ProcessProperties(jsonObject["Parameters"]["Colors"], newMaterial, (propertyName, propertyValue) =>
            {
                string unityPropertyName = "_" + propertyName;

                if (newMaterial.HasProperty(unityPropertyName))
                {
                    JObject colorObject = propertyValue.ToObject<JObject>();
                    Color color;
                    string hex = colorObject["Hex"].Value<string>();
                    if (!string.IsNullOrEmpty(hex) && ColorUtility.TryParseHtmlString(hex, out color))
                    {
                        newMaterial.SetColor(unityPropertyName, color);
                    }
                    else
                    {
                        color = new Color(colorObject["R"].Value<float>(), colorObject["G"].Value<float>(), colorObject["B"].Value<float>(), colorObject["A"].Value<float>());
                        newMaterial.SetColor(unityPropertyName, color);
                    }
                }
            });

            ProcessProperties(jsonObject["Parameters"]["Scalars"], newMaterial, (propertyName, propertyValue) =>
            {
                string unityPropertyName = "_" + propertyName;

                if (newMaterial.HasProperty(unityPropertyName) && propertyValue.Type == JTokenType.Float)
                {
                    newMaterial.SetFloat(unityPropertyName, propertyValue.Value<float>());
                }
            });

            ProcessProperties(jsonObject["Parameters"]["Switches"], newMaterial, (propertyName, propertyValue) =>
            {
                string unityPropertyName = "_" + propertyName;

                if (newMaterial.HasProperty(unityPropertyName) && propertyValue.Type == JTokenType.Boolean)
                {
                    newMaterial.SetInt(unityPropertyName, propertyValue.Value<bool>() ? 1 : 0);
                }
            });

            ProcessProperties(jsonObject["Parameters"]["Properties"], newMaterial, (propertyName, propertyValue) =>
            {
                string unityPropertyName = "_" + propertyName;

                if (newMaterial.HasProperty(unityPropertyName) && propertyValue.Type == JTokenType.Boolean)
                {
                    newMaterial.SetInt(unityPropertyName, propertyValue.Value<bool>() ? 1 : 0);
                }
            });

            ProcessProperties(jsonObject["Textures"], newMaterial, (propertyName, propertyValue) =>
            {
                string unityPropertyName = "_" + propertyName;

                if (newMaterial.HasProperty(unityPropertyName))
                {
                    string texturePath = propertyValue.Value<string>();

                    if (!string.IsNullOrEmpty(texturePath))
                    {
                        string textureName = texturePath.Substring(texturePath.LastIndexOf('.') + 1);

                        Texture texture = null;

                        if (textureCache.ContainsKey(textureName))
                        {
                            texture = textureCache[textureName];
                        }
                        else
                        {
                            string[] textureGUIDs = AssetDatabase.FindAssets(textureName + " t:texture");

                            if (textureGUIDs.Length > 0)
                            {
                                string assetPath = AssetDatabase.GUIDToAssetPath(textureGUIDs[0]);
                                texture = AssetDatabase.LoadAssetAtPath<Texture>(assetPath);

                                if (texture != null)
                                {
                                    textureCache.Add(textureName, texture);
                                }
                            }
                        }

                        if (texture != null)
                        {
                            newMaterial.SetTexture(unityPropertyName, texture);
                            string assetPath = AssetDatabase.GetAssetPath(texture);
                            loadedTexturePaths.Add(assetPath);

                            Vector2 scale = Vector2.one;
                            Vector2 offset = Vector2.zero;
                            newMaterial.SetTextureScale(unityPropertyName, scale);
                            newMaterial.SetTextureOffset(unityPropertyName, offset);
                        }
                    }
                }
            });
        }

        private static bool ContainsKey(JToken token, string key)
        {
            if (token is JArray array)
            {
                return array.Any(j => j["Key"].Value<string>() == key);
            }
            else if (token is JObject obj)
            {
                return obj.ContainsKey(key);
            }
            return false;
        }

        public static void ApplyCustomSettingsToMaterial(Material material, string jsonFileName)
        {
            var shaderName = material.shader.name;
            HoyoToonLogs.LogDebug($"Shader name: {shaderName}");

            if (HoyoToonDataManager.Data.MaterialSettings.TryGetValue(shaderName, out var shaderSettings))
            {
                HoyoToonLogs.LogDebug($"Found settings for shader: {shaderName}");

                var matchedSettings = shaderSettings.FirstOrDefault(setting => jsonFileName.Contains(setting.Key)).Value
                                      ?? shaderSettings.GetValueOrDefault("Default");

                if (matchedSettings != null)
                {
                    HoyoToonLogs.LogDebug($"Matched settings found for JSON file: {jsonFileName}");

                    foreach (var property in matchedSettings)
                    {
                        try
                        {
                            var propertyValue = property.Value.ToString();

                            // Check if the property value references another property
                            if (material.HasProperty(propertyValue))
                            {
                                var referencedValue = material.GetFloat(propertyValue);
                                material.SetFloat(property.Key, referencedValue);
                                HoyoToonLogs.LogDebug($"Successfully set property: {property.Key} to {referencedValue} (referenced from {propertyValue})");
                            }
                            else
                            {
                                // Attempt to parse the property value as int or float
                                if (int.TryParse(propertyValue, out var intValue))
                                {
                                    material.SetInt(property.Key, intValue);
                                    HoyoToonLogs.LogDebug($"Successfully set int property: {property.Key} to {intValue}");
                                }
                                else if (float.TryParse(propertyValue, out var floatValue))
                                {
                                    material.SetFloat(property.Key, floatValue);
                                    HoyoToonLogs.LogDebug($"Successfully set float property: {property.Key} to {floatValue}");
                                }
                                else
                                {
                                    HoyoToonLogs.WarningDebug($"Failed to parse property: {property.Key} as int or float");
                                }
                            }
                        }
                        catch (Exception ex)
                        {
                            HoyoToonLogs.ErrorDebug($"Failed to set property: {property.Key} with value: {property.Value}. Error: {ex.Message}");
                        }
                    }

                    if (matchedSettings.TryGetValue("renderQueue", out var renderQueue))
                    {
                        try
                        {
                            material.renderQueue = Convert.ToInt32(renderQueue);
                            HoyoToonLogs.LogDebug($"Successfully set renderQueue to {renderQueue}");
                        }
                        catch (Exception ex)
                        {
                            HoyoToonLogs.ErrorDebug($"Failed to set renderQueue to {renderQueue}. Error: {ex.Message}");
                        }
                    }
                }
            }
            else
            {
                HoyoToonLogs.ErrorDebug($"No settings found for shader: {shaderName}");
            }
        }

        private static void ApplyScriptedSettingsToMaterial(Material material, string jsonFileName, string jsonFile, JObject jsonObject)
        {
            string[] materialGUIDs = AssetDatabase.FindAssets("t:material", new[] { Path.GetDirectoryName(jsonFile) });
            Dictionary<string, Material> materials = new Dictionary<string, Material>();

            foreach (string guid in materialGUIDs)
            {
                string materialPath = AssetDatabase.GUIDToAssetPath(guid);
                Material mat = AssetDatabase.LoadAssetAtPath<Material>(materialPath);
                if (mat != null)
                {
                    materials[Path.GetFileNameWithoutExtension(materialPath)] = mat;
                }
            }

            if (material.shader.name == HSRShader)
            {
                if (jsonFileName.Contains("Hair"))
                {
                    string[] faceMaterialGUIDs = AssetDatabase.FindAssets("Face t:material", new[] { Path.GetDirectoryName(jsonFile) });
                    if (faceMaterialGUIDs.Length > 0)
                    {
                        string faceMaterialPath = AssetDatabase.GUIDToAssetPath(faceMaterialGUIDs[0]);
                        Material faceMaterial = AssetDatabase.LoadAssetAtPath<Material>(faceMaterialPath);

                        if (faceMaterial != null && faceMaterial.HasProperty("_ShadowColor"))
                        {
                            Color shadowColor = faceMaterial.GetColor("_ShadowColor");
                            material.SetColor("_ShadowColor", shadowColor);
                        }
                    }
                }
            }
            else if (material.shader.name == GIShader)
            {
                if (ContainsKey(jsonObject["m_SavedProperties"]?["m_Floats"], "_DummyFixedForNormal"))
                {
                    material.SetInt("_gameVersion", 1);
                }
                else
                {
                    material.SetInt("_gameVersion", 0);
                }
            }
            else if (material.shader.name == WuWaShader)
            {
                foreach (var kvp in materials)
                {
                    string materialName = kvp.Key;
                    Material originalMaterial = kvp.Value;

                    if (materialName.EndsWith("_OL"))
                    {
                        string baseMaterialName = materialName.Substring(0, materialName.Length - 3);
                        if (materials.TryGetValue(baseMaterialName, out Material baseMaterial))
                        {
                            if (originalMaterial.HasProperty("_MainTex"))
                            {
                                Texture mainTex = originalMaterial.GetTexture("_MainTex");
                                baseMaterial.SetTexture("_OutlineTexture", mainTex);
                            }

                            if (originalMaterial.HasProperty("_OutlineWidth"))
                            {
                                float outlineWidth = originalMaterial.GetFloat("_OutlineWidth");
                                baseMaterial.SetFloat("_OutlineWidth", outlineWidth);
                            }

                            if (originalMaterial.HasProperty("_UseVertexGreen_OutlineWidth"))
                            {
                                float useVertexGreenOutlineWidth = originalMaterial.GetFloat("_UseVertexGreen_OutlineWidth");
                                baseMaterial.SetFloat("_UseVertexGreen_OutlineWidth", useVertexGreenOutlineWidth);
                            }

                            if (originalMaterial.HasProperty("_UseVertexColorB_InnerOutline"))
                            {
                                float useVertexColorBInnerOutline = originalMaterial.GetFloat("_UseVertexColorB_InnerOutline");
                                baseMaterial.SetFloat("_UseVertexColorB_InnerOutline", useVertexColorBInnerOutline);
                            }

                            if (originalMaterial.HasProperty("_OutlineColor"))
                            {
                                Color outlineColor = originalMaterial.GetColor("_OutlineColor");
                                baseMaterial.SetColor("_OutlineColor", outlineColor);
                            }

                            if (originalMaterial.HasProperty("_UseMainTex"))
                            {
                                int useMainTex = originalMaterial.GetInt("_UseMainTex");
                                baseMaterial.SetInt("_UseMainTex", useMainTex);
                            }
                        }
                    }
                    else if (materialName.EndsWith("_HET") || materialName.EndsWith("_HETA"))
                    {
                        int lengthToTrim = materialName.EndsWith("_HET") ? 4 : 5;
                        string baseMaterialName = materialName.Substring(0, materialName.Length - lengthToTrim);
                        if (materials.TryGetValue(baseMaterialName, out Material baseMaterial))
                        {
                            if (originalMaterial.HasProperty("_Mask"))
                            {
                                Texture maskTex = originalMaterial.GetTexture("_Mask");
                                baseMaterial.SetTexture("_Mask", maskTex);
                            }
                        }
                    }
                    else if (materialName.EndsWith("Bangs"))
                    {
                        string faceMaterialName = materialName.Replace("Bangs", "Face");
                        if (materials.TryGetValue(faceMaterialName, out Material faceMaterial))
                        {
                            if (faceMaterial.HasProperty("_SkinSubsurfaceColor"))
                            {
                                Color shadowColor = faceMaterial.GetColor("_SkinSubsurfaceColor");
                                originalMaterial.SetColor("_HairShadowColor", shadowColor);
                            }
                        }
                    }
                }
            }
        }

        [MenuItem("Assets/HoyoToon/Materials/Generate Jsons", priority = 21)]
        public static void GenerateJsonsFromMaterials()
        {
            Material[] selectedMaterials = Selection.GetFiltered<Material>(SelectionMode.Assets);

            foreach (Material material in selectedMaterials)
            {
                string outputPath = Path.GetDirectoryName(AssetDatabase.GetAssetPath(material));
                outputPath = Path.Combine(outputPath, material.name + ".json");
                GenerateJsonFromMaterial(material, outputPath);
            }
            AssetDatabase.Refresh();
        }

        private static void GenerateJsonFromMaterial(Material material, string outputPath)
        {
            JObject jsonObject = new JObject();
            JObject m_SavedProperties = new JObject();
            JObject m_TexEnvs = new JObject();
            JObject m_Floats = new JObject();
            JObject m_Colors = new JObject();

            jsonObject["m_Shader"] = new JObject
        {
            { "m_FileID", material.shader.GetInstanceID() },
            { "Name", material.shader.name },
            { "IsNull", false }
        };

            Shader shader = material.shader;
            int propertyCount = ShaderUtil.GetPropertyCount(shader);
            for (int i = 0; i < propertyCount; i++)
            {
                string propertyName = ShaderUtil.GetPropertyName(shader, i);
                ShaderUtil.ShaderPropertyType propertyType = ShaderUtil.GetPropertyType(shader, i);

                if (propertyName.StartsWith("m_start") || propertyName.StartsWith("m_end"))
                {
                    continue;
                }

                switch (propertyType)
                {
                    case ShaderUtil.ShaderPropertyType.TexEnv:
                        Texture texture = material.GetTexture(propertyName);
                        if (texture != null)
                        {
                            JObject textureObject = new JObject
                        {
                            { "m_Texture", new JObject { { "m_FileID", 0 }, { "m_PathID", 0 }, { "Name", texture.name }, { "IsNull", false } } },
                            { "m_Scale", new JObject { { "X", material.GetTextureScale(propertyName).x }, { "Y", material.GetTextureScale(propertyName).y } } },
                            { "m_Offset", new JObject { { "X", material.GetTextureOffset(propertyName).x }, { "Y", material.GetTextureOffset(propertyName).y } } }
                        };
                            m_TexEnvs[propertyName] = textureObject;
                        }
                        break;
                    case ShaderUtil.ShaderPropertyType.Float:
                    case ShaderUtil.ShaderPropertyType.Range:
                        float floatValue = material.GetFloat(propertyName);
                        m_Floats[propertyName] = floatValue;
                        break;
                    case ShaderUtil.ShaderPropertyType.Color:
                        Color colorValue = material.GetColor(propertyName);
                        JObject colorObject = new JObject
                    {
                        { "r", colorValue.r },
                        { "g", colorValue.g },
                        { "b", colorValue.b },
                        { "a", colorValue.a }
                    };
                        m_Colors[propertyName] = colorObject;
                        break;
                }
            }

            m_SavedProperties["m_TexEnvs"] = m_TexEnvs;
            m_SavedProperties["m_Floats"] = m_Floats;
            m_SavedProperties["m_Colors"] = m_Colors;
            jsonObject["m_SavedProperties"] = m_SavedProperties;

            string jsonContent = jsonObject.ToString(Formatting.Indented);

            File.WriteAllText(outputPath, jsonContent);
        }

        #endregion
    }
}