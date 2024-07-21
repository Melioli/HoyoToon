using UnityEditor;
using UnityEngine;
using System;
using System.IO;

public class ScreenshotEditorWindow : EditorWindow
{
    private readonly string fileName = "Screenshot";
    private string folderPath = "Screenshots";
    private int resolutionMultiplier = 1;
    private bool includeTimestamp = true;
    private int initialWidth = 1920;
    private int initialHeight = 1080;
    private enum ViewType { SceneView, GameView }
    private RenderTexture renderTexture;
    private ViewType selectedView = ViewType.GameView;
    private bool transparency = false;
    private bool openScreenshotOnSave = false;
    private Camera sceneCamera;


    [MenuItem("HoyoToon/Editor Screenshot")]
    public static void ShowWindow()
    {
        GetWindow<ScreenshotEditorWindow>("Screenshot");
    }

    private void OnEnable()
    {
        SceneView.duringSceneGui += OnSceneGUI;
    }

    private void OnDisable()
    {
        SceneView.duringSceneGui -= OnSceneGUI;
        if (renderTexture != null)
        {
            renderTexture.Release();
            DestroyImmediate(renderTexture);
        }
    }

    private void OnSceneGUI(SceneView sceneView)
    {
        sceneCamera = sceneView.camera;
        Repaint();
    }

    private void OnGUI()
    {

        Rect bgRect = GUILayoutUtility.GetRect(GUIContent.none, GUIStyle.none, GUILayout.ExpandWidth(true), GUILayout.Height(145.0f));
        bgRect.x = 0;
        bgRect.width = EditorGUIUtility.currentViewWidth;
        Rect logoRect = new(bgRect.width / 2 - 375f, bgRect.height / 2 - 65f, 750f, 130f);

        string bgPathProperty = "UI/background";
        string logoPathProperty = "UI/screenshotlogo";

        if (!string.IsNullOrEmpty(bgPathProperty))
        {
            Texture2D bg = Resources.Load<Texture2D>(bgPathProperty);

            if (bg != null)
            {
                GUI.DrawTexture(bgRect, bg, ScaleMode.ScaleAndCrop);
            }
        }

        if (!string.IsNullOrEmpty(logoPathProperty))
        {
            Texture2D logo = Resources.Load<Texture2D>(logoPathProperty);

            if (logo != null)
            {
                GUI.DrawTexture(logoRect, logo, ScaleMode.ScaleToFit);
            }
        }

        GUILayout.Label("Screenshot Settings", EditorStyles.boldLabel);
        selectedView = (ViewType)EditorGUILayout.EnumPopup("View Type", selectedView);
        EditorGUILayout.Space();
        folderPath = EditorGUILayout.TextField("Folder Name", folderPath);
        includeTimestamp = EditorGUILayout.Toggle("Include Timestamp", includeTimestamp);
        EditorGUILayout.Space();
        initialWidth = EditorGUILayout.IntField("Initial Width", initialWidth);
        initialHeight = EditorGUILayout.IntField("Initial Height", initialHeight);
        resolutionMultiplier = EditorGUILayout.IntSlider("Resolution Multiplier", resolutionMultiplier, 1, 4);
        transparency = EditorGUILayout.Toggle("Transparency", transparency);
        openScreenshotOnSave = EditorGUILayout.Toggle("Open Screenshot on Save", openScreenshotOnSave);
        EditorGUILayout.Space();

        GUILayout.Label("Preview", EditorStyles.boldLabel);

        if (!Application.isPlaying && selectedView == ViewType.GameView)
        {
            EditorGUILayout.HelpBox("Game View preview only works in Play Mode. Please enter Play Mode or switch to Scene View to use this feature.", MessageType.Warning);
        }
        else
        {
            int width = (int)position.width;
            int height = 300;

            RenderSceneViewToTexture(width, height);

            if (renderTexture != null)
            {
                GUILayout.Label(renderTexture, GUILayout.Width(width), GUILayout.Height(height));
            }
        }


        if (GUILayout.Button("Take Screenshot"))
        {
            TakeScreenshot();
        }
        if (GUILayout.Button("Open Screenshot Folder"))
        {
            OpenScreenshotFolder();
        }

    }

    private void RenderSceneViewToTexture(int width, int height)
    {
        if (selectedView == ViewType.SceneView)
        {
            if (sceneCamera == null)
            {
                EditorGUILayout.LabelField("No active SceneView found.");
                return;
            }
        }

        if (renderTexture == null || renderTexture.width != width || renderTexture.height != height)
        {
            if (renderTexture != null)
            {
                renderTexture.Release();
                DestroyImmediate(renderTexture);
            }

            renderTexture = new RenderTexture(width, height, 24, RenderTextureFormat.ARGB32)
            {
                antiAliasing = 8
            };
        }

        RenderTexture currentRT = RenderTexture.active;
        RenderTexture.active = renderTexture;

        GL.Clear(true, true, Color.clear);

        if (selectedView == ViewType.SceneView)
        {
            sceneCamera.targetTexture = renderTexture;
            sceneCamera.Render();
            sceneCamera.targetTexture = null;
        }
        else if (selectedView == ViewType.GameView)
        {
            Camera gameCamera = Camera.main;
            if (gameCamera != null)
            {
                gameCamera.targetTexture = renderTexture;
                gameCamera.Render();
                gameCamera.targetTexture = null;
            }
            else
            {
                EditorGUILayout.LabelField("No active Game Camera found.");
            }
        }

        RenderTexture.active = currentRT;

        EditorApplication.QueuePlayerLoopUpdate();
        SceneView.RepaintAll();
    }

    private void TakeScreenshot()
    {
        int width = initialWidth * resolutionMultiplier;
        int height = initialHeight * resolutionMultiplier;

        RenderTexture renderTexture = new(width, height, 24, RenderTextureFormat.ARGB32)
        {
            antiAliasing = 8,
            depth = 24
        };
        renderTexture.Create();

        Camera camera = GetCamera();
        if (camera == null) return;

        RenderTexture currentRT = RenderTexture.active;
        RenderTexture currentCameraRT = camera.targetTexture;
        CameraClearFlags currentClearFlags = camera.clearFlags;
        Color currentBackgroundColor = camera.backgroundColor;

        RenderTexture.active = renderTexture;
        camera.targetTexture = renderTexture;

        if (transparency)
        {
            camera.clearFlags = CameraClearFlags.SolidColor;
            camera.backgroundColor = new Color(0, 0, 0, 0);
        }

        camera.Render();

        Texture2D screenshot = new Texture2D(width, height, TextureFormat.RGBA32, false);
        screenshot.ReadPixels(new Rect(0, 0, width, height), 0, 0);
        screenshot.Apply();

        camera.targetTexture = currentCameraRT;
        camera.clearFlags = currentClearFlags;
        camera.backgroundColor = currentBackgroundColor;
        RenderTexture.active = currentRT;

        SetAlphaChannel(screenshot);

        SaveScreenshot(screenshot);
    }

    private Camera GetCamera()
    {
        Camera camera = null;

        if (selectedView == ViewType.SceneView)
        {
            SceneView sceneView = SceneView.lastActiveSceneView;
            if (sceneView != null)
            {
                camera = sceneView.camera;
            }
            else
            {
                HoyoToonLogs.ErrorDebug("No active SceneView found.");
            }
        }
        else if (selectedView == ViewType.GameView)
        {
            camera = Camera.main ?? UnityEngine.Object.FindObjectOfType<Camera>();
            if (camera == null)
            {
                HoyoToonLogs.ErrorDebug("No camera found in the scene.");
            }
        }

        return camera;
    }

    private void SetAlphaChannel(Texture2D screenshot)
    {
        Color32[] pixels = screenshot.GetPixels32();
        for (int i = 0; i < pixels.Length; i++)
        {
            if (pixels[i].a > 0)
            {
                pixels[i].a = 255;
            }
        }
        screenshot.SetPixels32(pixels);
        screenshot.Apply();
    }

    private void SaveScreenshot(Texture2D screenshot)
    {
        byte[] bytes = screenshot.EncodeToPNG();
        string timestamp = includeTimestamp ? "_" + DateTime.Now.ToString("yyyy-MM-dd_HH-mm-ss") : "";
        string screenshotName = $"{fileName}{timestamp}.png";
        string fullFolderPath = Path.Combine(Application.dataPath, "../", folderPath);
        Directory.CreateDirectory(fullFolderPath);
        string screenshotPath = Path.Combine(fullFolderPath, screenshotName);

        File.WriteAllBytes(screenshotPath, bytes);

        HoyoToonLogs.LogDebug($"Screenshot saved to: {screenshotPath}");

        if (openScreenshotOnSave)
        {
            OpenScreenshot(screenshotPath);
        }
    }

    private void OpenScreenshot(string path)
    {
        System.Diagnostics.Process.Start(path);
    }

    private void OpenScreenshotFolder()
    {
        string fullPath = System.IO.Path.GetFullPath(System.IO.Path.Combine(Application.dataPath, "../" + folderPath));
        if (System.IO.Directory.Exists(fullPath))
        {
            System.Diagnostics.Process.Start("explorer.exe", fullPath);
        }
        else
        {
            HoyoToonLogs.LogDebug("Screenshot folder does not exist: " + fullPath);
        }
    }
}