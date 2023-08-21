//Made by Mana (manashiku) & Meliodas (FinalityMeli)
//Discord: https://discord.gg/VDzZERg6U4
//Github: https://github.com/Melioli/HoyoToon

using System.Collections;
using System.IO;
using UnityEditor;
using UnityEngine;

public class TangentGenerator : MonoBehaviour
{
    [MenuItem("GameObject/HoyoToon/Set Tangents", false, 0)]
    [MenuItem("HoyoToon/Set Tangents")]
    public static void WriteAverageNormalToTangentTool()
    {
        MeshFilter[] meshFilters = Selection.activeGameObject.GetComponentsInChildren<MeshFilter>();

        EditorCoroutine.Start(ProcessMeshes(meshFilters));
    }

    private static IEnumerator ProcessMeshes(MeshFilter[] meshFilters)
    {
        SkinnedMeshRenderer[] skinMeshRenderers = Selection.activeGameObject.GetComponentsInChildren<SkinnedMeshRenderer>();

        foreach (var skinMeshRenderer in skinMeshRenderers)
        {
            Mesh mesh = skinMeshRenderer.sharedMesh;
            Mesh editedMesh = ModifyMeshTangents(mesh);
            SaveMeshAsset(skinMeshRenderer, editedMesh);

            // Wait for the next frame
            yield return null;
        }
    }

    private static Mesh ModifyMeshTangents(Mesh mesh)
    {
        var vertices = mesh.vertices;
        var triangles = mesh.triangles;
        var unmerged = new Vector3[mesh.vertexCount];
        var merged = new Vector3[mesh.vertexCount];
        var tangents = new Vector4[mesh.vertexCount];

        // for each triangle
        for (int i = 0; i < triangles.Length; i += 3)
        {
            // get triangles and their points
            var i0 = triangles[i + 0];
            var i1 = triangles[i + 1];
            var i2 = triangles[i + 2];

            var v0 = vertices[i0] * 100;
            var v1 = vertices[i1] * 100;
            var v2 = vertices[i2] * 100;

            // calculate flat normals first
            var normal_ = Vector3.Cross(v1 - v0, v2 - v0).normalized;

            // get angle between the points of the triangle for weighted normals
            unmerged[i0] += normal_ * Vector3.Angle(v1 - v0, v2 - v0);
            unmerged[i1] += normal_ * Vector3.Angle(v0 - v1, v2 - v1);
            unmerged[i2] += normal_ * Vector3.Angle(v0 - v2, v1 - v2);
        }

        for (int i = 0; i < vertices.Length; i++)
        {
            for (int j = 0; j < vertices.Length; j++)
            {
                if (vertices[i] == vertices[j])
                {
                    // don't want to give the wrong vertices the wrong normals
                    merged[i] += unmerged[j];
                }
            }
        }

        for (int i = 0; i < merged.Length; i++)
        {
            merged[i] = merged[i].normalized;
            // finally, normalize the normals
            tangents[i] = new Vector4(merged[i].x, merged[i].y, merged[i].z, 0);
            // since the tangent array and merged normals array should be the same length
            // this can be done in here
        }

        mesh.tangents = tangents;

        return mesh;
    }

    private static void SaveMeshAsset(MeshFilter meshFilter, Mesh editedMesh)
    {
        string assetPath = AssetDatabase.GetAssetPath(meshFilter.sharedMesh);
        if (!string.IsNullOrEmpty(assetPath))
        {
            Mesh originalMesh = AssetDatabase.LoadAssetAtPath<Mesh>(assetPath);
            if (originalMesh != null)
            {
                // Create a new instance of the original mesh
                Mesh newMesh = UnityEngine.Object.Instantiate(originalMesh);

                // Assign the modified properties to the new mesh
                newMesh.vertices = editedMesh.vertices;
                newMesh.normals = editedMesh.normals;
                newMesh.tangents = editedMesh.tangents;
                newMesh.uv = editedMesh.uv;

                // Preserve the original submeshes and materials
                newMesh.subMeshCount = editedMesh.subMeshCount;
                for (int i = 0; i < editedMesh.subMeshCount; i++)
                {
                    newMesh.SetTriangles(editedMesh.GetTriangles(i), i);
                }

                // Enable "Read/Write Enabled" for the new mesh asset        
                ModelImporter modelImporter = AssetImporter.GetAtPath(assetPath) as ModelImporter;
                if (modelImporter != null)
                {
                    modelImporter.isReadable = true;
                    modelImporter.SaveAndReimport();
                }
                else
                {
                    Debug.LogError("Failed to set 'Read/Write Enabled' for the new mesh asset. ModelImporter not found for path: " + assetPath);
                }

                // Create the "Tangent Mesh" folder if it doesn't exist
                string folderPath = Path.GetDirectoryName(assetPath) + "/Tangent Mesh";
                if (!AssetDatabase.IsValidFolder(folderPath))
                {
                    AssetDatabase.CreateFolder(Path.GetDirectoryName(assetPath), "Tangent Mesh");
                }

                // Save the new mesh as a separate asset inside the "Tangent Mesh" folder
                string newAssetPath = folderPath + "/" + Path.GetFileNameWithoutExtension(assetPath) + ".mesh";
                AssetDatabase.CreateAsset(newMesh, newAssetPath);
                AssetDatabase.SaveAssets();
                AssetDatabase.Refresh();

                // Assign the new mesh to the mesh filter
                meshFilter.sharedMesh = newMesh;
            }
            else
            {
                Debug.LogError("Failed to replace mesh asset. Original mesh not found at path: " + assetPath);
            }
        }
        else
        {
            Debug.LogError("Failed to retrieve asset path for the selected object.");
        }
    }

    private static void SaveMeshAsset(SkinnedMeshRenderer skinMeshRenderer, Mesh editedMesh)
    {
        string assetPath = AssetDatabase.GetAssetPath(skinMeshRenderer.sharedMesh);
        if (!string.IsNullOrEmpty(assetPath))
        {
            Mesh originalMesh = AssetDatabase.LoadAssetAtPath<Mesh>(assetPath);
            if (originalMesh != null)
            {
                // Create a new instance of the original mesh
                Mesh newMesh = UnityEngine.Object.Instantiate(originalMesh);

                // Assign the modified properties to the new mesh
                newMesh.vertices = editedMesh.vertices;
                newMesh.normals = editedMesh.normals;
                newMesh.tangents = editedMesh.tangents;
                newMesh.uv = editedMesh.uv;

                // Preserve the original submeshes and materials
                newMesh.subMeshCount = editedMesh.subMeshCount;
                for (int i = 0; i < editedMesh.subMeshCount; i++)
                {
                    newMesh.SetTriangles(editedMesh.GetTriangles(i), i);
                }

                // Enable "Read/Write Enabled" for the new mesh asset        
                ModelImporter modelImporter = AssetImporter.GetAtPath(assetPath) as ModelImporter;
                if (modelImporter != null)
                {
                    modelImporter.isReadable = true;
                    modelImporter.SaveAndReimport();
                }
                else
                {
                    Debug.LogError("Failed to set 'Read/Write Enabled' for the new mesh asset. ModelImporter not found for path: " + assetPath);
                }

                // Create the "Tangent Mesh" folder if it doesn't exist
                string folderPath = Path.GetDirectoryName(assetPath) + "/Tangent Mesh";
                if (!AssetDatabase.IsValidFolder(folderPath))
                {
                    AssetDatabase.CreateFolder(Path.GetDirectoryName(assetPath), "Tangent Mesh");
                }

                // Save the new mesh as a separate asset inside the "Tangent Mesh" folder
                string newAssetPath = folderPath + "/" + Path.GetFileNameWithoutExtension(assetPath) + ".mesh";
                AssetDatabase.CreateAsset(newMesh, newAssetPath);
                AssetDatabase.SaveAssets();
                AssetDatabase.Refresh();

                // Assign the new mesh to the mesh filter
                skinMeshRenderer.sharedMesh = newMesh;
            }
            else
            {
                Debug.LogError("Failed to replace mesh asset. Original mesh not found at path: " + assetPath);
            }
        }
        else
        {
            Debug.LogError("Failed to retrieve asset path for the selected object.");
        }
    }
}