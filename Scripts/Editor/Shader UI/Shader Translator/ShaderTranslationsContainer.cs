#if UNITY_EDITOR
using System;
using System.Collections.Generic;

namespace HoyoToon.HoyoToonEditor.ShaderTranslations
{
    [Serializable]
    public class ShaderTranslationsContainer
    {
        public string containerName = "Properties";
        public List<PropertyTranslation> PropertyTranslations = new List<PropertyTranslation>();
    }
}
#endif