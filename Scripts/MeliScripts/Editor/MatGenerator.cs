//This work is licensed under the Creative Commons Attribution-NonCommercial 2.0 License. 
//To view a copy of the license, visit https://creativecommons.org/licenses/by-nc/2.0/legalcode

//Made by Meliodas (FinalityMeli)
//Discord: https://discord.gg/VDzZERg6U4
//Github: https://github.com/Melioli/HoyoToon

using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.Linq;
using System.Text.RegularExpressions;
using System.IO;
using System.Globalization;
public class MatGenerator
{
    #region constants
    private const string gishader = "HoyoToon/Genshin";
    private const string hsrshader = "HoyoToon/StarRail";
    private const string hi3shader = "HoyoToon/Honkai";


    private const string regexFaceNameMatchPatternGI = @"(?i)face";
    private const string regexweaponNameMatchPatternGI = @"(?i)equip";
    private const string regexFaceNameMatchPatternHSR = @"(?i)face$";
    private const string regexBody1NameMatchPatternHSR = @"(?i)body1";
    private const string regexBody2NameMatchPatternHSR = @"(?i)body2";
    private const string regexBody1TransNameMatchPatternHSR = @"(?i)body1_trans";
    private const string regexBody2TransNameMatchPatternHSR = @"(?i)body2_trans";
    private const string regexHairNameMatchPatternHSR = @"(?i)hair";
    private const string regexweaponNameMatchPatternHSR = @"(?i)weapon";
    private const string regexphoneNameMatchPatternHSR = @"(?i)phone";
    private const string regexEyeShadowNameMatchPatternHSR = @"(?i)eyeshadow";
    private const string regexFaceShadowMaskMatchPatternHSR = @"(?i)facemask";
    

    #endregion

    [MenuItem("Assets/HoyoToon/Generate GI Materials")]
    private static void CreateMaterialsGI()
    {
        try
        {
            AssetDatabase.StartAssetEditing();
            foreach (var jsonAsset in GetAssetSelectionPaths().Select(AssetDatabase.LoadAssetAtPath<TextAsset>).Where(o => o))
            {
                if (!jsonAsset) continue;
                string json = jsonAsset.text;
                bool isFace = Regex.Match(jsonAsset.name, regexFaceNameMatchPatternGI).Success;
                bool isWeapon = Regex.Match(jsonAsset.name, regexweaponNameMatchPatternGI).Success;
                Shader shader = Shader.Find(gishader);
                Material newMat = new Material(shader);

                string floatsInfo = GetScope(json, "m_Floats");
                var floatMatches = Regex.Matches(floatsInfo, @"""(.*?)"": (.*?),");
                for (int i = 0; i < floatMatches.Count; i++)
                {
                    var m = floatMatches[i];
                    if (m.Success)
                    {
                        string floatName = m.Groups[1].Value;
                        string floatInfo = m.Groups[2].Value;
                        if (string.IsNullOrWhiteSpace(floatName) || string.IsNullOrWhiteSpace(floatInfo)) continue;
                        float.TryParse(floatInfo, out float value);
                        newMat.SetFloat(floatName, value);
                    }
                }

                string colorsInfo = GetScope(json, "m_Colors");
                var colorMatches = Regex.Matches(colorsInfo, @"""(.*?)"": ?{(.*?)}", RegexOptions.Singleline);
                for (int i = 0; i < colorMatches.Count; i++)
                {
                    var m = colorMatches[i];
                    string colorName = m.Groups[1].Value;
                    string colorInfo = m.Groups[2].Value;

                    if (string.IsNullOrWhiteSpace(colorName) || string.IsNullOrWhiteSpace(colorInfo)) continue;

                    float GetColorValue(char channel)
                    {
                        var m2 = Regex.Match(colorInfo, $@"""{channel}"": ?(\d*\.?\d+)(,|\s|\n|\r|$)");
                        if (!m2.Success) return 0;

                        float.TryParse(m2.Groups[1].Value, NumberStyles.Float, CultureInfo.InvariantCulture, out float value);
                        return value;
                    }

                    Color color = new Color(GetColorValue('r'), GetColorValue('g'), GetColorValue('b'), GetColorValue('a'));

                    newMat.SetColor(colorName, color);
                }

                if (isFace)
                {   
                    newMat.SetColor("_headForwardVector", new Color(0, 0, 1, 0));
                    newMat.SetColor("_headRightVector", new Color(1, 0, 0, 0));
                    newMat.SetInt("variant_selector", 1);
                }
                else if (isWeapon)
                {
                    newMat.SetInt("variant_selector", 2);
                }
                else
                {
                    newMat.SetInt("variant_selector", 0);
                }

                var jsonPath = AssetDatabase.GetAssetPath(jsonAsset);
                var materialsFolder = Path.GetDirectoryName(jsonPath);

                AssetDatabase.CreateAsset(newMat, AssetDatabase.GenerateUniqueAssetPath($"{materialsFolder}/{jsonAsset.name}.mat"));
            }
        }
        finally { AssetDatabase.StopAssetEditing(); }
    }

    [MenuItem("Assets/HoyoToon/Generate HSR Materials")]
    private static void CreateMaterialsHSR()
    {
        try
        {
            AssetDatabase.StartAssetEditing();
            foreach (var jsonAsset in GetAssetSelectionPaths().Select(AssetDatabase.LoadAssetAtPath<TextAsset>).Where(o => o))
            {
                if (!jsonAsset) continue;
                string json = jsonAsset.text;
                bool isFace = Regex.Match(jsonAsset.name, regexFaceNameMatchPatternHSR).Success;
                bool isBody1 = !isFace && Regex.Match(jsonAsset.name, regexBody1NameMatchPatternHSR).Success;
                bool isBody2 = !isFace && Regex.Match(jsonAsset.name, regexBody2NameMatchPatternHSR).Success;
                bool isBody1Trans = Regex.Match(jsonAsset.name, regexBody1TransNameMatchPatternHSR).Success;
                bool isBody2Trans = Regex.Match(jsonAsset.name, regexBody2TransNameMatchPatternHSR).Success;
                bool isHair = Regex.Match(jsonAsset.name, regexHairNameMatchPatternHSR).Success;
                bool isWeapon = Regex.Match(jsonAsset.name, regexweaponNameMatchPatternHSR).Success;
                bool isPhone = Regex.Match(jsonAsset.name, regexphoneNameMatchPatternHSR).Success;
                bool isEyeShadow = Regex.Match(jsonAsset.name, regexEyeShadowNameMatchPatternHSR).Success;
                bool IsFaceMask = Regex.Match(jsonAsset.name, regexFaceShadowMaskMatchPatternHSR).Success;
                Shader shader = Shader.Find(hsrshader);
                Material newMat = new Material(shader);

                string floatsInfo = GetScope(json, "m_Floats");
                var floatMatches = Regex.Matches(floatsInfo, @"""(.*?)"": (.*?),");
                for (int i = 0; i < floatMatches.Count; i++)
                {
                    var m = floatMatches[i];
                    if (m.Success)
                    {
                        string floatName = m.Groups[1].Value;
                        string floatInfo = m.Groups[2].Value;
                        if (string.IsNullOrWhiteSpace(floatName) || string.IsNullOrWhiteSpace(floatInfo)) continue;
                        float.TryParse(floatInfo, out float value);
                        newMat.SetFloat(floatName, value);
                    }
                }

                string colorsInfo = GetScope(json, "m_Colors");
                var colorMatches = Regex.Matches(colorsInfo, @"""(.*?)"": ?{(.*?)}", RegexOptions.Singleline);
                for (int i = 0; i < colorMatches.Count; i++)
                {
                    var m = colorMatches[i];
                    string colorName = m.Groups[1].Value;
                    string colorInfo = m.Groups[2].Value;

                    if (string.IsNullOrWhiteSpace(colorName) || string.IsNullOrWhiteSpace(colorInfo)) continue;

                    float GetColorValue(char channel)
                    {
                        var m2 = Regex.Match(colorInfo, $@"""{channel}"": ?(\d*\.?\d+)(,|\s|\n|\r|$)");
                        if (!m2.Success) return 0;

                        float.TryParse(m2.Groups[1].Value, NumberStyles.Float, CultureInfo.InvariantCulture, out float value);
                        return value;
                    }

                    Color color = new Color(GetColorValue('r'), GetColorValue('g'), GetColorValue('b'), GetColorValue('a'));

                    newMat.SetColor(colorName, color);
                }

                if (isFace)
                {   
                    newMat.SetColor("_headForwardVector", new Color(0, 0, 1, 0));
                    newMat.SetColor("_headRightVector", new Color(1, 0, 0, 0));
                    newMat.SetInt("variant_selector", 1);
                    newMat.SetInt("_BaseMaterial", 0);
                    newMat.SetInt("_HairMaterial", 0);
                    newMat.SetInt("_FaceMaterial", 1);
                    newMat.SetInt("_EyeShadowMat", 0);
                    newMat.SetInt("_CullMode", 2);
                    newMat.SetInt("_SrcBlend", 1);
                    newMat.SetInt("_DstBlend", 0);
                    newMat.SetInt("_StencilPassA", 0);
                    newMat.SetInt("_StencilPassB", 2);
                    newMat.SetInt("_StencilCompA", 5);
                    newMat.SetInt("_StencilCompB", 5);
                    newMat.SetInt("_StencilRef", 100);
                    newMat.renderQueue = 2010;
                }
                else if (isEyeShadow)
                {
                    newMat.SetInt("variant_selector", 2);
                    newMat.SetInt("_BaseMaterial", 0);
                    newMat.SetInt("_HairMaterial", 0);
                    newMat.SetInt("_FaceMaterial", 0);
                    newMat.SetInt("_EyeShadowMat", 1);
                    newMat.SetInt("_CullMode", 0);
                    newMat.SetInt("_SrcBlend", 2);
                    newMat.SetInt("_DstBlend", 0);
                    newMat.SetInt("_StencilPassA", 0);
                    newMat.SetInt("_StencilPassB", 2);
                    newMat.SetInt("_StencilCompA", 0);
                    newMat.SetInt("_StencilCompB", 8);
                    newMat.SetInt("_StencilRef", 0);
                    newMat.renderQueue = 2015;
                }
                else if (isHair)
                {
                    newMat.SetInt("variant_selector", 3);
                    newMat.SetInt("_BaseMaterial", 0);
                    newMat.SetInt("_HairMaterial", 1);
                    newMat.SetInt("_FaceMaterial", 0);
                    newMat.SetInt("_EyeShadowMat", 0);
                    newMat.SetInt("_CullMode", 0);
                    newMat.SetInt("_SrcBlend", 1);
                    newMat.SetInt("_DstBlend", 0);
                    newMat.SetInt("_StencilPassA", 0);
                    newMat.SetInt("_StencilPassB", 0);
                    newMat.SetInt("_StencilCompA", 5);
                    newMat.SetInt("_StencilCompB", 8);
                    newMat.SetInt("_StencilRef", 100);
                    newMat.renderQueue = 2020;

                }
                else if (IsFaceMask)
                {
                    newMat.SetInt("variant_selector", 1);
                    newMat.SetInt("_BaseMaterial", 0);
                    newMat.SetInt("_HairMaterial", 0);
                    newMat.SetInt("_FaceMaterial", 1);
                    newMat.SetInt("_EyeShadowMat", 0);
                    newMat.SetInt("_CullMode", 0);
                    newMat.SetInt("_SrcBlend", 1);
                    newMat.SetInt("_DstBlend", 0);
                    newMat.SetInt("_StencilPassA", 0);
                    newMat.SetInt("_StencilPassB", 2);
                    newMat.SetInt("_StencilCompA", 5);
                    newMat.SetInt("_StencilCompB", 5);
                    newMat.SetInt("_StencilRef", 99);
                    newMat.SetInt("_OutlineWidth", 0);
                    newMat.renderQueue = 2010;   
                }
                else if (isBody1Trans || isBody2Trans)
                {
                    newMat.SetInt("_IsTransparent", 1);
                    newMat.SetInt("variant_selector", 0);
                    newMat.SetInt("_BaseMaterial", 1);
                    newMat.SetInt("_HairMaterial", 0);
                    newMat.SetInt("_FaceMaterial", 0);
                    newMat.SetInt("_EyeShadowMat", 0);
                    newMat.SetInt("_CullMode", 0);
                    newMat.SetInt("_SrcBlend", 5);
                    newMat.SetInt("_DstBlend", 10);
                    newMat.SetInt("_StencilPassA", 2);
                    newMat.SetInt("_StencilPassB", 0);
                    newMat.SetInt("_StencilCompA", 0);
                    newMat.SetInt("_StencilCompB", 0);
                    newMat.SetInt("_StencilRef", 0);
                    newMat.renderQueue = 2040;
                }
                else
                {
                    newMat.SetInt("variant_selector", 0);
                    newMat.SetInt("_BaseMaterial", 1);
                    newMat.SetInt("_HairMaterial", 0);
                    newMat.SetInt("_FaceMaterial", 0);
                    newMat.SetInt("_EyeShadowMat", 0);
                    newMat.SetInt("_CullMode", 0);
                    newMat.SetInt("_SrcBlend", 5);
                    newMat.SetInt("_DstBlend", 10);
                    newMat.SetInt("_StencilPassA", 2);
                    newMat.SetInt("_StencilPassB", 0);
                    newMat.SetInt("_StencilCompA", 0);
                    newMat.SetInt("_StencilCompB", 0);
                    newMat.SetInt("_StencilRef", 0);
                    newMat.renderQueue = 2040;
                }

                var jsonPath = AssetDatabase.GetAssetPath(jsonAsset);
                var materialsFolder = Path.GetDirectoryName(jsonPath);

                AssetDatabase.CreateAsset(newMat, AssetDatabase.GenerateUniqueAssetPath($"{materialsFolder}/{jsonAsset.name}.mat"));
            }
        }
        finally { AssetDatabase.StopAssetEditing(); }
    }

    private static string GetScope(string text, string id)
    {
        if (string.IsNullOrWhiteSpace(text)) return string.Empty;
        int currentIndex = text.IndexOf(id);
        if (currentIndex != -1)
        {
            currentIndex = text.IndexOf('{', currentIndex);
            if (currentIndex != -1)
            {
                int startIndex = currentIndex + 1;
                int enclosureIndex;
                int openingIndex;
                int n = 0;
                do
                {
                    n++;
                    currentIndex++;
                    openingIndex = text.IndexOf('{', currentIndex);
                    currentIndex = enclosureIndex = text.IndexOf('}', currentIndex);
                } while (n != 50000 && enclosureIndex != -1 && (enclosureIndex > openingIndex && openingIndex != -1));

                if (n == 50000) throw new Exception("Unexpected Parsing Error");
                if (enclosureIndex != -1)
                {
                    string scopeText = text.Substring(startIndex, enclosureIndex - startIndex);
                    return scopeText;
                }
            }
        }

        return string.Empty;
    }

    private static IEnumerable<string> GetAssetSelectionPaths()
        => Selection.assetGUIDs.Select(AssetDatabase.GUIDToAssetPath);

}
