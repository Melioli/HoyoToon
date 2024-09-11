using UnityEngine;
using UnityEngine.Rendering;

namespace HoyoToon
{
    [ExecuteInEditMode]
    [DisallowMultipleComponent, ImageEffectAllowedInSceneView]
    public class HoyoToonPostProcess : MonoBehaviour
    {
        [SerializeField]
        [HideInInspector]
        private Shader postShader;
        [SerializeField]
        [HideInInspector]
        private Material postMaterial;

        [SerializeField]
        public enum GameMode
        {
            Genshin = 0,
            StarRail = 1,
            WutheringWaves = 2,
            Custom = 3,
        }
        public GameMode gameMode = GameMode.Genshin;

        [SerializeField]
        public enum BloomMode
        {
            Off = 0,
            Color = 1,
            Brightness = 2,
        }
        public BloomMode bloomMode = BloomMode.Color;

        public float bloomThreshold = 0.7f;
        public float bloomScalar = 0.7f;
        public float bloomIntensity = 0.5f;
        public Vector4 bloomWeights = new(0.1f, 0.2f, 0.3f, 0.4f);
        public Color bloomColor = Color.white;
        public float blurSamples = 10;
        public float blurWeight = 3f;
        [Range(0.1f, 1.0f)]
        public float downsampleValue = 0.5f;
        public enum ToneMode
        {
            Off = 0,
            GenshinGT = 1,
            GenshinCustom = 2,
            StarRail = 3,
        }
        public ToneMode toneMode = ToneMode.GenshinCustom;
        public float exposure = 1.05f;
        public float contrast = 1.0f;
        public float saturation = 1.0f;

        public float ACESParamA = 2.80f;
        public float ACESParamB = 0.40f;
        public float ACESParamC = 2.10f;
        public float ACESParamD = 0.5f;
        public float ACESParamE = 1.5f;


        private CommandBuffer commandBuffer;

        void OnEnable()
        {
            if (postShader == null) postShader = Shader.Find("Hidden/HoyoToon/Post Processing");
            if (postMaterial == null) postMaterial = new Material(postShader);
            postMaterial.hideFlags = HideFlags.HideAndDontSave;

            commandBuffer = new CommandBuffer { name = "HoyoToon Post Processing" };

            var camera = Camera.main;
            if (camera != null)
            {
                camera.AddCommandBuffer(CameraEvent.BeforeImageEffects, commandBuffer);
            }
        }

        void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            commandBuffer.Clear();

            if (bloomMode == BloomMode.Color)
            {
                // Add commands to the command buffer here
                commandBuffer.Blit(source, destination, postMaterial);
            }
            else if (bloomMode == BloomMode.Brightness)
            {
                // Add commands to the command buffer here
                commandBuffer.Blit(source, destination, postMaterial);
            }
            else
            {
                // Add commands to the command buffer here
                commandBuffer.Blit(source, destination, postMaterial);
            }
            if (bloomMode == BloomMode.Color)
            {
                postMaterial.SetFloat("_BloomMode", 1);
            }
            else if (bloomMode == BloomMode.Brightness)
            {
                postMaterial.SetFloat("_BloomMode", 2);
            }
            else
            {
                postMaterial.SetFloat("_BloomMode", 0);
            }

            if (toneMode == ToneMode.StarRail) postMaterial.SetFloat("_UseTonemap", 3);
            if (toneMode == ToneMode.GenshinGT) postMaterial.SetFloat("_UseTonemap", 1);
            if (toneMode == ToneMode.GenshinCustom) postMaterial.SetFloat("_UseTonemap", 2);
            if (toneMode == ToneMode.Off) postMaterial.SetFloat("_UseTonemap", 0);
            postMaterial.SetFloat("_BloomThreshold", bloomThreshold);
            postMaterial.SetFloat("_BloomIntensity", bloomIntensity);
            postMaterial.SetFloat("_BloomScalar", bloomScalar);
            postMaterial.SetVector("_BloomWeights", bloomWeights);
            postMaterial.SetColor("_BloomColor", bloomColor);
            postMaterial.SetFloat("_BlurSamples", blurSamples);
            postMaterial.SetFloat("_BlurWeight", blurWeight);
            postMaterial.SetFloat("_Exposure", exposure);
            postMaterial.SetFloat("_Contrast", contrast);
            postMaterial.SetFloat("_Saturation", saturation);

            postMaterial.SetFloat("_ACESParamA", ACESParamA);
            postMaterial.SetFloat("_ACESParamB", ACESParamB);
            postMaterial.SetFloat("_ACESParamC", ACESParamC);
            postMaterial.SetFloat("_ACESParamD", ACESParamD);
            postMaterial.SetFloat("_ACESParamE", ACESParamE);

            // var originalTex = RenderTexture.GetTemporary(source.width, source.height, 0, RenderTextureFormat.ARGB32);
            // RenderTexture.ReleaseTemporary(originalTex);

            var renderTextureMain = RenderTexture.GetTemporary(source.width, source.height, 0, RenderTextureFormat.RGB111110Float);
            Graphics.Blit(source, renderTextureMain);
            postMaterial.SetTexture("_RenderTarget", renderTextureMain);
            RenderTexture.ReleaseTemporary(renderTextureMain);

            int width = Mathf.RoundToInt(source.width * downsampleValue);
            int height = Mathf.RoundToInt(source.height * downsampleValue);
            var bloomPre = RenderTexture.GetTemporary(width, height, 0, RenderTextureFormat.ARGB32);

            // Graphics.Blit(renderTextureMain, bloomPre);

            Graphics.Blit(source, bloomPre, postMaterial, 0); // prefilter
            postMaterial.SetTexture("_BloomTexturePre", bloomPre);
            RenderTexture.ReleaseTemporary(bloomPre);


            Graphics.Blit(source, destination, postMaterial, 1);
        }

        void OnDisable()
        {
            var camera = Camera.main;
            if (camera != null && commandBuffer != null)
            {
                camera.RemoveCommandBuffer(CameraEvent.BeforeImageEffects, commandBuffer);
                commandBuffer.Release();
                commandBuffer = null;
            }
            postMaterial = null;
        }
    }
}