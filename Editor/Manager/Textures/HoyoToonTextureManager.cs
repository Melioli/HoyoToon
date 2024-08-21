using UnityEditor;
using UnityEngine;
using System.Collections.Generic;
using System.Linq;

namespace HoyoToon
{
    public class HoyoToonTextureManager
    {
        #region Constants
        private static readonly string[] clampKeyword = HoyoToonDataManager.Data.Textures.ClampKeyword;
        private static readonly string[] nonSRGBKeywords = HoyoToonDataManager.Data.Textures.NonSRGBKeywords;
        private static readonly string[] EndsWithNonSRGBKeywords = HoyoToonDataManager.Data.Textures.EndsWithNonSRGBKeywords;
        private static readonly string[] NonPower2Keywords = HoyoToonDataManager.Data.Textures.NonPower2Keywords;
        #endregion


        #region Textures

        public class TextureCondition
        {
            public string CurrentBodyType { get; set; }
            public Shader Shader { get; set; }
            public string PropertyName { get; set; }
            public string TextureName { get; set; }

            public bool Matches(string currentBodyType, Shader shader, string propertyName)
            {
                return CurrentBodyType == currentBodyType && Shader == shader && PropertyName == propertyName;
            }
        }

        private static readonly List<TextureCondition> textureConditions = new List<TextureCondition>();

        static HoyoToonTextureManager()
        {
            string[] GIbodyTypes = { HoyoToonParseManager.BodyType.GIBoy.ToString(), HoyoToonParseManager.BodyType.GIGirl.ToString(), HoyoToonParseManager.BodyType.GILady.ToString(), HoyoToonParseManager.BodyType.GIMale.ToString(), HoyoToonParseManager.BodyType.GILoli.ToString() };
            string[] GIFaceLightmap = { "Avatar_Boy_Tex_FaceLightmap", "Avatar_Girl_Tex_FaceLightmap", "Avatar_Lady_Tex_FaceLightmap", "Avatar_Male_Tex_FaceLightmap", "Avatar_Loli_Tex_FaceLightmap" };
            string[] HSRBodyTypes = { HoyoToonParseManager.BodyType.HSRMaid.ToString(), HoyoToonParseManager.BodyType.HSRKid.ToString(), HoyoToonParseManager.BodyType.HSRLad.ToString(), HoyoToonParseManager.BodyType.HSRMale.ToString(), HoyoToonParseManager.BodyType.HSRLady.ToString(), HoyoToonParseManager.BodyType.HSRGirl.ToString(), HoyoToonParseManager.BodyType.HSRBoy.ToString(), HoyoToonParseManager.BodyType.HSRMiss.ToString() };
            string[] HSRExpressionMap = { "W_160_Maid_Face_ExpressionMap_00", "W_120_Kid_Face_ExpressionMap_00", "M_170_Lad_Face_ExpressionMap", "M_180_Male_Face_ExpressionMap_00", "W_170_Lady_Face_ExpressionMap_00", "W_140_Girl_Face_ExpressionMap_00", "M_150_Boy_Face_ExpressionMap_00", "W_168_Miss_Face_ExpressionMap_00" };
            string[] HSRFaceMap = { "W_160_Maid_FaceMap_00", "W_120_Kid_FaceMap_00", "M_170_Lad_FaceMap_00", "M_180_Male_FaceMap_00", "W_170_Lady_FaceMap_00", "W_140_Girl_FaceMap_00", "M_150_Boy_FaceMap_00", "W_168_Miss_FaceMap_00" };

            // Genshin
            for (int i = 0; i < GIbodyTypes.Length; i++)
            {
                textureConditions.Add(new TextureCondition { CurrentBodyType = GIbodyTypes[i], Shader = Shader.Find(HoyoToonMaterialManager.GIShader), PropertyName = "_FaceMapTex", TextureName = GIFaceLightmap[i] });
                textureConditions.Add(new TextureCondition { CurrentBodyType = GIbodyTypes[i], Shader = Shader.Find(HoyoToonMaterialManager.GIShader), PropertyName = "_LightMapTex", TextureName = "Avatar_Tex_Face_Shadow" });
                textureConditions.Add(new TextureCondition { CurrentBodyType = GIbodyTypes[i], Shader = Shader.Find(HoyoToonMaterialManager.GIShader), PropertyName = "_MTMap", TextureName = "Avatar_Tex_MetalMap" });
                textureConditions.Add(new TextureCondition { CurrentBodyType = GIbodyTypes[i], Shader = Shader.Find(HoyoToonMaterialManager.GIShader), PropertyName = "_MTSpecularRamp", TextureName = "Avatar_Tex_Specular_Ramp" });
                textureConditions.Add(new TextureCondition { CurrentBodyType = GIbodyTypes[i], Shader = Shader.Find(HoyoToonMaterialManager.GIShader), PropertyName = "_WeaponDissolveTex", TextureName = "Eff_WeaponsTotem_Dissolve_00" });
                textureConditions.Add(new TextureCondition { CurrentBodyType = GIbodyTypes[i], Shader = Shader.Find(HoyoToonMaterialManager.GIShader), PropertyName = "_WeaponPatternTex", TextureName = "Eff_WeaponsTotem_Grain_00" });
                textureConditions.Add(new TextureCondition { CurrentBodyType = GIbodyTypes[i], Shader = Shader.Find(HoyoToonMaterialManager.GIShader), PropertyName = "_ScanPatternTex", TextureName = "Eff_Gradient_Repeat_01" });
                textureConditions.Add(new TextureCondition { CurrentBodyType = GIbodyTypes[i], Shader = Shader.Find(HoyoToonMaterialManager.GIShader), PropertyName = "_NyxStateOutlineNoise", TextureName = "Eff_Avatar_NyxState" });

            }

            // Star Rail
            for (int i = 0; i < HSRBodyTypes.Length; i++)
            {
                textureConditions.Add(new TextureCondition { CurrentBodyType = HSRBodyTypes[i], Shader = Shader.Find(HoyoToonMaterialManager.HSRShader), PropertyName = "_FaceMap", TextureName = HSRFaceMap[i] });
                textureConditions.Add(new TextureCondition { CurrentBodyType = HSRBodyTypes[i], Shader = Shader.Find(HoyoToonMaterialManager.HSRShader), PropertyName = "_ExpressionMap", TextureName = HSRExpressionMap[i] });
                textureConditions.Add(new TextureCondition { CurrentBodyType = HSRBodyTypes[i], Shader = Shader.Find(HoyoToonMaterialManager.HSRShader), PropertyName = "_DissolveMap", TextureName = "Eff_Noise_607" });
                textureConditions.Add(new TextureCondition { CurrentBodyType = HSRBodyTypes[i], Shader = Shader.Find(HoyoToonMaterialManager.HSRShader), PropertyName = "_DissolveMask", TextureName = "UI_Noise_29" });
            }
        }

        public static void HardsetTexture(Material newMaterial, string propertyName, Shader shader)
        {
            string currentBodyTypeString = HoyoToonParseManager.currentBodyType.ToString();

            if (!textureConditions.Any(condition => condition.Matches(currentBodyTypeString, shader, propertyName)))
            {
                HoyoToonLogs.WarningDebug($"No specific texture set for body type: {currentBodyTypeString}, shader: {shader.name}, property: {propertyName}, material: {newMaterial.name}");
                return;
            }

            foreach (var condition in textureConditions)
            {
                if (condition.Matches(currentBodyTypeString, shader, propertyName))
                {
                    Texture texture = Resources.Load<Texture>(condition.TextureName);
                    List<string> texturePaths = new List<string>();

                    if (texture == null)
                    {
                        string[] guids = AssetDatabase.FindAssets(condition.TextureName);
                        foreach (string guid in guids)
                        {
                            string path = AssetDatabase.GUIDToAssetPath(guid);
                            texture = AssetDatabase.LoadAssetAtPath<Texture>(path);
                            if (texture != null && texture.name == condition.TextureName)
                            {
                                texturePaths.Add(path);
                                break;
                            }
                        }
                    }

                    if (texture != null)
                    {
                        newMaterial.SetTexture(propertyName, texture);
                        SetTextureImportSettings(texturePaths);
                        return;
                    }
                    else
                    {
                        HoyoToonLogs.WarningDebug($"Texture not found with name: {condition.TextureName}");
                    }
                }
            }
        }

        public static void SetTextureImportSettings(IEnumerable<string> paths)
        {
            var pathsToReimport = new List<string>();

            AssetDatabase.StartAssetEditing();
            try
            {
                foreach (var path in paths)
                {
                    var texture = AssetDatabase.LoadAssetAtPath<Texture2D>(path);
                    if (texture == null) continue;

                    var importer = AssetImporter.GetAtPath(path) as TextureImporter;
                    if (importer == null) continue;

                    bool settingsChanged = false;

                    if (importer.textureType != TextureImporterType.Default)
                    {
                        importer.textureType = TextureImporterType.Default;
                        settingsChanged = true;
                    }

                    if (importer.textureCompression != TextureImporterCompression.Uncompressed)
                    {
                        importer.textureCompression = TextureImporterCompression.Uncompressed;
                        settingsChanged = true;
                    }

                    if (importer.mipmapEnabled)
                    {
                        importer.mipmapEnabled = false;
                        settingsChanged = true;
                    }

                    if (importer.streamingMipmaps)
                    {
                        importer.streamingMipmaps = false;
                        settingsChanged = true;
                    }

                    if (clampKeyword.Any(k => texture.name.IndexOf(k, System.StringComparison.InvariantCultureIgnoreCase) >= 0) && importer.wrapMode != TextureWrapMode.Clamp)
                    {
                        importer.wrapMode = TextureWrapMode.Clamp;
                        settingsChanged = true;
                    }

                    if (nonSRGBKeywords.Any(k => texture.name.IndexOf(k, System.StringComparison.InvariantCultureIgnoreCase) >= 0) && importer.sRGBTexture)
                    {
                        importer.sRGBTexture = false;
                        settingsChanged = true;
                    }

                    if (NonPower2Keywords.Any(k => texture.name.IndexOf(k, System.StringComparison.InvariantCultureIgnoreCase) >= 0) && importer.npotScale != TextureImporterNPOTScale.None)
                    {
                        importer.npotScale = TextureImporterNPOTScale.None;
                        settingsChanged = true;
                    }

                    if (EndsWithNonSRGBKeywords.Any(k => texture.name.EndsWith(k, System.StringComparison.InvariantCultureIgnoreCase)) && importer.sRGBTexture)
                    {
                        importer.sRGBTexture = false;
                        settingsChanged = true;
                    }

                    if (settingsChanged)
                    {
                        pathsToReimport.Add(path);
                    }
                }
            }
            finally
            {
                AssetDatabase.StopAssetEditing();
            }

            foreach (var path in pathsToReimport)
            {
                AssetDatabase.ImportAsset(path, ImportAssetOptions.ForceUpdate);
            }

            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
        }

        #endregion
    }
}