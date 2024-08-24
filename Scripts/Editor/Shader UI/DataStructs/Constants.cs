#if UNITY_EDITOR
namespace HoyoToon
{
    public class PATH
    {
        public const string TEXTURES_DIR = "Assets/textures";
        public const string RSP_NEEDED_PATH = "Assets/";

        public const string DELETING_DIR = "HoyoToon/trash";

        public const string PERSISTENT_DATA = "HoyoToon/persistent_data";

        public const string GRADIENT_INFO_FILE = "HoyoToon/gradients";

        public const string LINKED_MATERIALS_FILE = "HoyoToon/linked_materials.json";
    }

    public class URL
    {
        public const string MODULE_COLLECTION = "https://api.hoyotoon.com/packages.json";
        public const string SETTINGS_MESSAGE_URL = "https://api.hoyotoon.com/HoyoEditorSettingsWindow.json";
    }

    public class DEFINE_SYMBOLS
    {
        public const string IMAGING_EXISTS = "IMAGING_DLL_EXISTS";
    }

    public class RESOURCE_GUID
    {
        public const string RECT = "2329f8696fd09a743a5baf2a5f4986af";
        public const string ICON_LINK = "e85fd0a0e4e4fea46bb3fdeab5c3fb07";
        public const string ICON_HOYOTOON = "693aa4c2cdc578346a196469a06ddbba";
    }
}
#endif