Shader "HoyoToon/Star Rail/Character"
{
    Properties 
    { 
        //Header
        // [HideInInspector] shader_master_label ("✧<b><i><color=#C69ECE>HoyoToon Honkai Star Rail</color></i></b>✧", Float) = 0
		[HideInInspector] ShaderBG ("UI/background", Float) = 0
        [HideInInspector] ShaderLogo ("UI/hsrlogo", Float) = 0
        [HideInInspector] shader_is_using_hoyeditor ("", Float) = 0
        [HideInInspector] footer_github ("{texture:{name:hoyogithub},action:{type:URL,data:https://github.com/Melioli/HoyoToon},hover:Github}", Float) = 0
		[HideInInspector] footer_discord ("{texture:{name:hoyodiscord},action:{type:URL,data:https://discord.gg/meliverse},hover:Discord}", Float) = 0
        //Header End

        [HoyoToonShaderOptimizerLockButton] _ShaderOptimizerEnabled ("Lock Material", Float) = 0

        //Material Type
        [HoyoToonWideEnum(Base, 0, Face, 1, EyeShadow, 2, Hair, 3)]variant_selector("Material Type--{on_value_actions:[
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
        [HideInInspector] start_main ("Main", Float) = 0
            [SmallTexture]_MainTex ("Diffuse Texture", 2D) = "white" {}
            [SmallTexture]_LightMap ("Light Map Texture", 2D) = "grey" {}
            [Toggle]_UseMaterialValuesLUT ("Enable Material LUT", Float) = 0
            [SmallTexture]_MaterialValuesPackLUT ("Mat Pack LUT--{condition_show:{type:PROPERTY_BOOL,data:_UseMaterialValuesLUT==1.0}}", 2D) = "white" {}
            [Toggle] _MultiLight ("Enable Lighting from Multiple Sources", Float) = 1
            [Toggle] _FilterLight ("Limit Spot/Point Light Intensity", Float) = 1 // because VRC world creators are fucking awful at lighting you need to do shit like this to not blow your models the fuck up
            // on by default >:(
            [Toggle] _backfdceuv2 ("Back Face Use UV2", float) = 1
            //ifex _UseSecondaryTex == 0
            [HideInInspector] start_secondarymain("Secondary Texture", Float) = 0
                [Toggle] _UseSecondaryTex ("Enable Secondary Diffuse", float) = 0
                _SecondaryDiff ("Secondary Diffuse Texture", 2D) = "white" {}
                _SecondaryFade ("Fade to Secondary", Range(0,1)) = 0
            [HideInInspector] end_secondarymain("", Float) = 0
            //endex
            [HideInInspector] start_mainalpha ("Alpha Options", Float) = 0
                [Toggle]_IsTransparent ("Enable Transparency", float) = 0
                [Toggle] _EnableAlphaCutoff ("Enable Alpha Cutoff", Float) = 0
                _AlphaTestThreshold ("Alpha Cutoff value", Range(0.0, 1.0)) = 0.0
            [HideInInspector] end_mainalpha ("", Float) = 0
            [HideInInspector] start_maincolor ("Color Options", Float) = 0
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
            [HideInInspector] end_maincolor ("", Float) = 0
            [HideInInspector] start_facingdirection ("Facing Direction", Float) = 0
                _headUpVector ("Up Vector | XYZ", Vector) = (0, 1, 0, 0)
                _headForwardVector ("Forward Vector | XYZ", Vector) = (0, 0, 1, 0)
                _headRightVector ("Right Vector | XYZ ", Vector) = (-1, 0, 0, 0)
            [HideInInspector] end_facingdirection ("", Float) = 0
        [HideInInspector] end_main ("", Float) = 0
        // -------------------------------------------

        // face specific settings 
        //ifex _FaceMaterial == 0
        [HideInInspector] start_faceshading("Face--{condition_show:{type:PROPERTY_BOOL,data:_FaceMaterial==1.0}}", Float) = 0
            [SmallTexture] _FaceMap ("Face Map Texture", 2D) = "white" {}
            [SmallTexture] _FaceExpression ("Face Expression map", 2D) = "black" {}
            _NoseLineColor ("Nose Line Color", Color) = (1, 1, 1, 1)
            _NoseLinePower ("Nose Line Power", Range(0, 8)) = 1
            [HideInInspector] start_faceexpression("Face Expression", Float) = 0
                _ExCheekColor ("Expression Cheek Color, ", Color) = (1.0, 1.0, 1.0, 1.0)
                _ExMapThreshold ("Expression Map Threshold", Range(0.0, 1.0)) = 0.5
                _ExSpecularIntensity ("Expression Specular Intensity", Range(0.0, 7.0)) = 0.0
                _ExCheekIntensity ("Expression Cheek Intensity", Range(0, 1)) = 0
                _ExShyColor ("Expression Shy Color", Color) = (1, 1, 1, 1)
                _ExShyIntensity ("Expression Shy Intensity", Range(0, 1)) = 0
                _ExShadowColor ("Expression Shadow Color", Color) = (1, 1, 1, 1)
                // _ExEyeColor ("Expression Eye Color", Color) = (1, 1, 1, 1)
                _ExShadowIntensity ("Expression Shadow Intensity", Range(0, 1)) = 0
                
            [HideInInspector] end_faceexpression("", Float) = 0
        [HideInInspector] end_faceshading("", Float) = 0 
        //endex


        // Lighting Options
        // -------------------------------------------
        [HideInInspector] start_lighting("Lighting Options", Float) = 0
            //ifex _EnableShadow == 0
            [HideInInspector] start_lightandshadow("Shadow--{reference_property:_EnableShadow}", Float) = 0
                [Toggle] _EnableShadow ("Enable Shadow", Float) = 1
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
                //ifex _UseSelfShadow == 0
                [HideInInspector] start_selfshadow ("Self Shadow", Float) = 0
                    [Toggle] _UseSelfShadow ("Use Self Shadow", Float) = 0
                    _SelfShadowDarken ("Self Shadow Darken", Float) = 0
                    _SelfShadowDepthOffset ("Shadow Depth Offset", Float) = 0
                    _SelfShadowSampleOffset ("Shadow Sample Offset", Float) = 0
                [HideInInspector] end_selfshadow ("", Float) = 0
                //endex
            [HideInInspector] end_lightandshadow("", Float) = 0
            //endex
            //ifex _EnableRimLight == 0
            [HideInInspector] start_lightingrim("Rim Light--{reference_property:_EnableRimLight}", Float) = 0
                [Toggle] _EnableRimLight ("Enable Rim Light", Float) = 1
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
                [HideInInspector] start_lightingrimcolor("Rimlight Color", Float) = 0
                    _RimColor0 (" Rim Light Color 0 | (RGB ID = 0)", Color)   = (1, 1, 1, 1)
                    _RimColor1 (" Rim Light Color 1 | (RGB ID = 31)", Color)  = (1, 1, 1, 1)
                    _RimColor2 (" Rim Light Color 2 | (RGB ID = 63)", Color)  = (1, 1, 1, 1)
                    _RimColor3 (" Rim Light Color 3 | (RGB ID = 95)", Color)  = (1, 1, 1, 1)
                    _RimColor4 (" Rim Light Color 4 | (RGB ID = 127)", Color) = (1, 1, 1, 1)
                    _RimColor5 (" Rim Light Color 5 | (RGB ID = 159)", Color) = (1, 1, 1, 1)
                    _RimColor6 (" Rim Light Color 6 | (RGB ID = 192)", Color) = (1, 1, 1, 1)
                    _RimColor7 (" Rim Light Color 7 | (RGB ID = 223)", Color) = (1, 1, 1, 1)
                [HideInInspector] end_lightingrimcolor("", Float) = 0
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
                [HideInInspector] start_lightingrimsoftness("Rimlight Softness", Float) = 0
                    _RimEdgeSoftness0 ("Rim Edge Softness 0 | (RGB ID = 0)", Range(0.01, 0.9)) = 0.1
                    _RimEdgeSoftness1 ("Rim Edge Softness 1 | (RGB ID = 31)", Range(0.01, 0.9)) = 0.1
                    _RimEdgeSoftness2 ("Rim Edge Softness 2 | (RGB ID = 63)", Range(0.01, 0.9)) = 0.1
                    _RimEdgeSoftness3 ("Rim Edge Softness 3 | (RGB ID = 95)", Range(0.01, 0.9)) = 0.1
                    _RimEdgeSoftness4 ("Rim Edge Softness 4 | (RGB ID = 127)", Range(0.01, 0.9)) = 0.1
                    _RimEdgeSoftness5 ("Rim Edge Softness 5 | (RGB ID = 159)", Range(0.01, 0.9)) = 0.1
                    _RimEdgeSoftness6 ("Rim Edge Softness 6 | (RGB ID = 192)", Range(0.01, 0.9)) = 0.1
                    _RimEdgeSoftness7 ("Rim Edge Softness 7 | (RGB ID = 223)", Range(0.01, 0.9)) = 0.1
                [HideInInspector] end_lightingrimsoftness("", Float) = 0
                [HideInInspector] start_lightingrimtype("Rimlight Type", Float) = 0
                    _RimType0 ("Rim Type 0 | (RGB ID = 0)", Range(0.0, 1.0)) = 1.0
                    _RimType1 ("Rim Type 1 | (RGB ID = 31)", Range(0.0, 1.0)) = 1.0
                    _RimType2 ("Rim Type 2 | (RGB ID = 63)", Range(0.0, 1.0)) = 1.0
                    _RimType3 ("Rim Type 3 | (RGB ID = 95)", Range(0.0, 1.0)) = 1.0
                    _RimType4 ("Rim Type 4 | (RGB ID = 127)", Range(0.0, 1.0)) = 1.0
                    _RimType5 ("Rim Type 5 | (RGB ID = 159)", Range(0.0, 1.0)) = 1.0
                    _RimType6 ("Rim Type 6 | (RGB ID = 192)", Range(0.0, 1.0)) = 1.0
                    _RimType7 ("Rim Type 7 | (RGB ID = 223)", Range(0.0, 1.0)) = 1.0
                [HideInInspector] end_lightingrimtype("", Float) = 0
                [HideInInspector] start_lightingrimdark("Rimlight Dark", Float) = 0
                    _RimDark0 ("Rim Dark 0 | (RGB ID = 0)", Range(0.0, 1.0)) = 0.5
                    _RimDark1 ("Rim Dark 1 | (RGB ID = 31)", Range(0.0, 1.0)) = 0.5
                    _RimDark2 ("Rim Dark 2 | (RGB ID = 63)", Range(0.0, 1.0)) = 0.5
                    _RimDark3 ("Rim Dark 3 | (RGB ID = 95)", Range(0.0, 1.0)) = 0.5
                    _RimDark4 ("Rim Dark 4 | (RGB ID = 127)", Range(0.0, 1.0)) = 0.5
                    _RimDark5 ("Rim Dark 5 | (RGB ID = 159)", Range(0.0, 1.0)) = 0.5
                    _RimDark6 ("Rim Dark 6 | (RGB ID = 192)", Range(0.0, 1.0)) = 0.5
                    _RimDark7 ("Rim Dark 7 | (RGB ID = 223)", Range(0.0, 1.0)) = 0.5
                [HideInInspector] end_lightingrimdark("", Float) = 0
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
            [HideInInspector] end_lightingrim("", Float) = 0
            //endex
        [HideInInspector] end_lighting("", Int) = 0
        // -------------------------------------------

        //ifex _EnableSpecular == 0
        // specular 
        [HideInInspector] start_specular("Specular--{reference_property:_EnableSpecular}", Float) = 0
            [Toggle] _EnableSpecular ("Enable Specular", Float) = 1
            _ES_SPColor ("Global Specular Color", Color) = (1, 1, 1, 1)
            _ES_SPIntensity ("Global Specular Intensity", Float) = 0.5
            [HideInInspector] start_specularcolor("Specular Color", Float) = 0
                _SpecularColor0 ("Specular Color 0 | (RGB ID = 0)", Color)   = (1, 1, 1, 1)
                _SpecularColor1 ("Specular Color 1 | (RGB ID = 31)", Color)  = (1, 1, 1, 1)
                _SpecularColor2 ("Specular Color 2 | (RGB ID = 63)", Color)  = (1, 1, 1, 1)
                _SpecularColor3 ("Specular Color 3 | (RGB ID = 95)", Color)  = (1, 1, 1, 1)
                _SpecularColor4 ("Specular Color 4 | (RGB ID = 127)", Color) = (1, 1, 1, 1)
                _SpecularColor5 ("Specular Color 5 | (RGB ID = 159)", Color) = (1, 1, 1, 1)
                _SpecularColor6 ("Specular Color 6 | (RGB ID = 192)", Color) = (1, 1, 1, 1)
                _SpecularColor7 ("Specular Color 7 | (RGB ID = 223)", Color) = (1, 1, 1, 1)
            [HideInInspector] end_specularcolor("", Float) = 0
           
            [HideInInspector] start_specularshininess("Specular Shininess", Float) = 0
                _SpecularShininess0 ("Specular Shininess 0 (Power) | (RGB ID = 0)", Range(0.1, 500))   = 10
                _SpecularShininess1 ("Specular Shininess 1 (Power) | (RGB ID = 31)", Range(0.1, 500))  = 10
                _SpecularShininess2 ("Specular Shininess 2 (Power) | (RGB ID = 63)", Range(0.1, 500))  = 10
                _SpecularShininess3 ("Specular Shininess 3 (Power) | (RGB ID = 95)", Range(0.1, 500))  = 10
                _SpecularShininess4 ("Specular Shininess 4 (Power) | (RGB ID = 127)", Range(0.1, 500)) = 10
                _SpecularShininess5 ("Specular Shininess 5 (Power) | (RGB ID = 159)", Range(0.1, 500)) = 10
                _SpecularShininess6 ("Specular Shininess 6 (Power) | (RGB ID = 192)", Range(0.1, 500)) = 10
                _SpecularShininess7 ("Specular Shininess 7 (Power) | (RGB ID = 223)", Range(0.1, 500)) = 10
            [HideInInspector] end_specularshininess("", Float) = 0
        
            [HideInInspector] start_specularroughness("Specular Roughness", Float) = 0
                _SpecularRoughness0 ("Specular Roughness 0 | (RGB ID = 0)", Range(0, 1))   = 0.02
                _SpecularRoughness1 ("Specular Roughness 1 | (RGB ID = 31)", Range(0, 1))  = 0.02
                _SpecularRoughness2 ("Specular Roughness 2 | (RGB ID = 63)", Range(0, 1))  = 0.02
                _SpecularRoughness3 ("Specular Roughness 3 | (RGB ID = 95)", Range(0, 1))  = 0.02
                _SpecularRoughness4 ("Specular Roughness 4 | (RGB ID = 127)", Range(0, 1)) = 0.02
                _SpecularRoughness5 ("Specular Roughness 5 | (RGB ID = 159)", Range(0, 1)) = 0.02
                _SpecularRoughness6 ("Specular Roughness 6 | (RGB ID = 192)", Range(0, 1)) = 0.02
                _SpecularRoughness7 ("Specular Roughness 7 | (RGB ID = 223)", Range(0, 1)) = 0.02
            [HideInInspector] end_specularroughness("", Float) = 0
        
            [HideInInspector] start_specularintensity("Specular Intensity", Float) = 0
                _SpecularIntensity0 ("Specular Intensity 0 | (RGB ID = 0)", Range(0, 50))   = 1
                _SpecularIntensity1 ("Specular Intensity 1 | (RGB ID = 31)", Range(0, 50))  = 1
                _SpecularIntensity2 ("Specular Intensity 2 | (RGB ID = 63)", Range(0, 50))  = 1
                _SpecularIntensity3 ("Specular Intensity 3 | (RGB ID = 95)", Range(0, 50))  = 1
                _SpecularIntensity4 ("Specular Intensity 4 | (RGB ID = 127)", Range(0, 50)) = 1
                _SpecularIntensity5 ("Specular Intensity 5 | (RGB ID = 159)", Range(0, 50)) = 1
                _SpecularIntensity6 ("Specular Intensity 6 | (RGB ID = 192)", Range(0, 50)) = 1
                _SpecularIntensity7 ("Specular Intensity 7 | (RGB ID = 223)", Range(0, 50)) = 1
            [HideInInspector] end_specularintensity("", Float) = 0
        [HideInInspector] end_specular("", Float) = 0
        //endex

        //ifex _EnableStocking == 0
        [HideInInspector] start_stockings("Stockings--{reference_property:_EnableStocking}", Float) = 0
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
        [HideInInspector] end_stockings("", Float) = 0
        //endex
        //ifex _EnableOutline == 0
        [HideInInspector] start_outlines("Outlines--{reference_property:_EnableOutline}", Float) = 0
            [Toggle] _EnableOutline ("Enable Outlines", Float) = 1 // on by default
            _AlphaCutoff ("Outline Alpha Cutoff", Range(0,1)) = 0.0
            [Toggle]_EnableFOVWidth ("Enable FOV Scaling", Float) = 1
            _OutlineWidth ("Outline Width", Range(0, 1)) = 0.1
            _OutlineScale ("Outline Scale", Range(0, 1)) = 0.187
            [HideInInspector] start_outlinecolor("Outline Color", Float) = 0
                _OutlineColor ("Face Outline Color", Color) = (0, 0, 0, 1)
                _OutlineColor0 ("Outline Color 0 | (ID = 0)", Color) = (0, 0, 0, 1)
                _OutlineColor1 ("Outline Color 1 | (ID = 31)", Color) = (0, 0, 0, 1)
                _OutlineColor2 ("Outline Color 2 | (ID = 63)", Color) = (0, 0, 0, 1)
                _OutlineColor3 ("Outline Color 3 | (ID = 95)", Color) = (0, 0, 0, 1)
                _OutlineColor4 ("Outline Color 4 | (ID = 127)", Color) = (0, 0, 0, 1)
                _OutlineColor5 ("Outline Color 5 | (ID = 159)", Color) = (0, 0, 0, 1)
                _OutlineColor6 ("Outline Color 6 | (ID = 192)", Color) = (0, 0, 0, 1)
                _OutlineColor7 ("Outline Color 7 | (ID = 223)", Color) = (0, 0, 0, 1)
            [HideInInspector] end_outlinecolor("", Float) = 0
            [HideInInspector] start_outlinelip("Lip Outlines", Float) = 0
                _OutlineFixRange1 ("Lip _Outline Show Start", Range(0, 1)) = 0.1
                _OutlineFixRange2 ("Lip _Outline Show Max", Range(0, 1)) = 0.1
                _OutlineFixRange3 ("Lip _Outline Show Start", Range(0, 1)) = 0.1
                _OutlineFixRange4 ("Lip _Outline Show Max", Range(0, 1)) = 0.1
                _OutlineFixSide ("Outline Fix Star Side", Range(0, 1)) = 0.6
                _OutlineFixFront ("Outline Fix Star Front", Range(0, 1)) = 0.05
                _FixLipOutline ("TurnOn Temp Lip Outline", Range(0, 1)) = 0
            [HideInInspector] end_outlinelip("", Float) = 0
        [HideInInspector] end_outlines("", Float) = 0        
        //endex
        [HideInInspector] start_specialeffects("Special Effects", Float) = 0
            //ifex _EnableEmission == 0
            [HideInInspector] start_specialeffectsemission("Emission--{reference_property:_EmissionToggle}", Float) = 0
                [HideInInspector] [Toggle] _EmissionToggle ("", Float) = 0
                [Enum(Off, 0, Ingame, 1, Custom, 2)] _EnableEmission ("Enable Emission--{on_value_actions:[{value:0,actions:[{type:SET_PROPERTY,data:_EmissionToggle=0}]}, {value:1,actions:[{type:SET_PROPERTY,data:_EmissionToggle=1}]}, {value:2,actions:[{type:SET_PROPERTY,data:_EmissionToggle=1}]}]}", Float) = 0
                _EmissionTex ("Emission Texture--{condition_show:{type:PROPERTY_BOOL,data:_EnableEmission==2}}", 2D) = "white" {}
                _EmissionTintColor ("Emission Color Tint--{condition_show:{type:PROPERTY_BOOL,data:_EnableEmission>0}}", Color) = (1, 1, 1, 1)
                _EmissionThreshold ("Emission Threshold--{condition_show:{type:PROPERTY_BOOL,data:_EnableEmission>0}}", Range(0,1)) = 0.5
                _EmissionIntensity ("Emission Intensity--{condition_show:{type:PROPERTY_BOOL,data:_EnableEmission>0}}", Float) = 1
            [HideInInspector] end_specialeffectsemission("", Float) = 0
            //endex
            //ifex _EnableStencil == 0
            [HideInInspector] start_stencilfade("Stencils--{reference_property:_EnableStencil}", Float) = 0
                [Toggle] _EnableStencil ("Use Stencils", Float) = 0
                [HideInInspector] start_stencilalpha ("Fade Controls", Float) = 0
                    _HairBlendSilhouette ("Hair Blend Silhouette", Range(0, 1)) = 0.5
                    [Toggle]_UseHairSideFade ("Solid At Sides", Float) = 0
                    [Enum(Off, 0, Override, 1, Add, 2)] _UseDifAlphaStencil ("Diffuse Alpha Stencil Operation", Float) = 2
                    [Enum(Off, 0, Right, 1, Left, 2)] _HairSideChoose ("Stencil Filter", Int) = 0
                [HideInInspector] end_stencilalpha ("", Float) = 0
                [Enum(UnityEngine.Rendering.StencilOp)] _StencilPassA ("Stencil Pass Op A", Float) = 0
                [Enum(UnityEngine.Rendering.StencilOp)] _StencilPassB ("Stencil Pass Op B", Float) = 0
                [Enum(UnityEngine.Rendering.CompareFunction)] _StencilCompA ("Stencil Compare Function A", Float) = 8
                [Enum(UnityEngine.Rendering.CompareFunction)] _StencilCompB ("Stencil Compare Function B", Float) = 8
                [IntRange] _StencilRef ("Stencil Reference Value", Range(0, 255)) = 0
            [HideInInspector] end_stencilfade("", Float) = 0
            //endex
            //ifex _CausToggle == 0
            // CAUSTICS
            [HideInInspector] start_caustic("Caustics--{reference_property:_CausToggle}", Float) = 0
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
            [HideInInspector] end_caustic ("", Float) = 0 
            //endex
            //ifex _DissoveONM == 0
            [HideInInspector] start_dissolve("Dissolve--{reference_property:_DissoveONM}", Float) = 0
                [Toggle] _DissoveONM ("Enable Dissolve", Float) = 0.0
                [Enum(Off, 0, Simple, 1, Advanced, 2)] _DissolveMode ("Dissolve Mode--{condition_show:{type:PROPERTY_BOOL,data:_DissoveONM==1.0}}", Float) = 0
                [Toggle] _DissolveClip ("Enable Dissolve Clip--{condition_show:{type:PROPERTY_BOOL,data:_DissolveMode==2.0}}", Float) = 0.0
                _DissolveRateM ("Dissolve Rate--{condition_show:{type:PROPERTY_BOOL,data:_DissolveMode==2.0}}", Range(0.0, 1.0)) = 0.0
                _DissolveMap ("Distortion Map--{condition_show:{type:PROPERTY_BOOL,data:_DissolveMode==2.0}}", 2D) = "white" { }
                _DissolveMask ("Dissolve Mask--{condition_show:{type:PROPERTY_BOOL,data:_DissolveMode==2.0}}", 2D) = "white" { }
                [Toggle] _InvertDissovle ("Invert Dissolve Mask--{condition_show:{type:PROPERTY_BOOL,data:_DissolveMode==2.0}}", Float) = 0.0
                _DistortionSTM ("Distortion Scale/Offset--{condition_show:{type:PROPERTY_BOOL,data:_DissolveMode==2.0}}", Vector) = (2.0, 2.0, 0.0, 0.0)
                _DissolveSMT ("Dissolve Map Scale/Offset--{condition_show:{type:PROPERTY_BOOL,data:_DissolveMode==2.0}}", Vector) = (2.0, 2.0, 0.0, 0.0)
                _DissolveDistortionIntensityM ("Distortion Intensity--{condition_show:{type:PROPERTY_BOOL,data:_DissolveMode==2.0}}", Float) = 0.5
                _DissolveMapAddM ("Dissolve Map Threshold Offset--{condition_show:{type:PROPERTY_BOOL,data:_DissolveMode==2.0}}", Float) = 0.83
                _DissolveUVM ("Dissolve UV Offset--{condition_show:{type:PROPERTY_BOOL,data:_DissolveMode==2.0}}", Range(0.0, 1.0)) = 0.0
                _DissolveUVSpeedM ("Dissolve UV Speed--{condition_show:{type:PROPERTY_BOOL,data:_DissolveMode==2.0}}", Vector) = (0.0, 0.1, 0.0, -0.1)
                _DissolveComponentM ("Mask Channel Selector--{condition_show:{type:PROPERTY_BOOL,data:_DissolveMode==2.0}}", Vector) = (1.0, 1.0, 0.0, 0)
                [HideInInspector]start_disposition("Dissolve Position & Offsets--{condition_show:{type:PROPERTY_BOOL,data:_DissolveMode==2.0}}", Float) = 0
                    _DissoveDirecMaskM ("Dissolve Mask Direction", Float) = -0.36
                    _DissolvePosMaskPosM ("Dissolve Mask Position", Vector) = (1.0, 0.0, 0.0, 1.0)
                    [Toggle]_DissolvePosMaskWorldONM ("Dissolve Mask World Position", Float) = 1
                    [Toggle]_DissolvePosMaskGlobalOnM("Dissolve Position Mask Global Toggle", Float) = 1
                    _DissolvePosMaskRootOffsetM ("Dissolve Position Mask Root Offset", Vector) = (0.0, 1.0, 0.0, 0.0)
                    [Toggle]_DissolvePosMaskFilpOnM ("Dissolve Position Mask Flip", Float) = 0.0
                    [Toggle]_DissolvePosMaskOnM ("Dissolve Position Mask On", Float) = 1.0
                [HideInInspector]end_disposition("", Float) = 0
                [HideInInspector] start_disoutline("Dissolve Border--{condition_show:{type:PROPERTY_BOOL,data:_DissolveMode==2.0}}", Float) = 0
                    [HDR] _DissolveOutlineColor1M (" Dissolve Outline Color 1", Color) = (0.466358513, 3.10380745, 4.24164248, 1.0)
                    [HDR] _DissolveOutlineColor2M ("Dissolve Outline Color 2", Color) = (0.0, 0.0, 0.0, 0.0)
                    _DissolveOutlineSize1M ("Dissolve Outline Size 1", Float) = 0.02
                    _DissolveOutlineSize2M ("Dissolve Outline Size 2", Float) = -0.02
                    _DissolveOutlineSmoothStepM ("Dissolve Outline Smoothstep ", Vector) = (0.0, 0.0, 0.0, 0.0)
                    _DissolveOutlineOffsetM ("Dissolve Outline Offset", Float) = 1.0
                [HideInInspector] end_disoutline("", Float) = 0.0
        
                // simple dissolve options
                _DissolveSimpleRate ("Dissolve Rate--{condition_show:{type:PROPERTY_BOOL,data:_DissolveMode==1.0}}", Range(0.0, 1.0)) = 0.0
                [Toggle] _SimpleDissolveClip ("Enable Dissolve Clip--{condition_show:{type:PROPERTY_BOOL,data:_DissolveMode==1.0}}", Float) = 0.0
                _DissolveClipRate ("Dissolve Clip Rate--{condition_show:{type:PROPERTY_BOOL,data:_DissolveMode==1.0}}", Range(0.0, 1.0)) = 0.0
                [Enum(UV0, 0, UV1, 1, UV2, 2)] _DissolveUVChannel ("Dissolve UV Channel--{condition_show:{type:PROPERTY_BOOL,data:_DissolveMode==1.0}}", Float) = 0
                [Toggle] _DisableDissolveGradient ("Disable Dissolve Gradient--{condition_show:{type:PROPERTY_BOOL,data:_DissolveMode==1.0}}", Float) = 0.0
                [Toggle] _InvertGradient ("Invert Dissolve Gradient--{condition_show:{type:PROPERTY_BOOL,data:_DissolveMode==1.0}}", Float) = 0.0
                _DissolveGradientMask ("Dissolve Gradient Mask--{condition_show:{type:PROPERTY_BOOL,data:_DissolveMode==1.0}}", 2D) = "white" {}
                _DissolveAnimTex ("Dissolve Distortion Texture--{condition_show:{type:PROPERTY_BOOL,data:_DissolveMode==1.0}}", 2D) = "white" {}	
                _DissolveAnimSO ("Dissolve Distortion Scale|Offset--{condition_show:{type:PROPERTY_BOOL,data:_DissolveMode==1.0}}", Vector) = (1.0, 1.0, 0.0, 0.0)
                _DissolveAnimSpeed ("Dissolve Distortion Speed--{condition_show:{type:PROPERTY_BOOL,data:_DissolveMode==1.0}}", Range(-5.00, 5.00)) = 1.0
                _DissolveGradientOffset ("Dissolve Gradient Offset--{condition_show:{type:PROPERTY_BOOL,data:_DissolveMode==1.0}}", Float) = 0.0
                _DissolveAnimDirection ("Dissolve Distortion Direction | XY --{condition_show:{type:PROPERTY_BOOL,data:_DissolveMode==1.0}}", Vector) = (0.0, 0.0, 0.0, 0.0)
                _DissovleFadeSmoothstep ("Dissolve Fade Smoothstep | X = min | Y = max--{condition_show:{type:PROPERTY_BOOL,data:_DissolveMode==1.0}}", Vector) = (0.0, 1.0, 0.0, 0.0)		
                [Toggle]_DissolveUsePosition ("Dissolve Use Position--{condition_show:{type:PROPERTY_BOOL,data:_DissolveMode==1.0}}", Float) = 0.0
                [Toggle] _UseWorldPosDissolve ("Dissolve Use World Position--{condition_show:{type:AND,condition1:{type:PROPERTY_BOOL,data:_DissolveMode==1.0},condition2:{type:PROPERTY_BOOL,data:_DissolveUsePosition==1.0}}}", Float) = 0.0
                _DissolveFadeDirection ("Dissolve Fade Direction | XYZ --{condition_show:{type:PROPERTY_BOOL,data:_DissolveMode==1.0}}", Vector) = (0.0, 0.0, 0.0, 0.0)
                _DissovlePosFadeSmoothstep ("Dissolve Position Fade Smoothstep | X = min | Y = max--{condition_show:{type:PROPERTY_BOOL,data:_DissolveMode==1.0}}", Vector) = (0.0, 1.0, 0.0, 0.0)		

            [HideInInspector] end_dissolve("", Float) = 0
            //endex

            //ifex _EnableHueShift == 0
            // Hue Controls
            [HideInInspector] start_hueshift("Hue Shifting--{reference_property:_EnableHueShift}", Float) = 0
                [Toggle] _EnableHueShift ("Enable Hue Shifting", Float) = 0
                [Toggle] _UseHueMask ("Enable Hue Mask", Float) = 0
                _HueMaskTexture ("Hue Mask--{condition_show:{type:PROPERTY_BOOL,data:_UseHueMask==1.0}}", 2D) = "white" {}
                // Color Hue
                [HideInInspector] start_colorhue ("Diffuse--{reference_property:_EnableColorHue}", Float) = 0
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
                [HideInInspector] end_colorhue ("", Float) = 0
                // Outline Hue
                [HideInInspector] start_outlinehue ("Outline--{reference_property:_EnableOutlineHue}", Float) = 0
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
                [HideInInspector] end_outlinehue ("", Float) = 0
                // Glow Hue
                [HideInInspector] start_glowhue ("Emission--{reference_property:_EnableEmissionHue}", Float) = 0
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
                [HideInInspector] end_glowhue ("", Float) = 0
                // Rim Hue
                [HideInInspector] start_rimhue ("Rim--{reference_property:_EnableRimHue}", Float) = 0
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
                [HideInInspector] end_rimhue ("", Float) = 0
            [HideInInspector] end_hueshift ("", float) = 0        
            //endex
        [HideInInspector] end_specialeffects("", Float) = 0

        //Rendering Options
        [HideInInspector] start_renderingOptions("Rendering Options", Float) = 0
            [Enum(UnityEngine.Rendering.CullMode)] _CullMode ("Cull Mode", Float) = 2
            [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Source Blend", Int) = 1
            [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Destination Blend", Int) = 0
            //ifex _DebugMode == 0
            [HideInInspector] start_debugOptions("Debug--{reference_property:_DebugMode}", Float) = 0
                [Toggle] _DebugMode ("Enable Debug Mode", float) = 0
                [Enum(Off, 0, RGB, 1, A, 2)] _DebugDiffuse("Diffuse Debug Mode", Float) = 0
                [Enum(Off, 0, R, 1, G, 2, B, 3, A, 4)] _DebugLightMap ("Light Map Debug Mode", Float) = 0
                [Enum(Off, 0, R, 1, G, 2, B, 3, A, 4)] _DebugFaceMap ("Face Map Debug Mode", Float) = 0
                [Enum(Off, 0, R, 1, G, 2, B, 3, A, 4)] _DebugFaceExp ("Face Expression Map Debug Mode", Float) = 0
                [HoyoToonWideEnum(Off, 0, 1st, 1, 2nd, 2, 3rd, 3, 4th, 4, 5th, 5, 6th, 6, 7th, 7, 8th, 8)] _DebugMLut ("Material LUT Debug Mode", Float) = 0
                [HoyoToonWideEnum(Off, 0, R, 1, G, 2, B, 3, A, 4, RGB, 5, RGBA, 6)] _DebugMLutChannel ("Material LUT Channel Debug Mode", Float) = 0        
                [Enum(Off, 0, R, 1, G, 2, B, 3, A, 4)] _DebugVertexColor ("Vertex Color Debug Mode", Float) = 0
                [Enum(Off, 0, On, 1)] _DebugRimLight ("Rim Light Debug Mode", Float) = 0
                [Enum(Off, 0, Original (Encoded), 1, Original (Raw), 2)] _DebugNormalVector ("Normals Debug Mode", Float) = 0 
                [Enum(Off, 0, On, 1)] _DebugTangent ("Tangents/Secondary Normal Debug Mode", Float) = 0
                [Enum(Off, 0, On, 1)] _DebugSpecular ("Specular Debug Mode", Float) = 0
                [Enum(Off, 0, Factor, 1, Color, 2, Both, 3)] _DebugEmission ("Emission Debug Mode", Float) = 0 
                [Enum(Off, 0, Forward, 1, Right, 2, Up, 3)] _DebugFaceVector ("Facing Vector Debug Mode", Float) = 0
                [HoyoToonWideEnum(Off, 0, Materail ID 1, 1, Material ID 2, 2, Material ID 3, 3, Material ID 4, 4, Material ID 5, 5, Material ID 6, 6, Material ID 7, 7, Material ID 8, 8,All(Color Coded), 9)] _DebugMaterialIDs ("Material ID Debug Mode", Float) = 0        
                [Enum(Off, 0, On, 1)] _DebugLights ("Lights Debug Mode", Float) = 0
                [Enum(Off, 0, On, 1)] _DebugHairFade ("Hair Fade Debug Mode", Float) = 0
            [HideInInspector] end_debugOptions("Debug", Float) = 0
            //endex
        [HideInInspector] end_renderingOptions("Rendering Options", Float) = 0
        //Rendering Options End
    }
    SubShader
    {
        Tags{ "RenderType"="Opaque" "Queue"="Geometry" }
        HLSLINCLUDE

        //ifex _UseSecondaryTex == 0
        #define second_diffuse
        //endex
        //ifex _UseSelfShadow == 0
        #define self_shading
        //endex
        //ifex _EnableShadow == 0
        #define use_shadow
        //endex
        //ifex _FaceMaterial == 0
        #define faceishadow
        //endex
        //ifex _EnableSpecular == 0
        #define use_specular
        //endex 
        //ifex _EnableStocking == 0
        #define use_stocking
        //endex
        //ifex _EnableRimLight == 0
        #define use_rimlight
        //endex
        //ifex _EnableEmission == 0
        #define use_emission
        //endex
        //ifex _CausToggle == 0
        #define use_caustic
        //endex
        //ifex _EnableHueShift == 0
        #define can_shift
        //endex
        //ifex _DissoveONM == 0
        #define can_dissolve
        //endex
        //ifex _DebugMode == 0
        #define debug_mode
        //endex

        #include "UnityCG.cginc"
        #include "UnityLightingCommon.cginc"
        #include "UnityShaderVariables.cginc"
        #include "Lighting.cginc"
        #include "AutoLight.cginc"
        #include "UnityInstancing.cginc"
        #include "Includes/HoyoToonStarRail-inputs.hlsli"
        #include "Includes/HoyoToonStarRail-declarations.hlsl"
        #include "Includes/HoyoToonStarRail-common.hlsl"

        ENDHLSL

        //ifex _EnableShadow == 0 || _UseSelfShadow == 0
        Pass
        {
            Name "Hair Shadow"
            Tags{ "LightMode" = "ForwardBase" }
            Cull [_CullMode]
            // Blend [_SrcBlend] [_DstBlend]
            ZWrite Off
            ZTest LEqual
            ZClip False
            Blend DstColor Zero
            Stencil
            {
				ref 101
                Comp GEqual
				Pass Keep
                Fail Keep
            }
            HLSLPROGRAM
            // #define is_stencil
            #pragma multi_compile_fwdbase
            #define _IS_PASS_BASE
            #pragma multi_compile _is_shadow 
            #pragma vertex vs_base
            #pragma fragment ps_base

            #include "Includes/HoyoToonStarRail-program.hlsl"
            ENDHLSL
        }
        //endex

        Pass
        {
            Name "BasePass"
            Tags{ "LightMode" = "ForwardBase" }
            Cull [_CullMode]
            Blend [_SrcBlend] [_DstBlend]
            Stencil
            {
                ref 100              
        		Comp [_StencilCompA]
        		Pass [_StencilPassA]  
                // Fail Keep
        		// ZFail Keep
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

        //ifex _EnableStencil == 0
        Pass
        {
            Name "EyeStencilPass"
            Tags{ "LightMode" = "ForwardBase" }
            Cull [_CullMode] 
            Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha OneMinusSrcAlpha
            Stencil
            {
                ref 100             
        		Comp [_StencilCompB]
        		Pass [_StencilPassB]  
                // Fail Keep
        		// ZFail Keep
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
        //endex
        //ifex _MultiLight == 0
        Pass
        {
            Name "Light Pass"
            Tags{ "LightMode" = "ForwardAdd" }
            Cull [_Cull]
            ZWrite Off
            Blend One One
            
            HLSLPROGRAM
            #pragma multi_compile_fwdadd
            #define _IS_PASS_LIGHT

            #pragma vertex vs_base
            #pragma fragment ps_base 

            #include "Includes/HoyoToonStarRail-program.hlsl"
            ENDHLSL
        }  
        //endex  
        //ifex _EnableOutline == 0
        Pass
        {
            Name "Outline"
            Tags{ "LightMode" = "ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Front
			
            HLSLPROGRAM
            #pragma multi_compile_fwdbase
            #pragma vertex vs_edge
            #pragma fragment ps_edge

            #include "Includes/HoyoToonStarRail-program.hlsl"
            ENDHLSL
        }
        //endex
        
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
    CustomEditor "HoyoToon.ShaderEditor"
}
