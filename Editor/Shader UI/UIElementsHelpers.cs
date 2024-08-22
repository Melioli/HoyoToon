#if UNITY_EDITOR
using UnityEngine.UIElements;

namespace HoyoToon.HoyoToonEditor
{
    internal static class UIElementsHelpers
    {
        public static void SetTextFieldReadonly(TextField field, bool isReadOnly)
        {
            field.isReadOnly = isReadOnly;
            field.style.opacity = isReadOnly ? 0.5f : 1f;
        }
    }
}
#endif