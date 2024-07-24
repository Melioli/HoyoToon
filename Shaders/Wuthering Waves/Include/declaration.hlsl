// Textures
Texture2D _MainTex;
Texture2D _OutlineTexture;
Texture2D _Normal_Roughness_Metallic;
Texture2D _MaskTex;
Texture2D _TypeMask;
Texture2D _StencilMask;
Texture2D _Ramp;
Texture2D _MatCapTex;
Texture2D _HeightLightMap;
Texture2D _EM;
SamplerState sampler_MainTex;
SamplerState sampler_OutlineTexture;
SamplerState sampler_Normal_Roughness_Metallic;
SamplerState sampler_MaskTex;
SamplerState sampler_TypeMask;
SamplerState sampler_StencilMask;
SamplerState sampler_Ramp;
SamplerState sampler_MatCapTex;
SamplerState sampler_HeightLightMap;
SamplerState sampler_EM;

float4 _EM_TexelSize; // x 1/height y 1/width z height w width


UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);

// material shit
float _MaterialType;

// masking shit
float _UseToonMask;
float _UseSDFShadow;
float _UseSkinMask;
float _UseMainTexA;
float _UseRampMask;

// facing directions for face shadow and stencil fading 
float4 _headUpVector;
float4 _headForwardVector;
float4 _headRightVector;

// Colors 
float4 _BaseColor;
float4 _SkinColor;
float4 _SubsurfaceColor;
float4 _SkinSubsurfaceColor;

// specular
float _SpecularPower;
float _SpecStrength;
float _MetalSpecularPower;
float _MetalMatCapBack;
float _MatCapInt;
float _MetalMatCapInt;

// general shadow 
float _ForceShadowView;
float _ShadowProcess;
float _ShadowWidth;
float _BackShadowProcessOffset;
float _FrontShadowProcessOffset;
float _ShadowOffsetPower;
float _DecodeShadowTreshold;
float _SolidShadowWidth;
float _SolidShadowProcess;
float _SolidShadowStrength;
float _MaskShadowOffsetStrength;

float4 _ShadowColor;
float4 _SkinShadowColor;

// shadow ramp shit
float _RampProcess;
float _RampWidth;
float _UseFaceRamp;
float _RampAdd; 
float _UseRampColor;
float _RampPosition;
float _RampInt;
float _HairUseShadowRamp;
float _HairRampPosition;
float _HairRampIntensity;

// stocking
float _UseStocking;
float4 _AnistropyColor;
float4 _StockingLightColor;
float4 _StockingEdgeColor;
float4 _StockingColor;
float _AnistropyInt;
float _AnistropyNormalInt;
float _Stocking_KneeSkinIntensityOffset;
float _Stocking_KneeSkinRangeOffset;
float _StockingIntensity;
float _StockingLightRangeMax;
float _StockingLightRangeMin;
float _StockingRangeMax;
float _StockingRangeMiddle;
float _StockingRangeMin;
float _StockingSkinRange;

// hair shadow
float _EnableHairShadow;
float4 _HairShadowColor;
float _WriteToMask;
float3 _HairDistance;
float _HairDepthOffset;

// face shadow 
float _FaceMapRotateOffset;
float _SDFChannel;
float _SDFSmoothness;

// normal mapping
float _UseNormalMap;
float _NormalStrength;
float _NormalFlip;

// outline
float _Outline;
float _UseMainTex;
float _CurvatureStrength;
float _OutlineWidth;
float4 _OutlineColor;
float4 _OutlineColorTint;

// high lights 
float _EyeScale;
float _HeightRatioInput;
float _RotateAngle;
float _LightShakeSpeed;
float _LightShakeScale;
float _SecondLight_PositionX;
float _SecondLight_PositionY;
float _LightPositionX;
float _LightPositionY;
float _UseHeightLightShape;
float _UseEyeSDF;
float _HeightLight_PositionX;
float _HeightLight_PositionY;
float _HeightLight_WidthX;
float _HeightLight_WidthY;
float _LightShakPositionX;
float _LightShakPositionY;

// parallax 
int _ParallaxSteps;
float _ParallaxHeight;

// stencil
float _EnabelStencil;
float _StencilTrans;

// rim 
float _EnableRim;
float _RimWidth;

// pbr
float _Metalllic;
float _UsePBR;