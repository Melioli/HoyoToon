Shader "HoyoToon/Genshin"{
    Properties 
  { 
        //Header
        [HideInInspector] shader_master_label ("✧<b><i><color=#C69ECE>HoyoToon Genshin Impact</color></i></b>✧", Float) = 0
		[HideInInspector] shader_is_using_hoyeditor ("", Float) = 0
		[HideInInspector] footer_github ("{texture:{name:hoyogithub},action:{type:URL,data:https://github.com/Melioli/HoyoToon},hover:Github}", Float) = 0
		[HideInInspector] footer_discord ("{texture:{name:hoyodiscord},action:{type:URL,data:https://discord.gg/meliverse},hover:Discord}", Float) = 0
        [HideInInspector] footer_discord ("{texture:{name:hoyomeliverse},action:{type:URL,data:https://vrchat.com/home/world/wrld_3921fce9-c4c6-4ea4-ad0d-83c6d16a9fbf},hover:Meliverse Avatars}", Float) = 0
        //Header End
        

        //Material Type
        [HoyoWideEnum(Base, 0, Face, 1, Weapon, 2)]variant_selector("Material Type--{on_value_actions:[
		{value:0,actions:[{type:SET_PROPERTY,data:_UseFaceMapNew=0.0}, {type:SET_PROPERTY,data:_UseWeapon=0.0}]},
		{value:1,actions:[{type:SET_PROPERTY,data:_UseFaceMapNew=1.0}, {type:SET_PROPERTY,data:_UseWeapon=0.0}]},
        {value:2,actions:[{type:SET_PROPERTY,data:_UseFaceMapNew=0.0}, {type:SET_PROPERTY,data:_UseWeapon=1.0}
		}]}]}", Int) = 0
        //Material Type End


        //Main
        [HideInInspector] m_start_main ("Main--{button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#main},hover:Wiki Documentation}}", Float) = 0
        [SmallTexture]_MainTex("Diffuse Texture",2D)= "white" { }
        [SmallTexture]_LightMapTex("Light Map Texture", 2D) = "grey" {}
        [Enum(UV0, 0, UV1, 1)] _UseBackFaceUV2("Backface UV", int) = 1.0
        [Toggle] _VertexColorLinear ("Enable Linear Vertex Colors", Range(0.0, 1.0)) = 0.0
        [Toggle]_DayOrNight ("Enable Nighttime", Range(0.0, 1.0)) = 0.0
        [Toggle] _DisableColors ("Disable Material Color", Float) = 0
        [HideInInspector] m_start_maincolor ("Color Options--{button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#color-options},hover:Wiki Documentation}}", Float) = 0
        [HideInInspector] m_start_colormask ("Color Mask", Float) = 0
        [Toggle] _UseMaterialMasksTex("Enable Material Color Mask", Int) = 0
        [SmallTexture] _MaterialMasksTex ("Material Color Mask--{condition_show:{type:PROPERTY_BOOL,data:_UseMaterialMasksTex==1.0}}", 2D) = "white"{ }
        [HideInInspector] m_end_colormask ("", Float) = 0
        _Color ("Tint Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _Color2 ("Tint Color 2", Color) = (1.0, 1.0, 1.0, 1.0)
        _Color3 ("Tint Color 3", Color) = (1.0, 1.0, 1.0, 1.0)
        _Color4 ("Tint Color 4", Color) = (1.0, 1.0, 1.0, 1.0)
        _Color5 ("Tint Color 5", Color) = (1.0, 1.0, 1.0, 1.0)
        [HideInInspector] m_end_maincolor ("", Float) = 0
        [HideInInspector] m_start_mainalpha ("Alpha Options--{button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#alpha-options},hover:Wiki Documentation}}", Float) = 0
        [Enum(Off, 0, Transparency, 1, Glow, 2)] _MainTexAlphaUse("Diffuse Alpha Channel", Int) = 0
        _MainTexAlphaCutoff("Alpha Cuttoff", Range(0, 1.0)) = 0.5
        [HideInInspector] m_start_seethrough ("Ghosting--{button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#ghosting},hover:Wiki Documentation}}", Float) = 0
        [Helpbox]ghostmodehelpbox("Enabling Ghost Mode will require you to tweak the Alpha values of the Color Tint inside of Color Options to fade specific parts of the body.",Float)= 0
        [Enum(Off, 0, On, 1)] _AlphaSpecial("Enable Ghost Mode--{on_value_actions:[
        {value:0,actions:[{type:SET_PROPERTY,data:_SrcBlend=1},{type:SET_PROPERTY,data:_DstBlend=0},{type:SET_PROPERTY,data:render_queue=2000}]},
        {value:1,actions:[{type:SET_PROPERTY,data:_SrcBlend=5},{type:SET_PROPERTY,data:_DstBlend=10},{type:SET_PROPERTY,data:render_queue=2225}]}]}", Int) = 0
        [HideInInspector] m_end_seethrough ("", Float) = 0
        [HideInInspector] m_end_mainalpha ("", Float) = 0
        [HideInInspector] m_start_maindetail ("Details--{button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#details},hover:Wiki Documentation}}", Float) = 0
        [Toggle] _TextureLineUse ("Texture Line", Range(0.0, 1.0)) = 0.0
        _TextureLineSmoothness ("Texture Line Smoothness", Range(0.0, 1.0)) = 0.15
        _TextureLineThickness ("Texture Line Thickness", Range(0.0, 1.0)) = 0.55
        _TextureLineDistanceControl ("Texture Line Distance Control", Vector) = (0.1, 0.6, 1.0, 1.0)
        [Gamma] [HDR] _TextureLineMultiplier ("Texture Line Color", Color) = (0.6, 0.6, 0.6, 1.0)
        [HideInInspector] _TextureBiasWhenDithering ("Texture Dithering Bias", Float) = -1.0
        [HideInInspector] m_end_maindetail ("", Float) = 0
        [HideInInspector] m_start_matid ("Material IDs--{button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#material-ids},hover:Wiki Documentation}}", Float) = 0
        [Toggle] _UseMaterial2 ("Enable Material 2", Float) = 1.0
        [Toggle] _UseMaterial3 ("Enable Material 3", Float) = 1.0
        [Toggle] _UseMaterial4 ("Enable Material 4", Float) = 1.0
        [Toggle] _UseMaterial5 ("Enable Material 5", Float) = 1.0
        [HideInInspector] m_end_matid ("", Float) = 0
        [HideInInspector] m_end_main ("", Float) = 0
        //Main End

        //Normal Map
        [HideInInspector] m_start_normalmap ("Normal Map--{button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#normal-map},hover:Wiki Documentation}}", Float) = 0
        [Toggle] _UseBumpMap("Normal Map", Float) = 0.0
        [SmallTexture]_BumpMap("Normal Map",2D)= "bump" { } 
        // changed the default normal map texture to unitys basic bump map
        // [SmallTexture]_BumpMap("Normal Map",2D)= "white" { }
        _BumpScale ("Normal Map Scale", Range(0.0, 1.0)) = 0.0
        [HideInInspector] m_end_normalmap ("", Float) = 0
        //Normal Map End


        //Face Shading
        [HideInInspector] m_start_faceshading("Face--{condition_show:{type:PROPERTY_BOOL,data:_UseFaceMapNew==1.0},button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#face},hover:Wiki Documentation}} ", Float) = 0
        [Toggle] _flipFaceLighting ("Flip Face Lighting", Range(0.0, 1.0)) = 0.0
        [SmallTexture]_FaceMapTex ("Face Shadow",2D)= "white"{ }
        [HideInInspector] _UseFaceMapNew ("Enable Face Shader", Range(0.0, 1.0)) = 0.0
        _FaceMapSoftness ("Face Lighting Softness", Range(0.0, 1.0)) = 0.001
        [IntRange] _MaterialID ("Face Material ID", Range(1.0, 5.0)) = 2.0
        _headForwardVector ("Forward Vector | XYZ", Vector) = (0, 1, 0, 0)
        _headRightVector ("Right Vector | XYZ", Vector) = (0, 0, -1, 0)
        [HideInInspector] m_start_faceblush ("Blush--{button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#blush},hover:Wiki Documentation}}", Float) = 0
        _NoseBlushStrength ("Nose Blush Strength", Range(0.0, 1.0)) = 0.0
        _FaceBlushStrength ("Face Blush Strength", Range(0.0, 1.0)) = 0.0
        [Gamma] _NoseBlushColor ("Nose Blush Color", Color) = (1.0, 0.8, 0.7, 1.0)
        [Gamma] _FaceBlushColor ("Face Blush Color", Color) = (1.0, 0.8, 0.7, 1.0)
        [HideInInspector] m_end_faceblush ("", Float) = 0
        [HideInInspector] m_end_faceshading ("", Float) = 0
        //Face Shading End

        //Weapon Shading
        [HideInInspector] m_start_weaponshading("Weapon--{condition_show:{type:PROPERTY_BOOL,data:_UseWeapon==1.0},button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#weapon},hover:Wiki Documentation}}", Float) = 0
        [HideInInspector]_UseWeapon ("Weapon Shader", Range(0.0, 1.0)) = 0.0
        [Toggle] _UsePattern ("Enable Weapon Pattern", Range(0.0, 1.0)) = 1.0
        [Toggle] _ProceduralUVs ("Disable UV1", Range(0.0, 1.0)) = 0.0
        [SmallTexture]_WeaponDissolveTex("Weapon Dissolve",2D)= "white"{ }
        [SmallTexture]_WeaponPatternTex("Weapon Pattern",2D)= "white"{ }
        [SmallTexture]_ScanPatternTex("Scan Pattern",2D)= "black"{ }
        _ClipAlphaThreshold ("Dissolve Clipping Threshold", Range(0, 1)) = 1.0
        _WeaponDissolveValue ("Weapon Dissolve Value", Range(-1.0, 2.0)) = 1.0
        [Toggle] _DissolveDirection_Toggle ("Dissolve Direction Toggle", Range(0.0, 1.0)) = 0.0
        [Gamma] [HDR] _WeaponPatternColor ("Weapon Pattern Color", Color) = (1.682, 1.568729, 0.6554853, 1.0)
        _Pattern_Speed ("Pattern Speed", Float) = -0.033
        [HideInInspector] _SkillEmisssionPower ("Skill Emisssion Power", Float) = 0.6
        [Gamma] [HideInInspector] _SkillEmisssionColor ("Skill Emisssion Color", Vector) = (0.0, 0.0, 0.0, 0.0)
        [HideInInspector] _SkillEmissionScaler ("Skill Emission Scaler", Float) = 3.2
        [HideInInspector] m_start_weaponscan ("Scan--{button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#scan},hover:Wiki Documentation}}", Float) = 0
        _ScanColorScaler ("Scan Color Scaler", Float) = 0.0
        [Gamma] _ScanColor ("Scan Color", Color) = (0.8970588, 0.8970588, 0.8970588, 1.0)
        [Toggle] _ScanDirection_Switch ("Scan Direction Switch", Range(0.0, 1.0)) = 0.0
        _ScanSpeed ("Scan Speed", Float) = 0.8
        [HideInInspector] m_end_weaponscan ("", Float) = 0
        [HideInInspector] m_end_weaponshading ("", Float) = 0
        //Weapon Shading End


        //Lightning Options
        [HideInInspector] m_start_lighting("Lighting Options--{button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#lighting-options},hover:Wiki Documentation}}", Float) = 0
        [HideInInspector] g_start_light("", Int) = 0
        [HideInInspector] m_start_lightandshadow("Shadow--{button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#shadow},hover:Wiki Documentation}}", Float) = 0
        [SmallTexture]_PackedShadowRampTex("Shadow Ramp",2D)= "white"{ }
        [Toggle] _UseLightMapColorAO ("Enable Lightmap Ambient Occlusion", Range(0.0, 1.0)) = 1.0
        [Toggle] _UseShadowRamp ("Enable Shadow Ramp Texture", Float) = 1.0
        [Toggle] _UseVertexColorAO ("Enable Vertex Color Ambient Occlusion", Range(0.0, 1.0)) = 1.0
        _EnvironmentLightingStrength ("Environment Lighting Strength", Range(0.0, 1.0)) = 1.0

        _LightArea ("Shadow Position", Range(0.0, 2.0)) = 0.55
        _ShadowRampWidth ("Ramp Width", Range(0.2, 3.0)) = 1.0
        [HideInInspector] m_start_shadowtransitions("Shadow Transitions--{button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#shadow-transitions},hover:Wiki Documentation}}", Float) = 0
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
        [HideInInspector] m_start_shadowcolorsday("DayTime Colors--{button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#daytime-colors},hover:Wiki Documentation}}", Float) = 0
        [Gamma] _FirstShadowMultColor ("Daytime Shadow Color 1", Color) = (0.9, 0.7, 0.75, 1)
        [Gamma] _FirstShadowMultColor2 ("Daytime Shadow Color 2", Color) = (0.9, 0.7, 0.75, 1)
        [Gamma] _FirstShadowMultColor3 ("Daytime Shadow Color 3", Color) = (0.9, 0.7, 0.75, 1)
        [Gamma] _FirstShadowMultColor4 ("Daytime Shadow Color 4", Color) = (0.9, 0.7, 0.75, 1)
        [Gamma] _FirstShadowMultColor5 ("Daytime Shadow Color 5", Color) = (0.9, 0.7, 0.75, 1)
        [HideInInspector] m_end_shadowcolorsday ("", Float) = 0
        [HideInInspector] m_start_shadowcolorsnight("NightTime Colors--{button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#nighttime-colors},hover:Wiki Documentation}}", Float) = 0
        [Gamma] _CoolShadowMultColor ("Nighttime Shadow Color 1", Color) = (0.9, 0.7, 0.75, 1)
        [Gamma] _CoolShadowMultColor2 ("Nighttime Shadow Color 2", Color) = (0.9, 0.7, 0.75, 1)
        [Gamma] _CoolShadowMultColor3 ("Nighttime Shadow Color 3", Color) = (0.9, 0.7, 0.75, 1)
        [Gamma] _CoolShadowMultColor4 ("Nighttime Shadow Color 4", Color) = (0.9, 0.7, 0.75, 1)
        [Gamma] _CoolShadowMultColor5 ("Nighttime Shadow Color 5", Color) = (0.9, 0.7, 0.75, 1)
        [HideInInspector] m_end_shadowcolorsnight ("", Float) = 0
        [HideInInspector] m_end_lightandshadow ("", Float) = 0
        [HideInInspector] m_start_rimlight("Rim Light--{button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#rim-light},hover:Wiki Documentation}}", Float) = 0
        // [Toggle] _UseRimLight ("Enable Rim Lighting", Float) = 1 // on by default
        [Enum(Off, 0, Latest, 1,  Old, 2)] _UseRimLight ("Rim Light Calculation Mode", Float) = 1
        [Toggle] _SharpRimLight ("Enable Sharp Rim Light", Float) = 0 // 
        _RimThreshold ("Rim Threshold", Range(0.0, 1.0)) = 0.0 // 
        _RimLightIntensity ("Rim Light Intensity", Float) = 0.5
        _RimLightThickness ("Rim Light Thickness", Range(0.0, 10.0)) = 1.0
        [Enum(Add, 0, Color Dodge, 1)] _RimLightType ("Rim Light Blend Mode", Float) = 0.0
        [HideInInspector] m_start_lightingrimcolor("Rimlight Color--{button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#rim-light},hover:Wiki Documentation}}", Float) = 0
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
        [HideInInspector] m_start_reflections("Reflections--{button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#reflections},hover:Wiki Documentation}}", Float) = 0
        [HideInInspector] m_start_metallics("Metallics--{button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#metallics},hover:Wiki Documentation}}", Int) = 0
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
        [HideInInspector] m_start_metallicscolor("Metallic Colors--{condition_show:{type:PROPERTY_BOOL,data:_MetalMaterial==1.0},button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#blush},hover:Wiki Documentation}}}", Int) = 0
        [Gamma] [HDR] _MTMapDarkColor ("Metallic Matcap Dark Color", Color) = (0.51, 0.3, 0.19, 1.0)
        [Gamma] [HDR] _MTMapLightColor ("Metallic Matcap Light Color", Color) = (1.0, 1.0, 1.0, 1.0)
        [Gamma] _MTShadowMultiColor ("Metallic Matcap Shadow Multiply Color", Color) = (0.78, 0.77, 0.82, 1.0)
        [Gamma] [HDR] _MTSpecularColor ("Metallic Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
        [Gamma] _MTSharpLayerColor ("Metallic Sharp Layer Color", Color) = (1.0, 1.0, 1.0, 1.0)
        [HideInInspector] m_end_metallicscolor ("", Int) = 0
        [HideInInspector] m_end_metallics("", Int) = 0
        [HideInInspector] m_start_specular("Specular Reflections--{button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#specular-reflections},hover:Wiki Documentation}}", Int) = 0
        [Toggle] _SpecularHighlights ("Enable Specular", Float) = 0.0
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
        [HideInInspector] m_start_outlines("Outlines--{button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#outlines},hover:Wiki Documentation}}", Float) = 0
        [Enum(None, 0, Normal, 1,  Tangent, 2)] _OutlineType ("Outline Type", Float) = 1.0
        [Toggle] _FallbackOutlines ("Enable Fallback Outlines", Range(0.0, 1.0)) = 1.0
        [Toggle] [HideInInspector] _ClipPlaneWorld ("Clip Plane World", Range(0.0, 1.0)) = 1.0
        _OutlineWidth ("Outline Width", Float) = 0.03
        _Scale ("Outline Scale", Float) = 0.01
        [Toggle] [HideInInspector] _UseClipPlane ("Use Clip Plane?", Range(0.0, 1.0)) = 0.0
        [HideInInspector] _ClipPlane ("Clip Plane", Vector) = (0.0, 0.0, 0.0, 0.0)
        [HideInInspector] m_start_outlinescolor("Outline Colors--{button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#outline-colors},hover:Wiki Documentation}}", Float) = 0
        [Gamma] _OutlineColor ("Outline Color 1", Color) = (0.0, 0.0, 0.0, 1.0)
        [Gamma] _OutlineColor2 ("Outline Color 2", Color) = (0.0, 0.0, 0.0, 1.0)
        [Gamma] _OutlineColor3 ("Outline Color 3", Color) = (0.0, 0.0, 0.0, 1.0)
        [Gamma] _OutlineColor4 ("Outline Color 4", Color) = (0.0, 0.0, 0.0, 1.0)
        [Gamma] _OutlineColor5 ("Outline Color 5", Color) = (0.0, 0.0, 0.0, 1.0)
        [HideInInspector] m_end_outlinescolor ("", Float) = 0
        [HideInInspector] m_start_outlinesoffset("Outline Offset & Adjustments--{button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#outline-offset--adjustments},hover:Wiki Documentation}}", Float) = 0
        _OutlineWidthAdjustScales ("Outline Width Adjust Scales", Vector) = (0.01, 0.245, 0.6, 0.0)
        _OutlineWidthAdjustZs ("Outline Width Adjust Zs", Vector) = (0.001, 2.0, 6.0, 0.0)
        _MaxOutlineZOffset ("Max Z-Offset", Float) = 1.0
        [HideInInspector] m_end_outlinesoffset ("", Float) = 0
        [HideInInspector] m_end_outlines ("", Float) = 0
        //Outlines End

        //Special Effects
        [HideInInspector] m_start_specialeffects("Special Effects--{button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#special-effects},hover:Wiki Documentation}}", Float) = 0
        [HideInInspector] m_start_emissionglow("Emission / Archon Glow--{button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#emissionarchon-glow},hover:Wiki Documentation}}", Float) = 0
        [Enum(Default, 0, Custom, 1)] _EmissionType("Emission Type", Float) = 0.0
        [Gamma] _EmissionColor ("Emission Tint", Color) = (1.0, 1.0, 1.0, 1.0)
        [NoScaleOffset] [HDR] _CustomEmissionTex ("Custom Emission Texture--{condition_show:{type:PROPERTY_BOOL,data:_EmissionType==1}}", 2D) = "black"{}
        [NoScaleOffset] _CustomEmissionAOTex ("Custom Emission AO--{condition_show:{type:PROPERTY_BOOL,data:_EmissionType==1}}", 2D) = "white"{}
        _EmissionStrength ("Emission Strength", Float) = 1.0
        [HideInInspector] m_start_emissioneyeglow("Eye & Archon Glow--{button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#eye--archon-glow},hover:Wiki Documentation}}", Float) = 0
        [Helpbox]archonglowhelpbox("Archon Glow is exclusively for Archons. If you'd want other characters to behave the same, use the custom masking feature in the Emission section.",Float)= 0
        [Toggle] _ToggleEyeGlow ("Enable Eye & Archon Glow", Range(0.0, 1.0)) = 1.0
        _EyeGlowStrength ("Eye & Archon Glow Strength", Float) = 1.0
        [HideInInspector] m_end_emissioneyeglow ("", Float) = 0
        [HideInInspector] m_start_emissionpulse("Pulsing Emission--{button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#pulsing-emission},hover:Wiki Documentation}}", Float) = 0
        [Toggle] _TogglePulse ("Enable Pulse", Range(0.0, 1.0)) = 0.0
        [Toggle] _EyePulse ("Enable Eye & Archon Pulse", Float) =  0.0
        _PulseSpeed ("Pulse Speed", Float) = 1.0
        _PulseMinStrength ("Minimum Pulse Strength", Range(0.0, 1.0)) = 0.0
        _PulseMaxStrength ("Maximum Pulse Strength", Range(0.0, 1.0)) = 1.0
        [HideInInspector] m_end_emissionpulse ("", Float) = 0
        [HideInInspector] m_end_emissionglow ("", Float) = 0

        [HideInInspector] m_start_outlineemission("Outline Emission--{button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#outline-glow},hover:Wiki Documentation}}", Float) = 0
        [Toggle] _EnableOutlineGlow("Enable Outline Emission", Float) = 0
        _OutlineGlowInt("Outline Emission Intesnity", Range(0.0000, 100.0000)) = 1.0
        [HideInInspector] m_start_outlineemissioncolors("Outline Emission Colors--{button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#outline-emission-colors},hover:Wiki Documentation}}", Float) = 0
        _OutlineGlowColor("Outline Emission Color 1", Color) = (1.0, 1.0, 1.0, 1.0)
        _OutlineGlowColor2("Outline Emission Color 2", Color) = (1.0, 1.0, 1.0, 1.0)
        _OutlineGlowColor3("Outline Emission Color 3", Color) = (1.0, 1.0, 1.0, 1.0)
        _OutlineGlowColor4("Outline Emission Color 4", Color) = (1.0, 1.0, 1.0, 1.0)
        _OutlineGlowColor5("Outline Emission Color 5", Color) = (1.0, 1.0, 1.0, 1.0)
        [HideInInspector] m_end_outlineemissioncolors("", Float) = 0
        [HideInInspector] m_end_outlineemission ("", Float) = 0

        [HideInInspector] m_start_animatedtex("Texture Animation--{button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#texture-animation},hover:Wiki Documentation}}", Float) = 0
        [Toggle] _UseUVScroll ("Enable UV Scrolling", float) = 0
        _UVScrollX ("UV X Scroll Speed", Float) = 0
        _UVScrollY ("UV Y Scroll Speed", Float) = 0
        [Toggle]_EnableScrollXSwing ("UV X Scroll Swing", Float) = 0
        [Toggle]_EnableScrollYSwing ("UV Y Scroll Swing", Float) = 0
        [HideInInspector] m_end_animatedtex ("", Float) = 0

        [HideInInspector] m_start_starcock("Star Cloak--{button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#star-cloak},hover:Wiki Documentation}}", Float) = 0 //tribute to the starcock 
        [Toggle] _StarCloakEnable("Enable Star Cloak", Float) = 0.0
        [Enum(Paimon, 0, Asmoday, 1)] _StarCockType ("Star Cloak Type Override--{condition_show:{type:PROPERTY_BOOL,data:_StarCloakEnable==1.0}}", Float) = 0
        [Enum(UV0, 0, UV1, 1, UV2, 2 )] _StarUVSource ("UV Source--{condition_show:{type:PROPERTY_BOOL,data:_StarCloakEnable==1.0}}", Float) = 0.0
        [Toggle] _StarCloakOveride("Star Cloak Shading Only--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==0}}}", Float) = 0.0
        _StarCloakBlendRate ("Star Cloak Blend Rate--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==0}}}", Range(0.0, 2.0)) = 1.0
        _StarTex ("Star Texture 1--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==0}}}", 2D) = "black" { } // cock 
        _Star02Tex ("Star Texture 2--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==0}}}", 2D) = "black" { }
        _Star01Speed ("Star 1 Scroll Speed--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==0}}}", Float) = 0
        _StarBrightness ("Star Brightness--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==0}}}", Float) = 60
        _StarHeight ("Star Texture Height--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==0}}}", Float) = 14.89
        _Star02Height ("Star Texture 2 Height--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==0}}}", Float) = 0

        [HideInInspector] m_start_starcocknoise("Noise--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==0},condition2:{type:PROPERTY_BOOL,data:_StarCockType==1}},button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#noise},hover:Wiki Documentation}}}", Float) = 0 //starcock: the phantom cock

        _NoiseTex01 ("Noise Texture 1", 2D) = "white" { }
        _NoiseTex02 ("Noise Texture 2", 2D) = "white" { }
        _Noise01Speed ("Noise 1 Scroll Speed", Float) = 0.1
        _Noise02Speed ("Noise 2 Scroll Speed", Float) = -0.1
        _Noise03Brightness ("Noise 3 Brightness", Float) = 0.2

        [HideInInspector] m_end_starcocknoise("", Float) = 0 //starcock: attack of the cocks

        [HideInInspector] m_start_starcockcolorpallete("Color Pallete--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==0}},,button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#color-pallete},hover:Wiki Documentation}}}", Float) = 0 //starcock: revenge of the cock

        _ColorPaletteTex ("Color Palette Texture", 2D) = "white" { }
        _ColorPalletteSpeed ("Color Palette Scroll Speed", Float) = -0.1

        [HideInInspector] m_end_starcockcolorpallete("", Float) = 0 //starcock: the cock awakens
        
        [HideInInspector] m_start_starcockconstellation("Constellation--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==0}},button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#constellation},hover:Wiki Documentation}}}", Float) = 0 //starcock: the last cock
        _ConstellationTex ("Constellation Texture", 2D) = "white" { }
        _ConstellationHeight ("Constellation Texture Height", Float) = 1.2
        _ConstellationBrightness ("Constellation Brightness", Float) = 5

        [HideInInspector] m_end_starcockconstellation("", Float) = 0 //starcock: a starcock story

        [HideInInspector] m_start_starcockcloud("Cloud--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==0}},button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#cloud},hover:Wiki Documentation}}}", Float) = 0 //starcock: the rise of cock

        _CloudTex ("Cloud Texture", 2D) = "white" { }
        _CloudBrightness ("Cloud Texture Brightness", Float) = 1
        _CloudHeight ("Cloud Texture Height", Float) = 1

        [HideInInspector] m_end_starcockcloud("", Float) = 0 //starcock: the cock strikes back

        // [HideInInspector] m_start_starcockasmoday("Asmoday--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==1}},button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#cloud},hover:Wiki Documentation}}}", Float) = 0 //starcock: the rise of cock
        _FlowMap ("Star Texture--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==1}}}", 2D) = "white" { }
        _FlowMap02 ("Star Texture 2--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==1}}}", 2D) = "white" { }
        _NoiseMap ("Noise Map--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==1}}}", 2D) = "white" { }
        _FlowMask ("Flow Mask--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==1}}}", 2D) = "white" { }

        [HideInInspector] m_start_starcockgrad ("Gradient--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==1}}}", Float) = 0
        _BottomColor01 ("Top Color", Color) = (0,0,0,0)
        _BottomColor02 ("Bottom Color", Color) = (1,0,0,0)
        _BottomScale ("Gradient Scale", Float) = 1
        _BottomPower ("Gradient Power", Float) = 1
        [HideInInspector] m_end_starcockgrad ("", Float) = 0
        
        [HideInInspector] m_start_starcockflow ("Star Controls--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==1}}}", Float) = 0
        _FlowColor ("Star Color", Color) = (1,1,1,0)
        _FlowMaskScale ("Star Texture Scale", Float) = 1 
        _FlowMaskPower ("Star Texture Power", Float) = 1
        _FlowScale ("Star Intensity", Float) = 1
        _FlowMaskSpeed ("Star Texture Speed", Vector) = (0,0,0,0)
        _FlowMask02Speed ("Star Texture 02 Speed", Vector) = (0,0,0,0)
        [HideInInspector] m_end_starcockflow ("", Float) = 0
        [HideInInspector] m_start_starcockasmodaynoise ("Noise Controls--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_StarCloakEnable==1},condition2:{type:PROPERTY_BOOL,data:_StarCockType==1}}}", Float) = 0
        _NoiseScale ("Noise Scale", Range(0, 1)) = 0
        _NoiseSpeed ("Noise Speed", Vector) = (0,0,0,0)
        [HideInInspector] m_end_starcockasmodaynoise ("", Float) = 0

        // [HideInInspector] m_end_starcockasmoday("", Float) = 0

        [HideInInspector] m_end_starcock ("", Float) = 0

        [HideInInspector] m_start_asmodayarm("Asmoday Arm Effect", Float) = 0
        [Toggle] _HandEffectEnable ("Enable Asmoday Arm Effect", Float) = 0
        _LightColor ("Light Color", Color) = (0.4117647,0.1665225,0.1665225,0)
        _ShadowColor ("Shadow Color", Color) = (0.2941176,0.1319204,0.1319204,0)
        _ShadowWidth ("Shadow Width", Range(0, 1)) = 0.5764706
        _LineColor ("Line Color", Color) = (1,1,1,0)
        _TopLineRange ("Line Range", Range(0, 1)) = 0.2101024
        [HideInInspector] m_start_asmogayfresnel ("Fresnel", Float) = 0
        _FresnelColor ("Fresnel Color", Color) = (1,0.7573529,0.7573529,0)
        _FresnelPower ("Fresnel Power", Float) = 5
        _FresnelScale ("Fresnel Scale", Range(-1, 1)) = -0.4970588
        [HideInInspector] m_end_asmogayfresnel ("", Float) = 0
        [HideInInspector] m_start_asmodaygradient ("Alpha Gradients", Float) = 0
        _GradientPower ("Gradient Power", Float) = 1
        _GradientScale ("Gradient Scale", Float) = 1
        [HideInInspector] m_end_asmodaygradient ("", Float) = 0
        [HideInInspector] m_start_asmodaymask ("Mask Values", Float) = 0
        _Mask ("Mask", 2D) = "white" { }
        _DownMaskRange ("Down Mask Range", Range(0, 1)) = 0.3058824
        _TopMaskRange ("Top Mask Range", Range(0, 1)) = 0.1147379
        _Mask_Speed_U ("Mask X Scroll Speed", Float) = -0.1
        [HideInInspector] m_end_asmodaymask ("", Float) = 0
        [HideInInspector] m_start_asmodayuv ("UV Scales & Offsets", Float) = 0
        _Tex01_UV ("Mask 1 UV Scale and Offset", Vector) = (1,1,0,0)
        _Tex02_UV ("Mask 2 UV Scale and Offset", Vector) = (1,1,0,0)
        _Tex03_UV ("Mask 3 UV Scale and Offset", Vector) = (1,1,0,0)
        _Tex04_UV ("Mask 4 UV Scale and Offset", Vector) = (1,1,0,-0.01)
        _Tex05_UV ("Mask 5 UV Scale and Offset", Vector) = (1,1,0,0)
        [HideInInspector] m_end_asmodayuv ("", Float) = 0
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

        [HideInInspector] m_start_fresnel("Fresnel--{button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#fresnel},hover:Wiki Documentation}}", Float) = 0
        [Toggle] _UseFresnel ("Enable Fresnel", Range(0.0, 1.0)) = 1.0
        [Gamma] _HitColor ("Fresnel Color", Color) = (0.0, 0.0, 0.0, 1.0)
        [Gamma] _ElementRimColor ("Element Rim Color", Color) = (0.0, 0.0, 0.0, 1.0)
        _HitColorScaler ("Fresnel Color Scaler", Float) = 6
        _HitColorFresnelPower ("Fresnel Power", Float) = 1.5
        [HideInInspector] m_end_fresnel ("", Float) = 0
        [HideInInspector] m_start_caustic("Caustics--{button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#caustics},hover:Wiki Documentation}}", Float) = 0
        [Toggle] _CausToggle ("Enable Caustics", Float) = 0.0
        _CausTexture ("Caustic Texture--{condition_show:{type:PROPERTY_BOOL,data:_CausToggle==1.0}}", 2D) = "black" {} 
        _CausTexSTA ("First Caustic Texture Scale & Bias--{condition_show:{type:PROPERTY_BOOL,data:_CausToggle==1.0}}", Vector) = (1.0, 1.0, 0.0, 0.0)
        _CausTexSTB ("Second Caustic Texture Scale & Bias--{condition_show:{type:PROPERTY_BOOL,data:_CausToggle==1.0}}", Vector) = (1.0, 1.0, 0.0, 0.0)
        [Toggle] _CausUV ("Use UVs for projection--{condition_show:{type:PROPERTY_BOOL,data:_CausToggle==1.0}}", Float) = 0.0
        _CausSpeedA ("First Caustic Speed--{condition_show:{type:PROPERTY_BOOL,data:_CausToggle==1.0}}", Range(-5.00, 5.00)) = 1.0
        _CausSpeedB ("Second Caustic Speed--{condition_show:{type:PROPERTY_BOOL,data:_CausToggle==1.0}}", Range(-5.00, 5.00)) = 1.0
        _CausColor ("Caustic Color--{condition_show:{type:PROPERTY_BOOL,data:_CausToggle==1.0}}", Color) = (1.0, 1.0, 1.0, 1.0)
        _CausInt ("Caustic Intensity--{condition_show:{type:PROPERTY_BOOL,data:_CausToggle==1.0}}", Range(0.000, 10.000)) = 1.0
        _CausExp ("Caustic Exponent--{condition_show:{type:PROPERTY_BOOL,data:_CausToggle==1.0}}", Range(0.000, 10.000)) = 1.0
        [Toggle] _EnableSplit ("Enable Caustic RGB Split--{condition_show:{type:PROPERTY_BOOL,data:_CausToggle==1.0}}", Float) = 0.0
        _CausSplit ("Caustic RGB Split--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_CausToggle==1},condition2:{type:PROPERTY_BOOL,data:_EnableSplit==1}}}", Range(0.0, 1.0)) = 0.0
        [HideInInspector] m_end_caustic ("", Float) = 0 
        [HideInInspector] m_end_specialeffects ("", Float) = 0
        //Special Effects End

        //Rendering Options
        [HideInInspector] m_start_renderingOptions("Rendering Options--{button_help:{text:Tutorial,action:{type:URL,data:https://github.com/Melioli/HoyoToon/wiki/Using-the-Genshin-Shader#render-options},hover:Wiki Documentation}}", Float) = 0
        [Enum(UnityEngine.Rendering.CullMode)] _Cull("Cull", Float) = 0
        [Enum(Off, 0, On, 1)] _ZWrite("ZWrite", Int) = 1
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest ("ZTest", Float) = 4
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Source Blend", Int) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Destination Blend", Int) = 0
        [HideInInspector] m_start_debugOptions("Debug", Float) = 0
        [Toggle] _ReturnDiffuseRGB ("Show Diffuse", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnDiffuseA ("Show Diffuse Alpha", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnLightmapR ("Show Lightmap Red", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnLightmapG ("Show Lightmap Green", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnLightmapB ("Show Lightmap Blue", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnLightmapA ("Show Lightmap Alpha", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnFaceMap ("Show Face Shadow", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnFaceMapAlpha ("Show Face Shadow Alpha", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnNormalMap ("Show Normal Map", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnTextureLineMap ("Show Texture Line Map", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnVertexColorR ("Show Vertex Color Red", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnVertexColorG ("Show Vertex Color Green", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnVertexColorB ("Show Vertex Color Blue", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnVertexColorA ("Show Vertex Color Alpha", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnRimLight ("Show Rim Light", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnNormals ("Show Normals", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnRawNormals ("Show Raw Normals", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnTangents ("Show Tangents", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnMetal ("Show Metal", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnSpecular ("Show Specular", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnEmissionFactor ("Show Emission Factor", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnForwardVector ("Show Forward Vector (it should look blue)", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnRightVector ("Show Right Vector (it should look red)", Range(0.0, 1.0)) = 0.0
        [HideInInspector] m_end_debugOptions("Debug", Float) = 0
        //[Enum(Thry.ColorMask)] _ColorMask ("Color Mask", Int) = 15
        //_OffsetFactor ("Offset Factor", Float) = 0.0
        //_OffsetUnits ("Offset Units", Float) = 0.0
        //[ToggleUI]_RenderingReduceClipDistance ("Reduce Clip Distance", Float) = 0
        //[ToggleUI]_IgnoreFog ("Ignore Fog", Float) = 0
        //[HideInInspector] Instancing ("Instancing", Float) = 0 //add this property for instancing variants settings to be shown
        
        //[Enum(Thry.BlendOp)]_BlendOpAlpha ("Alpha Blend Op", Int) = 0
        //[Space][ThryHeaderLabel(Additive Blending, 13)]
        //[Enum(Thry.BlendOp)]_AddBlendOp ("RGB Blend Op", Int) = 0
        //[Enum(Thry.BlendOp)]_AddBlendOpAlpha ("Alpha Blend Op", Int) = 0
        //[Enum(UnityEngine.Rendering.BlendMode)] _AddSrcBlend ("Source Blend", Int) = 1
        //[Enum(UnityEngine.Rendering.BlendMode)] _AddDstBlend ("Destination Blend", Int) = 1
        [HideInInspector] m_end_renderingOptions("Rendering Options", Float) = 0
        //Rendering Options End
    }
    SubShader{
        Tags{ "RenderType"="Opaque" "Queue"="Geometry" }

        ZWrite [_ZWrite]

        HLSLINCLUDE

        #pragma vertex vert
        #pragma fragment frag

        #pragma multi_compile _ UNITY_HDR_ON
        // #pragma multi_compile_fog

        #include "UnityCG.cginc"
        #include "UnityLightingCommon.cginc"
        #include "UnityShaderVariables.cginc"
        #include "HoyoToonGenshin-inputs.hlsli"

        /* properties */
        Texture2D _MainTex;                 SamplerState sampler_MainTex;
        float4 _MainTex_ST;
        Texture2D _LightMapTex;             SamplerState sampler_LightMapTex;
        Texture2D _FaceMapTex;                 
        Texture2D _BumpMap;                 SamplerState sampler_BumpMap;
        Texture2D _PackedShadowRampTex;     SamplerState sampler_PackedShadowRampTex;
        Texture2D _MTSpecularRamp;          SamplerState sampler_MTSpecularRamp;
        Texture2D _MTMap;                   SamplerState sampler_MTMap;
        Texture2D _WeaponDissolveTex;       SamplerState sampler_WeaponDissolveTex;
        Texture2D _WeaponPatternTex;        SamplerState sampler_WeaponPatternTex;
        Texture2D _ScanPatternTex;          SamplerState sampler_ScanPatternTex;

        Texture2D _CustomEmissionTex;       SamplerState sampler_CustomEmissionTex;
        Texture2D _CustomEmissionAOTex;     SamplerState sampler_CustomEmissionAOTex;

        Texture2D _MaterialMasksTex;

        // star cloak textures and samplers
        Texture2D _StarTex;
        SamplerState sampler_StarTex;  
        float4 _StarTex_ST;
        Texture2D _Star02Tex;               
        float4 _Star02Tex_ST; 
        Texture2D _NoiseTex01;
        SamplerState sampler_NoiseTex01;
        float4 _NoiseTex01_ST;
        Texture2D _NoiseTex02;
        float4 _NoiseTex02_ST;
        Texture2D _ColorPaletteTex;
        SamplerState sampler_ColorPaletteTex;
        float4 _ColorPaletteTex_ST;  
        Texture2D _ConstellationTex;
        float4 _ConstellationTex_ST;
        Texture2D _CloudTex; 
        float4 _CloudTex_ST;

        Texture2D _FlowMap;
        Texture2D _FlowMap02;
        Texture2D _NoiseMap;
        SamplerState sampler_NoiseMap;
        Texture2D _FlowMask;
        float4 _FlowMap_ST;
        float4 _FlowMap02_ST;
        float4 _NoiseMap_ST;
        float4 _FlowMask_ST;

        Texture2D _CausTexture;
        float4 _CausTexture_ST;

        Texture2D _Mask; 
        SamplerState sampler_Mask;
        float4 _Mask_ST;


        UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);


        bool _UseMaterialMasksTex;
        float _DisableColors;
        float4 _Color;
        float4 _Color2;
        float4 _Color3;
        float4 _Color4;
        float4 _Color5;

        float _DayOrNight;
        float _EnvironmentLightingStrength;
        float4 _ES_SceneFrontRimColor;
        float _SharpRimLight;
        float _RimThreshold;
        float _UseRimLight;
        float _RimLightType;
        float _RimLightIntensity;
        float _RimLightThickness;
        float _VertexColorLinear;

        float4 _RimColor0;
        float4 _RimColor1;
        float4 _RimColor2;
        float4 _RimColor3;
        float4 _RimColor4;
        float _RimEdgeSoftness0;
        float _RimEdgeSoftness1;
        float _RimEdgeSoftness2;
        float _RimEdgeSoftness3;
        float _RimEdgeSoftness4;
        float _RimPower0;
        float _RimPower1;
        float _RimPower2;
        float _RimPower3;
        float _RimPower4;

        float _UseFresnel;
        float4 _HitColor;
        float4 _ElementRimColor;
        float _HitColorScaler;
        float _HitColorFresnelPower;

        float _UseFaceMapNew;
        float4 _headForwardVector;
        float4 _headRightVector;
        float _FaceMapSoftness;
        float _flipFaceLighting;
        float _MaterialID;
        float _NoseBlushStrength;
        float4 _NoseBlushColor;
        float _FaceBlushStrength;
        float4 _FaceBlushColor;

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

        float _UseWeapon;
        float _UsePattern;
        float _ProceduralUVs;
        float _ClipAlphaThreshold;
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

        float _MainTexAlphaUse;
        bool _AlphaSpecial;

        float _ToggleEyeGlow;
        float _EmissionType;
        float4 _EmissionColor;
        float _EyeGlowStrength;
        float _EmissionStrength;
        bool _EyePulse;
        float _TogglePulse;
        float _PulseSpeed;
        float _PulseMinStrength;
        float _PulseMaxStrength;

        float _MainTexAlphaCutoff;

        float _BumpScale;
        float _LightArea;
        float _ShadowRampWidth;
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
        float _UseBackFaceUV2;
        bool _UseBumpMap;
        float _UseLightMapColorAO;
        float _UseMaterial2;
        float _UseMaterial3;
        float _UseMaterial4;
        float _UseMaterial5;
        float _UseShadowRamp;
        float _UseVertexColorAO;
        float4 _CoolShadowMultColor;
        float4 _CoolShadowMultColor2;
        float4 _CoolShadowMultColor3;
        float4 _CoolShadowMultColor4;
        float4 _CoolShadowMultColor5;
        float4 _FirstShadowMultColor;
        float4 _FirstShadowMultColor2;
        float4 _FirstShadowMultColor3;
        float4 _FirstShadowMultColor4;
        float4 _FirstShadowMultColor5;

        float _SpecularHighlights;
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

        float _MTMapBrightness;
        float _MTMapTileScale;
        float _MTShininess;
        float _MTSpecularAttenInShadow;
        float _MTSpecularScale;
        float _MTSharpLayerOffset;
        float _MTUseSpecularRamp;
        float _MetalMaterial;
        float4 _MTMapDarkColor;
        float4 _MTMapLightColor;
        float4 _MTShadowMultiColor;
        float4 _MTSpecularColor;
        float4 _MTSharpLayerColor;

        float _TextureBiasWhenDithering;
        float _TextureLineSmoothness;
        float _TextureLineThickness;
        float _TextureLineUse;
        float4 _TextureLineDistanceControl;
        float4 _TextureLineMultiplier;

        float _StarCloakEnable;
        float _StarCloakBlendRate;
        float _StarCockType;
        float _StarCloakOveride;
        float _StarUVSource;
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

        float _UseUVScroll;
        float _UVScrollX;
        float _UVScrollY;
        float _EnableScrollXSwing;
        float _EnableScrollYSwing;

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

        bool _EnableOutlineGlow;
        float _OutlineGlowInt;
        float4 _OutlineGlowColor;
        float4 _OutlineGlowColor2;
        float4 _OutlineGlowColor3;
        float4 _OutlineGlowColor4;
        float4 _OutlineGlowColor5;


        float _ClipPlaneWorld;
        float _MaxOutlineZOffset;
        float _OutlineType; // cb0[13]
        float _FallbackOutlines;
        float _OutlineWidth; // cb0[39].w or cb0[15].x
        float _Scale; // cb0[17].z
        float _UseClipPlane;
        float4 _ClipPlane; // cb0[26]
        float4 _OutlineColor;
        float4 _OutlineColor2;
        float4 _OutlineColor3;
        float4 _OutlineColor4;
        float4 _OutlineColor5;
        float4 _OutlineWidthAdjustScales; // cb0[20]
        float4 _OutlineWidthAdjustZs; // cb0[19]

        float _ReturnDiffuseRGB;
        float _ReturnDiffuseA;
        float _ReturnLightmapR;
        float _ReturnLightmapG;
        float _ReturnLightmapB;
        float _ReturnLightmapA;
        float _ReturnFaceMap;
        float _ReturnFaceMapAlpha;
        float _ReturnNormalMap;
        float _ReturnTextureLineMap;
        float _ReturnVertexColorR;
        float _ReturnVertexColorG;
        float _ReturnVertexColorB;
        float _ReturnVertexColorA;
        float _ReturnRimLight;
        float _ReturnNormals;
        float _ReturnRawNormals;
        float _ReturnTangents;
        float _ReturnMetal;
        float _ReturnSpecular;
        float _ReturnEmissionFactor;
        float _ReturnForwardVector;
        float _ReturnRightVector;

        /* end of properties */


        #include "HoyoToonGenshin-helpers.hlsl"

        ENDHLSL

        Pass{
            Name "ForwardBase"

            Tags{ "LightMode" = "ForwardBase" }

            Cull [_Cull]

            Blend [_SrcBlend] [_DstBlend]

            HLSLPROGRAM

            #pragma multi_compile_fwdbase

            #include "HoyoToonGenshin-main.hlsl"

            ENDHLSL
        }
        Pass{
            Name "OutlinePass"
            
            Tags{ "LightMode" = "ForwardBase" }

            Cull Front

            Blend [_SrcBlend] [_DstBlend]

            HLSLPROGRAM

            #pragma multi_compile_fwdbase

            #include "HoyoToonGenshin-outlines.hlsl"

            ENDHLSL
        }
        Pass
        {
            Tags {"LightMode"="ShadowCaster"}

            Cull [_Cull]

            HLSLPROGRAM
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"
            #include "HoyoToonGenshin-shadows.hlsl"
            ENDHLSL
        }
    }
    CustomEditor "Hoyo.ShaderEditor"
}
