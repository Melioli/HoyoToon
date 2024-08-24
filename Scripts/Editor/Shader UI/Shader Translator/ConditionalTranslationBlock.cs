#if UNITY_EDITOR
using System;

namespace HoyoToon.HoyoToonEditor.ShaderTranslations
{
    [Serializable]
    public class ConditionalTranslationBlock
    {
        public enum ConditionalBlockType
        {
            If
        }

        public ConditionalBlockType ConditionType = ConditionalBlockType.If;
        public string ConditionalExpression;
        public string MathExpression;
    }
}
#endif