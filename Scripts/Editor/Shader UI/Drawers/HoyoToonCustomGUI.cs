#if UNITY_EDITOR
using System;
using System.Reflection;
using UnityEditor;
using UnityEngine;

namespace HoyoToon
{
    public class HoyoToonCustomGUIDrawer : MaterialPropertyDrawer
    {
        private MethodInfo _method;
        public HoyoToonCustomGUIDrawer(string type, string namespaceName, string method)
        {
            Type t = Type.GetType(type + ", " + namespaceName);
            if (t != null)
            {
                _method = t.GetMethod(method);
            }
        }

        public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
        {
            if (_method != null)
            {
                _method.Invoke(null, new object[] { position, prop, label, editor, ShaderEditor.Active });
            }
        }

        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            DrawingData.LastPropertyUsedCustomDrawer = true;
            return 0;
        }
    }

}
#endif