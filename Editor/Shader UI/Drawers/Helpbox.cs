#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;

namespace HoyoToon
{
    public class HelpboxDrawer : MaterialPropertyDrawer
    {
        readonly MessageType type;

        public HelpboxDrawer()
        {
            type = MessageType.Info;
        }

        public HelpboxDrawer(float f)
        {
            type = (MessageType)(int)f;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
        {
            EditorGUILayout.HelpBox(label.text, type);
        }

        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            DrawingData.LastPropertyUsedCustomDrawer = true;
            return 0;
        }
    }

}
#endif