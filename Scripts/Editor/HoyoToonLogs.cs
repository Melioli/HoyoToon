using UnityEngine;
using UnityEditor;

namespace HoyoToon
{
    public static class HoyoToonLogs
    {
        private const string DebugEnabledKey = "HoyoToon_DebugEnabled";

        static HoyoToonLogs()
        {
            DebugEnabled = EditorPrefs.GetBool(DebugEnabledKey, false);
        }

        public static bool DebugEnabled { get; private set; }

        [MenuItem("HoyoToon/Toggle Debug", false, 0)]
        private static void ToggleDebug()
        {
            DebugEnabled = !DebugEnabled;
            EditorPrefs.SetBool(DebugEnabledKey, DebugEnabled);

            string status = DebugEnabled ? "enabled" : "disabled";
            EditorUtility.DisplayDialog("Debug Status", $"Debug mode has been {status}.", "OK");
            LogDebug($"Debug mode {status}");
        }

        public static void LogDebug(string message)
        {
            if (DebugEnabled)
            {
                Debug.Log($"<color=purple>[Hoyotoon]</color> {message}");
            }
        }

        public static void WarningDebug(string message)
        {
            if (DebugEnabled)
            {
                Debug.LogWarning($"<color=purple>[Hoyotoon]</color> {message}");
            }
        }

        public static void ErrorDebug(string message)
        {
            if (DebugEnabled)
            {
                Debug.LogError($"<color=purple>[Hoyotoon]</color> {message}");
            }
        }
    }

}