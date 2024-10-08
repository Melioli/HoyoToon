// input and output structures 
struct appdata
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
};
struct v2f
{
    float2 uv0 : TEXCOORD0;
    float2 uv1 : TEXCOORD1;
    float2 uv2 : TEXCOORD2;
    float2 uv3 : TEXCOORD3;
    float4 vertex : SV_POSITION;
};
// general variable
float _GameType;

// material properties
Texture2D _MainTex;
SamplerState sampler_linear_clamp;
SamplerState sampler_linear_repeat;
SamplerState sampler_point_clamp;
float4 _MainTex_TexelSize;
float4 _HDRTexture_TexelSize;
float4 _PreFilter_TexelSize;
float4 _BloomV_TexelSize;
float4 _BloomAH_TexelSize;
float4 _BloomAV_TexelSize;
float4 _BloomBH_TexelSize;
float4 _BloomBV_TexelSize;
float4 _BloomCH_TexelSize;
float4 _BloomCV_TexelSize;
float4 _BloomAtlas_TexelSize;

Texture2D _CharacterMask;
Texture2D _MHYBloomTex;
Texture2D _HDRTexture;
Texture2D _OriginalTexture;
Texture2D _PreFilter;
Texture2D _BloomH;
Texture2D _BloomV;
Texture2D _BloomAH;
Texture2D _BloomAV; 
Texture2D _BloomBH;
Texture2D _BloomBV;
Texture2D _BloomCH;
Texture2D _BloomCV;
Texture2D _BloomAtlas;
Texture2D _FinalImage;

// genshin variables
float _MHYBloomThreshold;
float _MHYBloomIntensity;
float _MHYBloomScaler;
float _MHYBloomTonemapping;
float _MHYBloomExposure;
float4x4 _MHYWhiteBalanceMat;
float4x4 _HDRWhiteBalance;
float _bloomRadius;
float _UseBalance;
float _UserInputGamma;
float _FilmicHDR;

// star rail variables
float _BloomIntensity;
float _BloomThreshold;
float _BloomR;
float _BloomG;
float _BloomB;

float _Sharpening;
float4 _Vignette_Params1;
float4 _Vignette_Params2;

Texture2D _Lut2DTex;
SamplerState sampler_Lut2DTex;
float4 _Lut2DTex_TexelSize;
float4 _Lut2DTexParam;

int _IncludedLayers; // Renamed from _ExcludeLayers

float4 _UVTransformSource;
float4 _UVTransformTarget;
float4 _BlurLevelWeights;
float4 _BlurLevelBufferHeights;

float _Contrast;
float _Quality;

Texture2D _LayerRT;
float _LayerIndex;

// Add these lines
Texture2D _LayerTex;
SamplerState sampler_LayerTex;
