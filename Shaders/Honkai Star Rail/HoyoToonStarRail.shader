Shader "HoyoToon/StarRail"
{
    Properties
    {
        
        //Header
        [HideInInspector] shader_master_label ("✧<b><i><color=#C69ECE>HoyoToon Honkai Star Rail</color></i></b>✧", Float) = 0
		[HideInInspector] shader_is_using_hoyeditor ("", Float) = 0
        [HideInInspector] footer_github ("{texture:{name:hoyogithub},action:{type:URL,data:https://github.com/Melioli/HoyoToon},hover:Github}", Float) = 0
		[HideInInspector] footer_discord ("{texture:{name:hoyodiscord},action:{type:URL,data:https://discord.gg/meliverse},hover:Discord}", Float) = 0
        [HideInInspector] footer_discord ("{texture:{name:hoyomeliverse},action:{type:URL,data:https://vrchat.com/home/world/wrld_3921fce9-c4c6-4ea4-ad0d-83c6d16a9fbf},hover:Meliverse Avatars}", Float) = 0
        //Header End

        //Material Type
        [HoyoWideEnum(Base, 0, Face, 1, EyeShadow, 2, Hair, 3)]variant_selector("Material Type--{on_value_actions:[
		{value:0,actions:[{type:SET_PROPERTY,data:_BaseMaterial=1.0}, {type:SET_PROPERTY,data:_FaceMaterial=0.0}, {type:SET_PROPERTY,data:_EyeShadowMat=0.0}, {type:SET_PROPERTY,data:_HairMaterial=0.0}]},
        {value:0,actions:[{type:SET_PROPERTY,data:_CullMode=0}, {type:SET_PROPERTY,data:_SrcBlend=5}, {type:SET_PROPERTY,data:_DstBlend=10}]},
        {value:0,actions:[{type:SET_PROPERTY,data:_StencilPassA=2}, {type:SET_PROPERTY,data:_StencilPassB=0}, {type:SET_PROPERTY,data:_StencilCompA=0}]},
        {value:0,actions:[{type:SET_PROPERTY,data:_StencilCompB=0}, {type:SET_PROPERTY,data:_StencilRef=0}, {type:SET_PROPERTY,data:render_queue=2040}, {type:SET_PROPERTY,data:render_type=Opaque}]},

        {value:1,actions:[{type:SET_PROPERTY,data:_BaseMaterial=0.0}, {type:SET_PROPERTY,data:_FaceMaterial=1.0}, {type:SET_PROPERTY,data:_EyeShadowMat=0.0}, {type:SET_PROPERTY,data:_HairMaterial=0.0}]},
        {value:1,actions:[{type:SET_PROPERTY,data:_CullMode=2}, {type:SET_PROPERTY,data:_SrcBlend=1}, {type:SET_PROPERTY,data:_DstBlend=0}]},
        {value:1,actions:[{type:SET_PROPERTY,data:_StencilPassA=0}, {type:SET_PROPERTY,data:_StencilPassB=2}, {type:SET_PROPERTY,data:_StencilCompA=5}]},
        {value:1,actions:[{type:SET_PROPERTY,data:_StencilCompB=5}, {type:SET_PROPERTY,data:_StencilRef=100}, {type:SET_PROPERTY,data:render_queue=2010}, {type:SET_PROPERTY,data:render_type=Opaque}]},

        {value:2,actions:[{type:SET_PROPERTY,data:_BaseMaterial=0.0}, {type:SET_PROPERTY,data:_FaceMaterial=0.0}, {type:SET_PROPERTY,data:_EyeShadowMat=1.0}, {type:SET_PROPERTY,data:_HairMaterial=0.0}]},
        {value:2,actions:[{type:SET_PROPERTY,data:_CullMode=0}, {type:SET_PROPERTY,data:_SrcBlend=2}, {type:SET_PROPERTY,data:_DstBlend=0}]},
        {value:2,actions:[{type:SET_PROPERTY,data:_StencilPassA=0}, {type:SET_PROPERTY,data:_StencilPassB=2}, {type:SET_PROPERTY,data:_StencilCompA=0}]},
        {value:2,actions:[{type:SET_PROPERTY,data:_StencilCompB=8}, {type:SET_PROPERTY,data:_StencilRef=0}, {type:SET_PROPERTY,data:render_queue=2015}, {type:SET_PROPERTY,data:render_type=Opaque}]},

        {value:3,actions:[{type:SET_PROPERTY,data:_BaseMaterial=0.0}, {type:SET_PROPERTY,data:_FaceMaterial=0.0}, {type:SET_PROPERTY,data:_EyeShadowMat=0.0}, {type:SET_PROPERTY,data:_HairMaterial=1.0}]},
        {value:3,actions:[{type:SET_PROPERTY,data:_CullMode=0}, {type:SET_PROPERTY,data:_SrcBlend=1}, {type:SET_PROPERTY,data:_DstBlend=0}]},
        {value:3,actions:[{type:SET_PROPERTY,data:_StencilPassA=0}, {type:SET_PROPERTY,data:_StencilPassB=0}, {type:SET_PROPERTY,data:_StencilCompA=5}]},
        {value:3,actions:[{type:SET_PROPERTY,data:_StencilCompB=8}, {type:SET_PROPERTY,data:_StencilRef=100}, {type:SET_PROPERTY,data:render_queue=2020}, {type:SET_PROPERTY,data:render_type=Opaque}]}]}", Int) = 0

        //Material Type End

        // material types
        [HideInInspector] [Toggle] _BaseMaterial ("Use Base Shader", Float) = 1 // on by default
        [HideInInspector] [Toggle] _FaceMaterial ("Use Face Shader", Float) = 0
        [HideInInspector] [Toggle] _EyeShadowMat ("Use EyeShadow Shader", Float) = 0
        [HideInInspector] [Toggle] _HairMaterial ("Use Hair Shader", Float) = 0
        // -------------------------------------------

        // main coloring 
        [HideInInspector] m_start_main ("Main", Float) = 0
        [SmallTexture]_MainTex ("Diffuse Texture", 2D) = "white" {}
        [SmallTexture]_LightMap ("Light Map Texture", 2D) = "grey" {}
        [Toggle]_UseMaterialValuesLUT ("Enable Material LUT", Float) = 0
        [SmallTexture]_MaterialValuesPackLUT ("Mat Pack LUT--{condition_show:{type:PROPERTY_BOOL,data:_UseMaterialValuesLUT==1.0}}", 2D) = "white" {}
        [Toggle] _FilterLight ("Limit Spot/Point Light Intensity", Float) = 1 // because VRC world creators are fucking awful at lighting you need to do shit like this to not blow your models the fuck up
        // on by default >:(
        [HideInInspector] m_start_mainalpha ("Alpha Options", Float) = 0
        [Toggle]_IsTransparent ("Enable Transparency", float) = 0
        [Toggle] _EnableAlphaCutoff ("Enable Alpha Cutoff", Float) = 0
        _AlphaTestThreshold ("Alpha Cutoff value", Range(0.0, 1.0)) = 0.0
        [HideInInspector] m_end_mainalpha ("", Float) = 0
        [HideInInspector] m_start_maincolor ("Color Options", Float) = 0
        // _VertexShadowColor ("Vertex Shadow Color", Color) = (1, 1, 1, 1) // unsure of what this does yet for star rail
        _Color  ("Front Face Color", Color) = (1, 1, 1, 1)
        _BackColor ("Back Face Color", Color) = (1, 1, 1, 1)
        _Color0("Color 0", Color) = (1.0, 1.0, 1.0, 1.0)
        _Color1("Color 1", Color) = (1.0, 1.0, 1.0, 1.0)
        _Color2("Color 2", Color) = (1.0, 1.0, 1.0, 1.0)
        _Color3("Color 3", Color) = (1.0, 1.0, 1.0, 1.0)
        _Color4("Color 4", Color) = (1.0, 1.0, 1.0, 1.0)
        _Color5("Color 5", Color) = (1.0, 1.0, 1.0, 1.0)
        _Color6("Color 6", Color) = (1.0, 1.0, 1.0, 1.0)
        _Color7("Color 7", Color) = (1.0, 1.0, 1.0, 1.0)
        //_EnvColor ("Env Color", Color) = (1, 1, 1, 1)
        //_AddColor ("Add Color", Color) = (0, 0, 0, 0)
        [HideInInspector] m_end_maincolor ("", Float) = 0
        [HideInInspector] m_end_main ("", Float) = 0
        // -------------------------------------------

        // face specific settings 
        [HideInInspector] m_start_faceshading("Face--{condition_show:{type:PROPERTY_BOOL,data:_FaceMaterial==1.0}}", Float) = 0
        [SmallTexture] _FaceMap ("Face Map Texture", 2D) = "white" {}
        [SmallTexture] _FaceExpression ("Face Expression map", 2D) = "black" {}
        _NoseLineColor ("Nose Line Color", Color) = (1, 1, 1, 1)
        _NoseLinePower ("Nose Line Power", Range(0, 8)) = 1
        [HideInInspector] m_start_faceexpression("Face Expression", Float) = 0
        _ExCheekColor ("Expression Cheek Color, ", Color) = (1.0, 1.0, 1.0, 1.0)
        _ExMapThreshold ("Expression Map Threshold", Range(0.0, 1.0)) = 0.5
        _ExSpecularIntensity ("Expression Specular Intensity", Range(0.0, 7.0)) = 0.0
        _ExCheekIntensity ("Expression Cheek Intensity", Range(0, 1)) = 0
        _ExShyColor ("Expression Shy Color", Color) = (1, 1, 1, 1)
        _ExShyIntensity ("Expression Shy Intensity", Range(0, 1)) = 0
        _ExShadowColor ("Expression Shadow Color", Color) = (1, 1, 1, 1)
        // _ExEyeColor ("Expression Eye Color", Color) = (1, 1, 1, 1)
        _ExShadowIntensity ("Expression Shadow Intensity", Range(0, 1)) = 0
        _headUpVector ("Up Vector | XYZ", Vector) = (0, 1, 0, 0)
        _headForwardVector ("Forward Vector | XYZ", Vector) = (0, 0, 1, 0)
        _headRightVector ("Right Vector | XYZ ", Vector) = (-1, 0, 0, 0)
        [HideInInspector] m_end_faceexpression("", Float) = 0
        [HideInInspector] m_end_faceshading("", Float) = 0 

        // Hair Settings
        [HideInInspector] m_start_hair("Hair--{condition_show:{type:PROPERTY_BOOL,data:_HairMaterial==1.0}}", Float) = 0
        [Toggle]_UseHairSideFade ("Solid At Sides", Float) = 0
        _HairBlendSilhouette ("Hair Blend Silhouette", Range(0, 1)) = 0.5
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilPassA ("Stencil Pass Op A", Float) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilPassB ("Stencil Pass Op B", Float) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilCompA ("Stencil Compare Function A", Float) = 8
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilCompB ("Stencil Compare Function B", Float) = 8
        [IntRange] _StencilRef ("Stencil Reference Value", Range(0, 255)) = 0
        [HideInInspector] m_end_hair("", Float) = 0

        // Lighting Options
        // -------------------------------------------
        [HideInInspector] m_start_lighting("Lighting Options", Float) = 0
        [HideInInspector] m_start_lightandshadow("Shadow", Float) = 0
        [SmallTexture]_DiffuseRampMultiTex     ("Warm Shadow Ramp | 8 ramps", 2D) = "white" {} 
        [SmallTexture]_DiffuseCoolRampMultiTex ("Cool Shadow Ramp | 8 ramps", 2D) = "white" {}
        //[Toggle]_ShadowBoost ("Shadow Boost Enable", Float) = 0
        _ShadowRamp ("Shadow Ramp", Range(0.01, 1)) = 1
        //_ShadowBoostVal ("Shadow Boost Value", Range(0, 1)) = 0
        _ShadowColor ("Shadow Color", Color) = (0.5, 0.5, 0.5, 1)
        //_DarkColor   ("Dark Color", Color) = (0.85, 0.85, 0.85, 1)
        //_EyeShadowColor ("Eye Shadow Color", Color) = (1, 1, 1, 1)
        //_EyeBaseShadowColor ("EyeBase Shadow Color", Vector) = (1, 1, 1, 1)
		//_EyeShadowAngleMin ("EyeBase Shadow Min Angle", Range(0.36, 1.36)) = 0.85
		//_EyeShadowMaxAngle ("EyeBase Shadow Max Angle", Range(0, 1)) = 1
		//_ShadowThreshold ("Shadow Threshold", Range(0, 1)) = 0.5
		//_ShadowFeather ("Shadow Feather", Range(0.0001, 0.05)) = 0.0001
		//_BackShadowRange ("Back Shadow Range", Range(0, 1)) = 0
        [HideInInspector] m_end_lightandshadow("", Float) = 0
        [HideInInspector] m_start_lightingrim("Rim Light", Float) = 0
        _RimLightMode ("Rim Light Use LightMap.r", Range(0, 1)) = 1
        //_RimCt ("Rim CT", Float) = 5
        _Rimintensity ("Rim Intensity", Float) = 1
        _ES_Rimintensity ("Global Rim Intensity", Float) = 0.1
        //_RimWeight ("Rim Weight", Float) = 1
        //_RimFeatherWidth ("Rim Feather Width", Float) = 0.01
        //_RimIntensityTexIntensity ("Rim Texture Intensity", Range(1, -1)) = 0
        _RimWidth ("Rim Width", Float) = 1
        _RimOffset ("Rim Offset", Vector) = (0, 0, 0, 0)
        _ES_RimLightOffset ("Global Rim Light Offset | XY", Vector) = (0.0, 0.0, 0.0, 0.0)
        //_RimEdge ("Rim Edge Base", Range(0.01, 0.02)) = 0.015
        [HideInInspector] m_start_lightingrimcolor("Rimlight Color", Float) = 0
        _RimColor0 (" Rim Light Color 0 | (RGB ID = 0)", Color)   = (1, 1, 1, 1)
        _RimColor1 (" Rim Light Color 1 | (RGB ID = 31)", Color)  = (1, 1, 1, 1)
        _RimColor2 (" Rim Light Color 2 | (RGB ID = 63)", Color)  = (1, 1, 1, 1)
        _RimColor3 (" Rim Light Color 3 | (RGB ID = 95)", Color)  = (1, 1, 1, 1)
        _RimColor4 (" Rim Light Color 4 | (RGB ID = 127)", Color) = (1, 1, 1, 1)
        _RimColor5 (" Rim Light Color 5 | (RGB ID = 159)", Color) = (1, 1, 1, 1)
        _RimColor6 (" Rim Light Color 6 | (RGB ID = 192)", Color) = (1, 1, 1, 1)
        _RimColor7 (" Rim Light Color 7 | (RGB ID = 223)", Color) = (1, 1, 1, 1)
        [HideInInspector] m_end_lightingrimcolor("", Float) = 0
        // // --- Rim Width 
        // _RimWidth0 ("Rim Width 0 | (RGB ID = 0)", Float) = 1
        // _RimWidth1 ("Rim Width 1 | (RGB ID = 31)", Float) = 1
        // _RimWidth2 ("Rim Width 2 | (RGB ID = 63)", Float) = 1
        // _RimWidth3 ("Rim Width 3 | (RGB ID = 95)", Float) = 1
        // _RimWidth4 ("Rim Width 4 | (RGB ID = 127)", Float) = 1
        // _RimWidth5 ("Rim Width 5 | (RGB ID = 159)", Float) = 1
        // _RimWidth6 ("Rim Width 6 | (RGB ID = 192)", Float) = 1
        // _RimWidth7 ("Rim Width 7 | (RGB ID = 223)", Float) = 1
        // these actually go unused so im disabling them, dont delete these in case they use them in the future
        // --- Rim Edge Softness 
        [HideInInspector] m_start_lightingrimsoftness("Rimlight Softness", Float) = 0
        _RimEdgeSoftness0 ("Rim Edge Softness 0 | (RGB ID = 0)", Range(0.01, 0.9)) = 0.1
        _RimEdgeSoftness1 ("Rim Edge Softness 1 | (RGB ID = 31)", Range(0.01, 0.9)) = 0.1
        _RimEdgeSoftness2 ("Rim Edge Softness 2 | (RGB ID = 63)", Range(0.01, 0.9)) = 0.1
        _RimEdgeSoftness3 ("Rim Edge Softness 3 | (RGB ID = 95)", Range(0.01, 0.9)) = 0.1
        _RimEdgeSoftness4 ("Rim Edge Softness 4 | (RGB ID = 127)", Range(0.01, 0.9)) = 0.1
        _RimEdgeSoftness5 ("Rim Edge Softness 5 | (RGB ID = 159)", Range(0.01, 0.9)) = 0.1
        _RimEdgeSoftness6 ("Rim Edge Softness 6 | (RGB ID = 192)", Range(0.01, 0.9)) = 0.1
        _RimEdgeSoftness7 ("Rim Edge Softness 7 | (RGB ID = 223)", Range(0.01, 0.9)) = 0.1
        [HideInInspector] m_end_lightingrimsoftness("", Float) = 0
        [HideInInspector] m_start_lightingrimtype("Rimlight Type", Float) = 0
        _RimType0 ("Rim Type 0 | (RGB ID = 0)", Range(0.0, 1.0)) = 1.0
        _RimType1 ("Rim Type 1 | (RGB ID = 31)", Range(0.0, 1.0)) = 1.0
        _RimType2 ("Rim Type 2 | (RGB ID = 63)", Range(0.0, 1.0)) = 1.0
        _RimType3 ("Rim Type 3 | (RGB ID = 95)", Range(0.0, 1.0)) = 1.0
        _RimType4 ("Rim Type 4 | (RGB ID = 127)", Range(0.0, 1.0)) = 1.0
        _RimType5 ("Rim Type 5 | (RGB ID = 159)", Range(0.0, 1.0)) = 1.0
        _RimType6 ("Rim Type 6 | (RGB ID = 192)", Range(0.0, 1.0)) = 1.0
        _RimType7 ("Rim Type 7 | (RGB ID = 223)", Range(0.0, 1.0)) = 1.0
        [HideInInspector] m_end_lightingrimtype("", Float) = 0
        [HideInInspector] m_start_lightingrimdark("Rimlight Dark", Float) = 0
        _RimDark0 ("Rim Dark 0 | (RGB ID = 0)", Range(0.0, 1.0)) = 0.5
        _RimDark1 ("Rim Dark 1 | (RGB ID = 31)", Range(0.0, 1.0)) = 0.5
        _RimDark2 ("Rim Dark 2 | (RGB ID = 63)", Range(0.0, 1.0)) = 0.5
        _RimDark3 ("Rim Dark 3 | (RGB ID = 95)", Range(0.0, 1.0)) = 0.5
        _RimDark4 ("Rim Dark 4 | (RGB ID = 127)", Range(0.0, 1.0)) = 0.5
        _RimDark5 ("Rim Dark 5 | (RGB ID = 159)", Range(0.0, 1.0)) = 0.5
        _RimDark6 ("Rim Dark 6 | (RGB ID = 192)", Range(0.0, 1.0)) = 0.5
        _RimDark7 ("Rim Dark 7 | (RGB ID = 223)", Range(0.0, 1.0)) = 0.5
        [HideInInspector] m_end_lightingrimdark("", Float) = 0
        // // BACKLIGHT RIM
        // [Toggle] _EnableBackRimLight ("Enable Back Rim Light", Float) = 1
        // _RimShadowCt ("Rim Shadow Control", Float) = 1
        // _RimShadowIntensity ("Rim Shadow Intensity", Float) = 1
        // // --- Color
        // _RimShadowColor0 (" Rim Shadow Color 0 | (RGB ID = 0)", Color)   = (1, 1, 1, 1)
        // _RimShadowColor1 (" Rim Shadow Color 1 | (RGB ID = 31)", Color)  = (1, 1, 1, 1)
        // _RimShadowColor2 (" Rim Shadow Color 2 | (RGB ID = 63)", Color)  = (1, 1, 1, 1)
        // _RimShadowColor3 (" Rim Shadow Color 3 | (RGB ID = 95)", Color)  = (1, 1, 1, 1)
        // _RimShadowColor4 (" Rim Shadow Color 4 | (RGB ID = 127)", Color) = (1, 1, 1, 1)
        // _RimShadowColor5 (" Rim Shadow Color 5 | (RGB ID = 159)", Color) = (1, 1, 1, 1)
        // _RimShadowColor6 (" Rim Shadow Color 6 | (RGB ID = 192)", Color) = (1, 1, 1, 1)
        // _RimShadowColor7 (" Rim Shadow Color 7 | (RGB ID = 223)", Color) = (1, 1, 1, 1)
        // // --- Width
        // _RimShadowWidth0 ("Rim Shadow Width 0 | (RGB ID = 0)", Float) = 1
        // _RimShadowWidth1 ("Rim Shadow Width 1 | (RGB ID = 31)", Float) = 1
        // _RimShadowWidth2 ("Rim Shadow Width 2 | (RGB ID = 63)", Float) = 1
        // _RimShadowWidth3 ("Rim Shadow Width 3 | (RGB ID = 95)", Float) = 1
        // _RimShadowWidth4 ("Rim Shadow Width 4 | (RGB ID = 127)", Float) = 1
        // _RimShadowWidth5 ("Rim Shadow Width 5 | (RGB ID = 159)", Float) = 1
        // _RimShadowWidth6 ("Rim Shadow Width 6 | (RGB ID = 192)", Float) = 1
        // _RimShadowWidth7 ("Rim Shadow Width 7 | (RGB ID = 223)", Float) = 1
        // // --- Feather
        // _RimShadowFeather0 ("Rim Shadow Feather 0 | (RGB ID = 0)", Range(0.01, 0.99)) = 0.01
        // _RimShadowFeather1 ("Rim Shadow Feather 1 | (RGB ID = 31)", Range(0.01, 0.99)) = 0.01
        // _RimShadowFeather2 ("Rim Shadow Feather 2 | (RGB ID = 63)", Range(0.01, 0.99)) = 0.01
        // _RimShadowFeather3 ("Rim Shadow Feather 3 | (RGB ID = 95)", Range(0.01, 0.99)) = 0.01
        // _RimShadowFeather4 ("Rim Shadow Feather 4 | (RGB ID = 127)", Range(0.01, 0.99)) = 0.01
        // _RimShadowFeather5 ("Rim Shadow Feather 5 | (RGB ID = 159)", Range(0.01, 0.99)) = 0.01
        // _RimShadowFeather6 ("Rim Shadow Feather 6 | (RGB ID = 192)", Range(0.01, 0.99)) = 0.01
        // _RimShadowFeather7 ("Rim Shadow Feather 7 | (RGB ID = 223)", Range(0.01, 0.99)) = 0.01
        // // --- Offset 
        // _RimShadowOffset ("Rim Shadow Offset", Vector) = (0, 0, 0, 0)
        [HideInInspector] m_end_lightingrim("", Float) = 0
        [HideInInspector] m_end_lighting("", Int) = 0
        // -------------------------------------------

        // specular 
        [HideInInspector] m_start_specular("Specular", Float) = 0
        _ES_SPColor ("Global Specular Color", Color) = (1, 1, 1, 1)
        _ES_SPIntensity ("Global Specular Intensity", Float) = 0.5
        [HideInInspector] m_start_specularcolor("Specular Color", Float) = 0
        _SpecularColor0 ("Specular Color 0 | (RGB ID = 0)", Color)   = (1, 1, 1, 1)
        _SpecularColor1 ("Specular Color 1 | (RGB ID = 31)", Color)  = (1, 1, 1, 1)
        _SpecularColor2 ("Specular Color 2 | (RGB ID = 63)", Color)  = (1, 1, 1, 1)
        _SpecularColor3 ("Specular Color 3 | (RGB ID = 95)", Color)  = (1, 1, 1, 1)
        _SpecularColor4 ("Specular Color 4 | (RGB ID = 127)", Color) = (1, 1, 1, 1)
        _SpecularColor5 ("Specular Color 5 | (RGB ID = 159)", Color) = (1, 1, 1, 1)
        _SpecularColor6 ("Specular Color 6 | (RGB ID = 192)", Color) = (1, 1, 1, 1)
        _SpecularColor7 ("Specular Color 7 | (RGB ID = 223)", Color) = (1, 1, 1, 1)
        [HideInInspector] m_end_specularcolor("", Float) = 0

        [HideInInspector] m_start_specularshininess("Specular Shininess", Float) = 0
        _SpecularShininess0 ("Specular Shininess 0 (Power) | (RGB ID = 0)", Range(0.1, 500))   = 10
        _SpecularShininess1 ("Specular Shininess 1 (Power) | (RGB ID = 31)", Range(0.1, 500))  = 10
        _SpecularShininess2 ("Specular Shininess 2 (Power) | (RGB ID = 63)", Range(0.1, 500))  = 10
        _SpecularShininess3 ("Specular Shininess 3 (Power) | (RGB ID = 95)", Range(0.1, 500))  = 10
        _SpecularShininess4 ("Specular Shininess 4 (Power) | (RGB ID = 127)", Range(0.1, 500)) = 10
        _SpecularShininess5 ("Specular Shininess 5 (Power) | (RGB ID = 159)", Range(0.1, 500)) = 10
        _SpecularShininess6 ("Specular Shininess 6 (Power) | (RGB ID = 192)", Range(0.1, 500)) = 10
        _SpecularShininess7 ("Specular Shininess 7 (Power) | (RGB ID = 223)", Range(0.1, 500)) = 10
        [HideInInspector] m_end_specularshininess("", Float) = 0
        
        [HideInInspector] m_start_specularroughness("Specular Roughness", Float) = 0
        _SpecularRoughness0 ("Specular Roughness 0 | (RGB ID = 0)", Range(0, 1))   = 0.02
        _SpecularRoughness1 ("Specular Roughness 1 | (RGB ID = 31)", Range(0, 1))  = 0.02
        _SpecularRoughness2 ("Specular Roughness 2 | (RGB ID = 63)", Range(0, 1))  = 0.02
        _SpecularRoughness3 ("Specular Roughness 3 | (RGB ID = 95)", Range(0, 1))  = 0.02
        _SpecularRoughness4 ("Specular Roughness 4 | (RGB ID = 127)", Range(0, 1)) = 0.02
        _SpecularRoughness5 ("Specular Roughness 5 | (RGB ID = 159)", Range(0, 1)) = 0.02
        _SpecularRoughness6 ("Specular Roughness 6 | (RGB ID = 192)", Range(0, 1)) = 0.02
        _SpecularRoughness7 ("Specular Roughness 7 | (RGB ID = 223)", Range(0, 1)) = 0.02
        [HideInInspector] m_end_specularroughness("", Float) = 0
        
        [HideInInspector] m_start_specularintensity("Specular Intensity", Float) = 0
        _SpecularIntensity0 ("Specular Intensity 0 | (RGB ID = 0)", Range(0, 50))   = 1
        _SpecularIntensity1 ("Specular Intensity 1 | (RGB ID = 31)", Range(0, 50))  = 1
        _SpecularIntensity2 ("Specular Intensity 2 | (RGB ID = 63)", Range(0, 50))  = 1
        _SpecularIntensity3 ("Specular Intensity 3 | (RGB ID = 95)", Range(0, 50))  = 1
        _SpecularIntensity4 ("Specular Intensity 4 | (RGB ID = 127)", Range(0, 50)) = 1
        _SpecularIntensity5 ("Specular Intensity 5 | (RGB ID = 159)", Range(0, 50)) = 1
        _SpecularIntensity6 ("Specular Intensity 6 | (RGB ID = 192)", Range(0, 50)) = 1
        _SpecularIntensity7 ("Specular Intensity 7 | (RGB ID = 223)", Range(0, 50)) = 1
        [HideInInspector] m_end_specularintensity("", Float) = 0
        [HideInInspector] m_end_specular("", Float) = 0


        [HideInInspector] m_start_stockings("Stockings", Float) = 0
        [Toggle] _EnableStocking ("Enable Stockings", Float) = 0
        _StockRangeTex ("Stocking Range Texture", 2D) = "black" {}
        _Stockcolor ("Stocking Color", Color) = (1, 1, 1, 1)
        _StockDarkcolor ("Stocking Darkened Color", Color) = (1, 1, 1, 1)
        _Stockpower ("Stockings Power", Range(0.04, 1)) = 1
        _StockDarkWidth ("Stockings Rim Width", Range(0, 0.96)) = 0.5
        _StockSP ("Stockings Lighted Intensity", Range(0, 1)) = 0.25
        //_StockTransparency ("Stockings Transparency", Range(0, 1)) = 0
        _StockRoughness ("Stockings Texture Intensity", Range(0, 1)) = 1
		_Stockpower1 ("Stockings Lighted Width", Range(1, 32)) = 1
		// _Stockthickness ("Stockings Thickness", Range(0, 1)) = 0
        [HideInInspector] m_end_stockings("", Float) = 0

        
         
        [HideInInspector] m_start_specialeffects("Special Effects", Float) = 0
        [HideInInspector] m_start_specialeffectsemission("Emission", Float) = 0
        [Enum(Off, 0, Ingame, 1, Custom, 2)] _EnableEmission ("Enable Emission", Float) = 0
        _EmissionTex ("Emission Texture--{condition_show:{type:PROPERTY_BOOL,data:_EnableEmission==2}}", 2D) = "white" {}
        _EmissionTintColor ("Emission Color Tint--{condition_show:{type:PROPERTY_BOOL,data:_EnableEmission>0}}", Color) = (1, 1, 1, 1)
        _EmissionThreshold ("Emission Threshold--{condition_show:{type:PROPERTY_BOOL,data:_EnableEmission>0}}", Range(0,1)) = 0.5
        _EmissionIntensity ("Emission Intensity--{condition_show:{type:PROPERTY_BOOL,data:_EnableEmission>0}}", Float) = 1
        [HideInInspector] m_end_specialeffectsemission("", Float) = 0

        // CAUSTICS
        [HideInInspector] m_start_caustic("Caustics", Float) = 0
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
        [HideInInspector] m_start_dissolve("Dissolve", Float) = 0
        [Toggle] _DissoveONM ("Enable Dissolve", Float) = 0.0
        _DissolveRateM ("Dissolve Rate", Range(0.0, 1.0)) = 0.0
        _DissolveMap ("Distortion Map", 2D) = "white" { }
        _DissolveMask ("Dissolve Mask", 2D) = "white" { }
        _DistortionSTM ("Distortion Scale/Offset", Vector) = (2.0, 2.0, 0.0, 0.0)
        _DissolveSMT ("Dissolve Map Scale/Offset", Vector) = (2.0, 2.0, 0.0, 0.0)
        _DissolveDistortionIntensityM ("Distortion Intensity", Float) = 0.5
        _DissolveMapAddM ("Dissolve Map Threshold Offset", Float) = 0.83
        _DissolveUVM ("Dissolve UV Offset", Range(0.0, 1.0)) = 0.0
        _DissolveUVSpeedM ("Dissolve UV Speed ", Vector) = (0.0, 0.1, 0.0, -0.1)
        _DissolveComponentM ("Mask Channel Selector", Vector) = (1.0, 1.0, 0.0, 0)
        [HideInInspector]m_start_disposition("Dissolve Position & Offsets", Float) = 0
        _DissoveDirecMaskM ("Dissolve Mask Direction", Float) = -0.36
        _DissolvePosMaskPosM ("Dissolve Mask Position", Vector) = (1.0, 0.0, 0.0, 1.0)
        [Toggle]_DissolvePosMaskWorldONM ("Dissolve Mask World Position", Float) = 1
        [Toggle]_DissolvePosMaskGlobalOnM("Dissolve Position Mask Global Toggle", Float) = 1
        _DissolvePosMaskRootOffsetM ("Dissolve Position Mask Root Offset", Vector) = (0.0, 1.0, 0.0, 0.0)
        [Toggle]_DissolvePosMaskFilpOnM ("Dissolve Position Mask Flip", Float) = 0.0
        [Toggle]_DissolvePosMaskOnM ("Dissolve Position Mask On", Float) = 1.0
        [HideInInspector]m_end_disposition("", Float) = 0
        [HideInInspector] m_start_disoutline("Dissolve Border", Float) = 0
        [HDR] _DissolveOutlineColor1M (" Dissolve Outline Color 1", Color) = (0.466358513, 3.10380745, 4.24164248, 1.0)
        [HDR] _DissolveOutlineColor2M ("Dissolve Outline Color 2", Color) = (0.0, 0.0, 0.0, 0.0)
        _DissolveOutlineSize1M ("Dissolve Outline Size 1", Float) = 0.02
        _DissolveOutlineSize2M ("Dissolve Outline Size 2", Float) = -0.02
        _DissolveOutlineSmoothStepM ("Dissolve Outline Smoothstep ", Vector) = (0.0, 0.0, 0.0, 0.0)
        _DissolveOutlineOffsetM ("Dissolve Outline Offset", Float) = 1.0
        [HideInInspector] m_end_disoutline("", Float) = 0.0
        [HideInInspector] m_end_dissolve("", Float) = 0
        // Hue Controls
        [HideInInspector] m_start_hueshift("Hue Shifting", Float) = 0
        [Toggle] _UseHueMask ("Enable Hue Mask", Float) = 0
        _HueMaskTexture ("Hue Mask--{condition_show:{type:PROPERTY_BOOL,data:_UseHueMask==1.0}}", 2D) = "white" {}
        // Color Hue
        [HideInInspector] m_start_colorhue ("Diffuse}", Float) = 0
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
        _ColorHue6 ("Hue Shift 6", Range(0.0, 1.0)) = 0
        _ColorHue7 ("Hue Shift 7", Range(0.0, 1.0)) = 0
        _ColorHue8 ("Hue Shift 8", Range(0.0, 1.0)) = 0
        [HideInInspector] m_end_colorhue ("", Float) = 0
        // Outline Hue
        [HideInInspector] m_start_outlinehue ("Outline}", Float) = 0
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
        _OutlineHue6 ("Hue Shift 6", Range(0.0, 1.0)) = 0
        _OutlineHue7 ("Hue Shift 7", Range(0.0, 1.0)) = 0
        _OutlineHue8 ("Hue Shift 8", Range(0.0, 1.0)) = 0
        [HideInInspector] m_end_outlinehue ("", Float) = 0
        // Glow Hue
        [HideInInspector] m_start_glowhue ("Emission}", Float) = 0
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
        _EmissionHue6 ("Hue Shift 6", Range(0.0, 1.0)) = 0
        _EmissionHue7 ("Hue Shift 7", Range(0.0, 1.0)) = 0
        _EmissionHue8 ("Hue Shift 8", Range(0.0, 1.0)) = 0
        [HideInInspector] m_end_glowhue ("", Float) = 0
        // Rim Hue
        [HideInInspector] m_start_rimhue ("Rim}", Float) = 0
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
        _RimHue6 ("Hue Shift 6", Range(0.0, 1.0)) = 0
        _RimHue7 ("Hue Shift 7", Range(0.0, 1.0)) = 0
        _RimHue8 ("Hue Shift 8", Range(0.0, 1.0)) = 0
        [HideInInspector] m_end_rimhue ("", Float) = 0
        [HideInInspector] m_end_hueshift ("", float) = 0        
        [HideInInspector] m_end_specialeffects("", Float) = 0


        [HideInInspector] m_start_outlines("Outlines", Float) = 0
        [Toggle] _EnableOutline ("Enable Outlines", Float) = 1 // on by default
        _AlphaCutoff ("Outline Alpha Cutoff", Range(0,1)) = 0.0
        [Toggle]_EnableFOVWidth ("Enable FOV Scaling", Float) = 1
        _OutlineWidth ("Outline Width", Range(0, 1)) = 0.1
        _OutlineScale ("Outline Scale", Range(0, 1)) = 0.187
        [HideInInspector] m_start_outlinecolor("Outline Color", Float) = 0
        _OutlineColor ("Face Outline Color", Color) = (0, 0, 0, 1)
		_OutlineColor0 ("Outline Color 0 | (ID = 0)", Color) = (0, 0, 0, 1)
		_OutlineColor1 ("Outline Color 1 | (ID = 31)", Color) = (0, 0, 0, 1)
		_OutlineColor2 ("Outline Color 2 | (ID = 63)", Color) = (0, 0, 0, 1)
		_OutlineColor3 ("Outline Color 3 | (ID = 95)", Color) = (0, 0, 0, 1)
		_OutlineColor4 ("Outline Color 4 | (ID = 127)", Color) = (0, 0, 0, 1)
		_OutlineColor5 ("Outline Color 5 | (ID = 159)", Color) = (0, 0, 0, 1)
		_OutlineColor6 ("Outline Color 6 | (ID = 192)", Color) = (0, 0, 0, 1)
		_OutlineColor7 ("Outline Color 7 | (ID = 223)", Color) = (0, 0, 0, 1)
        [HideInInspector] m_end_outlinecolor("", Float) = 0
        [HideInInspector] m_start_outlinelip("Lip Outlines", Float) = 0
        _OutlineFixRange1 ("Lip _Outline Show Start", Range(0, 1)) = 0.1
        _OutlineFixRange2 ("Lip _Outline Show Max", Range(0, 1)) = 0.1
        _OutlineFixRange3 ("Lip _Outline Show Start", Range(0, 1)) = 0.1
        _OutlineFixRange4 ("Lip _Outline Show Max", Range(0, 1)) = 0.1
        _OutlineFixSide ("Outline Fix Star Side", Range(0, 1)) = 0.6
		_OutlineFixFront ("Outline Fix Star Front", Range(0, 1)) = 0.05
        _FixLipOutline ("TurnOn Temp Lip Outline", Range(0, 1)) = 0
        [HideInInspector] m_end_outlinelip("", Float) = 0
        [HideInInspector] m_end_outlines("", Float) = 0

        //Rendering Options
        [HideInInspector] m_start_renderingOptions("Rendering Options", Float) = 0
        [Enum(UnityEngine.Rendering.CullMode)] _CullMode ("Cull Mode", Float) = 2
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Source Blend", Int) = 1
		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Destination Blend", Int) = 0
        [HideInInspector] m_start_debugOptions("Debug", Float) = 0
        [Toggle] _DebugMode ("Enable Debug Mode", float) = 0
        [Enum(Off, 0, RGB, 1, A, 2)] _DebugDiffuse("Diffuse Debug Mode", Float) = 0
        [Enum(Off, 0, R, 1, G, 2, B, 3, A, 4)] _DebugLightMap ("Light Map Debug Mode", Float) = 0
        [Enum(Off, 0, R, 1, G, 2, B, 3, A, 4)] _DebugFaceMap ("Face Map Debug Mode", Float) = 0
        [Enum(Off, 0, R, 1, G, 2, B, 3, A, 4)] _DebugFaceExp ("Face Expression Map Debug Mode", Float) = 0
        [HoyoWideEnum(Off, 0, 1st, 1, 2nd, 2, 3rd, 3, 4th, 4, 5th, 5, 6th, 6, 7th, 7, 8th, 8)] _DebugMLut ("Material LUT Debug Mode", Float) = 0
        [HoyoWideEnum(Off, 0, R, 1, G, 2, B, 3, A, 4, RGB, 5, RGBA, 6)] _DebugMLutChannel ("Material LUT Channel Debug Mode", Float) = 0        
        [Enum(Off, 0, R, 1, G, 2, B, 3, A, 4)] _DebugVertexColor ("Vertex Color Debug Mode", Float) = 0
        [Enum(Off, 0, On, 1)] _DebugRimLight ("Rim Light Debug Mode", Float) = 0
        [Enum(Off, 0, Original (Encoded), 1, Original (Raw), 2)] _DebugNormalVector ("Normals Debug Mode", Float) = 0 
        [Enum(Off, 0, On, 1)] _DebugTangent ("Tangents/Secondary Normal Debug Mode", Float) = 0
        [Enum(Off, 0, On, 1)] _DebugSpecular ("Specular Debug Mode", Float) = 0
        [Enum(Off, 0, Factor, 1, Color, 2, Both, 3)] _DebugEmission ("Emission Debug Mode", Float) = 0 
        [Enum(Off, 0, Forward, 1, Right, 2, Up, 3)] _DebugFaceVector ("Facing Vector Debug Mode", Float) = 0
        [HoyoWideEnum(Off, 0, Materail ID 1, 1, Material ID 2, 2, Material ID 3, 3, Material ID 4, 4, Material ID 5, 5, Material ID 6, 6, Material ID 7, 7, Material ID 8, 8,All(Color Coded), 9)] _DebugMaterialIDs ("Material ID Debug Mode", Float) = 0        
        [Enum(Off, 0, On, 1)] _DebugLights ("Lights Debug Mode", Float) = 0
        [Enum(Off, 0, On, 1)] _DebugHairFade ("Hair Fade Debug Mode", Float) = 0
        [HideInInspector] m_end_debugOptions("Debug", Float) = 0
        [HideInInspector] m_end_renderingOptions("Rendering Options", Float) = 0
        //Rendering Options End
    }
    SubShader
    {
        Tags{ "RenderType"="Opaque" "Queue"="Geometry" }
        HLSLINCLUDE


        #pragma multi_compile_fog

        #include "UnityCG.cginc"
        #include "UnityLightingCommon.cginc"
        #include "UnityShaderVariables.cginc"
        #include "Lighting.cginc"
        #include "AutoLight.cginc"
        #include "UnityInstancing.cginc"
        #include "Includes/HoyoToonStarRail-inputs.hlsli"

        // ============================================
        // common properties 
        // -------------------------------------------
        // TEXTURES AND SAMPLERS
        Texture2D _MainTex; 
        Texture2D _LightMap;
        Texture2D _DiffuseRampMultiTex;
        Texture2D _DiffuseCoolRampMultiTex;
        Texture2D _StockRangeTex;
        Texture2D _FaceMap;
        Texture2D _FaceExpression;
        Texture2D _MaterialValuesPackLUT;
        Texture2D _EmissionTex; 
        Texture2D _CausTexture;
        Texture2D _MaskTex;
        Texture2D _DissolveMap;
        Texture2D _DissolveMask;
        Texture2D _HueMaskTexture;
        float4 _CausTexture_ST;
        SamplerState sampler_DissolveMap;
        SamplerState sampler_MaterialValuesPackLUT;
        SamplerState sampler_MainTex;
        SamplerState sampler_LightMap;
        SamplerState sampler_DiffuseRampMultiTex;
        SamplerState sampler_FaceMap;

        UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
        
        // MATERIAL STATES
        bool _BaseMaterial;
        bool _FaceMaterial;
        bool _EyeShadowMat;
        bool _HairMaterial;
        bool _IsTransparent;

        float _FilterLight;

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

        // alpha cutoff 
        float _EnableAlphaCutoff;
        float _AlphaTestThreshold;
        float _AlphaCutoff;

        // face specific properties 
        float3 _headUpVector;
        float3 _headForwardVector;
        float3 _headRightVector;
        float _HairBlendSilhouette;
        bool _UseHairSideFade;
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
        bool _EnableStocking;
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
        float _ShadowBoostVal;

        float _EnvironmentLightingStrength;

        bool _UseMaterialValuesLUT;

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
        float _DissoveONM;
        float _DissolveRateM;
        float4 _DissolveSTM;
        float4 _DistortionSTM;
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


        #include "Includes/HoyoToonStarRail-common.hlsl"

        ENDHLSL

        Pass
        {
            Name "BasePass"
            Tags{ "LightMode" = "ForwardBase" }
            Cull [_CullMode]
            Blend [_SrcBlend] [_DstBlend]
            Stencil
            {
				ref [_StencilRef]  
                Comp [_StencilCompA]
				Pass [_StencilPassA]
                Fail Keep
				ZFail Keep
			}

            HLSLPROGRAM
            // #define is_stencil
            #pragma multi_compile_fwdbase
            #define _IS_PASS_BASE
            #pragma vertex vs_base
            #pragma fragment ps_base

            #include "Includes/HoyoToonStarRail-program.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "EyeStencilPass"
            Tags{ "LightMode" = "ForwardBase" }
            Cull [_CullMode] 
            Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha OneMinusSrcAlpha
            Stencil
            {
                ref [_StencilRef]              
				Comp [_StencilCompB]
				Pass [_StencilPassB]  
                Fail Keep
				ZFail Keep
			}

            // Cull [_Cull]
            // Blend [_SrcBlend] [_DstBlend]

            HLSLPROGRAM
            #define is_stencil
            #define _IS_PASS_BASE
            #pragma multi_compile_fwdbase            
            #pragma vertex vs_base
            #pragma fragment ps_base

            #include "Includes/HoyoToonStarRail-program.hlsl"

            ENDHLSL
        }
        
        Pass
        {
            Name "Light Pass"
            Tags{ "LightMode" = "ForwardAdd" }
            Cull [_Cull]
            ZWrite Off
            Blend One One
            HLSLPROGRAM
            
            #pragma multi_compile_fwdadd
            #pragma multi_compile _IS_PASS_LIGHT

            #pragma vertex vs_base
            #pragma fragment ps_base 

            #include "Includes/HoyoToonStarRail-program.hlsl"
            ENDHLSL
        }    

        Pass
        {
            Name "Outline"
            Tags{ "LightMode" = "ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Front
            // Offset -1,-1
			
            HLSLPROGRAM

            #pragma multi_compile_fwdbase
            
            #pragma vertex vs_edge
            #pragma fragment ps_edge

            #include "Includes/HoyoToonStarRail-program.hlsl"

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

            #include "Includes/HoyoToonStarRail-program.hlsl"
            ENDHLSL
        } 
        // UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
        CustomEditor "Hoyo.ShaderEditor"
}
