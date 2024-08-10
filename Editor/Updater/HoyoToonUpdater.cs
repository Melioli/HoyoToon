using UnityEngine;
using UnityEditor;
using Unity.EditorCoroutines.Editor;
using System.Collections;
using UnityEngine.Networking;
using System.IO;
using System;
using System.Linq;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json;
using System.Collections.Generic;

namespace HoyoToon
{
    [InitializeOnLoad]
    public class HoyoToonUpdater
    {
        #region Constants
        private const string githubApiUrl = "https://api.github.com/repos/Melioli/HoyoToon/releases";
        private const string packageJsonApiUrl = "https://api.github.com/repos/Melioli/HoyoToon/contents/package.json";

        private static string GetPackageJsonApiUrl()
        {
            return $"{packageJsonApiUrl}?t={DateTime.UtcNow.Ticks}";
        }

        private static readonly string localVersion = GetPackageVersion();

        #endregion

        #region Updater
        static HoyoToonUpdater()
        {
            HoyoToonPreferences.LoadPrefs();
            if (EditorPrefs.GetBool(HoyoToonPreferences.CheckForUpdatesPref, true))
            {
                HoyoToonLogs.LogDebug("Checking for updates on startup...");
                CheckForUpdates();
            }
        }

        [MenuItem("HoyoToon/Check for Updates", false, 70)]
        public static void CheckForUpdates()
        {
            EditorCoroutineUtility.StartCoroutineOwnerless(CheckVersionAndUpdateCoroutine());
        }

        private static IEnumerator CheckVersionAndUpdateCoroutine()
        {
            HoyoToonLogs.LogDebug("Starting version check...");

            // Fetch remote package.json using GitHub API with cache-busting
            string packageJsonUrl = GetPackageJsonApiUrl();
            UnityWebRequest packageRequest = UnityWebRequest.Get(packageJsonUrl);
            packageRequest.SetRequestHeader("User-Agent", "request");
            yield return packageRequest.SendWebRequest();

            if (packageRequest.result != UnityWebRequest.Result.Success)
            {
                HoyoToonLogs.ErrorDebug($"Failed to fetch remote package.json: {packageRequest.error}");
                yield break;
            }

            string remoteVersion;
            try
            {
                var jsonResponse = JObject.Parse(packageRequest.downloadHandler.text);
                string base64Content = jsonResponse["content"]?.ToString().Trim();
                string decodedContent = System.Text.Encoding.UTF8.GetString(Convert.FromBase64String(base64Content));
                var packageJson = JObject.Parse(decodedContent);
                remoteVersion = packageJson["version"]?.ToString().Trim();
            }
            catch (Exception ex)
            {
                HoyoToonLogs.ErrorDebug($"Error parsing remote package.json: {ex.Message}");
                yield break;
            }

            HoyoToonLogs.LogDebug("Local version: " + localVersion);
            HoyoToonLogs.LogDebug("Remote version: " + remoteVersion);

            if (IsNewerVersion(remoteVersion, localVersion))
            {
                HoyoToonLogs.LogDebug("New version available: " + remoteVersion);

                // Fetch all releases information
                UnityWebRequest releaseRequest = UnityWebRequest.Get(githubApiUrl);
                releaseRequest.SetRequestHeader("User-Agent", "request");
                yield return releaseRequest.SendWebRequest();

                if (releaseRequest.result != UnityWebRequest.Result.Success)
                {
                    HoyoToonLogs.ErrorDebug($"Failed to fetch release info: {releaseRequest.error}");
                    yield break;
                }

                List<GitHubRelease> releases;
                try
                {
                    releases = JsonConvert.DeserializeObject<List<GitHubRelease>>(releaseRequest.downloadHandler.text);
                }
                catch (Exception ex)
                {
                    HoyoToonLogs.ErrorDebug($"Error parsing release info: {ex.Message}");
                    yield break;
                }

                var matchingRelease = releases.FirstOrDefault(release => release.tag_name.Trim() == remoteVersion);

                if (matchingRelease != null)
                {
                    string downloadSize = matchingRelease.assets[0].size.ToString();
                    string bodyContent = matchingRelease.body;

                    // Categorize files
                    List<string> unityPackageFiles = new List<string>();
                    List<string> upmVpmFiles = new List<string>();

                    foreach (var asset in matchingRelease.assets)
                    {
                        if (asset.browser_download_url.EndsWith(".unitypackage"))
                        {
                            unityPackageFiles.Add(asset.browser_download_url);
                        }
                        else if (asset.browser_download_url.EndsWith(".zip"))
                        {
                            upmVpmFiles.Add(asset.browser_download_url);
                        }
                    }

                    HoyoToonUpdaterGUI.ShowWindow(
                        localVersion,
                        remoteVersion,
                        downloadSize,
                        bodyContent,
                        unityPackageFiles,
                        upmVpmFiles,
                        () => NotifyUpdateThroughVCC(),
                        () => UpdateThroughUPM(),
                        () => HoyoToonLogs.LogDebug("Update canceled by user.")
                    );
                }
                else
                {
                    HoyoToonLogs.ErrorDebug("No matching release found for the remote version.");
                }
            }
            else
            {
                HoyoToonLogs.LogDebug("You are using the latest version. Local version: " + localVersion + "\nRemote version: " + remoteVersion);
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

        private static IEnumerator DownloadAndUpdatePackage(GitHubRelease.Asset[] assets)
        {
            foreach (var asset in assets)
            {
                HoyoToonLogs.LogDebug($"Starting download for {asset.browser_download_url}...");

                UnityWebRequest packageRequest = UnityWebRequest.Get(asset.browser_download_url);
                string tempFilePath = Path.Combine(Application.temporaryCachePath, Path.GetFileName(asset.browser_download_url));
                packageRequest.downloadHandler = new DownloadHandlerFile(tempFilePath);
                yield return packageRequest.SendWebRequest();

                if (packageRequest.result != UnityWebRequest.Result.Success)
                {
                    HoyoToonLogs.ErrorDebug($"Failed to download {asset.browser_download_url}: {packageRequest.error}");
                    yield break;
                }

                HoyoToonLogs.LogDebug($"Download successful for {asset.browser_download_url}. Importing package...");

                if (EditorPrefs.GetBool(HoyoToonPreferences.AutoImportPref, true))
                {
                    HoyoToonLogs.LogDebug("Auto-importing package...");
                    AssetDatabase.ImportPackage(tempFilePath, false);
                    HoyoToonLogs.LogDebug("Package imported successfully.");
                }
                else
                {
                    AssetDatabase.ImportPackage(tempFilePath, true);
                    HoyoToonLogs.LogDebug("Auto-import is disabled. Please import the package manually.");
                }
            }
        }

        private static string GetPackageVersion()
        {
            string packageJsonPath = Path.Combine(Application.dataPath, "../Packages/com.meliverse.hoyotoon/package.json");
            if (File.Exists(packageJsonPath))
            {
                try
                {
                    string jsonText = File.ReadAllText(packageJsonPath);
                    JObject json = JObject.Parse(jsonText);
                    string version = json["version"]?.ToString();

                    return version ?? "0.0.0";
                }
                catch (Exception ex)
                {
                    HoyoToonLogs.ErrorDebug($"Error reading or parsing package.json: {ex.Message}");
                    return "0.0.0";
                }
            }
            else
            {
                HoyoToonLogs.WarningDebug($"package.json not found at: {packageJsonPath}");
                return "0.0.0";
            }
        }

        private static GitHubRelease.Asset[] ConvertToAssets(List<string> urls)
        {
            return urls.Select(url => new GitHubRelease.Asset { browser_download_url = url }).ToArray();
        }

        private static void NotifyUpdateThroughVCC()
        {
            EditorUtility.DisplayDialog("Update through VCC", "Please update the package through the Creator Companion.", "OK");
        }

        private static void UpdateThroughUPM()
        {
            EditorApplication.ExecuteMenuItem("Window/Package Manager");
            EditorApplication.delayCall += () =>
            {
                var packageManagerWindow = EditorWindow.GetWindow(Type.GetType("UnityEditor.PackageManager.UI.PackageManagerWindow,Unity.PackageManagerUI.Editor"));
                if (packageManagerWindow != null)
                {
                    var packageManager = packageManagerWindow.GetType().GetField("m_PackageManager", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance).GetValue(packageManagerWindow);
                    var packageList = packageManager.GetType().GetField("m_PackageList", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance).GetValue(packageManager);
                    var packageItems = packageList.GetType().GetField("m_Items", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance).GetValue(packageList) as IEnumerable;

                    foreach (var item in packageItems)
                    {
                        var packageInfo = item.GetType().GetProperty("packageInfo").GetValue(item);
                        if (packageInfo != null)
                        {
                            var packageName = packageInfo.GetType().GetProperty("name").GetValue(packageInfo).ToString();
                            if (packageName == "com.meliverse.hoyotoon")
                            {
                                var updateButton = item.GetType().GetField("m_UpdateButton", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance).GetValue(item);
                                if (updateButton != null)
                                {
                                    updateButton.GetType().GetMethod("OnClick").Invoke(updateButton, null);
                                    break;
                                }
                            }
                        }
                    }
                }
            };
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
}