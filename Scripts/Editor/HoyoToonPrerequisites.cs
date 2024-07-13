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
    private static string manifestPath = Path.Combine(Application.dataPath, "../Packages/manifest.json");
    private static bool pluginsFolderDeleted = false;
    private static bool prerequisitesChecked = false;

    static HoyoToonPrerequisites()
    {
        EditorApplication.update += CheckAndInstallPackagesOnLoad;
        EditorApplication.quitting += OnEditorQuitting;
        EditorApplication.update += DeletePluginsFolder;
        EditorApplication.update += PrerequisitesValidator;
    }

    private static void CheckAndInstallPackagesOnLoad()
    {
        EditorApplication.update -= CheckAndInstallPackagesOnLoad;
        if (ShouldCheckDependencies())
        {
            CheckAndInstallPackages();
        }
    }

    private static void CheckAndInstallPackages()
    {
        UnlockPackagesIfNeeded();
        listRequest = Client.List(true);
        EditorApplication.update += ListRequestProgress;
    }

    private static void ListRequestProgress()
    {
        if (listRequest.IsCompleted)
        {
            if (listRequest.Status == StatusCode.Success)
            {
                CheckMissingPackages();
                initialCheckPerformed = true;
            }
            else if (listRequest.Status >= StatusCode.Failure)
            {
                Debug.LogError("<color=purple>[Hoyotoon]</color> Failed to list packages: " + listRequest.Error.message);
            }

            EditorApplication.update -= ListRequestProgress;
        }
    }

    private static void CheckMissingPackages()
    {
        bool packagesInstalled = true;
        foreach (var packageName in PackagesToCheck)
        {
            bool packageFound = false;
            foreach (var package in listRequest.Result)
            {
                if (package.name == packageName)
                {
                    packageFound = true;
                    break;
                }
            }

            if (!packageFound)
            {
                packagesInstalled = false;
                PromptUserToInstallPackage(packageName);
            }
        }

        if (packagesInstalled)
        {
            Debug.Log("<color=purple>[Hoyotoon]</color> All required packages are already installed.");
        }
    }

    private static void PromptUserToInstallPackage(string packageName)
    {
        if (EditorUtility.DisplayDialog("Install Required Package",
                                        $"The package '{packageName}' is required for HoyoToon to work properly but not installed. Do you want to install it now?",
                                        "Yes", "No"))
        {
            InstallPackage(packageName);
        }
    }

    private static void InstallPackage(string packageName)
    {
        Debug.Log($"<color=purple>[Hoyotoon]</color> Installing {packageName} package...");
        var addRequest = Client.Add(packageName);
        EditorApplication.update += () => AddRequestProgress(addRequest, packageName);
    }

    private static void AddRequestProgress(AddRequest addRequest, string packageName)
    {
        if (addRequest.IsCompleted)
        {
            if (addRequest.Status == StatusCode.Success)
            {
                Debug.Log($"<color=purple>[Hoyotoon]</color> Successfully installed {addRequest.Result.packageId}");
                EditorUtility.DisplayDialog("Package Installed",
                                            $"The package '{addRequest.Result.packageId}' has been successfully installed.",
                                            "OK");
            }
            else if (addRequest.Status >= StatusCode.Failure)
            {
                Debug.LogError($"<color=purple>[Hoyotoon]</color> Failed to install {packageName}: {addRequest.Error.message}");
                EditorUtility.DisplayDialog("Package Installation Failed",
                                            $"Failed to install the package '{packageName}': {addRequest.Error.message}",
                                            "OK");
            }

            EditorApplication.update -= () => AddRequestProgress(addRequest, packageName);
        }
    }

    private static void UnlockPackagesIfNeeded()
    {
        if (File.Exists(manifestPath))
        {
            string manifestContent = File.ReadAllText(manifestPath);
            var manifest = JsonUtility.FromJson<Manifest>(manifestContent);

            bool manifestModified = false;
            foreach (var packageName in PackagesToCheck)
            {
                if (manifest.lockedDependencies != null && manifest.lockedDependencies.ContainsKey(packageName))
                {
                    if (EditorUtility.DisplayDialog("Unlock Required Package",
                                                    $"The package '{packageName}' is locked and required for HoyoToon to work properly. Do you want to unlock it?",
                                                    "Yes", "No"))
                    {
                        manifest.lockedDependencies.Remove(packageName);
                        manifestModified = true;
                        Debug.Log($"<color=purple>[Hoyotoon]</color> {packageName} package was locked. It has been unlocked.");
                    }
                }
            }

            if (manifestModified)
            {
                string modifiedManifestContent = JsonUtility.ToJson(manifest, true);
                File.WriteAllText(manifestPath, modifiedManifestContent);
                AssetDatabase.Refresh();
            }
        }
        else
        {
            Debug.LogError("<color=purple>[Hoyotoon]</color> Could not find manifest.json file.");
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

    private static void DeletePluginsFolder()
    {
        if (!pluginsFolderDeleted)
        {
            string scriptFolderPath = Path.Combine(Application.dataPath, "Hoyoverse/Shaders/HoyoToon/Scripts");
            string pluginsFolderPath = Path.Combine(scriptFolderPath, "Plugins");
            if (Directory.Exists(pluginsFolderPath))
            {
                Directory.Delete(pluginsFolderPath, true);
                string metaFilePath = pluginsFolderPath + ".meta";
                if (File.Exists(metaFilePath))
                {
                    File.Delete(metaFilePath);
                }
                Debug.Log("<color=purple>[Hoyotoon]</color> Outdated dependencies removed and plugins folder deleted.");
                pluginsFolderDeleted = true;
                AssetDatabase.Refresh();
            }
            else
            {
                pluginsFolderDeleted = true;
            }
        }
    }

    private static void OnEditorQuitting()
    {
        EditorApplication.update -= CheckAndInstallPackagesOnLoad;
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
                EditorUtility.DisplayDialog("Error", "The Color Space is currently set to Gamma. To ensure proper rendering, we'll set the Color Space to Linear.", "OK");
                Debug.LogError("<color=purple>[Hoyotoon]</color> The Color Space is currently set to Gamma. To ensure proper rendering, we'll set the Color Space to Linear.");

                PlayerSettings.colorSpace = ColorSpace.Linear;
                EditorUtility.DisplayDialog("Settings Updated", "The Color Space has been set to Linear. Unity will now initiate reloading its textures and lighting options.", "OK");
                Debug.Log("<color=purple>[Hoyotoon]</color> The Color Space has been set to Linear. Unity will now initiate reloading its textures and lighting options.");
            }

            if (QualitySettings.shadowProjection == ShadowProjection.CloseFit)
            {
                Debug.Log("<color=purple>[Hoyotoon]</color> The Shadow Projection is set to Close Fit.");
            }
            else
            {
                EditorUtility.DisplayDialog("Error", "The Shadow Projection is currently set to Stable Fit. To ensure high quality casted shadows inside the Unity Editor, we'll set the Shadow Projection to Close Fit.", "OK");
                Debug.LogError("<color=purple>[Hoyotoon]</color> The Shadow Projection is currently set to Stable Fit. To ensure high quality casted shadows inside the Unity Editor, we'll set the Shadow Projection to Close Fit.");

                QualitySettings.shadowProjection = ShadowProjection.CloseFit;
                EditorUtility.DisplayDialog("Settings Updated", "The Shadow Projection has been set to Close Fit.", "OK");
                Debug.Log("<color=purple>[Hoyotoon]</color> The Shadow Projection has been set to Close Fit.");
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
