// textures : 
Texture2D _MainTex; // this is the diffuse color texture
Texture2D _LightMapTex; // this is both the body/hair lightmap texture and the faceshadow texture
Texture2D _FaceMapTex; // this is the facelightmap texture
Texture2D _PackedShadowRampTex;
Texture2D _CustomAO;
Texture2D _BumpMap;
Texture2D _MTMap;
Texture2D _MTSpecularRamp;
Texture2D _MaterialMasksTex;
Texture2D _CustomEmissionTex;
Texture2D _StarTex;
Texture2D _Star02Tex;
Texture2D _NoiseTex01;
Texture2D _NoiseTex02;
Texture2D _ColorPaletteTex;
Texture2D _ConstellationTex;
Texture2D _CloudTex;
Texture2D _LeatherReflect;
Texture2D _LeatherLaserRamp;
Texture2D _GlassSpecularTex;
Texture2D _TempNyxStatePaintMaskTex;
Texture2D _NyxStateOutlineColorRamp;
Texture2D _NyxStateOutlineNoise;
Texture2D _StarMask;
Texture2D _BlockHighlightMask;
Texture2D _BrightLineMask;
Texture2D _FlowMap;
Texture2D _FlowMap02;
Texture2D _NoiseMap;
Texture2D _FlowMask;
Texture2D _Mask;
UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
Texture2D _ClipAlphaTex;
Texture2D _HueMaskTexture;
Texture2D _WeaponDissolveTex;
Texture2D _WeaponPatternTex;
Texture2D _ScanPatternTex;
float4 _MainTex_ST; // scale and translation offsets for main texture
float4 _Star02Tex_ST;
float4 _NoiseTex01_ST;
float4 _NoiseTex02_ST;
float4 _ColorPaletteTex_ST;
float4 _ConstellationTex_ST;
float4 _CloudTex_ST;
float4 _StarTex_ST;
float4 _FlowMap_ST;
float4 _FlowMap02_ST;
float4 _NoiseMap_ST;
float4 _FlowMask_ST;
float4 _Mask_ST;
float4 _GlassSpecularTex_ST;
float4 _WeaponDissolveTex_ST;
float4 _WeaponPatternTex_ST;
float4 _ScanPatternTex_ST;

SamplerState sampler_MainTex; 
SamplerState sampler_LightMapTex; 
SamplerState sampler_FaceMapTex;
SamplerState sampler_BumpMap;
SamplerState sampler_PackedShadowRampTex;
SamplerState sampler_MTMap;
SamplerState sampler_MTSpecularRamp;
<<<<<<< Updated upstream
=======
SamplerState sampler_LeatherReflect;
>>>>>>> Stashed changes
SamplerState sampler_WeaponDissolveTex;
SamplerState sampler_WeaponPatternTex;
SamplerState sampler_ScanPatternTex;
SamplerState sampler_NyxStateOutlineNoise;
SamplerState sampler_NyxStateOutlineColorRamp;

// main properties
float _UseBackFaceUV2;
float _MainTexAlphaUse;
float _MainTexAlphaCutoff;
float _UseMaterial2;
float _UseMaterial3;
float _UseMaterial4;
float _UseMaterial5;

// light: 
float _FilterLight;

// colors 
float _UseMaterialMasksTex;
float _MainTexColoring;
float4 _MainTexTintColor;
float _DisableColors;
float4 _Color;
float4 _Color2;
float4 _Color3;
float4 _Color4;
float4 _Color5;

// alpha clipping 
float _UseClipping;
float _ClipMethod;
float4 _ClipBoxPositionOffset;
float4 _ClipBoxScale;
float _ClipBoxHighLightScale;
float4 _ClipHighLightColor;
float _ClipAlphaUVSet;
float _ClipAlphaThreshold;
float _ClipDissolveDirection;
float _ClipDissolveValue;
float _ClipDissolveHightlightScale;
float _ClipAlphaHighLightScale;

// face propreties 
float _FaceBlushStrength;
float3 _FaceBlushColor;
float3 _headForwardVector;
float3 _headRightVector;
float _FaceMapSoftness;
float _FaceMapRotateOffset;
float _UseFaceMapNew;

// weapon properties
float _UseWeapon;
float _WeaponDissolveValue;
float _DissolveDirection_Toggle;
float4 _WeaponPatternColor;
float _Pattern_Speed;
float _SkillEmisssionPower;
float4 _SkillEmisssionColor;
float _SkillEmissionScaler;
float _ScanColorScaler;
float4 _ScanColor;
float _ScanDirection_Switch;
float _ScanSpeed;

// glass properties
float4 _MainColor;
float4 _GlassThicknessColor;
float4 _GlassSpecularDetailColor;
float4 _GlassSpecularColor;
float _GlassTiling;
float _MainColorScaler;
float _UseGlassSpecularToggle;
float _GlassSpecularOffset;
float _GlasspecularLength;
float _GlasspecularLengthRange;
float _GlassThickness;
float _GlassThicknessScale;
float _GlassSpecularDetailOffset;
float _GlassSpecularDetailLength;
float _GlassSpecularDetailLengthRange;

// normal map properties
<<<<<<< Updated upstream
=======
float _DummyFixedForNormal;
float _isNativeMainNormal;
>>>>>>> Stashed changes
float _UseBumpMap;
float _BumpScale;

// sdf detail line
float  _TextureLineUse;
float4 _TextureLineMultiplier;
float4 _TextureLineDistanceControl;
float  _TextureLineThickness;
float  _TextureLineSmoothness;

// shadow properties
float _DayOrNight;
float _MultiLight;
float _EnvironmentLightingStrength;
float _UseShadowRamp;
float _UseLightMapColorAO;
float _UseVertexColorAO;
float _LightArea;
float _ShadowRampWidth;
float _UseVertexRampWidth;
float _UseShadowTransition;
float _ShadowTransitionRange;
float _ShadowTransitionRange2;
float _ShadowTransitionRange3;
float _ShadowTransitionRange4;
float _ShadowTransitionRange5;
float _ShadowTransitionSoftness;
float _ShadowTransitionSoftness2;
float _ShadowTransitionSoftness3;
float _ShadowTransitionSoftness4;
float _ShadowTransitionSoftness5;
float4 _FirstShadowMultColor;
float4 _FirstShadowMultColor2;
float4 _FirstShadowMultColor3;
float4 _FirstShadowMultColor4;
float4 _FirstShadowMultColor5;
float4 _CoolShadowMultColor;
float4 _CoolShadowMultColor2;
float4 _CoolShadowMultColor3;
float4 _CoolShadowMultColor4;
float4 _CoolShadowMultColor5;
float _CustomAOEnable;

// metal properties : 
float _MetalMaterial;
float _MTUseSpecularRamp;
float _MTMapTileScale;
float _MTMapBrightness;
float _MTShininess;
float _MTSpecularScale;
float _MTSpecularAttenInShadow;
float _MTSharpLayerOffset;
float4 _MTMapDarkColor;
float4 _MTMapLightColor;
float4 _MTShadowMultiColor;
float4 _MTSpecularColor;
float4 _MTSharpLayerColor;

// specular properties :
float _SpecularHighlights;
float _UseToonSpecular;
float _SpecualrInShaow;
float _Shininess;
float _Shininess2;
float _Shininess3;
float _Shininess4;
float _Shininess5;
float _SpecMulti;
float _SpecMulti2;
float _SpecMulti3;
float _SpecMulti4;
float _SpecMulti5;
float _SpecOpacity;
float _SpecOpacity2;
float _SpecOpacity3;
float _SpecOpacity4;
float _SpecOpacity5;
float4 _SpecularColor;
float4 _SpecularColor2;
float4 _SpecularColor3;
float4 _SpecularColor4;
float4 _SpecularColor5;

// leather : 
float _UseCharacterLeather;
float _LeatherLaserTiling;
float _LeatherLaserOffset;
float _LeatherLaserScale;
float4 _LeatherSpecularColor;
float _LeatherReflectOffset;
float _LeatherReflectBlur;
float _LeatherReflectScale;
float _LeatherSpecularShift;
float _LeatherSpecularRange;
float _LeatherSpecularScale;
float _LeatherSpecularSharpe;
float4 _LeatherSpecularDetailColor;
float _LeatherSpecularDetailRange;
float _LeatherSpecularDetailScale;
float _LeatherSpecularDetailSharpe;

// rim light properties :
float _UseRimLight; 
float _RimLightThickness;
float _RimLightIntensity;
float _RimThreshold;
float4 _RimColor;
float4 _RimColor1;
float4 _RimColor2;
float4 _RimColor3;
float4 _RimColor4;
float4 _RimColor5;

// emission properties : 
float _EmissionType;
float _EmissionScaler;
float _EmissionScaler1;
float _EmissionScaler2;
float _EmissionScaler3;
float _EmissionScaler4;
float _EmissionScaler5;
float4 _EmissionColor_MHY;
float4 _EmissionColor1_MHY;
float4 _EmissionColor2_MHY;
float4 _EmissionColor3_MHY;
float4 _EmissionColor4_MHY;
float4 _EmissionColor5_MHY;
float4 _EmissionColorEye;
float _TogglePulse;
float _EyePulse;
float _PulseSpeed;
float _PulseMinStrength;
float _PulseMaxStrength;
float _ToggleEyeGlow;
float _EyeGlowStrength;
float _EyeTimeOffset;

// fresnel properties
float4 _HitColor;
float4 _ElementRimColor;
float _HitColorScaler;
float _HitColorFresnelPower;

// nyx state properties
float _EnableNyxState;
float _EnableNyxOutline;
float _NyxBodyUVCoord;
float _BodyAffected;
float _LineAffected;
float _TempNyxStatePaintMaskChannel;
float4 _NyxStateOutlineWidthVarietyWithResolution;
float4 _NyxStateOutlineColorOnBodyMultiplier;
float _NyxStateOutlineColorOnBodyOpacity;
float _NyxStateOutlineColorScale;
float4 _NyxStateOutlineColor;
float2 _NyxStateOutlineColorNoiseScale;
float4 _NyxStateOutlineColorNoiseAnim;
float _NyxStateOutlineColorNoiseTurbulence;
float _NyxStateEnableOutlineWidthScaleHeightLerp;
float _NyxStateOutlineWidthScale;
float2 _NyxStateOutlineWidthScaleRange;
float4 _NyxStateOutlineWidthScaleLerpHeightRange;
float2 _NyxStateOutlineVertAnimNoiseScale;
float2 _NyxStateOutlineVertAnimNoiseAnim;
float _NyxStateOutlineVertAnimScale;
float _NyxStateEnableOutlineVertAnimScaleHeightLerp;
float2 _NyxStateOutlineVertAnimScaleRange;
float4 _NyxStateOutlineVertAnimScaleLerpHeightRange;

// outline properties 
float  _OutlineType;
float _FallbackOutlines;
float _OutlineWidth;
float _OutlineCorrectionWidth;
float _Scale;
<<<<<<< Updated upstream
=======
float _OutLineIntensity;
float _OutLineIntensity2;
float _OutLineIntensity3;
float _OutLineIntensity4;
float _OutLineIntensity5;
>>>>>>> Stashed changes
float4 _OutlineColor;
float4 _OutlineColor2;
float4 _OutlineColor3;
float4 _OutlineColor4;
float4 _OutlineColor5;
float4 _OutlineWidthAdjustScales;
float4 _OutlineWidthAdjustZs;
float  _MaxOutlineZOffset;

// special fx
float _StarUVSource;
float _StarCockEmis;
bool _StarCloakEnable;
int _StarCockType;

// skirk specific
float _UseScreenUV;
float _StarTiling;
float4 _StarTexSpeed;
float4 _StarColor;
float _StarFlickRange;
float4 _StarFlickColor;
float4 _StarFlickerParameters;
float4 _BlockHighlightColor;
float4 _BlockHighlightViewWeight;
float _CloakViewWeight;
float _BlockHighlightRange;
float _BlockHighlightSoftness;
float _BrightLineMaskContrast;
float4 _BrightLineColor;
float4 _BrightLineMaskSpeed;

// paimon/dainsleif
float _StarBrightness;
float _StarHeight;
float _Star02Height;
float _Noise01Speed;
float _Noise02Speed;
float _ColorPalletteSpeed;
float _ConstellationHeight;
float _ConstellationBrightness;
float _Star01Speed;
float _Noise03Brightness;
float _CloudBrightness;
float _CloudHeight;

// asmoday cloak
float4 _BottomColor01;
float4 _BottomColor02;
float _BottomScale;
float _BottomPower;
float _FlowMaskScale;
float _FlowMaskPower;
float4 _FlowColor;
float _FlowScale;
float4 _FlowMaskSpeed;
float4 _FlowMask02Speed;
float _NoiseScale;
float4 _NoiseSpeed;

// asmoday arm
float _HandEffectEnable;
float4 _LineColor;
float4 _LightColor;
float4 _ShadowColor;
float _DownMaskRange;
float _TopMaskRange;
float _TopLineRange;
float4 _FresnelColor;
float _FresnelPower;
float _FresnelScale;
float _ShadowWidth;
float4 _Tex01_UV;
float _Tex01_Speed_U;
float _Tex01_Speed_V;
float4 _Tex02_UV;
float _Tex02_Speed_U;
float _Tex02_Speed_V;
float4 _Tex03_UV;
float _Tex03_Speed_U;
float _Tex03_Speed_V;
float4 _Tex04_UV;
float _Tex04_Speed_U;
float _Tex04_Speed_V;
float4 _Tex05_UV;
float _Tex05_Speed_U;
float _Tex05_Speed_V;
float _Mask_Speed_U;
float _GradientPower;
float _GradientScale;

// outline emission
float _EnableOutlineGlow;
float _OutlineGlowInt;
float4 _OutlineGlowColor;
float4 _OutlineGlowColor2;
float4 _OutlineGlowColor3;
float4 _OutlineGlowColor4;
float4 _OutlineGlowColor5;

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
float _EnableOutlineHue;
float _AutomaticOutlineShift;
float _ShiftOutlineSpeed;
float _GlobalOutlineHue;
float _OutlineHue;
float _OutlineHue2;
float _OutlineHue3;
float _OutlineHue4;
float _OutlineHue5;
float _EnableEmissionHue;
float _AutomaticEmissionShift;
float _ShiftEmissionSpeed;
float _GlobalEmissionHue;
float _EmissionHue;
float _EmissionHue2;
float _EmissionHue3;
float _EmissionHue4;
float _EmissionHue5;
float _EnableRimHue;
float _AutomaticRimShift;
float _ShiftRimSpeed;
float _GlobalRimHue;
float _RimHue;
float _RimHue2;
float _RimHue3;
float _RimHue4;
float _RimHue5;

// debug
float _DebugMode;
float _DebugDiffuse;
float _DebugLightMap;
float _DebugFaceMap;
float _DebugNormalMap;
float _DebugVertexColor;
float _DebugRimLight;
float _DebugNormalVector;
float _DebugTangent;
float _DebugMetal;
float _DebugSpecular;
float _DebugEmission;
float _DebugFaceVector;
float _DebugMaterialIDs;
float _DebugLights;

uniform float _GI_Intensity;
uniform float4x4 _LightMatrix0;