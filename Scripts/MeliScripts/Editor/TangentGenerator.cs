//Made by Mana (manashiku) & Meliodas (FinalityMeli)
//Discord: https://discord.gg/VDzZERg6U4
//Github: https://github.com/Melioli/HoyoToon

using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

public class TangentGenerator : MonoBehaviour
{   [MenuItem("GameObject/HoyoToon/Set Tangents", false, 0)]
    [MenuItem("HoyoToon/Set Tangents")]
    public static void GenTangents()
    {
        MeshFilter[] meshFilters = Selection.activeGameObject.GetComponentsInChildren<MeshFilter>();
        foreach (var meshFilter in meshFilters)
        {
            Mesh mesh = meshFilter.sharedMesh;
            ModifyMeshTangents(mesh);
            meshFilter.sharedMesh = mesh;
        }

        SkinnedMeshRenderer[] skinMeshRenders = Selection.activeGameObject.GetComponentsInChildren<SkinnedMeshRenderer>();
        foreach (var skinMeshRender in skinMeshRenders)
        {
            Mesh mesh = skinMeshRender.sharedMesh;
            ModifyMeshTangents(mesh);
        }

        // Call SaveMeshAssets after modifying all meshes
        SaveMeshAssets(Selection.activeGameObject);
    }

    private static Mesh ModifyMeshTangents(Mesh mesh)
    {
        Mesh newMesh = UnityEngine.Object.Instantiate(mesh);

        var vertices = newMesh.vertices;
        var triangles = newMesh.triangles;
        var unmerged = new Vector3[newMesh.vertexCount];
        var merged = new Vector3[newMesh.vertexCount];
        var tangents = new Vector4[newMesh.vertexCount];

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

        newMesh.tangents = tangents;

        return newMesh;
    }

    private static void SaveMeshAssets(GameObject gameObject)
    {
        MeshFilter[] meshFilters = gameObject.GetComponentsInChildren<MeshFilter>();
        SkinnedMeshRenderer[] skinMeshRenderers = gameObject.GetComponentsInChildren<SkinnedMeshRenderer>();

        foreach (var meshFilter in meshFilters)
        {
            Mesh mesh = meshFilter.sharedMesh;
            Mesh newMesh = ModifyMeshTangents(mesh);
            newMesh.name = mesh.name + " Tangent";
            meshFilter.sharedMesh = newMesh;

            // save modified mesh to disk
            string path = AssetDatabase.GetAssetPath(mesh);
            string folderPath = Path.GetDirectoryName(path) + "/Tangent Mesh";
            if (!Directory.Exists(folderPath))
            {
                AssetDatabase.CreateFolder(Path.GetDirectoryName(path), "Tangent Mesh");
            }
            path = folderPath + "/" + Path.GetFileNameWithoutExtension(path) + " " + newMesh.name + ".mesh";
            AssetDatabase.CreateAsset(newMesh, path);
        }

        foreach (var skinMeshRenderer in skinMeshRenderers)
        {
            Mesh mesh = skinMeshRenderer.sharedMesh;
            Mesh newMesh = ModifyMeshTangents(mesh);
            newMesh.name = mesh.name + " Tangent";
            skinMeshRenderer.sharedMesh = newMesh;

            // save modified mesh to disk
            string path = AssetDatabase.GetAssetPath(mesh);
            string folderPath = Path.GetDirectoryName(path) + "/Tangent Mesh";
            if (!Directory.Exists(folderPath))
            {
                AssetDatabase.CreateFolder(Path.GetDirectoryName(path), "Tangent Mesh");
            }
            path = folderPath + "/" + Path.GetFileNameWithoutExtension(path) + " " + newMesh.name + ".mesh";
            AssetDatabase.CreateAsset(newMesh, path);
        }
    }
}