using UnityEngine;
using UnityEditor;
using Unity.EditorCoroutines.Editor;
using System.Collections;
using UnityEngine.Networking;
using System.IO;
using System;

[InitializeOnLoad]
public class HoyoToonUpdater

{
    #region Constants
    private const string githubApiUrl = "https://api.github.com/repos/Melioli/HoyoToon/releases/latest";
    private static readonly string version = HoyoToonManager.version;

    #endregion


    #region Updater
    static HoyoToonUpdater()
    {
        HoyoToonPreferences.LoadPrefs();
        if (EditorPrefs.GetBool(HoyoToonPreferences.CheckForUpdatesPref, true))
        {
            HoyoToonLogs.LogDebug("<color=purple>[Hoyotoon]</color> Checking for updates on startup...");
            CheckForUpdates();
        }
    }

    [MenuItem("HoyoToon/Check for Updates")]
    [MenuItem("Assets/HoyoToon/Check for Updates")]
    public static void CheckForUpdates()
    {
        EditorCoroutineUtility.StartCoroutineOwnerless(CheckVersionAndUpdateCoroutine());
    }

    private static IEnumerator CheckVersionAndUpdateCoroutine()
    {
        HoyoToonLogs.LogDebug("<color=purple>[Hoyotoon]</color> Starting version check...");

        UnityWebRequest versionRequest = UnityWebRequest.Get(githubApiUrl);
        versionRequest.SetRequestHeader("User-Agent", "request");
        yield return versionRequest.SendWebRequest();

        if (versionRequest.result != UnityWebRequest.Result.Success)
        {
            HoyoToonLogs.ErrorDebug($"<color=purple>[Hoyotoon]</color> Failed to fetch version: {versionRequest.error}, Response Code: {versionRequest.responseCode}");
            yield break;
        }

        var jsonResponse = JsonUtility.FromJson<GitHubRelease>(versionRequest.downloadHandler.text);
        string latestVersion = jsonResponse.tag_name.Trim();
        string packageUrl = jsonResponse.assets[0].browser_download_url;
        string downloadSize = jsonResponse.assets[0].size.ToString(); // Size in bytes
        string bodyContent = jsonResponse.body;

        HoyoToonLogs.LogDebug("<color=purple>[Hoyotoon]</color> Current version: " + version);
        HoyoToonLogs.LogDebug("<color=purple>[Hoyotoon]</color> Latest version: " + latestVersion);

        if (IsNewerVersion(latestVersion, version))
        {
            HoyoToonLogs.LogDebug("<color=purple>[Hoyotoon]</color> New version available: " + latestVersion);

            HoyoToonUpdaterGUI.ShowWindow(
                version,
                latestVersion,
                downloadSize,
                bodyContent,
                () => EditorCoroutineUtility.StartCoroutineOwnerless(DownloadAndUpdatePackage(packageUrl, latestVersion)),
                () => HoyoToonLogs.LogDebug("<color=purple>[Hoyotoon]</color> Update canceled by user.")
            );
        }
        else if (IsNewerVersion(version, latestVersion))
        {
            HoyoToonLogs.ErrorDebug("<color=purple>[Hoyotoon]</color> How the fuck is that even possible.... oh wait yeah developer.. ");
        }
        else
        {
            HoyoToonLogs.LogDebug("<color=purple>[Hoyotoon]</color> You are using the latest version. Current version: " + version + "\nLatest version: " + latestVersion);
        }
    }

    private static bool IsNewerVersion(string latestVersion, string version)
    {
        string[] latestParts = latestVersion.Split('.');
        string[] currentParts = version.Split('.');

        for (int i = 0; i < latestParts.Length; i++)
        {
            int latest = int.Parse(latestParts[i]);
            int current = int.Parse(currentParts[i]);
            if (latest > current)
            {
                return true;
            }
            else if (latest < current)
            {
                return false;
            }
        }
        return false;
    }

    private static IEnumerator DownloadAndUpdatePackage(string packageUrl, string latestVersion)
    {
        HoyoToonLogs.LogDebug("<color=purple>[Hoyotoon]</color> Starting package download...");

        UnityWebRequest packageRequest = UnityWebRequest.Get(packageUrl);
        string tempFilePath = Path.Combine(Application.temporaryCachePath, "Hoyotoon " + latestVersion + ".unitypackage");
        packageRequest.downloadHandler = new DownloadHandlerFile(tempFilePath);
        yield return packageRequest.SendWebRequest();

        if (packageRequest.result != UnityWebRequest.Result.Success)
        {
            HoyoToonLogs.ErrorDebug("<color=purple>[Hoyotoon]</color> Failed to download package: " + packageRequest.error);
            yield break;
        }

        HoyoToonLogs.LogDebug("<color=purple>[Hoyotoon]</color> Package download successful. Importing package...");

        if (EditorPrefs.GetBool(HoyoToonPreferences.AutoImportPref, true))
        {
            HoyoToonLogs.LogDebug("<color=purple>[Hoyotoon]</color> Auto-importing package...");
            AssetDatabase.ImportPackage(tempFilePath, false);
            HoyoToonLogs.LogDebug("<color=purple>[Hoyotoon]</color> Package imported successfully.");
        }
        else
        {
            AssetDatabase.ImportPackage(tempFilePath, true);
            HoyoToonLogs.LogDebug("<color=purple>[Hoyotoon]</color> Auto-import is disabled. Please import the package manually.");
        }
    }

    [Serializable]
    public class GitHubRelease
    {
        public string tag_name;
        public string body;
        public Asset[] assets;

        [Serializable]
        public class Asset
        {
            public string browser_download_url;
            public long size;
        }
    }

    #endregion
}
