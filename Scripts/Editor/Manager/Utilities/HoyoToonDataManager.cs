#if UNITY_EDITOR
using System;
using System.IO;
using System.Net.Http;
using Newtonsoft.Json;
using System.Collections.Generic;

namespace HoyoToon
{
    public static class HoyoToonDataManager
    {
        static string packageName = "com.meliverse.hoyotoon";
        static string packagePath = Path.Combine(HoyoToonParseManager.GetPackagePath(packageName), "Scripts/Editor/Manager");
        private static readonly string cacheFilePath = Path.Combine(packagePath, "HoyoToonManager.json");
        private static readonly string url = "https://api.hoyotoon.com/HoyoToonManager.json";
        private static HoyoToonData hoyoToonData;
        public static string HSRShader => GetShaderPath("HSRShader");
        public static string GIShader => GetShaderPath("GIShader");
        public static string Hi3Shader => GetShaderPath("Hi3Shader");
        public static string Hi3P2Shader => GetShaderPath("Hi3P2Shader");
        public static string WuWaShader => GetShaderPath("WuWaShader");

        static HoyoToonDataManager()
        {
            Initialize();
        }

        private static void Initialize()
        {
            hoyoToonData = GetHoyoToonData();
        }

        public static HoyoToonData Data => hoyoToonData;

        public static HoyoToonData GetHoyoToonData()
        {
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    string json = client.GetStringAsync(url).Result;
                    CacheJson(json);
                    HoyoToonLogs.LogDebug("Successfully retrieved HoyoToon data from the server.");
                    return JsonConvert.DeserializeObject<HoyoToonData>(json);
                }
            }
            catch (Exception ex)
            {
                HoyoToonLogs.ErrorDebug($"Failed to get HoyoToon data from the server. Using cached data. Exception: {ex.Message}, StackTrace: {ex.StackTrace}");
                return ReadFromCache();
            }
        }

        private static void CacheJson(string json)
        {
            string directoryPath = Path.GetDirectoryName(cacheFilePath);
            if (!Directory.Exists(directoryPath))
            {
                Directory.CreateDirectory(directoryPath);
            }

            File.WriteAllText(cacheFilePath, json);
        }

        private static HoyoToonData ReadFromCache()
        {
            if (File.Exists(cacheFilePath))
            {
                string json = File.ReadAllText(cacheFilePath);
                return JsonConvert.DeserializeObject<HoyoToonData>(json);
            }

            return new HoyoToonData();
        }

        private static string GetShaderPath(string shaderKey)
        {
            HoyoToonLogs.LogDebug($"Retrieving shader path for key: {shaderKey}");
            if (Data.Shaders.TryGetValue(shaderKey, out var paths))
            {
                HoyoToonLogs.LogDebug($"Shader path found: {paths[0]}");
                return paths[0];
            }
            HoyoToonLogs.LogDebug($"No shader path found for key: {shaderKey}");
            return null;
        }
    }

    public class HoyoToonData
    {
        public TexturesData Textures { get; set; }
        public Dictionary<string, string[]> Shaders { get; set; }
        public Dictionary<string, string[]> ShaderKeywords { get; set; }
        public string[] SkipMeshes { get; set; }
        public Dictionary<string, Dictionary<string, Dictionary<string, object>>> MaterialSettings { get; set; }

        public class TexturesData
        {
            public string[] ClampKeyword { get; set; }
            public string[] NonSRGBKeywords { get; set; }
            public string[] EndsWithNonSRGBKeywords { get; set; }
            public string[] NonPower2Keywords { get; set; }
        }
    }
}
#endif