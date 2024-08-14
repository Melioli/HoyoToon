using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using UnityEditor;
using UnityEngine;
using static HoyoToon.GradientEditor;
using static HoyoToon.TexturePacker;

namespace HoyoToon
{
    public class HoyoToonRichLabelDrawer : MaterialPropertyDrawer
    {
        readonly int _size;
        GUIStyle _style;

        public HoyoToonRichLabelDrawer(float size)
        {
            this._size = (int)size;
        }

        public HoyoToonRichLabelDrawer() : this(EditorStyles.standardFont.fontSize) { }

        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return _size + 4;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor)
        {
            // Done here instead of constructor because else unity throws warnings
            if (_style == null)
            {
                _style = new GUIStyle(EditorStyles.boldLabel);
                _style.richText = true;
                _style.fontSize = this._size;
            }

            float offst = position.height;
            position = EditorGUI.IndentedRect(position);
            GUI.Label(position, label, _style);
        }
    }

}