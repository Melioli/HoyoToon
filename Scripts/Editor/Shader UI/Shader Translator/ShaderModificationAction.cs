#if UNITY_EDITOR
using System;
using System.Collections;
using System.Collections.Generic;

namespace HoyoToon.HoyoToonEditor.ShaderTranslations
{
    [Serializable]
    public class ShaderModificationAction
    {
        public enum ActionType
        {
            ChangeTargetShader,
            SetTargetPropertyValue,
        }

        public ActionType actionType;
        public string propertyName;
        public string targetValue;
    }
}
#endif