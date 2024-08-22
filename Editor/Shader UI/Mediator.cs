#if UNITY_EDITOR
using UnityEngine;

namespace HoyoToon
{
    public class Mediator
    {

        private static Material m_copy;
        public static Material copy_material
        {
            set
            {
                m_copy = value;
            }
            get
            {
                return m_copy;
            }
        }

        public static ShaderPart transfer_group;
    }
}
#endif