using System;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEditor;
using System.Linq;
using System.Reflection;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Text.RegularExpressions;

public class HoyoToonManager
{
    #region Constants

    public const string version = "3.50";
    public const string HSRShader = "HoyoToon/Star Rail/Character";
    private const string GIShader = "HoyoToon/Genshin/Character";
    private const string Hi3Shader = "HoyoToon/Honkai Impact/Character Part 1";
    private const string Hi3P2Shader = "HoyoToon/Honkai Impact/Character Part 2";
    private const string WuWaShader = "HoyoToon/Wuthering Waves/Character";
    private static readonly string[] clampKeyword = { "Dissolve", "ramp", "Star", "_Skin" };
    private static readonly string[] nonSRGBKeywords = { "normalmap", "lightmap", "face_shadow", "specular_ramp", "gradient", "Grain", "Dissolve", "Repeat", "Stockings", "ExpressionMap", "FaceMap", "materialidvalueslut", "ColorMask", "_Mask", "_Normal", "_HM", "_N", "_HET", "_ID", "_SDF", "_CUBE", "_EG", "_EM", "T_Caustic" };
    private static readonly string[] NonPower2Keywords = { "materialidvalueslut" };


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

    #endregion

    #region Setup

    [MenuItem("Assets/HoyoToon/Setup FBX")]
    private static void SetupFBX()
    {
        SetFBXImportSettings(GetAssetSelectionPaths());
    }

    // [MenuItem("Assets/HoyoToon/Bodytype")]
    // private static void CheckBody()
    // {
    //     DetermineBodyType();
    // }

    #endregion

    #region Parsing

    private static string[] GetAssetSelectionPaths()
    {
        return Selection.assetGUIDs.Select(AssetDatabase.GUIDToAssetPath).ToArray();
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
                throw new MissingComponentException("<color=purple>[Hoyotoon]</color> The GameObject or its children must have a MeshFilter or SkinnedMeshRenderer component.");
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
                    Debug.Log($"<color=purple>[Hoyotoon]</color> Matched texture: {textureName} with BodyType.Hi3P2");
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
                    else if (!textureName.ToLower().Contains("girl") && !textureName.ToLower().Contains("lady")
                    && !textureName.ToLower().Contains("male") && !textureName.ToLower().Contains("loli") && !Regex.IsMatch(textureName, @"\d{2}"))
                    {
                        currentBodyType = BodyType.HI3P1;
                        bodyTypeSet = false;
                        Debug.Log($"<color=purple>[Hoyotoon]</color> Matched texture: {textureName} with BodyType.Hi3P1");
                    }
                }
            }
            if (!bodyTypeSet)
            {
                currentBodyType = BodyType.WuWa;
                Debug.Log($"<color=purple>[Hoyotoon]</color> No specific match found. Setting BodyType to WuWa");
            }
        }
        else
        {
            string validFolderNames = string.Join(", ", new[] { "Textures", "Texture", "Tex" });
            EditorUtility.DisplayDialog("Error", $"Textures folder path does not exist. Ensure your textures are in a folder named {validFolderNames}.", "OK");
            Debug.LogError("<color=purple>[Hoyotoon]</color> You need to have a Textures folder matching the valid names (e.g., 'Textures', 'Texture', 'Tex') and have all the textures inside of them.");
        }
        Debug.Log($"<color=purple>[Hoyotoon]</color> Current Body Type: {currentBodyType}");
    }

    #endregion

    #region Material Generation

    [MenuItem("Assets/HoyoToon/Generate Materials")]
    public static void GenerateMaterialsFromJson()
    {
        // Start asset editing
        AssetDatabase.StartAssetEditing();

        try
        {
            DetermineBodyType();
            var textureCache = new Dictionary<string, Texture>();
            UnityEngine.Object[] selectedObjects = Selection.objects;
            List<string> loadedTexturePaths = new List<string>();

            foreach (var selectedObject in selectedObjects)
            {
                string selectedPath = AssetDatabase.GetAssetPath(selectedObject);

                if (Path.GetExtension(selectedPath) == ".json")
                {
                    // Process the selected JSON file
                    ProcessJsonFile(selectedPath, textureCache, loadedTexturePaths);
                }
                else
                {
                    string directoryName = Path.GetDirectoryName(selectedPath);
                    string materialsFolderPath = new[] { "Materials", "Material", "Mat" }
                        .Select(folder => Path.Combine(directoryName, folder))
                        .FirstOrDefault(path => Directory.Exists(path) && Directory.GetFileSystemEntries(path).Any(path => true));

                    if (materialsFolderPath != null)
                    {
                        if (Directory.Exists(materialsFolderPath))
                        {
                            string[] jsonFiles = Directory.GetFiles(materialsFolderPath, "*.json");
                            foreach (string jsonFile in jsonFiles)
                            {
                                ProcessJsonFile(jsonFile, textureCache, loadedTexturePaths);
                            }
                        }
                    }
                    else
                    {
                        string validFolderNames = string.Join(", ", new[] { "Materials", "Material", "Mat" });
                        EditorUtility.DisplayDialog("Error", $"Materials folder path does not exist. Ensure your materials are in a folder named {validFolderNames}.", "OK");
                        Debug.LogError("<color=purple>[Hoyotoon]</color> Materials folder path does not exist. Ensure your materials are in a folder named 'Materials'.");
                    }
                }
            }
        }
        finally
        {
            // Stop asset editing
            AssetDatabase.StopAssetEditing();

            // Save assets and refresh the asset database once
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
        }
    }

    private static void ProcessJsonFile(string jsonFile, Dictionary<string, Texture> textureCache, List<string> loadedTexturePaths)
    {
        TextAsset jsonTextAsset = AssetDatabase.LoadAssetAtPath<TextAsset>(jsonFile);
        string jsonContent = jsonTextAsset.text;
        JObject jsonObject = JObject.Parse(jsonContent);
        string jsonFileName = Path.GetFileNameWithoutExtension(jsonFile);


        bool isUnrealEngine = jsonObject["Parameters"] != null;
        bool IsUnity = jsonObject["m_SavedProperties"] != null;

        Dictionary<string, string> shaderKeys = new Dictionary<string, string>
        {
            { "_UtilityDisplay1", GIShader },
            {"_DisableCGP", GIShader},
            { "_SPCubeMapIntensity", Hi3Shader },
            { "_DissolveDistortionIntensity", HSRShader },
            { "_ScreenLineInst", HSRShader},
            { "_RampTexV", Hi3P2Shader},
            { "_MiscGrp", Hi3P2Shader},
            { "ShadingModel", WuWaShader}
        };

        Shader shaderToApply = null;

        JToken shaderToken = jsonObject["m_Shader"];
        if (shaderToken != null && shaderToken["Name"] != null && !string.IsNullOrEmpty(shaderToken["Name"].Value<string>()))
        {
            shaderToApply = Shader.Find(shaderToken["Name"].Value<string>());
        }

        if (shaderToApply == null)
        {
            foreach (var shaderKey in shaderKeys)
            {
                // Hoyoverse Shaders
                JToken texEnvsToken = jsonObject["m_SavedProperties"]?["m_TexEnvs"];
                JToken floatsToken = jsonObject["m_SavedProperties"]?["m_Floats"];

                bool texEnvsContainsKey = texEnvsToken != null && ContainsKey(texEnvsToken, shaderKey.Key);
                bool floatsContainsKey = floatsToken != null && ContainsKey(floatsToken, shaderKey.Key);

                if (texEnvsContainsKey || floatsContainsKey)
                {
                    shaderToApply = Shader.Find(shaderKey.Value);
                    break;
                }

                // KuroGames Shaders
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
                    shaderToApply = Shader.Find(shaderKey.Value);
                    break;
                }
            }

            if (shaderToApply != null)
            {
                string materialPath = Path.GetDirectoryName(jsonFile) + "/" + jsonFileName + ".mat";

                Material newMaterial = AssetDatabase.LoadAssetAtPath<Material>(materialPath);
                bool isNewMaterial = false;
                if (newMaterial == null)
                {
                    newMaterial = new Material(shaderToApply);
                    isNewMaterial = true;
                }

                if (IsUnity)
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
                                throw new Exception("<color=purple>[Hoyotoon]</color> You're using outdated materials. Please download/extract using the latest AssetStudio.");
                            }

                            string textureName = textureObject["Name"].Value<string>();

                            if (!string.IsNullOrEmpty(textureName))
                            {
                                Texture texture = null;

                                // Check if the texture is in the cache
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

                                        // Add the texture to the cache
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

                else if (isUnrealEngine)
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
                                // Extract the texture name from the path
                                string textureName = texturePath.Substring(texturePath.LastIndexOf('.') + 1);

                                Texture texture = null;

                                // Check if the texture is in the cache
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

                                        // Add the texture to the cache
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

                                    // Assuming scale and offset are not provided in the new JSON structure
                                    // Set default scale and offset
                                    Vector2 scale = Vector2.one;
                                    Vector2 offset = Vector2.zero;
                                    newMaterial.SetTextureScale(unityPropertyName, scale);
                                    newMaterial.SetTextureOffset(unityPropertyName, offset);
                                }
                            }
                        }
                    });
                }

                ApplyCustomSettingsToMaterial(newMaterial, jsonFileName, jsonFile);


                if (isNewMaterial)
                {
                    HardSetTextures(newMaterial, loadedTexturePaths);
                    AssetDatabase.CreateAsset(newMaterial, materialPath);
                }

                //ApplyAfterChanges(newMaterial, jsonFile);
            }
            else
            {
                EditorUtility.DisplayDialog("Error", $"No compatible shader found for " + jsonFileName, "OK");
                Debug.LogError("<color=purple>[Hoyotoon]</color> No compatible shader found for " + jsonFileName);
            }
        }
    }

    public static void HardSetTextures(Material newMaterial, List<string> loadedTexturePaths)
    {
        var textureMap = new Dictionary<string, string>
    {
        { "_MTMap", "Avatar_Tex_MetalMap" },
        { "_MTSpecularRamp", "Avatar_Tex_Specular_Ramp"},
        { "_DissolveMap", "Eff_Noise_607" },
        { "_DissolveMask", "UI_Noise_29" },
        { "_WeaponDissolveTex", "Eff_WeaponsTotem_Dissolve_00" },
        { "_WeaponPatternTex", "Eff_WeaponsTotem_Grain_00" },
        { "_ScanPatternTex", "Eff_Gradient_Repeat_01" }
    };

        if (currentBodyType.ToString().StartsWith("GI"))
        {
            string bodyType = currentBodyType.ToString().Substring(2);
            textureMap["_FaceMapTex"] = $"Avatar_{bodyType}_Tex_FaceLightmap";
        }

        // Cache for loaded textures
        var textureCache = new Dictionary<string, Texture>();

        foreach (var textureProperty in textureMap)
        {
            string textureName = textureProperty.Value;
            Texture texture = null;

            // Check if the texture is in the cache
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

                    // Add the texture to the cache
                    if (texture != null)
                    {
                        textureCache.Add(textureName, texture);
                    }
                }
            }

            if (texture != null)
            {
                newMaterial.SetTexture(textureProperty.Key, texture);
                string texturePath = AssetDatabase.GetAssetPath(texture);
                loadedTexturePaths.Add(texturePath);
            }
        }
        SetTextureImportSettings(loadedTexturePaths);
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

    public static void ApplyCustomSettingsToMaterial(Material material, string jsonFileName, string jsonFile)
    {
        //Hoyoverse Shaders
        if (material.shader.name == HSRShader && jsonFileName.Contains("Face"))
        {
            material.SetInt("variant_selector", 1);
            material.SetInt("_BaseMaterial", 0);
            material.SetInt("_HairMaterial", 0);
            material.SetInt("_FaceMaterial", 1);
            material.SetInt("_EyeShadowMat", 0);
            material.SetInt("_CullMode", 2);
            material.SetInt("_SrcBlend", 1);
            material.SetInt("_DstBlend", 0);
            material.SetInt("_StencilPassA", 0);
            material.SetInt("_StencilPassB", 2);
            material.SetInt("_StencilCompA", 5);
            material.SetInt("_StencilCompB", 5);
            material.SetInt("_StencilRef", 100);
            material.renderQueue = 2010;
        }
        else if (material.shader.name == HSRShader && jsonFileName.Contains("EyeShadow"))
        {
            material.SetInt("variant_selector", 2);
            material.SetInt("_BaseMaterial", 0);
            material.SetInt("_HairMaterial", 0);
            material.SetInt("_FaceMaterial", 0);
            material.SetInt("_EyeShadowMat", 1);
            material.SetInt("_CullMode", 0);
            material.SetInt("_SrcBlend", 2);
            material.SetInt("_DstBlend", 0);
            material.SetInt("_StencilPassA", 0);
            material.SetInt("_StencilPassB", 2);
            material.SetInt("_StencilCompA", 0);
            material.SetInt("_StencilCompB", 8);
            material.SetInt("_StencilRef", 0);
            material.renderQueue = 2015;
        }
        else if (material.shader.name == HSRShader && jsonFileName.Contains("FaceMask"))
        {
            material.SetInt("variant_selector", 1);
            material.SetInt("_BaseMaterial", 0);
            material.SetInt("_HairMaterial", 0);
            material.SetInt("_FaceMaterial", 1);
            material.SetInt("_EyeShadowMat", 0);
            material.SetInt("_CullMode", 0);
            material.SetInt("_SrcBlend", 1);
            material.SetInt("_DstBlend", 0);
            material.SetInt("_StencilPassA", 0);
            material.SetInt("_StencilPassB", 2);
            material.SetInt("_StencilCompA", 5);
            material.SetInt("_StencilCompB", 5);
            material.SetInt("_StencilRef", 99);
            material.SetInt("_OutlineWidth", 0);
            material.renderQueue = 2010;
        }
        else if (material.shader.name == HSRShader && jsonFileName.Contains("Trans"))
        {
            material.SetInt("_IsTransparent", 1);
            material.SetInt("variant_selector", 0);
            material.SetInt("_BaseMaterial", 1);
            material.SetInt("_HairMaterial", 0);
            material.SetInt("_FaceMaterial", 0);
            material.SetInt("_EyeShadowMat", 0);
            material.SetInt("_CullMode", 0);
            material.SetInt("_SrcBlend", 5);
            material.SetInt("_DstBlend", 10);
            material.SetInt("_StencilPassA", 2);
            material.SetInt("_StencilPassB", 0);
            material.SetInt("_StencilCompA", 0);
            material.SetInt("_StencilCompB", 0);
            material.SetInt("_StencilRef", 0);
            material.renderQueue = 2041;
        }
        else if (material.shader.name == HSRShader && jsonFileName.Contains("Hair"))
        {
            material.SetInt("variant_selector", 3);
            material.SetInt("_BaseMaterial", 0);
            material.SetInt("_HairMaterial", 1);
            material.SetInt("_FaceMaterial", 0);
            material.SetInt("_EyeShadowMat", 0);
            material.SetInt("_CullMode", 0);
            material.SetInt("_SrcBlend", 1);
            material.SetInt("_DstBlend", 0);
            material.SetInt("_StencilPassA", 0);
            material.SetInt("_StencilPassB", 0);
            material.SetInt("_StencilCompA", 5);
            material.SetInt("_StencilCompB", 8);
            material.SetInt("_StencilRef", 100);
            material.SetInt("_UseSelfShadow", 1);
            material.renderQueue = 2020;

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
        else if (material.shader.name == HSRShader)
        {
            material.SetInt("variant_selector", 0);
            material.SetInt("_BaseMaterial", 1);
            material.SetInt("_HairMMaterial", 0);
            material.SetInt("_FaceMaterial", 0);
            material.SetInt("_EyeShadowMat", 0);
            material.SetInt("_CullMode", 0);
            material.SetInt("_SrcBlend", 5);
            material.SetInt("_DstBlend", 10);
            material.SetInt("_StencilPassA", 2);
            material.SetInt("_StencilPassB", 0);
            material.SetInt("_StencilCompA", 0);
            material.SetInt("_StencilCompB", 0);
            material.SetInt("_StencilRef", 0);
            material.SetFloat("_OutlineScale", 0.187f);
            material.SetFloat("_RimWidth", 1f);
            material.SetInt("_UseSelfShadow", 1);
            material.renderQueue = 2040;

        }
        else if (material.shader.name == GIShader && jsonFileName.Contains("Face"))
        {
            material.SetInt("variant_selector", 1);
            material.SetInt("_UseFaceMapNew", 1);
            material.SetInt("_UseSelfShadow", 0);
        }
        else if (material.shader.name == GIShader && jsonFileName.Contains("Equip"))
        {
            material.SetInt("variant_selector", 2);
            material.SetInt("_UseWeapon", 1);
        }
        else if (material.shader.name == GIShader)
        {
            material.SetInt("variant_selector", 0);
        }
        else if (material.shader.name == Hi3Shader && jsonFileName.Contains("Face"))
        {
            material.SetInt("variant_selector", 1);
            material.SetInt("_StencilPassA", 0);
            material.SetInt("_StencilPassB", 2);
            material.SetInt("_StencilCompA", 6);
            material.SetInt("_StencilCompB", 8);
            material.SetInt("_StencilRef", 16);
            material.renderQueue = 2000;
        }
        else if (material.shader.name == Hi3Shader && jsonFileName.Contains("Hair"))
        {
            material.SetInt("variant_selector", 2);
            material.SetInt("_StencilPassA", 0);
            material.SetInt("_StencilPassB", 2);
            material.SetInt("_StencilCompA", 6);
            material.SetInt("_StencilCompB", 8);
            material.SetInt("_StencilRef", 16);
            material.renderQueue = 2002;
        }
        else if (material.shader.name == Hi3Shader && jsonFileName.Contains("Eye"))
        {
            material.SetInt("variant_selector", 3);
            material.SetInt("_StencilPassA", 0);
            material.SetInt("_StencilPassB", 2);
            material.SetInt("_StencilCompA", 6);
            material.SetInt("_StencilCompB", 8);
            material.SetInt("_StencilRef", 16);
            material.renderQueue = 2001;
        }
        else if (material.shader.name == Hi3Shader && jsonFileName.Contains("Alpha"))
        {
            material.SetInt("_AlphaType", 1);
            material.SetInt("_SrcBlend", 5);
            material.SetInt("_DstBlend", 10);
            material.renderQueue = 2003;
        }
        else if (material.shader.name == Hi3P2Shader && jsonFileName.Contains("Face"))
        {
            material.SetInt("variant_selector", 1);
            material.SetInt("_StencilPassA", 0);
            material.SetInt("_StencilPassB", 2);
            material.SetInt("_StencilCompA", 6);
            material.SetInt("_StencilCompB", 8);
            material.SetInt("_StencilRef", 16);
            material.renderQueue = 2000;
        }
        else if (material.shader.name == Hi3P2Shader && jsonFileName.Contains("Hair"))
        {
            material.SetInt("variant_selector", 2);
            material.SetInt("_StencilPassA", 0);
            material.SetInt("_StencilPassB", 2);
            material.SetInt("_StencilCompA", 6);
            material.SetInt("_StencilCompB", 8);
            material.SetInt("_StencilRef", 16);
            material.renderQueue = 2002;
        }
        else if (material.shader.name == Hi3P2Shader && jsonFileName.Contains("Eye"))
        {
            material.SetInt("variant_selector", 3);
            material.SetInt("_StencilPassA", 0);
            material.SetInt("_StencilPassB", 2);
            material.SetInt("_StencilCompA", 6);
            material.SetInt("_StencilCompB", 8);
            material.SetInt("_StencilRef", 16);
            material.renderQueue = 2001;
        }

        // KuroGames Shaders
        else if (material.shader.name == WuWaShader && jsonFileName.Contains("Bangs"))
        {
            material.SetInt("_MaterialType", 3);
        }
        else if (material.shader.name == WuWaShader && jsonFileName.Contains("Eye"))
        {
            material.SetInt("_MaterialType", 2);
        }
        else if (material.shader.name == WuWaShader && jsonFileName.Contains("Face"))
        {
            material.SetInt("_MaterialType", 1);
        }
        else if (material.shader.name == WuWaShader && jsonFileName.Contains("Hair"))
        {
            material.SetInt("_MaterialType", 4);
        }
    }


    private static void SetTextureImportSettings(IEnumerable<string> paths)
    {
        var pathsToReimport = new List<string>();

        AssetDatabase.StartAssetEditing();
        try
        {
            foreach (var p in paths)
            {
                var texture = AssetDatabase.LoadAssetAtPath<Texture2D>(p);
                if (!texture) continue;

                TextureImporter importer = AssetImporter.GetAtPath(p) as TextureImporter;
                if (!importer) continue;

                bool settingsChanged = false;

                if (importer.textureType != TextureImporterType.Default ||
                    importer.textureCompression != TextureImporterCompression.Uncompressed ||
                    importer.mipmapEnabled != false ||
                    importer.streamingMipmaps != false ||
                    (clampKeyword.Any(k => texture.name.IndexOf(k, System.StringComparison.InvariantCultureIgnoreCase) >= 0) && importer.wrapMode != TextureWrapMode.Clamp) ||
                    (nonSRGBKeywords.Any(k => texture.name.IndexOf(k, System.StringComparison.InvariantCultureIgnoreCase) >= 0) && importer.sRGBTexture != false) ||
                    (NonPower2Keywords.Any(k => texture.name.IndexOf(k, System.StringComparison.InvariantCultureIgnoreCase) >= 0) && importer.npotScale != TextureImporterNPOTScale.None))
                {
                    importer.textureType = TextureImporterType.Default;
                    importer.textureCompression = TextureImporterCompression.Uncompressed;
                    importer.mipmapEnabled = false;
                    importer.streamingMipmaps = false;

                    if (clampKeyword.Any(k => texture.name.IndexOf(k, System.StringComparison.InvariantCultureIgnoreCase) >= 0))
                        importer.wrapMode = TextureWrapMode.Clamp;

                    if (nonSRGBKeywords.Any(k => texture.name.IndexOf(k, System.StringComparison.InvariantCultureIgnoreCase) >= 0))
                        importer.sRGBTexture = false;

                    if (NonPower2Keywords.Any(k => texture.name.IndexOf(k, System.StringComparison.InvariantCultureIgnoreCase) >= 0))
                        importer.npotScale = TextureImporterNPOTScale.None;

                    settingsChanged = true;
                }

                if (settingsChanged)
                {
                    pathsToReimport.Add(p);
                }
            }
        }
        finally
        {
            AssetDatabase.StopAssetEditing();
        }

        foreach (var p in pathsToReimport)
        {
            AssetDatabase.ImportAsset(p, ImportAssetOptions.ForceUpdate);
        }

        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }

    [MenuItem("Assets/HoyoToon/Generate Jsons")]
    public static void GenerateJsonsFromMaterials()
    {
        // Get the selected materials
        Material[] selectedMaterials = Selection.GetFiltered<Material>(SelectionMode.Assets);

        // Iterate over the selected materials
        foreach (Material material in selectedMaterials)
        {
            // Generate the JSON file for each material
            string outputPath = Path.GetDirectoryName(AssetDatabase.GetAssetPath(material));
            outputPath = Path.Combine(outputPath, material.name + ".json");
            GenerateJsonFromMaterial(material, outputPath);
        }

        // Refresh the folder to import the JSON files
        AssetDatabase.Refresh();
    }

    private static void GenerateJsonFromMaterial(Material material, string outputPath)
    {
        JObject jsonObject = new JObject();
        JObject m_SavedProperties = new JObject();
        JObject m_TexEnvs = new JObject();
        JObject m_Floats = new JObject();
        JObject m_Colors = new JObject();

        // Save shader name
        jsonObject["m_Shader"] = new JObject
        {
            { "m_FileID", material.shader.GetInstanceID() },
            { "Name", material.shader.name },
            { "IsNull", false }
        };

        // Iterate over the shader properties
        Shader shader = material.shader;
        int propertyCount = ShaderUtil.GetPropertyCount(shader);
        for (int i = 0; i < propertyCount; i++)
        {
            string propertyName = ShaderUtil.GetPropertyName(shader, i);
            ShaderUtil.ShaderPropertyType propertyType = ShaderUtil.GetPropertyType(shader, i);

            // Ignore properties that start with m_start or m_end
            if (propertyName.StartsWith("m_start") || propertyName.StartsWith("m_end"))
            {
                continue;
            }

            // Depending on the property type, get the value from the material and add it to the JObject
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
                case ShaderUtil.ShaderPropertyType.Range: // Treat Range as Float
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

        // Serialize the JObject to a JSON string
        string jsonContent = jsonObject.ToString(Formatting.Indented);

        // Write the JSON string to a file
        File.WriteAllText(outputPath, jsonContent);
    }

    #endregion

    #region FBX Setup

    private static void SetFBXImportSettings(IEnumerable<string> paths)
    {
        bool changesMade = false;

        AssetDatabase.StartAssetEditing();
        try
        {
            foreach (var p in paths)
            {
                var fbx = AssetDatabase.LoadAssetAtPath<Mesh>(p);
                if (!fbx) continue;

                ModelImporter importer = AssetImporter.GetAtPath(p) as ModelImporter;
                if (!importer) continue;

                importer.globalScale = 1;
                importer.isReadable = true;
                importer.SearchAndRemapMaterials(ModelImporterMaterialName.BasedOnMaterialName, ModelImporterMaterialSearch.Everywhere);
                if (importer.animationType != ModelImporterAnimationType.Human || importer.avatarSetup != ModelImporterAvatarSetup.CreateFromThisModel)
                {
                    importer.animationType = ModelImporterAnimationType.Human;
                    importer.avatarSetup = ModelImporterAvatarSetup.CreateFromThisModel;
                    changesMade = true;
                }

                if (ModifyAndSaveHumanoidBoneMapping(importer))
                {
                    changesMade = true;
                }

                string pName = "legacyComputeAllNormalsFromSmoothingGroupsWhenMeshHasBlendShapes";
                PropertyInfo prop = importer.GetType().GetProperty(pName, BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.Public);
                prop.SetValue(importer, true);
            }
        }
        finally
        {
            AssetDatabase.StopAssetEditing();
        }

        if (changesMade)
        {
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
        }
    }

    private static bool ModifyAndSaveHumanoidBoneMapping(ModelImporter importer)
    {
        HumanDescription humanDescription = importer.humanDescription;
        List<HumanBone> humanBones = new List<HumanBone>(humanDescription.human);

        bool changesMade = false;

        for (int i = 0; i < humanBones.Count; i++)
        {
            if (humanBones[i].humanName == "Jaw")
            {
                humanBones.RemoveAt(i);
                changesMade = true;
                break;
            }
        }

        string leftEyeBoneName = null;
        string rightEyeBoneName = null;

        if (humanBones.Exists(bone => bone.boneName == "+EyeBoneLA02" || bone.boneName == "EyeBoneLA02"))
        {
            leftEyeBoneName = "+EyeBoneLA02";
            rightEyeBoneName = "+EyeBoneRA02";
        }
        else if (humanBones.Exists(bone => bone.boneName == "Eye_L"))
        {
            leftEyeBoneName = "Eye_L";
            rightEyeBoneName = "Eye_R";
        }
        else
        {
            leftEyeBoneName = "Eye_L";
            rightEyeBoneName = "Eye_R";
        }

        for (int i = 0; i < humanBones.Count; i++)
        {
            if (humanBones[i].humanName == "LeftEye")
            {
                HumanBone bone = humanBones[i];
                bone.boneName = leftEyeBoneName;
                humanBones[i] = bone;
                changesMade = true;
            }
            else if (humanBones[i].humanName == "RightEye")
            {
                HumanBone bone = humanBones[i];
                bone.boneName = rightEyeBoneName;
                humanBones[i] = bone;
                changesMade = true;
            }
        }

        if (changesMade)
        {
            humanDescription.human = humanBones.ToArray();
            importer.humanDescription = humanDescription;
        }

        if (changesMade)
        {
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
        }

        return changesMade;
    }

    #endregion

    #region Tangent Generation

    [MenuItem("GameObject/HoyoToon/Generate Tangents", false, 0)]
    public static void GenTangents()
    {
        DetermineBodyType();

        MeshFilter[] meshFilters = Selection.activeGameObject.GetComponentsInChildren<MeshFilter>();
        foreach (var meshFilter in meshFilters)
        {
            Mesh mesh = meshFilter.sharedMesh;
            if (currentBodyType == BodyType.Hi3P2)
            {
                MoveColors(mesh);
                meshFilter.sharedMesh = mesh;
            }
            else
            {

                ModifyMeshTangents(mesh);
                meshFilter.sharedMesh = mesh;
            }

        }

        SkinnedMeshRenderer[] skinMeshRenders = Selection.activeGameObject.GetComponentsInChildren<SkinnedMeshRenderer>();
        foreach (var skinMeshRender in skinMeshRenders)
        {
            Mesh mesh = skinMeshRender.sharedMesh;
            if (currentBodyType == BodyType.Hi3P2)
            {
                MoveColors(mesh);
                skinMeshRender.sharedMesh = mesh;
            }
            else
            {

                ModifyMeshTangents(mesh);
                skinMeshRender.sharedMesh = mesh;
            }
        }

        SaveMeshAssets(Selection.activeGameObject, currentBodyType);
    }

    private static Mesh ModifyMeshTangents(Mesh mesh)
    {
        Mesh newMesh = UnityEngine.Object.Instantiate(mesh);

        var vertices = newMesh.vertices;
        var triangles = newMesh.triangles;
        var unmerged = new Vector3[newMesh.vertexCount];
        var merged = new Dictionary<Vector3, Vector3>(); // Use a dictionary to map vertices to their merged normals
        var tangents = new Vector4[newMesh.vertexCount];

        for (int i = 0; i < triangles.Length; i += 3)
        {
            var i0 = triangles[i + 0];
            var i1 = triangles[i + 1];
            var i2 = triangles[i + 2];

            var v0 = vertices[i0] * 100;
            var v1 = vertices[i1] * 100;
            var v2 = vertices[i2] * 100;

            var normal_ = Vector3.Cross(v1 - v0, v2 - v0).normalized;

            unmerged[i0] += normal_ * Vector3.Angle(v1 - v0, v2 - v0);
            unmerged[i1] += normal_ * Vector3.Angle(v0 - v1, v2 - v1);
            unmerged[i2] += normal_ * Vector3.Angle(v0 - v2, v1 - v2);
        }

        for (int i = 0; i < vertices.Length; i++)
        {
            if (!merged.ContainsKey(vertices[i]))
            {
                merged[vertices[i]] = unmerged[i];
            }
            else
            {
                merged[vertices[i]] += unmerged[i];
            }
        }

        for (int i = 0; i < vertices.Length; i++)
        {
            var normal = merged[vertices[i]].normalized;
            tangents[i] = new Vector4(normal.x, normal.y, normal.z, 0);
        }

        newMesh.tangents = tangents;

        return newMesh;
    }

    private static Mesh MoveColors(Mesh mesh)
    {
        Mesh newMesh = UnityEngine.Object.Instantiate(mesh);

        var vertices = newMesh.vertices;
        var tangents = newMesh.tangents;
        var colors = newMesh.colors;

        // Initialize colors array if it's null or doesn't have the same length as vertices array
        if (colors == null || colors.Length != vertices.Length)
        {
            colors = new Color[vertices.Length];
            for (int i = 0; i < colors.Length; i++)
            {
                colors[i] = Color.white; // or any default color
            }
            newMesh.colors = colors;
        }

        for (int i = 0; i < vertices.Length; i++)
        {
            tangents[i].x = colors[i].r * 2 - 1;
            tangents[i].y = colors[i].g * 2 - 1;
            tangents[i].z = colors[i].b * 2 - 1;
        }
        newMesh.SetTangents(tangents);

        return newMesh;
    }

    private static void SaveMeshAssets(GameObject gameObject, BodyType currentBodyType)
    {
        MeshFilter[] meshFilters = gameObject.GetComponentsInChildren<MeshFilter>();
        SkinnedMeshRenderer[] skinMeshRenderers = gameObject.GetComponentsInChildren<SkinnedMeshRenderer>();

        foreach (var meshFilter in meshFilters)
        {
            Mesh mesh = meshFilter.sharedMesh;
            Mesh newMesh;
            if (currentBodyType == BodyType.Hi3P2)
            {
                newMesh = MoveColors(mesh);
            }
            else
            {
                newMesh = ModifyMeshTangents(mesh);
            }
            newMesh.name = mesh.name; // Set the name of the new mesh to the name of the original mesh
            meshFilter.sharedMesh = newMesh;

            string path = AssetDatabase.GetAssetPath(mesh);
            string folderPath = Path.GetDirectoryName(path) + "/Meshes";
            if (!Directory.Exists(folderPath))
            {
                AssetDatabase.CreateFolder(Path.GetDirectoryName(path), "Meshes");
            }
            path = folderPath + "/" + newMesh.name + ".asset";
            AssetDatabase.CreateAsset(newMesh, path);
        }

        foreach (var skinMeshRenderer in skinMeshRenderers)
        {
            Mesh mesh = skinMeshRenderer.sharedMesh;
            Mesh newMesh;
            if (currentBodyType == BodyType.Hi3P2)
            {
                newMesh = MoveColors(mesh);
            }
            else
            {
                newMesh = ModifyMeshTangents(mesh);
            }
            newMesh.name = mesh.name; // Set the name of the new mesh to the name of the original mesh
            skinMeshRenderer.sharedMesh = newMesh;

            string path = AssetDatabase.GetAssetPath(mesh);
            string folderPath = Path.GetDirectoryName(path) + "/Meshes";
            if (!Directory.Exists(folderPath))
            {
                AssetDatabase.CreateFolder(Path.GetDirectoryName(path), "Meshes");
            }
            path = folderPath + "/" + newMesh.name + ".asset";
            AssetDatabase.CreateAsset(newMesh, path);
        }
    }

    #endregion

}

