using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.Reflection;
using System.IO;
using System.Linq;

namespace HoyoToon
{
    public class HoyoToonMeshManager
    {
        private static readonly List<string> SkipTangentMeshes = new List<string>(HoyoToonDataManager.Data.SkipMeshes);

        #region FBX Setup

        public static void SetFBXImportSettings(IEnumerable<string> paths)
        {
            bool changesMade = false;

            AssetDatabase.StartAssetEditing();
            try
            {
                foreach (var p in paths)
                {
                    var fbx = AssetDatabase.LoadAssetAtPath<Mesh>(p);
                    if (!fbx) continue;

                    ModelImporter importer = AssetImporter.GetAtPath(p) as ModelImporter;
                    if (!importer) continue;

                    importer.globalScale = 1;
                    importer.isReadable = true;
                    importer.SearchAndRemapMaterials(ModelImporterMaterialName.BasedOnMaterialName, ModelImporterMaterialSearch.Everywhere);
                    if (importer.animationType != ModelImporterAnimationType.Human || importer.avatarSetup != ModelImporterAvatarSetup.CreateFromThisModel)
                    {
                        importer.animationType = ModelImporterAnimationType.Human;
                        importer.avatarSetup = ModelImporterAvatarSetup.CreateFromThisModel;
                        changesMade = true;
                    }

                    if (ModifyAndSaveHumanoidBoneMapping(importer))
                    {
                        changesMade = true;
                    }

                    string pName = "legacyComputeAllNormalsFromSmoothingGroupsWhenMeshHasBlendShapes";
                    PropertyInfo prop = importer.GetType().GetProperty(pName, BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.Public);
                    prop.SetValue(importer, true);

                    importer.SaveAndReimport();
                }
            }
            finally
            {
                AssetDatabase.StopAssetEditing();
            }

            if (changesMade)
            {
                AssetDatabase.SaveAssets();
                AssetDatabase.Refresh();
            }
        }

        private static bool ModifyAndSaveHumanoidBoneMapping(ModelImporter importer)
        {
            var humanDescription = importer.humanDescription;
            var humanBones = new List<HumanBone>(humanDescription.human);
            bool changesMade = false;

            // Remove Jaw bone
            changesMade |= humanBones.RemoveAll(bone => bone.humanName == "Jaw") > 0;

            // Determine eye bone names
            string leftEyeBoneName = humanBones.Any(bone => bone.boneName == "+EyeBoneLA02" || bone.boneName == "EyeBoneLA02") ? "+EyeBoneLA02" : "Eye_L";
            string rightEyeBoneName = leftEyeBoneName == "+EyeBoneLA02" ? "+EyeBoneRA02" : "Eye_R";

            // Update eye bones using a for loop
            for (int i = 0; i < humanBones.Count; i++)
            {
                var bone = humanBones[i]; // Create a temporary variable
                if (bone.humanName == "LeftEye" && bone.boneName != leftEyeBoneName)
                {
                    bone.boneName = leftEyeBoneName;
                    humanBones[i] = bone; // Assign it back to the list
                    changesMade = true;
                }
                else if (bone.humanName == "RightEye" && bone.boneName != rightEyeBoneName)
                {
                    bone.boneName = rightEyeBoneName;
                    humanBones[i] = bone; // Assign it back to the list
                    changesMade = true;
                }
            }

            if (changesMade)
            {
                humanDescription.human = humanBones.ToArray();
                importer.humanDescription = humanDescription;
                AssetDatabase.SaveAssets();
                AssetDatabase.Refresh();
            }

            return changesMade;
        }

        #endregion

        #region Tangent Generation

        public static void GenTangents(GameObject selectedObject)
        {
            HoyoToonParseManager.DetermineBodyType();

            MeshFilter[] meshFilters = selectedObject.GetComponentsInChildren<MeshFilter>();
            foreach (var meshFilter in meshFilters)
            {
                Mesh mesh = meshFilter.sharedMesh;
                if (HoyoToonParseManager.currentBodyType == HoyoToonParseManager.BodyType.Hi3P2)
                {
                    MoveColors(mesh);
                    meshFilter.sharedMesh = mesh;
                }
                else
                {
                    if (SkipTangentMeshes.Contains(meshFilter.name))
                    {
                        continue;
                    }
                    else
                    {

                        ModifyMeshTangents(mesh);
                        meshFilter.sharedMesh = mesh;
                    }
                }

            }

            SkinnedMeshRenderer[] skinMeshRenders = selectedObject.GetComponentsInChildren<SkinnedMeshRenderer>();
            foreach (var skinMeshRender in skinMeshRenders)
            {
                Mesh mesh = skinMeshRender.sharedMesh;
                if (HoyoToonParseManager.currentBodyType == HoyoToonParseManager.BodyType.Hi3P2)
                {
                    MoveColors(mesh);
                    skinMeshRender.sharedMesh = mesh;
                }
                else
                {
                    if (SkipTangentMeshes.Contains(skinMeshRender.name))
                    {
                        continue;
                    }
                    else
                    {
                        ModifyMeshTangents(mesh);
                        skinMeshRender.sharedMesh = mesh;
                    }
                }
            }

            SaveMeshAssets(selectedObject, HoyoToonParseManager.currentBodyType);
        }

        private static Mesh ModifyMeshTangents(Mesh mesh)
        {
            Mesh newMesh = UnityEngine.Object.Instantiate(mesh);

            var vertices = newMesh.vertices;
            var triangles = newMesh.triangles;
            var unmerged = new Vector3[newMesh.vertexCount];
            var merged = new Dictionary<Vector3, Vector3>();
            var tangents = new Vector4[newMesh.vertexCount];

            for (int i = 0; i < triangles.Length; i += 3)
            {
                var i0 = triangles[i + 0];
                var i1 = triangles[i + 1];
                var i2 = triangles[i + 2];

                var v0 = vertices[i0] * 100;
                var v1 = vertices[i1] * 100;
                var v2 = vertices[i2] * 100;

                var normal_ = Vector3.Cross(v1 - v0, v2 - v0).normalized;

                unmerged[i0] += normal_ * Vector3.Angle(v1 - v0, v2 - v0);
                unmerged[i1] += normal_ * Vector3.Angle(v0 - v1, v2 - v1);
                unmerged[i2] += normal_ * Vector3.Angle(v0 - v2, v1 - v2);
            }

            for (int i = 0; i < vertices.Length; i++)
            {
                if (!merged.ContainsKey(vertices[i]))
                {
                    merged[vertices[i]] = unmerged[i];
                }
                else
                {
                    merged[vertices[i]] += unmerged[i];
                }
            }

            for (int i = 0; i < vertices.Length; i++)
            {
                var normal = merged[vertices[i]].normalized;
                tangents[i] = new Vector4(normal.x, normal.y, normal.z, 0);
            }

            newMesh.tangents = tangents;

            return newMesh;
        }

        private static Mesh MoveColors(Mesh mesh)
        {
            Mesh newMesh = UnityEngine.Object.Instantiate(mesh);

            var vertices = newMesh.vertices;
            var tangents = newMesh.tangents;
            var colors = newMesh.colors;

            if (colors == null || colors.Length != vertices.Length)
            {
                colors = new Color[vertices.Length];
                for (int i = 0; i < colors.Length; i++)
                {
                    colors[i] = Color.white;
                }
                newMesh.colors = colors;
            }

            for (int i = 0; i < vertices.Length; i++)
            {
                tangents[i].x = colors[i].r * 2 - 1;
                tangents[i].y = colors[i].g * 2 - 1;
                tangents[i].z = colors[i].b * 2 - 1;
            }
            newMesh.SetTangents(tangents);

            return newMesh;
        }

        private static void SaveMeshAssets(GameObject gameObject, HoyoToonParseManager.BodyType currentBodyType)
        {
            MeshFilter[] meshFilters = gameObject.GetComponentsInChildren<MeshFilter>();
            SkinnedMeshRenderer[] skinMeshRenderers = gameObject.GetComponentsInChildren<SkinnedMeshRenderer>();

            foreach (var meshFilter in meshFilters)
            {
                Mesh mesh = meshFilter.sharedMesh;
                Mesh newMesh;
                if (currentBodyType == HoyoToonParseManager.BodyType.Hi3P2)
                {
                    newMesh = MoveColors(mesh);
                }
                else
                {
                    if (SkipTangentMeshes.Contains(meshFilter.name))
                    {
                        continue;
                    }
                    else
                    {
                        newMesh = ModifyMeshTangents(mesh);
                    }
                }
                newMesh.name = mesh.name;
                meshFilter.sharedMesh = newMesh;

                string path = AssetDatabase.GetAssetPath(mesh);
                string folderPath = Path.GetDirectoryName(path) + "/Meshes";
                if (!Directory.Exists(folderPath))
                {
                    AssetDatabase.CreateFolder(Path.GetDirectoryName(path), "Meshes");
                }
                path = folderPath + "/" + newMesh.name + ".asset";

                if (AssetDatabase.LoadAssetAtPath<Mesh>(path) != null)
                {
                    AssetDatabase.DeleteAsset(path);
                }

                AssetDatabase.CreateAsset(newMesh, path);
            }

            foreach (var skinMeshRenderer in skinMeshRenderers)
            {
                Mesh mesh = skinMeshRenderer.sharedMesh;
                Mesh newMesh;
                if (currentBodyType == HoyoToonParseManager.BodyType.Hi3P2)
                {
                    newMesh = MoveColors(mesh);
                }
                else
                {
                    if (SkipTangentMeshes.Contains(skinMeshRenderer.name))
                    {
                        continue;
                    }
                    else
                    {
                        newMesh = ModifyMeshTangents(mesh);
                    }
                }
                newMesh.name = mesh.name;
                skinMeshRenderer.sharedMesh = newMesh;

                string path = AssetDatabase.GetAssetPath(mesh);
                string folderPath = Path.GetDirectoryName(path) + "/Meshes";
                if (!Directory.Exists(folderPath))
                {
                    AssetDatabase.CreateFolder(Path.GetDirectoryName(path), "Meshes");
                }
                path = folderPath + "/" + newMesh.name + ".asset";

                if (AssetDatabase.LoadAssetAtPath<Mesh>(path) != null)
                {
                    AssetDatabase.DeleteAsset(path);
                }

                AssetDatabase.CreateAsset(newMesh, path);
            }
        }

        #endregion
    }
}