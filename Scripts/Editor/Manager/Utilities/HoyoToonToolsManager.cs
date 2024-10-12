#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;

namespace HoyoToon
{
    public static class HoyoToonToolsManager
    {
        public static void CopyGUIDToClipboard()
        {
            Object selectedObject = Selection.activeObject;
            if (selectedObject == null)
            {
                HoyoToonLogs.ErrorDebug("No asset selected. Please select an asset to copy its GUID.");
                return;
            }

            string path = AssetDatabase.GetAssetPath(selectedObject);
            string guid = AssetDatabase.AssetPathToGUID(path);

            if (string.IsNullOrEmpty(guid))
            {
                HoyoToonLogs.WarningDebug("Failed to get GUID for the selected asset.");
                return;
            }

            EditorGUIUtility.systemCopyBuffer = guid;
            HoyoToonLogs.LogDebug($"GUID {guid} copied to clipboard for asset: {selectedObject.name}");
        }
    }   
}
#endif
