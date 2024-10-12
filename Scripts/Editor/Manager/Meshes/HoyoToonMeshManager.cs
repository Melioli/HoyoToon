#if UNITY_EDITOR
using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.Reflection;
using System.IO;
using System.Linq;
using Newtonsoft.Json;

namespace HoyoToon
{
    public class HoyoToonMeshManager : Editor
    {
        private static readonly List<string> SkipTangentMeshes = new List<string>(HoyoToonDataManager.Data.SkipMeshes);
        private static Dictionary<string, Dictionary<string, (string guid, string meshName)>> originalMeshPaths = new Dictionary<string, Dictionary<string, (string guid, string meshName)>>();
        private static readonly string HoyoToonFolder = Path.Combine(Directory.GetParent(Application.dataPath).FullName, "HoyoToon");
        private static readonly string OriginalMeshPathsFile = Path.Combine(HoyoToonFolder, "OriginalMeshPaths.json");

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

            GameObject rootObject = GetRootParent(selectedObject);
            StoreOriginalMeshes(rootObject);

            bool processAllChildren = selectedObject == rootObject;

            ProcessMeshComponents<MeshFilter>(selectedObject, processAllChildren, (meshFilter) =>
            {
                if (meshFilter.sharedMesh != null)
                {
                    meshFilter.sharedMesh = ProcessAndSaveMesh(meshFilter.sharedMesh, meshFilter.name);
                }
            });

            ProcessMeshComponents<SkinnedMeshRenderer>(selectedObject, processAllChildren, (skinMeshRender) =>
            {
                if (skinMeshRender.sharedMesh != null)
                {
                    skinMeshRender.sharedMesh = ProcessAndSaveMesh(skinMeshRender.sharedMesh, skinMeshRender.name);
                }
            });

            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
        }

        private static void ProcessMeshComponents<T>(GameObject obj, bool processAllChildren, System.Action<T> processComponent) where T : Component
        {
            if (processAllChildren)
            {
                T[] components = obj.GetComponentsInChildren<T>();
                foreach (var component in components)
                {
                    processComponent(component);
                }
            }
            else
            {
                T component = obj.GetComponent<T>();
                if (component != null)
                {
                    processComponent(component);
                }
            }
        }

        private static Mesh ProcessAndSaveMesh(Mesh mesh, string componentName)
        {
            if (mesh == null) return null;

            Mesh newMesh;
            if (HoyoToonParseManager.currentBodyType == HoyoToonParseManager.BodyType.Hi3P2)
            {
                newMesh = MoveColors(mesh);
            }
            else
            {
                if (SkipTangentMeshes.Contains(componentName))
                {
                    return mesh;
                }
                else
                {
                    newMesh = ModifyMeshTangents(mesh);
                }
            }
            newMesh.name = mesh.name;

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
            return newMesh;
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

        private static void StoreOriginalMeshes(GameObject rootObject)
        {
            LoadOriginalMeshPaths(); // Load existing data

            string modelName = rootObject.name;
            if (!originalMeshPaths.ContainsKey(modelName))
            {
                originalMeshPaths[modelName] = new Dictionary<string, (string guid, string meshName)>();
            }

            MeshFilter[] meshFilters = rootObject.GetComponentsInChildren<MeshFilter>();
            foreach (var meshFilter in meshFilters)
            {
                if (meshFilter.sharedMesh != null)
                {
                    StoreMeshGUID(modelName, meshFilter.sharedMesh);
                }
            }

            SkinnedMeshRenderer[] skinMeshRenderers = rootObject.GetComponentsInChildren<SkinnedMeshRenderer>();
            foreach (var skinMeshRenderer in skinMeshRenderers)
            {
                if (skinMeshRenderer.sharedMesh != null)
                {
                    StoreMeshGUID(modelName, skinMeshRenderer.sharedMesh);
                }
            }

            SaveOriginalMeshPaths(); // Save the updated data
        }

        private static void StoreMeshGUID(string modelName, Mesh mesh)
        {
            string assetPath = AssetDatabase.GetAssetPath(mesh);
            string guid = AssetDatabase.AssetPathToGUID(assetPath);
            originalMeshPaths[modelName][mesh.name] = (guid, mesh.name);
        }

        public static void ResetTangents(GameObject selectedObject)
        {
            HoyoToonParseManager.DetermineBodyType();

            GameObject rootObject = GetRootParent(selectedObject);
            LoadOriginalMeshPaths();

            string modelName = rootObject.name;
            if (!originalMeshPaths.ContainsKey(modelName))
            {
                Debug.LogError($"No stored mesh paths found for model: {modelName}");
                return;
            }

            bool processAllChildren = selectedObject == rootObject;

            ProcessMeshComponents<MeshFilter>(selectedObject, processAllChildren, (meshFilter) =>
            {
                if (meshFilter.sharedMesh != null)
                {
                    meshFilter.sharedMesh = RestoreOriginalMesh(modelName, meshFilter.sharedMesh.name);
                }
            });

            ProcessMeshComponents<SkinnedMeshRenderer>(selectedObject, processAllChildren, (skinMeshRender) =>
            {
                if (skinMeshRender.sharedMesh != null)
                {
                    skinMeshRender.sharedMesh = RestoreOriginalMesh(modelName, skinMeshRender.sharedMesh.name);
                }
            });

            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
        }

        private static Mesh RestoreOriginalMesh(string modelName, string meshName)
        {
            if (originalMeshPaths[modelName].TryGetValue(meshName, out var meshInfo))
            {
                string assetPath = AssetDatabase.GUIDToAssetPath(meshInfo.guid);
                Object[] assets = AssetDatabase.LoadAllAssetsAtPath(assetPath);
                foreach (Object asset in assets)
                {
                    if (asset is Mesh originalMesh && originalMesh.name == meshInfo.meshName)
                    {
                        return originalMesh;
                    }
                }
            }

            Debug.LogWarning($"Original mesh not found for {meshName}. Unable to reset.");
            return null;
        }

        #endregion

        private static GameObject GetRootParent(GameObject obj)
        {
            while (obj.transform.parent != null)
            {
                obj = obj.transform.parent.gameObject;
            }
            return obj;
        }

        private static void LoadOriginalMeshPaths()
        {
            if (File.Exists(OriginalMeshPathsFile))
            {
                string json = File.ReadAllText(OriginalMeshPathsFile);
                var deserializedDictionary = JsonConvert.DeserializeObject<Dictionary<string, Dictionary<string, string[]>>>(json);

                originalMeshPaths = deserializedDictionary.ToDictionary(
                    kvp => kvp.Key,
                    kvp => kvp.Value.ToDictionary(
                        innerKvp => innerKvp.Key,
                        innerKvp => (innerKvp.Value[0], innerKvp.Value[1])
                    )
                );
            }
        }

        private static void SaveOriginalMeshPaths()
        {
            if (!Directory.Exists(HoyoToonFolder))
            {
                Directory.CreateDirectory(HoyoToonFolder);
            }

            var serializableDictionary = originalMeshPaths.ToDictionary(
                kvp => kvp.Key,
                kvp => kvp.Value.ToDictionary(
                    innerKvp => innerKvp.Key,
                    innerKvp => new[] { innerKvp.Value.guid, innerKvp.Value.meshName }
                )
            );

            string json = JsonConvert.SerializeObject(serializableDictionary, Formatting.Indented);
            File.WriteAllText(OriginalMeshPathsFile, json);
        }
    }
}
#endif