#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;

namespace HoyoToon
{
    public class sRGBWarningDecorator : MaterialPropertyDrawer
    {
        bool _isSRGB = true;

        public sRGBWarningDecorator()
        {
            _isSRGB = false;
        }

        public sRGBWarningDecorator(string shouldHaveSRGB)
        {
            this._isSRGB = shouldHaveSRGB.ToLower() == "true";
        }

        public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
        {
            if (Config.Singleton.showColorspaceWarnings)
                GUILib.ColorspaceWarning(prop, _isSRGB);
        }

        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            DrawingData.RegisterDecorator(this);
            return 0;
        }
    }
}
#endif