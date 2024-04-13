Shader "HoyoToon/Genshin/Character"
{
    Properties
    {
        //Header
        [HideInInspector] shader_master_label ("✧<b><i><color=#C69ECE>HoyoToon Genshin Impact</color></i></b>✧", Float) = 0
		[HideInInspector] shader_is_using_hoyeditor ("", Float) = 0
		[HideInInspector] footer_github ("{texture:{name:hoyogithub},action:{type:URL,data:https://github.com/Melioli/HoyoToon},hover:Github}", Float) = 0
		[HideInInspector] footer_discord ("{texture:{name:hoyodiscord},action:{type:URL,data:https://discord.gg/meliverse},hover:Discord}", Float) = 0
        //Header End
        

        //Material Type
        [HoyoToonWideEnum(Base, 0, Face, 1, Weapon, 2)]variant_selector("Material Type--{on_value_actions:[
		{value:0,actions:[{type:SET_PROPERTY,data:_UseFaceMapNew=0.0}, {type:SET_PROPERTY,data:_UseWeapon=0.0}]},
		{value:1,actions:[{type:SET_PROPERTY,data:_UseFaceMapNew=1.0}, {type:SET_PROPERTY,data:_UseWeapon=0.0}]},
        {value:2,actions:[{type:SET_PROPERTY,data:_UseFaceMapNew=0.0}, {type:SET_PROPERTY,data:_UseWeapon=1.0}
		}]}]}", Int) = 0
        //Material Type End


        //Main
        [HideInInspector] m_start_main ("Main", Float) = 0
        [SmallTexture]_MainTex("Diffuse Texture",2D)= "white" { }
        [SmallTexture]_LightMapTex("Light Map Texture", 2D) = "grey" {}
        [Toggle] _DrawBackFace ("Turn On Back Face", Float) = 0 // need to make this turn off backface culling
        [Enum(UV0, 0, UV1, 1)] _UseBackFaceUV2("Backface UV", int) = 1.0
        [Toggle] _FilterLight ("Limit Spot/Point Light Intensity", Float) = 1 // because VRC world creators are fucking awful at lighting you need to do shit like this to not blow your models the fuck up
        // on by default >:(
        [Toggle] _MainTexColoring("Enable Material Tinting", Float) = 0
        [Toggle] _DisableColors("Disable Material Colors", Float) = 0    
        // Main Color Tinting
        [HideInInspector] m_start_maincolor ("Color Options", Float) = 0
        // Color Mask
        [HideInInspector] m_start_colormask ("Color Mask", Float) = 0
        [Toggle] _UseMaterialMasksTex("Enable Material Color Mask", Int) = 0
        [SmallTexture] _MaterialMasksTex ("Material Color Mask--{condition_show:{type:PROPERTY_BOOL,data:_UseMaterialMasksTex==1.0}}", 2D) = "white"{ }
        [HideInInspector] m_end_colormask ("", Float) = 0
        // Tint and Colors
        _MainTexTintColor ("Main Texture Tint Colors", Color) = (0.5, 0.5, 0.5, 1.0)
        _Color ("Tint Color 1", Color) = (1.0, 1.0, 1.0, 1.0)
        _Color2 ("Tint Color 2", Color) = (1.0, 1.0, 1.0, 1.0)
        _Color3 ("Tint Color 3", Color) = (1.0, 1.0, 1.0, 1.0)
        _Color4 ("Tint Color 4", Color) = (1.0, 1.0, 1.0, 1.0)
        _Color5 ("Tint Color 5", Color) = (1.0, 1.0, 1.0, 1.0)
        [HideInInspector] m_end_maincolor ("", Float) = 0
        // Main Alpha
        [HideInInspector] m_start_mainalpha ("Alpha Options", Float) = 0
        [Enum(Off, 0, AlphaTest, 1, Glow, 2, FaceBlush, 3, Transparency, 4)] _MainTexAlphaUse("Diffuse Alpha Channel", Int) = 0
        _MainTexAlphaCutoff("Alpha Cuttoff", Range(0, 1.0)) = 0.5
        // See-Through 
        [HideInInspector] m_start_seethrough ("Ghosting", Float) = 0
        [Helpbox]ghostmodehelpbox("Enabling Ghost Mode will require you to tweak the Alpha values of the Color Tint inside of Color Options to fade specific parts of the body.",Float)= 0
        [Enum(Off, 0, On, 1)] _AlphaSpecial("Enable Ghost Mode--{on_value_actions:[
        {value:0,actions:[{type:SET_PROPERTY,data:_SrcBlend=1},{type:SET_PROPERTY,data:_DstBlend=0},{type:SET_PROPERTY,data:render_queue=2000}]},
        {value:1,actions:[{type:SET_PROPERTY,data:_SrcBlend=5},{type:SET_PROPERTY,data:_DstBlend=10},{type:SET_PROPERTY,data:render_queue=2225}]}]}", Int) = 0
        [HideInInspector] m_end_seethrough ("", Float) = 0   
        [HideInInspector] m_end_mainalpha ("", Float) = 0
        // Detail Line
        [HideInInspector] m_start_maindetail ("Details", Float) = 0
        [Toggle] _TextureLineUse ("Texture Line", Range(0.0, 1.0)) = 0.0
        _TextureLineSmoothness ("Texture Line Smoothness", Range(0.0, 1.0)) = 0.15
        _TextureLineThickness ("Texture Line Thickness", Range(0.0, 1.0)) = 0.55
        _TextureLineDistanceControl ("Texture Line Distance Control", Vector) = (0.1, 0.6, 1.0, 1.0)
        [Gamma] [HDR] _TextureLineMultiplier ("Texture Line Color", Color) = (0.6, 0.6, 0.6, 1.0)
        [HideInInspector] m_end_maindetail ("", Float) = 0
        // Material ID
        [HideInInspector] m_start_matid ("Material IDs", Float) = 0
        [Toggle] _UseMaterial2 ("Enable Material 2", Float) = 1.0
        [Toggle] _UseMaterial3 ("Enable Material 3", Float) = 1.0
        [Toggle] _UseMaterial4 ("Enable Material 4", Float) = 1.0
        [Toggle] _UseMaterial5 ("Enable Material 5", Float) = 1.0
        [HideInInspector] m_end_matid ("", Float) = 0
        [HideInInspector] m_end_main ("", Float) = 0
        //Main End

        //Normal Map
        [HideInInspector] m_start_normalmap ("Normal Map", Float) = 0
        [Toggle] _UseBumpMap("Normal Map", Float) = 0.0
        [SmallTexture]_BumpMap("Normal Map",2D)= "bump" { } 
        _BumpScale ("Normal Map Scale", Range(0.0, 1.0)) = 0.0
        [HideInInspector] m_end_normalmap ("", Float) = 0
        //Normal Map End

        //Face Shading
        [HideInInspector] m_start_faceshading("Face--{condition_show:{type:PROPERTY_BOOL,data:_UseFaceMapNew==1.0}} ", Float) = 0
        _FaceMapRotateOffset ("Face Map Rotate Offset", Range(-1, 1)) = 0
        [SmallTexture] _FaceMapTex ("Face Shadow",2D)= "white"{ }
        [HideInInspector] _UseFaceMapNew ("Enable Face Shader", Float) = 0.0
        _FaceMapSoftness ("Face Lighting Softness", Range(0.0, 1.0)) = 0.001
        _headForwardVector ("Forward Vector | XYZ", Vector) = (0, 0, 1, 0)
        _headRightVector ("Right Vector | XYZ", Vector) = (-1, 0, 0, 0)
        // Face Bloom
        [HideInInspector] m_start_faceblush ("Blush", Float) = 0
        _FaceBlushStrength ("Face Blush Strength", Range(0.0, 1.0)) = 0.0
        [Gamma] _FaceBlushColor ("Face Blush Color", Color) = (1.0, 0.8, 0.7, 1.0)
        [HideInInspector] m_end_faceblush ("", Float) = 0
        [HideInInspector] m_end_faceshading ("", Float) = 0
        //Face Shading End

        //Weapon Shading
        [HideInInspector] m_start_weaponshading("Weapon--{condition_show:{type:PROPERTY_BOOL,data:_UseWeapon==1.0}}", Float) = 0
        [HideInInspector]_UseWeapon ("Weapon Shader", Range(0.0, 1.0)) = 0.0
        [Toggle] _UsePattern ("Enable Weapon Pattern", Range(0.0, 1.0)) = 1.0
        [Toggle] _ProceduralUVs ("Disable UV1", Range(0.0, 1.0)) = 0.0
        [SmallTexture]_WeaponDissolveTex("Weapon Dissolve",2D)= "white"{ }
        [SmallTexture]_WeaponPatternTex("Weapon Pattern",2D)= "white"{ }
        [SmallTexture]_ScanPatternTex("Scan Pattern",2D)= "black"{ }
        _WeaponDissolveValue ("Weapon Dissolve Value", Range(0.0, 1.0)) = 1.0
        [Toggle] _DissolveDirection_Toggle ("Dissolve Direction Toggle", Range(0.0, 1.0)) = 0.0
        [HDR] _WeaponPatternColor ("Weapon Pattern Color", Color) = (1.682, 1.568729, 0.6554853, 1.0)
        _Pattern_Speed ("Pattern Speed", Float) = -0.033
        _SkillEmisssionPower ("Skill Emisssion Power", Float) = 0.6
        _SkillEmisssionColor ("Skill Emisssion Color", Color) = (0.0, 0.0, 0.0, 0.0)
        _SkillEmissionScaler ("Skill Emission Scaler", Float) = 3.2
        // Weapon Scan
        [HideInInspector] m_start_weaponscan ("Scan", Float) = 0
        _ScanColorScaler ("Scan Color Scaler", Float) = 0.0
        _ScanColor ("Scan Color", Color) = (0.8970588, 0.8970588, 0.8970588, 1.0)
        [Toggle] _ScanDirection_Switch ("Scan Direction Switch", Range(0.0, 1.0)) = 0.0
        _ScanSpeed ("Scan Speed", Float) = 0.8
        [HideInInspector] m_end_weaponscan ("", Float) = 0
        [HideInInspector] m_end_weaponshading ("", Float) = 0
        //Weapon Shading End

        //Lightning Options
        [HideInInspector] m_start_lighting("Lighting Options", Float) = 0
        [HideInInspector] g_start_light("", Int) = 0
        
        [HideInInspector] m_start_lightandshadow("Shadow", Float) = 0
        [Toggle] _DayOrNight ("Enable Nighttime", Range(0.0, 1.0)) = 0.0 // _ES_ColorTone       
        [SmallTexture]_PackedShadowRampTex("Shadow Ramp",2D)= "white"{ }
        [Toggle] _UseLightMapColorAO ("Enable Lightmap Ambient Occlusion", Range(0.0, 1.0)) = 1.0
        [Toggle] _UseShadowRamp ("Enable Shadow Ramp Texture", Float) = 1.0
        [Toggle] _UseVertexColorAO ("Enable Vertex Color Ambient Occlusion", Range(0.0, 1.0)) = 1.0
        [Toggle] _UseVertexRampWidth ("Use Vertex Shadow Ramp Width", Float) = 0
        [Toggle] _MultiLight ("Enable Multi Light Source Mode", float) = 1.0
        //_EnvironmentLightingStrength ("Environment Lighting Strength", Range(0.0, 1.0)) = 1.0
        _LightArea ("Shadow Position", Range(0.0, 2.0)) = 0.55
        _ShadowRampWidth ("Ramp Width", Range(0.2, 3.0)) = 1.0
        [Toggle] _CustomAOEnable ("Enable Custom AO", Float) = 0	
        [SmallTexture]_CustomAO ("Custom AO Texture--{condition_show:{type:PROPERTY_BOOL,data:_CustomAOEnable==1.0}}",2D)= "white"{ }
        // Shadow Transition
        [HideInInspector] m_start_shadowtransitions("Shadow Transitions", Float) = 0
        [Toggle] _UseShadowTransition ("Use Shadow Transition (only work when shadow ramp is off)", Float) = 0
        _ShadowTransitionRange ("Shadow Transition Range 1", Range(0.0, 1.0)) = 0.01
        _ShadowTransitionRange2 ("Shadow Transition Range 2", Range(0.0, 1.0)) = 0.01
        _ShadowTransitionRange3 ("Shadow Transition Range 3", Range(0.0, 1.0)) = 0.01
        _ShadowTransitionRange4 ("Shadow Transition Range 4", Range(0.0, 1.0)) = 0.01
        _ShadowTransitionRange5 ("Shadow Transition Range 5", Range(0.0, 1.0)) = 0.01
        _ShadowTransitionSoftness ("Shadow Transition Softness 1", Range(0.0, 1.0)) = 0.5
        _ShadowTransitionSoftness2 ("Shadow Transition Softness 2", Range(0.0, 1.0)) = 0.5
        _ShadowTransitionSoftness3 ("Shadow Transition Softness 3", Range(0.0, 1.0)) = 0.5
        _ShadowTransitionSoftness4 ("Shadow Transition Softness 4", Range(0.0, 1.0)) = 0.5
        _ShadowTransitionSoftness5 ("Shadow Transition Softness 5", Range(0.0, 1.0)) = 0.5
        [HideInInspector] m_end_shadowtransitions ("", Float) = 0
        // Day Shadow Color
        [HideInInspector] m_start_shadowcolorsday("DayTime Colors", Float) = 0
        [Gamma] _FirstShadowMultColor ("Daytime Shadow Color 1", Color) = (0.9, 0.7, 0.75, 1)
        [Gamma] _FirstShadowMultColor2 ("Daytime Shadow Color 2", Color) = (0.9, 0.7, 0.75, 1)
        [Gamma] _FirstShadowMultColor3 ("Daytime Shadow Color 3", Color) = (0.9, 0.7, 0.75, 1)
        [Gamma] _FirstShadowMultColor4 ("Daytime Shadow Color 4", Color) = (0.9, 0.7, 0.75, 1)
        [Gamma] _FirstShadowMultColor5 ("Daytime Shadow Color 5", Color) = (0.9, 0.7, 0.75, 1)
        [HideInInspector] m_end_shadowcolorsday ("", Float) = 0
        // Night Shadow Color
        [HideInInspector] m_start_shadowcolorsnight("NightTime Colors", Float) = 0
        [Gamma] _CoolShadowMultColor ("Nighttime Shadow Color 1", Color) = (0.9, 0.7, 0.75, 1)
        [Gamma] _CoolShadowMultColor2 ("Nighttime Shadow Color 2", Color) = (0.9, 0.7, 0.75, 1)
        [Gamma] _CoolShadowMultColor3 ("Nighttime Shadow Color 3", Color) = (0.9, 0.7, 0.75, 1)
        [Gamma] _CoolShadowMultColor4 ("Nighttime Shadow Color 4", Color) = (0.9, 0.7, 0.75, 1)
        [Gamma] _CoolShadowMultColor5 ("Nighttime Shadow Color 5", Color) = (0.9, 0.7, 0.75, 1)
        [HideInInspector] m_end_shadowcolorsnight ("", Float) = 0
        [HideInInspector] m_end_lightandshadow ("", Float) = 0
        // Rim Light 
        [HideInInspector] m_start_rimlight("Rim Light", Float) = 0
        [Toggle] _UseRimLight ("Enable Rim Light", Float) = 1
        _RimThreshold ("Rim Threshold--{condition_show:{type:PROPERTY_BOOL,data:_UseRimLight==1.0}}", Range(0.0, 1.0)) = 0.5
        _RimLightIntensity ("Rim Light Intensity--{condition_show:{type:PROPERTY_BOOL,data:_UseRimLight==1.0}}", Float) = 0.25
        _RimLightThickness ("Rim Light Thickness--{condition_show:{type:PROPERTY_BOOL,data:_UseRimLight==1.0}}", Range(0.0, 10.0)) = 1.0
        [HideInInspector] m_start_lightingrimcolor("Rimlight Color--{condition_show:{type:PROPERTY_BOOL,data:_UseRimLight==1.0}}", Float) = 0
        _RimColor (" Rim Light Color", Color)   = (1, 1, 1, 1)
        _RimColor0 (" Rim Light Color 1 | (RGB ID = 0)", Color)   = (1, 1, 1, 1)
        _RimColor1 (" Rim Light Color 2 | (RGB ID = 31)", Color)  = (1, 1, 1, 1)
        _RimColor2 (" Rim Light Color 3 | (RGB ID = 63)", Color)  = (1, 1, 1, 1)
        _RimColor3 (" Rim Light Color 4 | (RGB ID = 95)", Color)  = (1, 1, 1, 1)
        _RimColor4 (" Rim Light Color 5 | (RGB ID = 127)", Color) = (1, 1, 1, 1)
        [HideInInspector] m_end_lightingrimcolor("", Float) = 0
        [HideInInspector] m_end_rimlight ("", Float) = 0
        [HideInInspector] g_end_light("", Int) = 0
        [HideInInspector] m_end_lightning ("", Float) = 0
        //Lightning Options End

        //Reflections
        [HideInInspector] m_start_reflections("Reflections", Float) = 0
        [HideInInspector] m_start_metallics("Metallics", Int) = 0
        [Toggle] _MetalMaterial ("Enable Metallic", Range(0.0, 1.0)) = 1.0
        [SmallTexture]_MTMap("Metallic Matcap--{condition_show:{type:PROPERTY_BOOL,data:_MetalMaterial==1.0}}",2D)= "white"{ }
        [Toggle] _MTUseSpecularRamp ("Enable Metal Specular Ramp--{condition_show:{type:PROPERTY_BOOL,data:_MetalMaterial==1.0}}", Float) = 0.0
        [SmallTexture]_MTSpecularRamp("Specular Ramp--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_MetalMaterial==1},condition2:{type:PROPERTY_BOOL,data:_MTUseSpecularRamp==1}}}",2D)= "white"{ }
        _MTMapBrightness ("Metallic Matcap Brightness--{condition_show:{type:PROPERTY_BOOL,data:_MetalMaterial==1.0}}", Float) = 3.0
        _MTShininess ("Metallic Specular Shininess--{condition_show:{type:PROPERTY_BOOL,data:_MetalMaterial==1.0}}", Float) = 90.0
        _MTSpecularScale ("Metallic Specular Scale--{condition_show:{type:PROPERTY_BOOL,data:_MetalMaterial==1.0}}", Float) = 15.0 
        _MTMapTileScale ("Metallic Matcap Tile Scale--{condition_show:{type:PROPERTY_BOOL,data:_MetalMaterial==1.0}}", Range(0.0, 2.0)) = 1.0
        _MTSpecularAttenInShadow ("Metallic Specular Power in Shadow--{condition_show:{type:PROPERTY_BOOL,data:_MetalMaterial==1.0}}", Range(0.0, 1.0)) = 0.2
        _MTSharpLayerOffset ("Metallic Sharp Layer Offset--{condition_show:{type:PROPERTY_BOOL,data:_MetalMaterial==1.0}}", Range(0.001, 1.0)) = 1.0
        // Metal Color
        [HideInInspector] m_start_metallicscolor("Metallic Colors--{condition_show:{type:PROPERTY_BOOL,data:_MetalMaterial==1.0}}", Int) = 0
        _MTMapDarkColor ("Metallic Matcap Dark Color", Color) = (0.51, 0.3, 0.19, 1.0)
        _MTMapLightColor ("Metallic Matcap Light Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _MTShadowMultiColor ("Metallic Matcap Shadow Multiply Color", Color) = (0.78, 0.77, 0.82, 1.0)
        _MTSpecularColor ("Metallic Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _MTSharpLayerColor ("Metallic Sharp Layer Color", Color) = (1.0, 1.0, 1.0, 1.0)
        [HideInInspector] m_end_metallicscolor ("", Int) = 0
        [HideInInspector] m_end_metallics("", Int) = 0
        // Specular 
        [HideInInspector] m_start_specular("Specular Reflections", Int) = 0
        [Toggle] _SpecularHighlights ("Enable Specular", Float) = 0.0
        [HideInInspector] [Toggle] _UseToonSpecular ("Enable Specular", Float) = 0.0
        _Shininess ("Shininess 1--{condition_show:{type:PROPERTY_BOOL,data:_SpecularHighlights==1.0}}", Float) = 10
        _Shininess2 ("Shininess 2--{condition_show:{type:PROPERTY_BOOL,data:_SpecularHighlights==1.0}}", Float) = 10
        _Shininess3 ("Shininess 3--{condition_show:{type:PROPERTY_BOOL,data:_SpecularHighlights==1.0}}", Float) = 10
        _Shininess4 ("Shininess 4--{condition_show:{type:PROPERTY_BOOL,data:_SpecularHighlights==1.0}}", Float) = 10
        _Shininess5 ("Shininess 5--{condition_show:{type:PROPERTY_BOOL,data:_SpecularHighlights==1.0}}", Float) = 10
        _SpecMulti ("Specular Multiplier 1--{condition_show:{type:PROPERTY_BOOL,data:_SpecularHighlights==1.0}}", Float) = 0.1
        _SpecMulti2 ("Specular Multiplier 2--{condition_show:{type:PROPERTY_BOOL,data:_SpecularHighlights==1.0}}", Float) = 0.1
        _SpecMulti3 ("Specular Multiplier 3--{condition_show:{type:PROPERTY_BOOL,data:_SpecularHighlights==1.0}}", Float) = 0.1
        _SpecMulti4 ("Specular Multiplier 4--{condition_show:{type:PROPERTY_BOOL,data:_SpecularHighlights==1.0}}", Float) = 0.1
        _SpecMulti5 ("Specular Multiplier 5--{condition_show:{type:PROPERTY_BOOL,data:_SpecularHighlights==1.0}}", Float) = 0.1
        [Gamma] _SpecularColor ("Specular Color--{condition_show:{type:PROPERTY_BOOL,data:_SpecularHighlights==1.0}}", Color) = (1.0, 1.0, 1.0, 1.0)
        [HideInInspector] m_end_specular("", Int) = 0
        [HideInInspector] m_end_reflections ("", Float) = 0
        //Reflections End
        
        //Outlines
        [HideInInspector] m_start_outlines("Outlines", Float) = 0
        [Enum(None, 0, Normal, 1,  Tangent, 2)] _OutlineType ("Outline Type", Float) = 1.0
        [Toggle] _FallbackOutlines ("Enable Static Outlines", Range(0.0, 1.0)) = 0
        _OutlineWidth ("Outline Width", Float) = 0.03
        _Scale ("Outline Scale", Float) = 0.01
        [Toggle] [HideInInspector] _UseClipPlane ("Use Clip Plane?", Range(0.0, 1.0)) = 0.0
        [HideInInspector] _ClipPlane ("Clip Plane", Vector) = (0.0, 0.0, 0.0, 0.0)
        // Outline Color
        [HideInInspector] m_start_outlinescolor("Outline Colors", Float) = 0
        [Gamma] _OutlineColor ("Outline Color 1", Color) = (0.0, 0.0, 0.0, 1.0)
        [Gamma] _OutlineColor2 ("Outline Color 2", Color) = (0.0, 0.0, 0.0, 1.0)
        [Gamma] _OutlineColor3 ("Outline Color 3", Color) = (0.0, 0.0, 0.0, 1.0)
        [Gamma] _OutlineColor4 ("Outline Color 4", Color) = (0.0, 0.0, 0.0, 1.0)
        [Gamma] _OutlineColor5 ("Outline Color 5", Color) = (0.0, 0.0, 0.0, 1.0)
        [HideInInspector] m_end_outlinescolor ("", Float) = 0
        // Outline Offsets
        [HideInInspector] m_start_outlinesoffset("Outline Offset & Adjustments", Float) = 0
        _OutlineWidthAdjustScales ("Outline Width Adjust Scales", Vector) = (0.01, 0.245, 0.6, 0.0)
        _OutlineWidthAdjustZs ("Outline Width Adjust Zs", Vector) = (0.001, 2.0, 6.0, 0.0)
        _MaxOutlineZOffset ("Max Z-Offset", Float) = 1.0
        [HideInInspector] m_end_outlinesoffset ("", Float) = 0
        [HideInInspector] m_end_outlines ("", Float) = 0
        //Outlines End

        // //Special Effects
        [HideInInspector] m_start_specialeffects("Special Effects", Float) = 0
        [HideInInspector] m_start_emissionglow("Emission / Archon Glow", Float) = 0
        [Enum(From Diffuse Alpha, 0, From Custom Mask, 1)]  _EmissionType ("Emission Mask Source", Float) = 0
        _CustomEmissionTex ("Custom Emission Texture--{condition_show:{type:PROPERTY_BOOL,data:_EmissionType==1}}", 2D) = "black"{}
        // Emission Intensity
        [HideInInspector] m_start_glowscale("Emission Intensity", Float) = 0
        _EmissionScaler ("Emission Intensity", Range(0, 100)) = 1
        _EmissionScaler1 ("Emission Intensity For Material 1", Range(0, 100)) = 1
        _EmissionScaler2 ("Emission Intensity For Material 2", Range(0, 100)) = 1
        _EmissionScaler3 ("Emission Intensity For Material 3", Range(0, 100)) = 1
        _EmissionScaler4 ("Emission Intensity For Material 4", Range(0, 100)) = 1
        _EmissionScaler5 ("Emission Intensity For Material 5", Range(0, 100)) = 1
        [HideInInspector] m_end_glowscale("", Float) = 0
        // Emission Color
        [HideInInspector] m_start_glowcolor("Emission Color", Float) = 0
        _EmissionColor_MHY ("Emission Color", Color) = (1,1,1,1)
        _EmissionColor1_MHY ("Emission Color For Material 1", Color) = (1,1,1,1)
        _EmissionColor2_MHY ("Emission Color For Material 2", Color) = (1,1,1,1)
        _EmissionColor3_MHY ("Emission Color For Material 3", Color) = (1,1,1,1)
        _EmissionColor4_MHY ("Emission Color For Material 4", Color) = (1,1,1,1)
        _EmissionColor5_MHY ("Emission Color For Material 5", Color) = (1,1,1,1)
        _EmissionColorEye ("Emission Color For Eye--{condition_show:{type:PROPERTY_BOOL,data:_ToggleEyeGlow==1.0}}", Color) = (1,1,1,1)
        [HideInInspector] m_end_glowcolor("", Float) = 0
        // Force Eye Glow
        [HideInInspector] m_start_eyeemission("Eye Emission", Float) = 0
        [Toggle] _ToggleEyeGlow ("Enable Eye Glow", Float) = 1.0
       
        _EyeGlowStrength ("Eye Glow Strength", Float) = 0.5
        _EyeTimeOffset ("Eye Glow Timing Offset", Range(0.0, 1.0)) = 0.1
        [HideInInspector] m_end_eyeemission("", Float) = 0
        // Emission Pulse
        [HideInInspector] m_start_emissionpulse("Pulsing Emission", Float) = 0
        [Toggle] _TogglePulse ("Enable Pulse", Range(0.0, 1.0)) = 0.0 
        [Toggle] _EyePulse ("Enable Pulse for Eyes", Float) = 0
        _PulseSpeed ("Pulse Speed", Float) = 1.3
        _PulseMinStrength ("Minimum Pulse Strength", Range(0.0, 1.0)) = 0.0
        _PulseMaxStrength ("Maximum Pulse Strength", Range(0.0, 1.0)) = 1.0
        [HideInInspector] m_end_emissionpulse ("", Float) = 0
        [HideInInspector] m_end_emissionglow ("", Float) = 0
        // Outline Emission
        [HideInInspector] m_start_outlineemission("Outline Emission", Float) = 0
        [Toggle] _EnableOutlineGlow("Enable Outline Emission", Float) = 0
        _OutlineGlowInt("Outline Emission Intesnity", Range(0.0000, 100.0000)) = 1.0
        [HideInInspector] m_start_outlineemissioncolors("Outline Emission Colors", Float) = 0
        _OutlineGlowColor("Outline Emission Color 1", Color) = (1.0, 1.0, 1.0, 1.0)
        _OutlineGlowColor2("Outline Emission Color 2", Color) = (1.0, 1.0, 1.0, 1.0)
        _OutlineGlowColor3("Outline Emission Color 3", Color) = (1.0, 1.0, 1.0, 1.0)
        _OutlineGlowColor4("Outline Emission Color 4", Color) = (1.0, 1.0, 1.0, 1.0)
        _OutlineGlowColor5("Outline Emission Color 5", Color) = (1.0, 1.0, 1.0, 1.0)
        [HideInInspector] m_end_outlineemissioncolors("", Float) = 0
        [HideInInspector] m_end_outlineemission ("", Float) = 0
        // Star Cock
        [HideInInspector] m_start_starcock("Star Cloak", Float) = 0 //tribute to the starcock 
        [Toggle] _StarCloakEnable("Enable Star Cloak", Float) = 0.0
        [Enum(Paimon, 0, Skirk, 1, Asmoday, 2)] _StarCockType ("Star Cloak Type Override--{condition_show:{type:PROPERTY_BOOL,data:_StarCloakEnable==1.0}}", Float) = 0
        [Toggle] _StarCockEmis ("Star Cloak As Emission--{condition_show:{type:PROPERTY_BOOL,data:_StarCloakEnable==1.0}}", Float) = 0
        [Enum(UV0, 0, UV1, 1, UV2, 2)] _StarUVSource ("UV Source--{condition_show:{type:PROPERTY_BOOL,data:_StarCloakEnable==1.0}}", Float) = 0.0
        [Toggle] _StarCloakOveride("Star Cloak Shading Only--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==0}}}", Float) = 0.0
        _StarCloakBlendRate ("Star Cloak Blend Rate--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType0}}}", Range(0.0, 2.0)) = 1.0
        _StarTex ("Star Texture 1--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType<2}}}", 2D) = "black" { } // cock 
        _Star02Tex ("Star Texture 2--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==0}}}", 2D) = "black" { }
        _Star01Speed ("Star 1 Scroll Speed--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==0}}}", Float) = 0
        _StarBrightness ("Star Brightness--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==0}}}", Float) = 60
        _StarHeight ("Star Texture Height--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==0}}}", Float) = 14.89
        _Star02Height ("Star Texture 2 Height--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==0}}}", Float) = 0
        // Noise
        [HideInInspector] m_start_starcocknoise("Noise--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==0}}}", Float) = 0 //starcock: the phantom cock
        _NoiseTex01 ("Noise Texture 1", 2D) = "white" { }
        _NoiseTex02 ("Noise Texture 2", 2D) = "white" { }
        _Noise01Speed ("Noise 1 Scroll Speed", Float) = 0.1
        _Noise02Speed ("Noise 2 Scroll Speed", Float) = -0.1
        _Noise03Brightness ("Noise 3 Brightness", Float) = 0.2
        [HideInInspector] m_end_starcocknoise("", Float) = 0 //starcock: attack of the cocks
        // Color Palette
        [HideInInspector] m_start_starcockcolorpallete("Color Pallete--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==0}}}", Float) = 0 //starcock: revenge of the cock
        _ColorPaletteTex ("Color Palette Texture", 2D) = "white" { }
        _ColorPalletteSpeed ("Color Palette Scroll Speed", Float) = -0.1
        [HideInInspector] m_end_starcockcolorpallete("", Float) = 0 //starcock: the cock awakens
        // Constellation
        [HideInInspector] m_start_starcockconstellation("Constellation--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==0}}}", Float) = 0 //starcock: the last cock
        _ConstellationTex ("Constellation Texture", 2D) = "white" { }
        _ConstellationHeight ("Constellation Texture Height", Float) = 1.2
        _ConstellationBrightness ("Constellation Brightness", Float) = 5
        [HideInInspector] m_end_starcockconstellation("", Float) = 0 //starcock: a starcock story
        // Cloud
        [HideInInspector] m_start_starcockcloud("Cloud--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==0}}}", Float) = 0 //starcock: the rise of cock
        _CloudTex ("Cloud Texture", 2D) = "white" { }
        _CloudBrightness ("Cloud Texture Brightness", Float) = 1
        _CloudHeight ("Cloud Texture Height", Float) = 1
        [HideInInspector] m_end_starcockcloud("", Float) = 0 //starcock: the cock strikes back
        // Textures
        _FlowMap ("Star Texture--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==2}}}", 2D) = "white" { }
        _FlowMap02 ("Star Texture 2--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==2}}}", 2D) = "white" { }
        _NoiseMap ("Noise Map--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==2}}}", 2D) = "white" { }
        _FlowMask ("Flow Mask--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==2}}}", 2D) = "white" { }
        // Gradient
        [HideInInspector] m_start_starcockgrad ("Gradient--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==2}}}", Float) = 0
        _BottomColor01 ("Top Color", Color) = (0,0,0,0)
        _BottomColor02 ("Bottom Color", Color) = (1,0,0,0)
        _BottomScale ("Gradient Scale", Float) = 1
        _BottomPower ("Gradient Power", Float) = 1
        [HideInInspector] m_end_starcockgrad ("", Float) = 0
        // Flow
        [HideInInspector] m_start_starcockflow ("Star Controls--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==2}}}", Float) = 0
        _FlowColor ("Star Color", Color) = (1,1,1,0)
        _FlowMaskScale ("Star Texture Scale", Float) = 1 
        _FlowMaskPower ("Star Texture Power", Float) = 1
        _FlowScale ("Star Intensity", Float) = 1
        _FlowMaskSpeed ("Star Texture Speed", Vector) = (0,0,0,0)
        _FlowMask02Speed ("Star Texture 02 Speed", Vector) = (0,0,0,0)
        [HideInInspector] m_end_starcockflow ("", Float) = 0
        // Asmoday Noise
        [HideInInspector] m_start_starcockasmodaynoise ("Noise Controls--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==2}}}", Float) = 0
        _NoiseScale ("Noise Scale", Range(0, 1)) = 0
        _NoiseSpeed ("Noise Speed", Vector) = (0,0,0,0)
        [HideInInspector] m_end_starcockasmodaynoise ("", Float) = 0
        // Skirk Options
        _StarMask ("Stars Mask--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==1}}}", 2D) = "white" { }
        [Toggle] _UseScreenUV ("Enable Screen UV--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==1}}}", Float) = 0
        _StarTiling ("Star Tiling--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==1}}}", Float) = 1
        _StarTexSpeed ("Star TexSpeed--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==1}}}", Vector) = (0,0,0,0)
        _StarColor ("Star Color--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==1}}}", Color) = (1,1,1,1)
        _StarFlickRange ("Star Flicker Range--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==1}}}", Range(0, 1)) = 0.2
        _StarFlickColor ("Star Flicker Color--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==1}}}", Color) = (1,1,1,1)
        _StarFlickerParameters ("Star Flicker Parameters--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==1}}}", Vector) = (1,20,0.5,0)
        // Skirk Block 
        [HideInInspector] m_start_skockblock ("Highlight Block Controls--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==1}}}", Float) = 0
        _BlockHighlightMask ("Block Highlight Mask", 2D) = "black" { }
        _BlockHighlightColor ("Block Highlight Color", Color) = (1,1,1,1)
        _BlockHighlightViewWeight ("Block Highlight View Weight", Range(0, 1)) = 0.5
        _CloakViewWeight ("Cloak View Weight (StarMaskG)", Range(0, 1)) = 0.5
        _BlockHighlightRange ("Block Highlight Range", Range(0, 1)) = 0.9
        _BlockHighlightSoftness ("Block Highlight Softness", Range(0, 1)) = 0
        [HideInInspector] m_end_skockblock ("", Float) = 0
        // Skirk Bright Light Mask
        [HideInInspector] m_start_skockbright ("Bright Line Controls--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==1}}}", Float) = 0
        _BrightLineMask ("Bright Line Mask", 2D) = "white" { }
        _BrightLineMaskContrast ("Bright Line Mask Contrast", Range(0.01, 10)) = 1
        _BrightLineColor ("Bright Line Color", Color) = (1,1,1,1)
        _BrightLineMaskSpeed ("Bright Line Mask Speed", Vector) = (0,0,0,0)
        [HideInInspector] m_end_skockbright ("", Float) = 0
        [HideInInspector] m_start_asmodayarm("Asmoday Arm Effect", Float) = 0
        [Toggle] _HandEffectEnable ("Enable Asmoday Arm Effect", Float) = 0
        _LightColor ("Light Color", Color) = (0.4117647,0.1665225,0.1665225,0)
        _ShadowColor ("Shadow Color", Color) = (0.2941176,0.1319204,0.1319204,0)
        _ShadowWidth ("Shadow Width", Range(0, 1)) = 0.5764706
        _LineColor ("Line Color", Color) = (1,1,1,0)
        _TopLineRange ("Line Range", Range(0, 1)) = 0.2101024
        // Fresnel Controls
        [HideInInspector] m_start_asmogayfresnel ("Fresnel", Float) = 0
        _FresnelColor ("Fresnel Color", Color) = (1,0.7573529,0.7573529,0)
        _FresnelPower ("Fresnel Power", Float) = 5
        _FresnelScale ("Fresnel Scale", Range(-1, 1)) = -0.4970588
        [HideInInspector] m_end_asmogayfresnel ("", Float) = 0
        // Gradient Controls
        [HideInInspector] m_start_asmodaygradient ("Alpha Gradients", Float) = 0
        _GradientPower ("Gradient Power", Float) = 1
        _GradientScale ("Gradient Scale", Float) = 1
        [HideInInspector] m_end_asmodaygradient ("", Float) = 0
        // Mask Controls
        [HideInInspector] m_start_asmodaymask ("Mask Values", Float) = 0
        _Mask ("Mask", 2D) = "white" { }
        _DownMaskRange ("Down Mask Range", Range(0, 1)) = 0.3058824
        _TopMaskRange ("Top Mask Range", Range(0, 1)) = 0.1147379
        _Mask_Speed_U ("Mask X Scroll Speed", Float) = -0.1
        [HideInInspector] m_end_asmodaymask ("", Float) = 0
        // UV Scale and Offset for the multiple _MainTex samples
        [HideInInspector] m_start_asmodayuv ("UV Scales & Offsets", Float) = 0
        _Tex01_UV ("Mask 1 UV Scale and Offset", Vector) = (1,1,0,0)
        _Tex02_UV ("Mask 2 UV Scale and Offset", Vector) = (1,1,0,0)
        _Tex03_UV ("Mask 3 UV Scale and Offset", Vector) = (1,1,0,0)
        _Tex04_UV ("Mask 4 UV Scale and Offset", Vector) = (1,1,0,-0.01)
        _Tex05_UV ("Mask 5 UV Scale and Offset", Vector) = (1,1,0,0)
        [HideInInspector] m_end_asmodayuv ("", Float) = 0
        // Scrolling speed for the multple _MainTex samples
        [HideInInspector] m_start_asmodayspeed ("UV Scrolling Speeds", Float) = 0
        _Tex01_Speed_U ("Mask 1 X Scroll Speed", Float) = 0.1
        _Tex01_Speed_V ("Mask 1 Y Scroll Speed", Float) = 0
        _Tex02_Speed_U ("Mask 2 X Scroll Speed", Float) = -0.1
        _Tex02_Speed_V ("Mask 2 Y Scroll Speed", Float) = 0
        _Tex03_Speed_U ("Mask 3 X Scroll Speed", Float) = 0
        _Tex03_Speed_V ("Mask 3 Y Scroll Speed", Float) = -0.5
        _Tex04_Speed_U ("Mask 4 X Scroll Speed", Float) = 0
        _Tex04_Speed_V ("Mask 4 Y Scroll Speed", Float) = 0
        _Tex05_Speed_U ("Mask 5 X Scroll Speed", Float) = 0
        _Tex05_Speed_V ("Mask 5 Y Scroll Speed", Float) = 0 
        [HideInInspector] m_end_asmodayspeed ("", Float) = 0
        [HideInInspector] m_end_asmodayarm ("", Float) = 0 
        [HideInInspector] m_end_starcock ("", Float) = 0
        // Asmoday Arm
        
        // Skill Animation Fresnel
        [HideInInspector] m_start_fresnel("Fresnel", Float) = 0
        _HitColor ("Hit Color", Color) = (0,0,0,0)
        _ElementRimColor ("Element Rim Color", Color) = (0,0,0,0)
        _HitColorScaler ("Hit Color Intensity", Range(0.00, 100.00)) = 6
        _HitColorFresnelPower ("Hit Fresnel Power", Range(0.00,100.00)) = 1.5
        [HideInInspector] m_end_fresnel ("", Float) = 0
        // Hue Controls
        [HideInInspector] m_start_hueshift("Hue Shifting", Float) = 0
        [Toggle] _UseHueMask ("Enable Hue Mask", Float) = 0
        _HueMaskTexture ("Hue Mask--{condition_show:{type:PROPERTY_BOOL,data:_UseHueMask==1.0}}", 2D) = "white" {}
        // Color Hue
        [HideInInspector] m_start_colorhue ("Diffuse", Float) = 0
        [Enum(R, 0, G, 1, B, 2, A, 3)] _DiffuseMaskSource ("Hue Mask Channel--{condition_show:{type:PROPERTY_BOOL,data:_UseHueMask==1.0}}", Float) = 0
        [Toggle] _EnableColorHue ("Enable Diffuse Hue Shift", Float) = 1
        [Toggle] _AutomaticColorShift ("Enable Auto Hue Shift", Float) = 0
        _ShiftColorSpeed ("Shift Speed", Float) = 0.0
        _GlobalColorHue ("Main Hue Shift", Range(0.0, 1.0)) = 0
        _ColorHue ("Hue Shift 1", Range(0.0, 1.0)) = 0
        _ColorHue2 ("Hue Shift 2", Range(0.0, 1.0)) = 0
        _ColorHue3 ("Hue Shift 3", Range(0.0, 1.0)) = 0
        _ColorHue4 ("Hue Shift 4", Range(0.0, 1.0)) = 0
        _ColorHue5 ("Hue Shift 5", Range(0.0, 1.0)) = 0
        [HideInInspector] m_end_colorhue ("", Float) = 0
        // Outline Hue
        [HideInInspector] m_start_outlinehue ("Outline", Float) = 0
        [Enum(R, 0, G, 1, B, 2, A, 3)] _OutlineMaskSource ("Hue Mask Channel--{condition_show:{type:PROPERTY_BOOL,data:_UseHueMask==1.0}}", Float) = 0
        [Toggle] _EnableOutlineHue ("Enable Outline Hue Shift", Float) = 1
        [Toggle] _AutomaticOutlineShift ("Enable Auto Hue Shift", Float) = 0
        _ShiftOutlineSpeed ("Shift Speed", Float) = 0.0
        _GlobalOutlineHue ("Main Hue Shift", Range(0.0, 1.0)) = 0
        _OutlineHue ("Hue Shift 1", Range(0.0, 1.0)) = 0
        _OutlineHue2 ("Hue Shift 2", Range(0.0, 1.0)) = 0
        _OutlineHue3 ("Hue Shift 3", Range(0.0, 1.0)) = 0
        _OutlineHue4 ("Hue Shift 4", Range(0.0, 1.0)) = 0
        _OutlineHue5 ("Hue Shift 5", Range(0.0, 1.0)) = 0
        [HideInInspector] m_end_outlinehue ("", Float) = 0
        // Glow Hue
        [HideInInspector] m_start_glowhue ("Emission", Float) = 0
        [Enum(R, 0, G, 1, B, 2, A, 3)] _EmissionMaskSource ("Hue Mask Channel--{condition_show:{type:PROPERTY_BOOL,data:_UseHueMask==1.0}}", Float) = 0
        [Toggle] _EnableEmissionHue ("Enable Emission Hue Shift", Float) = 1
        [Toggle] _AutomaticEmissionShift ("Enable Auto Hue Shift", Float) = 0
        _ShiftEmissionSpeed ("Shift Speed", Float) = 0.0
        _GlobalEmissionHue ("Main Hue Shift", Range(0.0, 1.0)) = 0
        _EmissionHue ("Hue Shift 1", Range(0.0, 1.0)) = 0
        _EmissionHue2 ("Hue Shift 2", Range(0.0, 1.0)) = 0
        _EmissionHue3 ("Hue Shift 3", Range(0.0, 1.0)) = 0
        _EmissionHue4 ("Hue Shift 4", Range(0.0, 1.0)) = 0
        _EmissionHue5 ("Hue Shift 5", Range(0.0, 1.0)) = 0
        [HideInInspector] m_end_glowhue ("", Float) = 0
        // Rim Hue
        [HideInInspector] m_start_rimhue ("Rim", Float) = 0
        [Enum(R, 0, G, 1, B, 2, A, 3)] _RimMaskSource ("Hue Mask Channel--{condition_show:{type:PROPERTY_BOOL,data:_UseHueMask==1.0}}", Float) = 0
        [Toggle] _EnableRimHue ("Enable Rim Hue Shift", Float) = 1
        [Toggle] _AutomaticRimShift ("Enable Auto Hue Shift", Float) = 0
        _ShiftRimSpeed ("Shift Speed", Float) = 0.0
        _GlobalRimHue ("Main Hue Shift", Range(0.0, 1.0)) = 0
        _RimHue ("Hue Shift 1", Range(0.0, 1.0)) = 0
        _RimHue2 ("Hue Shift 2", Range(0.0, 1.0)) = 0
        _RimHue3 ("Hue Shift 3", Range(0.0, 1.0)) = 0
        _RimHue4 ("Hue Shift 4", Range(0.0, 1.0)) = 0
        _RimHue5 ("Hue Shift 5", Range(0.0, 1.0)) = 0
        [HideInInspector] m_end_rimhue ("", Float) = 0
        [HideInInspector] m_end_hueshift ("", float) = 0
        [HideInInspector] m_end_specialeffects ("", Float) = 0
        //Special Effects End

        //Rendering Options
        [HideInInspector] m_start_renderingOptions("Rendering Options", Float) = 0
        [Enum(UnityEngine.Rendering.CullMode)] _Cull("Cull", Float) = 0
        [Enum(Off, 0, On, 1)] _ZWrite("ZWrite", Int) = 1
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest ("ZTest", Float) = 4
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Source Blend", Int) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Destination Blend", Int) = 0
        // Debug Options
        [HideInInspector] m_start_debugOptions("Debug", Float) = 0
        [Toggle] _DebugMode ("Enable Debug Mode", float) = 0
        [Enum(Off, 0, RGB, 1, A, 2)] _DebugDiffuse("Diffuse Debug Mode", Float) = 0
        [Enum(Off, 0, R, 1, G, 2, B, 3, A, 4)] _DebugLightMap ("Light Map Debug Mode", Float) = 0
        [Enum(Off, 0, R, 1, G, 2, B, 3, A, 4)] _DebugFaceMap ("Face Map Debug Mode", Float) = 0
        [Enum(Off, 0, Bump, 1, Line SDF, 2)] _DebugNormalMap ("Normal Map Debug Mode", Float) = 0
        [Enum(Off, 0, R, 1, G, 2, B, 3, A, 4)] _DebugVertexColor ("Vertex Color Debug Mode", Float) = 0
        [Enum(Off, 0, On, 1)] _DebugRimLight ("Rim Light Debug Mode", Float) = 0
        [Enum(Off, 0, Original (Encoded), 1, Original (Raw), 2, Bumped (Encoded), 3, Bumped (Raw), 4)] _DebugNormalVector ("Normals Debug Mode", Float) = 0 
        [Enum(Off, 0, On, 1)] _DebugTangent ("Tangents/Secondary Normal Debug Mode", Float) = 0
        [Enum(Off, 0, On, 1)] _DebugMetal ("Metal Debug Mode", Float) = 0
        [Enum(Off, 0, On, 1)] _DebugSpecular ("Specular Debug Mode", Float) = 0
        [Enum(Off, 0, Factor, 1, Color, 2, Both, 3)] _DebugEmission ("Emission Debug Mode", Float) = 0 
        [Enum(Off, 0, Forward, 1, Right, 2)] _DebugFaceVector ("Facing Vector Debug Mode", Float) = 0
        [Enum(Off, 0, On, 1)] _DebugLights ("Lights Debug Mode", Float) = 0
        [HoyoToonWideEnum(Off, 0, Materail ID 1, 1, Material ID 2, 2, Material ID 3, 3, Material ID 4, 4, Material ID 5, 5, All(Color Coded), 6)] _DebugMaterialIDs ("Material ID Debug Mode", Float) = 0
        [HideInInspector] m_end_debugOptions("Debug", Float) = 0
        [HideInInspector] m_end_renderingOptions("Rendering Options", Float) = 0
        //Rendering Options End
    }
    SubShader
    {
        Tags{ "RenderType"="Opaque" "Queue"="Geometry" }
        HLSLINCLUDE

        #include "UnityCG.cginc"
        #include "UnityLightingCommon.cginc"
        #include "UnityShaderVariables.cginc"
        #include "Lighting.cginc"
        #include "AutoLight.cginc"
        #include "UnityInstancing.cginc"

        // textures : 
        Texture2D _MainTex; // this is the diffuse color texture
        float4 _MainTex_ST; // scale and translation offsets for main texture
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
        float4 _Star02Tex_ST;
        float4 _NoiseTex01_ST;
        float4 _NoiseTex02_ST;
        float4 _ColorPaletteTex_ST;
        float4 _ConstellationTex_ST;
        float4 _CloudTex_ST;
        float4 _StarTex_ST;
        Texture2D _StarMask;
        Texture2D _BlockHighlightMask;
        Texture2D _BrightLineMask;
        Texture2D _FlowMap;
        Texture2D _FlowMap02;
        Texture2D _NoiseMap;
        Texture2D _FlowMask;
        float4 _FlowMap_ST;
        float4 _FlowMap02_ST;
        float4 _NoiseMap_ST;
        float4 _FlowMask_ST;
        Texture2D _Mask;
        float4 _Mask_ST;
        // camera textures 
        UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
        Texture2D _ClipAlphaTex;
        Texture2D _HueMaskTexture;

        Texture2D _WeaponDissolveTex;
        float4 _WeaponDissolveTex_ST;
        Texture2D _WeaponPatternTex;
        float4 _WeaponPatternTex_ST;
        Texture2D _ScanPatternTex;
        float4 _ScanPatternTex_ST;

        SamplerState sampler_MainTex; 
        SamplerState sampler_LightMapTex; 
        SamplerState sampler_FaceMapTex;
        SamplerState sampler_BumpMap;
        SamplerState sampler_PackedShadowRampTex;
        SamplerState sampler_MTMap;
        SamplerState sampler_MTSpecularRamp;
        SamplerState sampler_WeaponDissolveTex;
        SamplerState sampler_WeaponPatternTex;
        SamplerState sampler_ScanPatternTex;

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

        // normal map properties
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
        float4 _SpecularColor;

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

        // outline properties 
        float  _OutlineType;
        float _FallbackOutlines;
        float _OutlineWidth;
        float _OutlineCorrectionWidth;
        float _Scale;
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

        #include "Includes/HoyoToonGenshin-inputs.hlsl"
        #include "Includes/HoyoToonGenshin-common.hlsl"

        ENDHLSL

        Pass
        {
            Name "Character Pass"
            Tags{ "LightMode" = "ForwardBase" }
            Cull [_Cull]
            Blend [_SrcBlend] [_DstBlend]
            HLSLPROGRAM
            
            #pragma multi_compile_fwdbase
            #pragma multi_compile _IS_PASS_BASE
            
            #pragma vertex vs_model
            #pragma fragment ps_model

            #include "Includes/HoyoToonGenshin-program.hlsl"
            ENDHLSL
        }      

        Pass
        {
            Name "Character Light Pass"
            Tags{ "LightMode" = "ForwardAdd" }
            Cull [_Cull]
            ZWrite Off
            Blend One One
            HLSLPROGRAM
            
            #pragma multi_compile_fwdadd
            #pragma multi_compile _IS_PASS_LIGHT

            #pragma vertex vs_model
            #pragma fragment ps_model 

            #include "Includes/HoyoToonGenshin-program.hlsl"
            ENDHLSL
        }    

        Pass
        {
            Name "Outline Pass"
            Tags{ "LightMode" = "ForwardBase" }
            Cull Front
            HLSLPROGRAM
            #pragma multi_compile_fwdbase
            
            #pragma vertex vs_edge
            #pragma fragment ps_edge

            #include "Includes/HoyoToonGenshin-program.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "Shadow Pass"
            Tags{ "LightMode" = "ShadowCaster" }
            Cull [_Cull]
            Blend [_SrcBlend] [_DstBlend]
            HLSLPROGRAM
            
            #pragma multi_compile_fwdbase
            
            #pragma vertex vs_shadow
            #pragma fragment ps_shadow

            #include "Includes/HoyoToonGenshin-program.hlsl"
            ENDHLSL
        }   
    }
    CustomEditor "HoyoToon.ShaderEditor"
}
