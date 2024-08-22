#if UNITY_EDITOR
using System;

namespace HoyoToon
{
    public class RemoteMessageDrawer : LocalMessageDrawer
    {

        protected override void Init(string s)
        {
            if (_isInit) return;
            WebHelper.DownloadStringASync(s, (Action<string>)((string data) =>
            {
                _buttonData = Parser.Deserialize<ButtonData>(data);
            }));
            _isInit = true;
        }
    }

}
#endif