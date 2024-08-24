#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;

namespace HoyoToon
{
    public class HoyoToonSeperatorDecorator : MaterialPropertyDrawer
    {
        Color _color = Styles.COLOR_FG;

        public HoyoToonSeperatorDecorator() { }
        public HoyoToonSeperatorDecorator(string c)
        {
            ColorUtility.TryParseHtmlString(c, out _color);
        }

        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            DrawingData.RegisterDecorator(this);
            return 1;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor)
        {
            position = EditorGUI.IndentedRect(position);
            EditorGUI.DrawRect(position, _color);
        }
    }
}
#endif