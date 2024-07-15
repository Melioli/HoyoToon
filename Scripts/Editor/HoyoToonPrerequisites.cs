using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEditor.PackageManager;
using UnityEditor.PackageManager.Requests;
using UnityEngine;

[InitializeOnLoad]
public static class HoyoToonPrerequisites
{
    private static readonly string[] PackagesToCheck = {
        "com.unity.nuget.newtonsoft-json",
        "com.unity.editorcoroutines"
    };

    private static bool initialCheckPerformed = false;
    private static ListRequest listRequest;
    private static bool prerequisitesChecked = false;

    static HoyoToonPrerequisites()
    {
        EditorApplication.update += CheckAndUninstallPackagesOnLoad;
        EditorApplication.update += PrerequisitesValidator;
        EditorApplication.quitting += OnEditorQuitting;
    }

    private static void CheckAndUninstallPackagesOnLoad()
    {
        EditorApplication.update -= CheckAndUninstallPackagesOnLoad;
        if (ShouldCheckDependencies())
        {
            CheckAndUninstallPackages();
        }
    }

    private static void CheckAndUninstallPackages()
    {
        listRequest = Client.List(true);
        EditorApplication.update += ListRequestProgress;
    }

    private static void ListRequestProgress()
    {
        if (listRequest.IsCompleted)
        {
            if (listRequest.Status == StatusCode.Success)
            {
                CheckUnnecessaryPackages();
                initialCheckPerformed = true;
            }
            EditorApplication.update -= ListRequestProgress;
        }
    }

    private static void CheckUnnecessaryPackages()
    {
        foreach (var packageName in PackagesToCheck)
        {
            foreach (var package in listRequest.Result)
            {
                if (package.name == packageName)
                {
                    PromptUserToUninstallPackage(packageName);
                    break;
                }
            }
        }
    }

    private static void PromptUserToUninstallPackage(string packageName)
    {
        if (EditorUtility.DisplayDialog("Duplicate Package Detected",
                                        $"The package '{packageName}' is installed but detected as a duplicate and could cause issues with HoyoToon since it's already packaged with the shader. Do you want to uninstall it?",
                                        "Yes", "No"))
        {
            UninstallPackage(packageName);
        }
    }

    private static void UninstallPackage(string packageName)
    {
        Debug.Log($"<color=purple>[Hoyotoon]</color> Uninstalling {packageName} package...");
        var removeRequest = Client.Remove(packageName);
        EditorApplication.update += () => RemoveRequestProgress(removeRequest, packageName);
    }

    private static void RemoveRequestProgress(RemoveRequest removeRequest, string packageName)
    {
        if (removeRequest.IsCompleted)
        {
            if (removeRequest.Status == StatusCode.Success)
            {
                EditorUtility.DisplayDialog("Package Uninstalled", $"The package '{packageName}' has been successfully uninstalled.", "OK");
                Debug.Log($"<color=purple>[Hoyotoon]</color> Successfully uninstalled {packageName}");
            }
            else
            {
                EditorUtility.DisplayDialog("Error", $"Failed to uninstall {packageName}: {removeRequest.Error.message}", "OK");
                Debug.LogError($"<color=purple>[Hoyotoon]</color> Failed to uninstall {packageName}: {removeRequest.Error.message}");
            }
            EditorApplication.update -= () => RemoveRequestProgress(removeRequest, packageName);
        }
    }

    private static bool ShouldCheckDependencies()
    {
        return !initialCheckPerformed || CheckForMissingNamespaceErrors();
    }

    private static bool CheckForMissingNamespaceErrors()
    {
        string[] logEntries = File.ReadAllLines(EditorApplication.applicationContentsPath + "/Unity/Editor/Editor.log");

        foreach (string logEntry in logEntries)
        {
            foreach (var packageName in PackagesToCheck)
            {
                if (logEntry.Contains($"The type or namespace name '{packageName}' could not be found"))
                {
                    return true;
                }
            }
        }

        return false;
    }

    private static void OnEditorQuitting()
    {
        EditorApplication.update -= CheckAndUninstallPackages;
        EditorApplication.quitting -= OnEditorQuitting;
    }

    private static void PrerequisitesValidator()
    {
        if (!prerequisitesChecked)
        {
            if (PlayerSettings.colorSpace == ColorSpace.Linear)
            {
                Debug.Log("<color=purple>[Hoyotoon]</color> The Color Space is set to Linear.");
            }
            else
            {
                EditorUtility.DisplayDialog("Error", "The Color Space is currently set to Gamma. To ensure proper rendering, we'll set the Color Space to Linear. Unity will then initiate reloading its textures and lighting options.", "OK");
                Debug.LogError("<color=purple>[Hoyotoon]</color> The Color Space is currently set to Gamma. To ensure proper rendering, we'll set the Color Space to Linear. Unity will then initiate reloading its textures and lighting options.");

                PlayerSettings.colorSpace = ColorSpace.Linear;
                EditorUtility.DisplayDialog("Settings Updated", "The Color Space has been set to Linear.", "OK");
                Debug.Log("<color=purple>[Hoyotoon]</color> The Color Space has been set to Linear.");
            }
            if (QualitySettings.shadowProjection == ShadowProjection.CloseFit)
            {
                Debug.Log("<color=purple>[Hoyotoon]</color> The Shadow Projection is set to Close Fit.");
            }
            else
            {
                if (EditorUserBuildSettings.activeBuildTarget != BuildTarget.StandaloneWindows)
                {
                    Debug.Log("<color=purple>[Hoyotoon]</color> Different Build Target detected. Skipping Shadow Projection check.");
                }
                else
                {
                    EditorUtility.DisplayDialog("Error", "The Shadow Projection is currently set to Stable Fit. To ensure high quality casted shadows inside the Unity Editor, we'll set the Shadow Projection to Close Fit.", "OK");
                    Debug.LogError("<color=purple>[Hoyotoon]</color> The Shadow Projection is currently set to Stable Fit. To ensure high quality casted shadows inside the Unity Editor, we'll set the Shadow Projection to Close Fit.");

                    QualitySettings.shadowProjection = ShadowProjection.CloseFit;
                    EditorUtility.DisplayDialog("Settings Updated", "The Shadow Projection has been set to Close Fit.", "OK");
                    Debug.Log("<color=purple>[Hoyotoon]</color> The Shadow Projection has been set to Close Fit.");
                }
            }

            prerequisitesChecked = true;
        }
    }

    [System.Serializable]
    private class Manifest
    {
        public Dictionary<string, string> dependencies;
        public Dictionary<string, string> lockedDependencies;
    }
}
