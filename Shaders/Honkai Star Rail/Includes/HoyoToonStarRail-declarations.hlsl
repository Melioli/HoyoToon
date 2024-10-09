// ============================================
// common properties 
// -------------------------------------------
// TEXTURES AND SAMPLERS
Texture2D _MainTex; 
#if defined(second_diffuse)
Texture2D _SecondaryDiff; 
#endif
Texture2D _LightMap;
#if defined(use_shadow)
Texture2D _DiffuseRampMultiTex;
Texture2D _DiffuseCoolRampMultiTex;
#endif
#if defined(use_stocking)
Texture2D _StockRangeTex;
#endif
#if defined(faceishadow)
Texture2D _FaceMap;
Texture2D _FaceExpression;
#endif
Texture2D _MaterialValuesPackLUT;
#if defined(use_emission)
Texture2D _EmissionTex; 
#endif
#if defined(use_caustic)
Texture2D _CausTexture;
#endif
#if defined(can_dissolve)
Texture2D _DissolveMap;
Texture2D _DissolveMask;
Texture2D _DissolveGradientMask;
Texture2D _DissolveAnimTex;
#endif
#if defined(can_shift)
Texture2D _HueMaskTexture;
#endif

float4 _CausTexture_ST;


SamplerState sampler_MainTex;
SamplerState sampler_linear_repeat;
SamplerState sampler_linear_clamp;

#if defined(use_rimlight)
UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
#endif

float _testA;

// MATERIAL STATES
float _BaseMaterial;
float _FaceMaterial;
float _EyeShadowMat;
float _HairMaterial;
float _IsTransparent;

float _FilterLight;

float _EnableSpecular;
float _EnableShadow;
float _EnableRimLight;

// COLORS
float4 _Color;
float4 _BackColor;
float4 _EnvColor;
float4 _AddColor;
float4 _Color0;
float4 _Color1;
float4 _Color2;
float4 _Color3;
float4 _Color4;
float4 _Color5;
float4 _Color6;
float4 _Color7;
float _backfdceuv2;

// secondary 
float _UseSecondaryTex;
float _SecondaryFade;

// alpha cutoff 
float _EnableAlphaCutoff;
float _AlphaTestThreshold;
float _AlphaCutoff;

// face specific properties 
float3 _headUpVector;
float3 _headForwardVector;
float3 _headRightVector;
float _HairBlendSilhouette;
float _UseHairSideFade;
int _HairSideChoose;
float _UseDifAlphaStencil;
float _EnableStencil;
float3 _ShadowColor;
float3 _NoseLineColor;
float _NoseLinePower;
float4 _ExCheekColor;
float _ExMapThreshold;
float _ExSpecularIntensity;
float _ExCheekIntensity;
float4 _ExShyColor;
float _ExShyIntensity;
float4 _ExShadowColor;
float4 _ExEyeColor;
float _ExShadowIntensity;

// stocking proprties
float _EnableStocking;
float4 _StockRangeTex_ST;
float4 _Stockcolor;
float4 _StockDarkcolor;
float _StockTransparency;
float _StockDarkWidth;
float _Stockpower;
float _Stockpower1;
float _StockSP;
float _StockRoughness;
float _Stockthickness;

// shadow properties
float _ShadowRamp;
float _ShadowBoost; // these two values are used on the shadow mapping to increase its brightness
float _UseSelfShadow;
float _SelfShadowDarken;
float _SelfShadowDepthOffset;
float _SelfShadowSampleOffset;
float _ShadowBoostVal;

float _ES_LEVEL_ADJUST_ON;
float4 _ES_LevelSkinLightColor;
float4 _ES_LevelSkinShadowColor;
float4 _ES_LevelHighLightColor;
float4 _ES_LevelShadowColor;
float _ES_LevelShadow;
float _ES_LevelMid;
float _ES_LevelHighLight;

float _EnvironmentLightingStrength;

float _UseMaterialValuesLUT;

// specular properties 
float4 _ES_SPColor;
float _ES_SPIntensity;
float4 _SpecularColor0; 
float4 _SpecularColor1; 
float4 _SpecularColor2; 
float4 _SpecularColor3; 
float4 _SpecularColor4; 
float4 _SpecularColor5; 
float4 _SpecularColor6; 
float4 _SpecularColor7;     
float  _SpecularShininess0; 
float  _SpecularShininess1; 
float  _SpecularShininess2; 
float  _SpecularShininess3; 
float  _SpecularShininess4; 
float  _SpecularShininess5; 
float  _SpecularShininess6; 
float  _SpecularShininess7; 
float  _SpecularRoughness0; 
float  _SpecularRoughness1; 
float  _SpecularRoughness2; 
float  _SpecularRoughness3; 
float  _SpecularRoughness4; 
float  _SpecularRoughness5; 
float  _SpecularRoughness6; 
float  _SpecularRoughness7; 
float  _SpecularIntensity0; 
float  _SpecularIntensity1; 
float  _SpecularIntensity2; 
float  _SpecularIntensity3; 
float  _SpecularIntensity4; 
float  _SpecularIntensity5; 
float  _SpecularIntensity6; 
float  _SpecularIntensity7; 

// rim light properties 
float _RimLightMode;
float _RimCt;
float _Rimintensity;
float _ES_Rimintensity;
float _RimWeight;
float _RimFeatherWidth;
float _RimIntensityTexIntensity;
float _RimWidth;
float4 _RimOffset;
float2 _ES_RimLightOffset; // only using the first two
float _RimEdge;
float4 _RimColor0;
float4 _RimColor1;
float4 _RimColor2;
float4 _RimColor3;
float4 _RimColor4;
float4 _RimColor5;
float4 _RimColor6;
float4 _RimColor7;
float _RimWidth0;
float _RimWidth1;
float _RimWidth2;
float _RimWidth3;
float _RimWidth4;
float _RimWidth5;
float _RimWidth6;
float _RimWidth7;
float _RimEdgeSoftness0;
float _RimEdgeSoftness1;
float _RimEdgeSoftness2;
float _RimEdgeSoftness3;
float _RimEdgeSoftness4;
float _RimEdgeSoftness5;
float _RimEdgeSoftness6;
float _RimEdgeSoftness7;
float _RimType0;
float _RimType1;
float _RimType2;
float _RimType3;
float _RimType4;
float _RimType5;
float _RimType6;
float _RimType7;
float _RimDark0;
float _RimDark1;
float _RimDark2;
float _RimDark3;
float _RimDark4;
float _RimDark5;
float _RimDark6;
float _RimDark7;

// rim shadow properties 
float _EnableBackRimLight;
float _RimShadowCt;
float _RimShadowIntensity;
float3 _RimShadowOffset;
float4 _RimShadowColor0;
float4 _RimShadowColor1;
float4 _RimShadowColor2;
float4 _RimShadowColor3;
float4 _RimShadowColor4;
float4 _RimShadowColor5;
float4 _RimShadowColor6;
float4 _RimShadowColor7;
float _RimShadowWidth0;
float _RimShadowWidth1;
float _RimShadowWidth2;
float _RimShadowWidth3;
float _RimShadowWidth4;
float _RimShadowWidth5;
float _RimShadowWidth6;
float _RimShadowWidth7;
float _RimShadowFeather0;
float _RimShadowFeather1;
float _RimShadowFeather2;
float _RimShadowFeather3;
float _RimShadowFeather4;
float _RimShadowFeather5;
float _RimShadowFeather6;
float _RimShadowFeather7;

// dissolve
float  _DissolveMode;
float _DissoveONM;
float _DissolveClip;
float _DissolveRateM;
float4 _DissolveSTM;
float4 _DistortionSTM;
float _InvertDissovle;
float _DissolveDistortionIntensityM;
float _DissolveOutlineSize1M;
float _DissolveOutlineSize2M;
float _DissolveOutlineOffsetM;
float4 _DissolveOutlineColor1M;
float4 _DissolveOutlineColor2M;
float _DissoveDirecMaskM;
float _DissolveMapAddM;
float4 _DissolveOutlineSmoothStepM;
float _DissolveUVM;
float4 _DissolveUVSpeedM;
float4 _DissolveComponentM;
float4 _DissolvePosMaskPosM;
float _DissolvePosMaskWorldONM;
float4 _DissolvePosMaskRootOffsetM;
float _DissolvePosMaskFilpOnM;
float _DissolvePosMaskOnM;
float _DissolveUseDirectionM;
float4 _DissolveDiretcionXYZM;
float4 _DissolveCenterM;
float _DissolvePosMaskGlobalOnM;

// simple dissolve paramaters`
float4 _DissolveAnimSO;
float _ReverseRate;
float _DisableDissolveGradient;
float _InvertGradient;
float _UseWorldPosDissolve;
float _DissolveSimpleRate;
float _DissolveUVChannel;
float _SimpleDissolveClip;
float _DissolveAnimSpeed;
float _DissolveGradientOffset;
float4 _DissolveAnimDirection;
float4 _DissovleFadeSmoothstep;
float4 _DissovlePosFadeSmoothstep;
float _DissolveUsePosition;
float4 _DissolveFadeDirection;
float _FadeToSecondary;
float _DissolveClipRate;

// emission properties
int _EnableEmission;
float4 _EmissionTintColor;
float _EmissionThreshold;
float _EmissionIntensity;

// caustic properties
float _CausToggle;
float _CausUV;
float4 _CausTexSTA;
float4 _CausTexSTB;
float _CausSpeedA;
float _CausSpeedB;
float4 _CausColor;
float _CausInt;
float _CausExp;
float _EnableSplit;
float _CausSplit;

// liquid properties
float _UseGlass;
float _FillAmount1;
float _FillAmount2;
float _WobbleX;
float _WobbleZ;
float _PosY0;
float _PosY1;
float _PosY2;
float _MainTexSpeed;
float4 _BrightColor;
float4 _DarkColor;
float4 _FoamColor;
float _FoamWidth;
float4 _SurfaceColor;
float _SurfaceLighted;
float _RimColor;
float _RimPower;
float _LiquidOpaqueness;
float4 _GlassColorA;
float _GlassFrsnIn;
float _Opaqueness;
float4 _GlassColorU;
float _SpecularShininess;
float _SpecularThreshold;
float _SpecularIntensity;
float4 _SPDir;
float _EdgeWidth;

// outline properties 
float _EnableOutline;
float _EnableFOVWidth;
float _OutlineWidth;
float _OutlineScale;
float _OutlineFixFront;
float _OutlineFixSide;
float _OutlineFixRange1;
float _OutlineFixRange2;
float _OutlineFixRange3;
float _OutlineFixRange4;
float _FixLipOutline;
float4 _OutlineColor;
float4 _OutlineColor0;
float4 _OutlineColor1;
float4 _OutlineColor2;
float4 _OutlineColor3;
float4 _OutlineColor4;
float4 _OutlineColor5;
float4 _OutlineColor6;
float4 _OutlineColor7;

// hue shift
float _UseHueMask;
float _DiffuseMaskSource;
float _OutlineMaskSource;
float _EmissionMaskSource;
float _RimMaskSource;
float _EnableColorHue;
float _AutomaticColorShift;
float _ShiftColorSpeed;
float _GlobalColorHue;
float _ColorHue;
float _ColorHue2;
float _ColorHue3;
float _ColorHue4;
float _ColorHue5;
float _ColorHue6;
float _ColorHue7;
float _ColorHue8;
float _EnableOutlineHue;
float _AutomaticOutlineShift;
float _ShiftOutlineSpeed;
float _GlobalOutlineHue;
float _OutlineHue;
float _OutlineHue2;
float _OutlineHue3;
float _OutlineHue4;
float _OutlineHue5;
float _OutlineHue6;
float _OutlineHue7;
float _OutlineHue8;
float _EnableEmissionHue;
float _AutomaticEmissionShift;
float _ShiftEmissionSpeed;
float _GlobalEmissionHue;
float _EmissionHue;
float _EmissionHue2;
float _EmissionHue3;
float _EmissionHue4;
float _EmissionHue5;
float _EmissionHue6;
float _EmissionHue7;
float _EmissionHue8;
float _EnableRimHue;
float _AutomaticRimShift;
float _ShiftRimSpeed;
float _GlobalRimHue;
float _RimHue;
float _RimHue2;
float _RimHue3;
float _RimHue4;
float _RimHue5;
float _RimHue6;
float _RimHue7;
float _RimHue8;

float _DebugMode;
float _DebugDiffuse;
float _DebugLightMap;
float _DebugFaceMap;
float _DebugFaceExp;
float _DebugMLut;
float _DebugMLutChannel;
float _DebugVertexColor;
float _DebugRimLight;
float _DebugNormalVector;
float _DebugTangent;
float _DebugSpecular;
float _DebugEmission;
float _DebugFaceVector;
float _DebugHairFade;
float _DebugMaterialIDs;
float _DebugLights;

uniform float _GI_Intensity;
uniform float4x4 _LightMatrix0;