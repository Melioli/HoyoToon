#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;
using System.Diagnostics;

namespace HoyoToon
{
    public class Helper : Editor
    {
        private static Stopwatch stopwatch = Stopwatch.StartNew();

        public static bool ClassWithNamespaceExists(string classname)
        {
            return (from assembly in AppDomain.CurrentDomain.GetAssemblies()
                    from type in assembly.GetTypes()
                    where type.FullName == classname
                    select type).Count() > 0;
        }

        public static Type FindTypeByFullName(string fullname)
        {
            return (from assembly in AppDomain.CurrentDomain.GetAssemblies()
                    from type in assembly.GetTypes()
                    where type.FullName == fullname
                    select type).FirstOrDefault();
        }

        private static readonly DateTime UnixEpoch = new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc);

        public static long GetCurrentUnixTimestampMillis()
        {
            return (long)(DateTime.UtcNow - UnixEpoch).TotalMilliseconds;
        }

        public static long DatetimeToUnixSeconds(DateTime time)
        {
            return (long)(time - UnixEpoch).TotalSeconds;
        }

        public static long GetUnityStartUpTimeStamp()
        {
            // Returns the time in milliseconds since the Stopwatch started (when the class was loaded)
            return GetCurrentUnixTimestampMillis() - stopwatch.ElapsedMilliseconds;
        }

        public static int CompareVersions(string v1, string v2)
        {
            v1 = v1.Replace(",", ".");
            v2 = v2.Replace(",", ".");
            Match v1_match = Regex.Match(v1, @"(a|b)?\d+((\.|a|b)\d+)*(a|b)?");
            Match v2_match = Regex.Match(v2, @"(a|b)?\d+((\.|a|b)\d+)*(a|b)?");
            if (!v1_match.Success && !v2_match.Success) return 0;
            else if (!v1_match.Success) return 1;
            else if (!v2_match.Success) return -1;
            v1 = v1_match.Value;
            v2 = v2_match.Value;

            int index_v1 = 0;
            int index_v2 = 0;
            string chunk_v1;
            string chunk_v2;
            while (index_v1 < v1.Length || index_v2 < v2.Length)
            {
                if (index_v1 < v1.Length)
                {
                    chunk_v1 = "";
                    if (v1[index_v1] == 'a')
                        chunk_v1 = "-2";
                    else if (v1[index_v1] == 'b')
                        chunk_v1 = "-1";
                    else
                    {
                        while (index_v1 < v1.Length && v1[index_v1] != 'a' && v1[index_v1] != 'b' && v1[index_v1] != '.')
                            chunk_v1 += v1[index_v1++];
                        if (index_v1 < v1.Length && (v1[index_v1] == 'a' || v1[index_v1] == 'b'))
                            index_v1--;
                    }
                    index_v1++;
                }
                else
                    chunk_v1 = "0";

                if (index_v2 < v2.Length)
                {
                    chunk_v2 = "";
                    if (v2[index_v2] == 'a')
                        chunk_v2 = "-2";
                    else if (v2[index_v2] == 'b')
                        chunk_v2 = "-1";
                    else
                    {
                        while (index_v2 < v2.Length && v2[index_v2] != 'a' && v2[index_v2] != 'b' && v2[index_v2] != '.')
                            chunk_v2 += v2[index_v2++];
                        if (index_v2 < v2.Length && (v2[index_v2] == 'a' || v2[index_v2] == 'b'))
                            index_v2--;
                    }
                    index_v2++;
                }
                else
                    chunk_v2 = "0";

                int v1P = int.Parse(chunk_v1);
                int v2P = int.Parse(chunk_v2);
                if (v1P > v2P) return -1;
                else if (v1P < v2P) return 1;
            }
            return 0;
        }

        public static bool IsPrimitive(Type t)
        {
            return t.IsPrimitive || t == typeof(Decimal) || t == typeof(String);
        }

        public static string GetStringBetweenBracketsAndAfterId(string input, string id, char[] brackets)
        {
            string[] parts = Regex.Split(input, id);
            if (parts.Length > 1)
            {
                char[] behind_id = parts[1].ToCharArray();
                int i = 0;
                int begin = 0;
                int end = behind_id.Length - 1;
                int depth = 0;
                bool escaped = false;
                while (i < behind_id.Length)
                {
                    if (behind_id[i] == brackets[0] && !escaped)
                    {
                        if (depth == 0)
                            begin = i;
                        depth++;
                    }
                    else if (behind_id[i] == brackets[1] && !escaped)
                    {
                        depth--;
                        if (depth == 0)
                        {
                            end = i;
                            break;
                        }
                    }

                    if (behind_id[i] == '\\')
                        escaped = !escaped;
                    else
                        escaped = false;
                    i++;
                }
                return parts[1].Substring(begin, end);
            }
            return input;
        }

        public static float SolveMath(string exp, float parameter)
        {
            exp = exp.Replace("x", parameter.ToString(CultureInfo.InvariantCulture));
            exp = exp.Replace(" ", "");
            float f;
            if (ExpressionEvaluator.Evaluate<float>(exp, out f)) return f;
            return 0;
        }

        public static float Mod(float a, float b)
        {
            return a - b * Mathf.Floor(a / b);
        }

        public static int LevenshteinDistance(string s, string t)
        {
            int n = s.Length;
            int m = t.Length;
            int[,] d = new int[n + 1, m + 1];
            if (n == 0)
            {
                return m;
            }
            if (m == 0)
            {
                return n;
            }
            for (int i = 0; i <= n; d[i, 0] = i++)
                ;
            for (int j = 0; j <= m; d[0, j] = j++)
                ;
            for (int i = 1; i <= n; i++)
            {
                for (int j = 1; j <= m; j++)
                {
                    int cost = (t[j - 1] == s[i - 1]) ? 0 : 1;
                    d[i, j] = Math.Min(
                        Math.Min(d[i - 1, j] + 1, d[i, j - 1] + 1),
                        d[i - 1, j - 1] + cost);
                }
            }
            return d[n, m];
        }

        static Dictionary<MethodInfo, byte[]> s_patchedData = new Dictionary<MethodInfo, byte[]>();
        public static unsafe void TryDetourFromTo(MethodInfo src, MethodInfo dst)
        {
#if UNITY_EDITOR_WIN
            try
            {
                if (IntPtr.Size == sizeof(Int64))
                {
                    long Source_Base = src.MethodHandle.GetFunctionPointer().ToInt64();
                    long Destination_Base = dst.MethodHandle.GetFunctionPointer().ToInt64();

                    IntPtr Source_IntPtr = src.MethodHandle.GetFunctionPointer();
                    var backup = new byte[0xC];
                    Marshal.Copy(Source_IntPtr, backup, 0, 0xC);
                    s_patchedData.Add(src, backup);

                    byte* Pointer_Raw_Source = (byte*)Source_Base;

                    long* Pointer_Raw_Address = (long*)(Pointer_Raw_Source + 0x02);

                    *(Pointer_Raw_Source + 0x00) = 0x48;
                    *(Pointer_Raw_Source + 0x01) = 0xB8;
                    *Pointer_Raw_Address = Destination_Base;
                    *(Pointer_Raw_Source + 0x0A) = 0xFF;
                    *(Pointer_Raw_Source + 0x0B) = 0xE0;
                }
                else
                {
                    int Source_Base = src.MethodHandle.GetFunctionPointer().ToInt32();
                    int Destination_Base = dst.MethodHandle.GetFunctionPointer().ToInt32();

                    IntPtr Source_IntPtr = src.MethodHandle.GetFunctionPointer();
                    var backup = new byte[0x5];
                    Marshal.Copy(Source_IntPtr, backup, 0, 0x5);
                    s_patchedData.Add(src, backup);

                    byte* Pointer_Raw_Source = (byte*)Source_Base;

                    int* Pointer_Raw_Address = (int*)(Pointer_Raw_Source + 1);

                    int offset = (Destination_Base - Source_Base) - 5;

                    *Pointer_Raw_Source = 0xE9;
                    *Pointer_Raw_Address = offset;
                }
            }
            catch (Exception ex)
            {
                HoyoToonLogs.ErrorDebug($"Unable to detour: {src?.Name ?? "UnknownSrc"} -> {dst?.Name ?? "UnknownDst"}\n{ex}");
                throw;
            }
#endif
        }
        public static unsafe void RestoreDetour(MethodInfo src)
        {
#if UNITY_EDITOR_WIN
            var Source_IntPtr = src.MethodHandle.GetFunctionPointer();
            var backup = s_patchedData[src];
            Marshal.Copy(backup, 0, Source_IntPtr, backup.Length);
            s_patchedData.Remove(src);
#endif
        }
        // End of Detour Methods

    }
}
#endif