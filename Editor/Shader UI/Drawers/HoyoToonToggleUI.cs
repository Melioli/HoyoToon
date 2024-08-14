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
    public class HoyoToonToggleUIDrawer : HoyoToonToggleDrawer
    {
        public HoyoToonToggleUIDrawer()
        {
        }

        //the reason for weird string thing here is that you cant have bools as params for drawers
        public HoyoToonToggleUIDrawer(string keywordLeft)
        {
            if (keywordLeft == "true") left = true;
            else if (keywordLeft == "false") left = false;
            else keyword = keywordLeft;
        }

        public HoyoToonToggleUIDrawer(string keyword, string left)
        {
            this.keyword = keyword;
            this.left = left == "true";
        }
    }

}