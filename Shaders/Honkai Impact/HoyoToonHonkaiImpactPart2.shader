Shader "HoyoToon/Honkai Impact/Character Part 2"
{
    Properties 
  { 
        //Header
        //[HideInInspector] shader_master_label ("✧<b><i><color=#C69ECE>HoyoToon Honkai Impact Part 2</color></i></b>✧", Float) = 0
        [HideInInspector] shader_master_bg ("UI/background", Float) = 0
        [HideInInspector] shader_master_logo ("UI/hi3p2logo", Float) = 0
        [HideInInspector] shader_is_using_hoyeditor ("", Float) = 0
        [HideInInspector] footer_github ("{texture:{name:hoyogithub},action:{type:URL,data:https://github.com/Melioli/HoyoToon},hover:Github}", Float) = 0
        [HideInInspector] footer_discord ("{texture:{name:hoyodiscord},action:{type:URL,data:https://discord.gg/meliverse},hover:Discord}", Float) = 0
        //Header End

        [HoyoToonWideEnum(Base, 0, Face, 1, Hair, 2, Eye, 3)]variant_selector("Material Type--{on_value_actions:[
            {value:0,actions:[{type:SET_PROPERTY,data:_StencilPassA=0}, {type:SET_PROPERTY,data:_StencilPassB=0}, {type:SET_PROPERTY,data:_StencilCompA=8}]},
            {value:0,actions:[{type:SET_PROPERTY,data:_StencilCompB=8}, {type:SET_PROPERTY,data:_StencilRef=0}, {type:SET_PROPERTY,data:render_queue=2000}, {type:SET_PROPERTY,data:render_type=Opaque}]},

            {value:1,actions:[{type:SET_PROPERTY,data:_StencilPassA=0}, {type:SET_PROPERTY,data:_StencilPassB=2}, {type:SET_PROPERTY,data:_StencilCompA=6}]},
            {value:1,actions:[{type:SET_PROPERTY,data:_StencilCompB=8}, {type:SET_PROPERTY,data:_StencilRef=16}, {type:SET_PROPERTY,data:render_queue=2000}, {type:SET_PROPERTY,data:render_type=Opaque}]},

            {value:2,actions:[{type:SET_PROPERTY,data:_StencilPassA=0}, {type:SET_PROPERTY,data:_StencilPassB=2}, {type:SET_PROPERTY,data:_StencilCompA=6}]},
            {value:2,actions:[{type:SET_PROPERTY,data:_StencilCompB=8}, {type:SET_PROPERTY,data:_StencilRef=16}, {type:SET_PROPERTY,data:render_queue=2002}, {type:SET_PROPERTY,data:render_type=Opaque}]},
            
            {value:3,actions:[{type:SET_PROPERTY,data:_StencilPassA=0}, {type:SET_PROPERTY,data:_StencilPassB=2}, {type:SET_PROPERTY,data:_StencilCompA=6}]},
            {value:3,actions:[{type:SET_PROPERTY,data:_StencilCompB=8}, {type:SET_PROPERTY,data:_StencilRef=16}, {type:SET_PROPERTY,data:render_queue=2001}, {type:SET_PROPERTY,data:render_type=Opaque}]}]}", Int) = 0
            //Material Type End
            // face and eyes should use Base Stencil, Hair includes the stencil by default

        [HideInInspector] m_start_main ("Main", Float) = 0
            _MainTex ("Diffuse Texture", 2D) = "white" {}
            _LightMapTex ("Light Map Tex", 2D) = "gray" { } // (R X-ray Mask, G Shadow Threshold, B Specular Shininess, A NoUsed)
            [Toggle] _UseVFaceSwitch2UV ("Back Face Uses UV2", Float) = 0
            _Color ("Front Face Color", Color) = (1,1,1,1) 
            _BackFaceColor ("Back Face Color", Color) = (1,1,1,1)
            [HideInInspector] m_start_alpha("Alpha", Float) = 0
                _Opaqueness ("Transparency", Range(0,1)) = 1
                _VertexAlphaFactor ("Alpha From Vertex Factor", Range(0,1)) = 0 // (0: off)
                _CutOff ("Alpha Test Factor", Range(0,1)) = 0.5
            [HideInInspector] m_end_alpha ("", Float) = 0
        [HideInInspector] m_end_main ("", Float) = 0
        
        [HideInInspector] m_start_bump("Normal Map", Float) = 0
            _BumpMap ("Normal Map", 2D) = "bump" { } // (RGB - Normal)
            _BumpScale ("Normal Scale", Range(0, 5)) = 1
        [HideInInspector] m_end_bump("Normal Map", Float) = 0

        [HideInInspector] m_start_faceshading("Face Shading--{condition_show:{type:PROPERTY_BOOL,data:variant_selector==1.0}}", Float) = 0.0
            [HideInInspector] m_start_faceshadow ("Face Shadow", Float) = 0
                _FaceMapTex ("Face Map Texture", 2D) = "gray" { } // (A)
            [HideInInspector] [Toggle]_EnableFaceMap ("Use Face Map", Float) = 0
            [HideInInspector] m_end_faceshadow("", Float) = 0
            [HideInInspector] m_start_faceexp("Face Expression", Float) = 0
                _FaceExpTex ("Face Expression Texture", 2D) = "white" { }
                [Toggle] _ExpOutlineToggle ("Expression Controls Outline Width", Float) = 0
                _ExpOutlineFix ("Expression Outline Fix", Range(0, 1)) = 0
                [HideInInspector] m_start_expcolor("Color", Float) = 0
                    _ExpBlushColorR ("Expression Blush Color(R)", Color) = (1,0,0,1)
                    _ExpShadowColorG ("Expression Shadow Color(G)", Color) = (0.5,0.5,0.5,1)
                    _ExpShadowColorB ("Expression Shadow Color(B)", Color) = (0.5,0.5,0.5,1)
                    _ExpShadowColorA ("Expression Shadow Color(A)", Color) = (0.5,0.5,0.5,1)
                [HideInInspector] m_end_expcolor("", Float) = 0
                [HideInInspector] m_start_expint("Intensity", Float) = 0
                    _ExpBlushIntensityR ("Expression Blush Intensity(R)", Range(0, 1)) = 0
                    _ExpShadowIntensityG ("Expression Shadow Intensity(G)", Range(0, 1)) = 0
                    _ExpShadowIntensityB ("Expression Shadow Intensity(B)", Range(0, 1)) = 0
                    _ExpShadowIntensityA ("Expression Shadow Intensity(A)", Range(0, 1)) = 0
                [HideInInspector] m_end_expint("", Float) = 0
            [HideInInspector] m_end_faceexp("", Float) = 0 
            [HideInInspector] m_start_directions("Facing Directions", Float) = 0
                _headForwardVector ("Forward Vector | XYZ", Vector) = (0, 0, 1, 0)
                _headRightVector ("Right Vector | XYZ", Vector) = (-1, 0, 0, 0)
                _headUpVector ("Up Vector || XYZ", Vector) = (0, 1, 0, 0)
            [HideInInspector] m_end_directions ("", Float) = 0
        [HideInInspector] m_end_faceshading(" ", Float) = 0

        [HideInInspector] m_start_lighting("Lighting Options", Float) = 0
            [Toggle] _FilterLight ("Limit Spot/Point Light Intensity", Float) = 1    
            [HideInInspector] m_start_shadow ("Shadow", Float) = 0.0   
                _RampTex ("Diffuse Ramp Texture", 2D) = "white" { }
                _RampTexV ("Diffuse Ramp Y Coordinate", Range(0, 1)) = 1
                _DiffuseOffset ("Shadow Offset", Range(-1, 1)) = 0
                _ToneSoft ("Tone Shading Soft", Range(0, 0.5)) = 0.1
                _SceneShadowSoft ("Scene Shadow Soft", Range(0, 0.5)) = 0.05
                _LightArea ("Light Area Threshold", Range(0, 1)) = 0.51
                // [HideInInspector] m_start_hair_shading("Hair Shading--{condition_show:{type:PROPERTY_BOOL,data:variant_selector==2.0}}", Float) = 0
                //     _HairShadowWidthX ("Hair Shadow Width :X", Float) = 0 // these are things used for a hair shadow texture thats created at runtime
                //     _HairShadowWidthY ("Hair Shadow Width :Y", Float) = 0
                // [HideInInspector] m_end_hair_shading("", Float) = 0
                [Toggle] _EnableBlack ("Enable Contrast Adjustment", Float) = 0
                _ShadowContrast ("Shadow Color Contrast", Float) = 1
                [HideInInspector] m_start_shadow_color("Shadow Colors--{condition_show:{type:PROPERTY_BOOL,data:variant_selector<2.0}}", Float) = 0
                    [Toggle]_ShadowRampTexUsed ("Use Shadow Colors 2 through 5", Float) = 0
                    _ShadowMultColor ("Shadow Colors", Color) = (0.9,0.7,0.75,1)
                    _ShadowMultColor2 ("Shadow Color 2--{condition_show:{type:PROPERTY_BOOL,data:_ShadowRampTexUsed==1.0}}", Color) = (0.9,0.7,0.75,1)
                    _ShadowMultColor3 ("Shadow Color 3--{condition_show:{type:PROPERTY_BOOL,data:_ShadowRampTexUsed==1.0}}", Color) = (0.9,0.7,0.75,1)
                    _ShadowMultColor4 ("Shadow Color 4--{condition_show:{type:PROPERTY_BOOL,data:_ShadowRampTexUsed==1.0}}", Color) = (0.9,0.7,0.75,1)
                    _ShadowMultColor5 ("Shadow Color 5--{condition_show:{type:PROPERTY_BOOL,data:_ShadowRampTexUsed==1.0}}", Color) = (0.9,0.7,0.75,1)
                [HideInInspector] m_end_shadow_color ("", Float) = 0
                [HideInInspector] m_start_hair_shadow("Shadow Colors--{condition_show:{type:PROPERTY_BOOL,data:variant_selector==2.0}}", Float) = 0
                    _FirstShadowMultColor ("First Shadow Multiply Color", Color) = (0.9,0.7,0.75,1)
                    _SecondShadowMultColor ("Second Shadow Multiply Color", Color) = (0.75,0.6,0.65,1)
                [HideInInspector] m_end_hair_shadow("", Float) = 0
                [HideInInspector] _SecondShadow ("Second Shadow Threshold", Range(0, 1)) = 0.51
            [HideInInspector] m_end_shadow ("Shadow", Float) = 0.0  
        [HideInInspector] m_end_lighting("", Float) = 0

        [HideInInspector] m_start_reflections("Reflections", Float) = 0
            [HideInInspector] m_start_metallics("Metallics", Int) = 0
                [Toggle]_MTMapRampTexUsed ("Enable", Float) = 0
                _MTMap ("Metal Map Texture--{condition_show:{type:PROPERTY_BOOL,data:_MTMapRampTexUsed==1.0}}", 2D) = "white" { }
                _MTMapTileScale ("Metal Map Tile Scale--{condition_show:{type:PROPERTY_BOOL,data:_MTMapRampTexUsed==1.0}}", Float) = 1
                _MTMapThreshold ("Metal Map Threshold--{condition_show:{type:PROPERTY_BOOL,data:_MTMapRampTexUsed==1.0}}", Range(0, 1)) = 0.5
                _MTMapBrightness ("Metal Map Brightness--{condition_show:{type:PROPERTY_BOOL,data:_MTMapRampTexUsed==1.0}}", Float) = 1
                _MTShininess ("Metal Shininess--{condition_show:{type:PROPERTY_BOOL,data:_MTMapRampTexUsed==1.0}}", Float) = 11
                _MTSpecularAttenInShadow ("Metal Specular Attenuation in Shadow--{condition_show:{type:PROPERTY_BOOL,data:_MTMapRampTexUsed==1.0}}", Range(0, 1)) = 0.2
                [HideInInspector] m_start_metallicscolor("Metallic Colors--{condition_show:{type:PROPERTY_BOOL,data:_MTMapRampTexUsed==1.0}}", Int) = 0
                    _MTMapLightColor ("Metal Map Light Color", Color) = (1,1,1,1)
                    _MTMapDarkColor ("Metal Map Dark Color", Color) = (0,0,0,0)
                    _MTShadowMultiColor ("Metal Shadow Multiply Color", Color) = (0.8,0.8,0.8,0.8)
                    _MTSpecularColor ("Metal Specular Color", Color) = (1,1,1,1)
                [HideInInspector] m_end_metallicscolor ("", Int) = 0
            [HideInInspector] m_end_metallics("", Int) = 0

            [HideInInspector] m_start_specular("Specular Reflections", Int) = 0
                [Toggle] _UseSoftSpecular ("Use Soft Specular--{condition_show:{type:PROPERTY_BOOL,data:variant_selector<2.0}}", Float) = 0
                _Shininess ("Specular Shininess--{condition_show:{type:PROPERTY_BOOL,data:variant_selector<2.0}}", Range(0.1, 100)) = 10
                _SpecSoftRange ("Specular Soft--{condition_show:{type:PROPERTY_BOOL,data:variant_selector<2.0}}", Range(0, 0.5)) = 0
                _SpecMulti ("Specular Multiply Factor--{condition_show:{type:PROPERTY_BOOL,data:variant_selector<2.0}}", Range(0, 10)) = 0.1
                [HideInInspector] m_start_specularcolor ("Specular Color--{condition_show:{type:PROPERTY_BOOL,data:variant_selector<2.0}}", Float) = 0
                    [Toggle] _SpecularRampTexUsed ("Use Specular Colors 2 through 5", Float) = 0
                    _LightSpecColor ("Light Specular Color 1", Color) = (1,1,1,1)
                    _LightSpecColor2 ("Light Specular Color 2--{condition_show:{type:PROPERTY_BOOL,data:_SpecularRampTexUsed==1.0}}", Color) = (1,1,1,1)
                    _LightSpecColor3 ("Light Specular Color 3--{condition_show:{type:PROPERTY_BOOL,data:_SpecularRampTexUsed==1.0}}", Color) = (1,1,1,1)
                    _LightSpecColor4 ("Light Specular Color 4--{condition_show:{type:PROPERTY_BOOL,data:_SpecularRampTexUsed==1.0}}", Color) = (1,1,1,1)
                    _LightSpecColor5 ("Light Specular Color 5--{condition_show:{type:PROPERTY_BOOL,data:_SpecularRampTexUsed==1.0}}", Color) = (1,1,1,1)
                [HideInInspector] m_end_specularcolor ("", Float) = 0         
                _SpecularOffset ("Specular Offset--{condition_show:{type:PROPERTY_BOOL,data:variant_selector==2.0}}", Vector) = (0,0,0,1)
                _SpecularShiftRange ("Specular Shift Range--{condition_show:{type:PROPERTY_BOOL,data:variant_selector==2.0}}", Range(-5, 5)) = 0.1
                _RampMap ("Hair Ramp Map Texture--{condition_show:{type:PROPERTY_BOOL,data:variant_selector==2.0}}", 2D) = "white" { } // |RG (2D diffuse ramp) BA (2D specular ramp)
                _JitterMap ("Hair Jitter Map Texture--{condition_show:{type:PROPERTY_BOOL,data:variant_selector==2.0}}", 2D) = "gray" { } // |A (jitter noise)
                [HideInInspector]_HairStripPatternsTex ("Hair Strip Pattern", 2D) = "white" {}
                [HideInInspector] m_start_masking("Mask--{condition_show:{type:PROPERTY_BOOL,data:variant_selector==2.0}}", Float) = 0
                    _SpecularMaskMap ("Specular Mask Map", 2D) = "White" { }
                    _SpecularMaskLerp ("Specular Mask Lerp", Range(0, 1)) = 1
                [HideInInspector] m_end_masking("", Float) = 0
                [HideInInspector] m_start_LowGrp ("Low--{condition_show:{type:PROPERTY_BOOL,data:variant_selector==2.0}}", Float) = 0
                    _SpecularLowColor ("Specular Low Color", Color) = (0.5,0.5,0.5,1)
                    _SpecularLowIntensity ("Specular Low Intensity", Range(0, 3)) = 0.5
                    _SpecularLowShift ("Specular Low Shift", Range(-5, 5)) = 0
                    _SpecularLowJitterRangeMin ("Specular Low Jitter Min", Range(0, 5)) = 0
                    _SpecularLowJitterRangeMax ("Specular Low Jitter Max", Range(0, 5)) = 1
                    _SpecularLowShininessRangeMin ("Specular Low Shininess Range Min", Range(0, 2500)) = 0.1
                    _SpecularLowShininessRangeMax ("Specular Low Shininess Range Max", Range(0, 2500)) = 0.1
                [HideInInspector] m_end_LowGrp ("Low", Float) = 0
                [HideInInspector] m_start_HighGrp ("High--{condition_show:{type:PROPERTY_BOOL,data:variant_selector==2.0}}", Float) = 0
                    _SpecularHighColor ("Specular High Color", Color) = (0.5,0.5,0.5,1)
                    _SpecularHighIntensity ("Specular High Intensity", Range(0, 3)) = 0.5
                    _SpecularHighShift ("Specular High Shift", Range(-5, 5)) = 0
                    _SpecularHighJitterRangeMin ("Specular High Jitter Min", Range(-5, 5)) = 0
                    _SpecularHighJitterRangeMax ("Specular High Jitter Max", Range(-5, 5)) = 1
                    _SpecularHighShininessRangeMin ("Specular High Shininess Range Min", Range(0, 2500)) = 0.1
                    _SpecularHighShininessRangeMax ("Specular High Shininess Range Max", Range(0, 2500)) = 0.1
                [HideInInspector] m_end_HighGrp ("High", Float) = 0
            [HideInInspector] m_end_specular("", Int) = 0

            [HideInInspector] m_start_rimglow("Rim Glow", Float) = 0
                [Toggle] _EnableRimGlow ("Enable Rim Glow", Float) = 0
                _RGPower ("Rim Glow Power--{condition_show:{type:PROPERTY_BOOL,data:_EnableRimGlow==1.0}}", Range(0.001, 100)) = 1
                _RGSoftRange ("Rim Glow Soft Range--{condition_show:{type:PROPERTY_BOOL,data:_EnableRimGlow==1.0}}", Range(0, 1)) = 0.1
                _RimGlowStrength ("Rim Glow Emission Strength--{condition_show:{type:PROPERTY_BOOL,data:_EnableRimGlow==1.0}}", Range(0, 100)) = 1
                    [HideInInspector] m_start_rimcolor("Rim Color", Float) = 0
                        [Toggle] _RGRampTexUsed ("Use Rim Colors 2 through 5", Float) = 0
                        _RGColor ("Rim Glow Color 1", Color) = (1,1,1,1)
                        _RGColor2 ("Rim Glow Color 2--{condition_show:{type:PROPERTY_BOOL,data:_RGRampTexUsed==1.0}}", Color) = (1,1,1,1)
                        _RGColor3 ("Rim Glow Color 3--{condition_show:{type:PROPERTY_BOOL,data:_RGRampTexUsed==1.0}}", Color) = (1,1,1,1)
                        _RGColor4 ("Rim Glow Color 4--{condition_show:{type:PROPERTY_BOOL,data:_RGRampTexUsed==1.0}}", Color) = (1,1,1,1)
                        _RGColor5 ("Rim Glow Color 5--{condition_show:{type:PROPERTY_BOOL,data:_EnableRimGlow==1.0}}", Color) = (1,1,1,1)
                    [HideInInspector] m_end_rimcolor("", Float) = 0
                [HideInInspector] m_end_rimglow("", Float) = 0

        [HideInInspector] m_end_reflections ("", Float) = 0

        [HideInInspector] m_start_outlines("Outlines", Float) = 0
            _OutlineWidth ("Outline Width", Range(0, 100)) = 0.04
            _Scale ("Outline Scale", Range(0, 100)) = 0.04
            _GlobalOutlineScale("Global Outline Scale", Vector) = (1,1,1,0)
            //_OutlineEmission ("Outline Emission", Range(0, 100)) = 1
            
            
            [HideInInspector] m_start_outline_color("Color", Float) = 0 
                [Toggle]_More_Outline_Color ("Use Outline Colors 2 through 5", Float) = 0
                _OutlineColor ("Outline Color 1", Color) = (0,0,0,1)
                _OutlineColor2 ("Outline Color 2--{condition_show:{type:PROPERTY_BOOL,data:_More_Outline_Color==1.0}}", Color) = (0,0,0,1)
                _OutlineColor3 ("Outline Color 3--{condition_show:{type:PROPERTY_BOOL,data:_More_Outline_Color==1.0}}", Color) = (0,0,0,1)
                _OutlineColor4 ("Outline Color 4--{condition_show:{type:PROPERTY_BOOL,data:_More_Outline_Color==1.0}}", Color) = (0,0,0,1)
                _OutlineColor5 ("Outline Color 5--{condition_show:{type:PROPERTY_BOOL,data:_More_Outline_Color==1.0}}", Color) = (0,0,0,1)
            [HideInInspector] m_end_outline_color("", Float) = 0 
        [HideInInspector] m_end_outlinescolor ("", Float) = 0

        [HideInInspector] m_start_specialeffects("Special Effects", Float) = 0

            [HideInInspector] m_start_xray("Stencil/X-Ray", Float) = 0
                _HairBlendSilhouette ("Hair Blend Silhouette", Range(0, 1)) = 0.5
                [IntRange] _StencilRef ("Stencil Reference Value", Range(0, 255)) = 0
                [Enum(UnityEngine.Rendering.StencilOp)] _StencilPassA ("Stencil Pass Op A", Float) = 0
                [Enum(UnityEngine.Rendering.StencilOp)] _StencilPassB ("Stencil Pass Op B", Float) = 0
                [Enum(UnityEngine.Rendering.CompareFunction)] _StencilCompA ("Stencil Compare Function A", Float) = 8
                [Enum(UnityEngine.Rendering.CompareFunction)] _StencilCompB ("Stencil Compare Function B", Float) = 8
            [HideInInspector] m_end_xray("", Float) = 0
            
            [HideInInspector] m_start_emissionglow("Emission", Float) = 0
                [Enum(Off, 0, On, 1)]_Emission_Type ("Emission", Float) = 0
                _EmissionStrength ("Emission Strength", Range(0, 100)) = 1
                [Toggle]_MulAlbedo ("Multiply Emission by Diffuse", Float) = 0
                [Toggle]_UseMainTexAsEmission ("Use Diffuse Alpha as Emission Mask", Float) = 0
                [HideInInspector] m_start_emission_color("Color", Float) = 0 
                    [Toggle]_EmissionRampTexUsed ("Use Emission Colors 2 through 5", Float) = 0
                    _EmissionColor ("Emission Color 1", Color) = (1,1,1,1)
                    _EmissionColor2 ("Emission Color 2--{condition_show:{type:PROPERTY_BOOL,data:_EmissionRampTexUsed==1.0}}", Color) = (0,0,0,1)
                    _EmissionColor3 ("Emission Color 3--{condition_show:{type:PROPERTY_BOOL,data:_EmissionRampTexUsed==1.0}}", Color) = (0,0,0,1)
                    _EmissionColor4 ("Emission Color 4--{condition_show:{type:PROPERTY_BOOL,data:_EmissionRampTexUsed==1.0}}", Color) = (0,0,0,1)
                    _EmissionColor5 ("Emission Color 5--{condition_show:{type:PROPERTY_BOOL,data:_EmissionRampTexUsed==1.0}}", Color) = (0,0,0,1)
                [HideInInspector] m_end_emission_color("", Float) = 0 
            [HideInInspector] m_end_emissionglow ("", Float) = 0

            // [HideInInspector] m_start_vfxgeneral("VFX General", Float) = 0
            //     [Toggle] _IsVFX ("Enable VFX Settings", Float) = 0
            //     _EmissionScaler ("Emission Scaler", Range(0, 50)) = 0
            //     [PowerSlider(3.0)] _Saturation ("Saturation", Range(0, 10)) = 1
            //     [PowerSlider(3.0)] _Contrast ("Contrast", Range(0, 10)) = 1
            //     [Toggle] _UseCustomData ("Use Custom Data", Float) = 1
            //     _DiffuseTex1 ("Diffuse Tex1", 2D) = "white" { }
            //     _DiffAngle1 ("Diffuse Angle", Range(0, 360)) = 0
            //     _DiffAngleSpeed1 ("Diffuse Angle Speed", Float) = 0
            //     _USpeed1 ("Diffuse Tex1 U Speed(Custom1.x)", Float) = 0
            //     _VSpeed1 ("Diffuse Tex1 V Speed(Custom1.y)", Float) = 0
            //     [Toggle] _UseScreenUV ("Use ScreenUV", Float) = 0
            //     [HideInInspector] m_start_parallaxgrp("Parallax", Float) = 0
            //         [Toggle]_Parallax_ON ("Parallax", Float) = 0
            //         _HeightFactor ("Height Factor", Float) = 0
            //     [HideInInspector] m_end_parallaxgrp("", Float) = 0
            //     [HideInInspector] m_start_diffusetwo("Secondary Diffuse", Float) = 0
            //         [Toggle]_DifTex2_ON ("Diffuse 2", Float) = 0
            //         _DiffuseTex2 ("Diffuse Tex2", 2D) = "white" { }
            //         _DiffAngle2 ("Diffuse2 Angle", Range(0, 360)) = 0
            //         _DiffAngleSpeed2 ("Diffuse2 Angle Speed", Float) = 0
            //         _USpeed2 ("Diffuse Tex2 U Speed", Float) = 0
            //         _VSpeed2 ("Diffuse Tex2 V Speed", Float) = 0
            //         [Toggle] _UseRGBTint ("Use RGB Tint", Float) = 0
            //         _Diffuse2TintColorR ("Diff2 TintColor R", Color) = (1,1,1,1)
            //         _Diffuse2TintColorG ("Diff2 TintColor G", Color) = (1,1,1,1)
            //         _Diffuse2TintColorB ("Diff2 TintColor B", Color) = (1,1,1,1)
            //     [HideInInspector] m_end_diffusetwo("", Float) = 0
            //     [HideInInspector] m_start_dissolve ("Dissolve", Float) = 0
            //         [Toggle]_Dissolve_ON ("Dissolve", Float) = 0
            //         _DissolveTex ("Dissolve Tex", 2D) = "white" { }
            //         _DissolveMask ("Dissolve Mask", 2D) = "white" { }
            //         _DissolveMaskAngle ("Dissolve Mask Angle", Range(0, 360)) = 0
            //         _DissolveMaskAngleSpeed ("Dissolve Mask Angle Speed", Float) = 0
            //         _DissMaskIntensity ("Dissolve Mask Intensity", Range(0, 1)) = 0
            //         [Toggle] _UseUV2 ("Use UV2", Float) = 0
            //         _DissAngle ("Dissolve Angle", Range(0, 360)) = 0
            //         _DissAngleSpeed ("Dissolve Angle Speed", Float) = 0
            //         _DissUSpeed ("_Diss U Speed", Float) = 0
            //         _DissVSpeed ("_Diss V Speed", Float) = 0
            //         _DissolveRange ("Dissolve Range(Custom2.x)", Float) = 0
            //         _Smooth ("Smooth Intensity(Custom2.y)", Range(0, 1)) = 0
            //         _DissEdge ("Dissolve Edge Range", Range(-1, 1)) = 0
            //         _DissEdgeIntensity ("Dissolve Edge Intensity", Float) = 3
            //         _DissEdgeColor ("Dissolve Edge Color", Color) = (1,1,1,1)
            //         [Enum(Add, 0, AlphaBlend, 1, Tint, 2)] _DissBlendType ("Dissolve Blend Type", Float) = 0
            //     [HideInInspector] m_end_dissolve ("", Float) = 0
            //     [HideInInspector] m_start_masking ("Masking", Float) = 0
            //         [Toggle]_MaskTex_ON ("Mask Texture", Float) = 0
            //         _MaskTex ("Mask Tex", 2D) = "black" { }
            //         _MaskAngle ("Mask Angle", Range(0, 360)) = 0
            //         _MaskAngleSpeed ("Mask Angle Speed", Float) = 0
            //         [Toggle] _UseAChannel ("Use A Channel", Float) = 0
            //         _MaskIntensity ("Mask Intensity", Range(0, 1)) = 0
            //         _MaskUSpeed ("Mask U Speed(Custom1.z)", Float) = 0
            //         _MaskVSpeed ("Mask V Speed(Custom1.w)", Float) = 0
            //     [HideInInspector] m_end_masking ("", Float) = 0
            //     [HideInInspector] m_start_noisegroup("Noise Group", Float) = 0
            //         [Toggle] _NoiseTex_ON ("Noise Texture", Float) = 0
            //         _NoiseEffectDiffuse1 ("Effect Diffuse1", Float) = 1
            //         _NoiseEffectDiffuse2 ("Effect Diffuse2", Float) = 1
            //         _NoiseEffectDissolve ("Effect Dissolve", Float) = 1
            //         _NoiseTex ("Noise Tex", 2D) = "white" { }
            //         _NoiseUSpeed ("Noise U Speed", Float) = 0
            //         _NoiseVSpeed ("Noise V Speed", Float) = 0
            //         _NoiseIntensity ("Noise Intensity(Custom2.z)", Float) = 0
            //         _NoiseAffectChannle ("Noise Affect Channle(XY)", Vector) = (1,1,0,0)
            //         [Toggle] _UseUVMask ("Use UV Mask", Float) = 0
            //         _MaskLevel ("Mask Level", Float) = 1
            //         _NoiseMaskRotation ("Noise Mask Rotation", Range(0, 360)) = 0
            //         _NoiseOffset ("Noise Offset", Float) = 0
            //     [HideInInspector] m_end_noisegroup("", Float) = 0
            //     [HideInInspector] m_start_vtxoffset("Vertex Offset", Float) = 0
            //         [Toggle]_VertexOffset_ON ("Vertex Offset", Float) = 0
            //         _VertexOffsetTex ("VertexOffset Tex", 2D) = "white" { }
            //         _OffsetUSpeed ("Offset U Speed", Float) = 0
            //         _OffsetVSpeed ("Offset V Speed", Float) = 0
            //         [Toggle] _UseOffsetMask ("Use OffsetMask", Float) = 0
            //         _OffsetMaskTex ("VertexOffset MaskTex", 2D) = "white" { }
            //         [Toggle] _UseMaxOffset ("Limit Max Offset", Float) = 0
            //         _OffsetDir ("Offset Direction(XYZ), Max Offset(W)", Vector) = (0,0,1,1)
            //         _OffsetIntensity ("VertexOffset Intensity(Custom2.w)", Float) = 0
            //     [HideInInspector] m_end_vtxoffset("", Float) = 0
            //     [HideInInspector] m_start_depthbias ("Depth Bias", Float) = 0
            //         [Toggle] _EnableDepthBias ("EnableDepthBias", Float) = 0
            //         _ZDepthBias ("ZDepthBias--{condition_show:{type:PROPERTY_BOOL,data:_EnableDepthBias==1.0}}", Float) = 0
            //     [HideInInspector] m_end_depthbias ("", Float) = 0
            //     [HideInInspector] m_start_clip("Clipping", Float) = 0
            //         [Toggle] _Clip ("Clip Alpha", Float) = 0
            //         _ClipA ("Clip--{condition_show:{type:PROPERTY_BOOL,data:_Clip==1.0}}", Range(0, 1)) = 0
            //     [HideInInspector] m_end_clip("", float) = 0
            //     [HideInInspector] m_start_screen_effect("Screen Effect", Float) = 0
            //         [Toggle] _UseScreenVertex ("Use Screen Vertex", Float) = 0
            //         _ScreenScale ("Screen Scale--{condition_show:{type:PROPERTY_BOOL,data:_UseScreenVertex==1.0}}", Vector) = (1,1,1,1)
            //     [HideInInspector] m_end_screen_effect("", float) = 0
            //     [HideInInspector] m_start_fresnel("Fresnel", Float) = 0
            //         [Toggle] _UseFresnel ("Fresnel On", Float) = 0
            //         _FresnelParams ("Fresnel Parameters--{condition_show:{type:PROPERTY_BOOL,data:_UseFresnel==1.0}}", Vector) = (1,1,0,1)
            //         _FresnelColor ("Fresnel Color--{condition_show:{type:PROPERTY_BOOL,data:_UseFresnel==1.0}}", Color) = (1,1,1,1)
            //         _Inverse ("Inverse--{condition_show:{type:PROPERTY_BOOL,data:_UseFresnel==1.0}}", Float) = 0
            //         _UseFresnelAbs ("Use Fresnel Abs--{condition_show:{type:PROPERTY_BOOL,data:_UseFresnel==1.0}}", Float) = 0
            //         [Enum(RGB, 0, A, 1)] _FresnelChannel ("Fresnel Channel--{condition_show:{type:PROPERTY_BOOL,data:_UseFresnel==1.0}}", Float) = 0
            //     [HideInInspector] m_end_fresnel("", float) = 0
            //     [HideInInspector] m_start_depth("Depth", Float) = 0
            //         [Toggle] _UseDepth ("Depth On", Float) = 0
            //         [Enum(Transparent, 0, AlphaBlend, 1)] _DepthBlendType ("Depth Blend Type--{condition_show:{type:PROPERTY_BOOL,data:_UseDepth==1.0}}", Float) = 0
            //         _DepthCt ("DepthCt--{condition_show:{type:PROPERTY_BOOL,data:_UseDepth==1.0}}", Range(0, 5)) = 0.5
            //         _EdgeLight ("EdgeLight Color--{condition_show:{type:PROPERTY_BOOL,data:_UseDepth==1.0}}", Color) = (1,1,1,1)
            //         _EdgeBrightness ("EdgeLight Brightness--{condition_show:{type:PROPERTY_BOOL,data:_UseDepth==1.0}}", Float) = 1
            //         _EdgeContrast ("EdgeLight Contrast--{condition_show:{type:PROPERTY_BOOL,data:_UseDepth==1.0}}", Float) = 1
            //         [Toggle] _EdgeEffectCol ("EdgeLight Effect Color--{condition_show:{type:PROPERTY_BOOL,data:_UseDepth==1.0}}", Float) = 0
            //     [HideInInspector] m_end_depth("", float) = 0
            //     [HideInInspector] m_start_vfxnormal("Normal Map", Float) = 0
            //         [Toggle] _EnableNormalTex ("Enable Normal Tex", Float) = 0
            //         _Normalmap ("Normal map--{condition_show:{type:PROPERTY_BOOL,data:_EnableNormalTex==1.0}}", 2D) = "bump" { }
            //         _NormalIntensity ("Normal Intensity--{condition_show:{type:PROPERTY_BOOL,data:_EnableNormalTex==1.0}}", Float) = 1
            //     [HideInInspector] m_end_vfxnormal("", float) = 0
            //     [HideInInspector] m_start_locallight ("LocalLight", Float) = 0
            //         _EnableLocalLight ("Enable LocalLight", Float) = 0
            //         _MainIntensity ("Main Intensity--{condition_show:{type:PROPERTY_BOOL,data:_EnableLocalLight==1.0}}", Float) = 1
            //         _MainSmoothness ("Main Smoothness--{condition_show:{type:PROPERTY_BOOL,data:_EnableLocalLight==1.0}}", Float) = 0.5
            //         [Toggle] _UseLocalLightTint ("Use Tint Color--{condition_show:{type:PROPERTY_BOOL,data:_EnableLocalLight==1.0}}", Float) = 0
            //         _LocalLightTint ("LocalLight TintColor--{condition_show:{type:PROPERTY_BOOL,data:_EnableLocalLight==1.0}}", Color) = (1,1,1,1)
            //         _RampIntensity ("Ramp Intensity--{condition_show:{type:PROPERTY_BOOL,data:_EnableLocalLight==1.0}}", Float) = 1
            //         _RampSmoothness ("Ramp Smoothness--{condition_show:{type:PROPERTY_BOOL,data:_EnableLocalLight==1.0}}", Float) = 1
            //     [HideInInspector] m_end_locallight ("", Float) = 0
            // [HideInInspector] m_end_vfxgeneral("", Float) = 0

        [HideInInspector] m_end_specialeffects ("", Float) = 0

        [HideInInspector] m_start_renderingOptions("Rendering Options", Float) = 0
            [Enum(UnityEngine.Rendering.CullMode)] _CullMode("Cull", Float) = 0
            [Enum(Off, 0, On, 1)] _ZWrite("ZWrite", Int) = 1
            [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest ("ZTest", Float) = 4
            [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Source Blend", Int) = 1
            [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Destination Blend", Int) = 0
            _OffsetRate ("Offset Rate", Range(-1,1)) = 0
            _OffsetUnits ("Offset Units", Range(-1,1)) = 0

            // Debug Options
            [HideInInspector] m_start_debugOptions("Debug", Float) = 0
                [Toggle] _DebugMode ("Enable Debug Mode", float) = 0
                [Enum(Off, 0, RGB, 1, A, 2)] _DebugDiffuse("Diffuse Debug Mode", Float) = 0
                [Enum(Off, 0, R, 1, G, 2, B, 3, A, 4)] _DebugLightMap ("Light Map Debug Mode", Float) = 0
                [Enum(Off, 0, R, 1, G, 2, B, 3, A, 4)] _DebugFaceMap ("Face Map Debug Mode", Float) = 0
                [Enum(Off, 0, R, 1, G, 2, B, 3, A, 4)] _DebugExpMap ("Face Expression Map Debug Mode", Float) = 0
                [Enum(Off, 0, Bump, 1)] _DebugNormalMap ("Normal Map Debug Mode", Float) = 0
                [HoyoToonWideEnum(Off, 0, R, 1, G, 2, B, 3, A, 4, RGB, 5)] _DebugVertexColor ("Vertex Color Debug Mode", Float) = 0
                [Enum(Off, 0, On, 1)] _DebugRimLight ("Rim Light Debug Mode", Float) = 0
                [Enum(Off, 0, Original (Encoded), 1, Original (Raw), 2, Bumped (Encoded), 3, Bumped (Raw), 4)] _DebugNormalVector ("Normals Debug Mode", Float) = 0 
                [Enum(Off, 0, On, 1)] _DebugTangent ("Tangents/Secondary Normal Debug Mode", Float) = 0
                [Enum(Off, 0, On, 1)] _DebugMetal ("Metal Debug Mode", Float) = 0
                [Enum(Off, 0, On, 1)] _DebugSpecular ("Specular Debug Mode", Float) = 0
                [Enum(Off, 0, Factor, 1, Color, 2, Both, 3)] _DebugEmission ("Emission Debug Mode", Float) = 0 
                [Enum(Off, 0, Forward, 1, Right, 2, Up, 3)] _DebugFaceVector ("Facing Vector Debug Mode", Float) = 0
                [Enum(Off, 0, On, 1)] _DebugLights ("Lights Debug Mode", Float) = 0
                [HoyoToonWideEnum(Off, 0, Materail ID 1, 1, Material ID 2, 2, Material ID 3, 3, Material ID 4, 4, Material ID 5, 5, All(Color Coded), 6)] _DebugMaterialIDs ("Material ID Debug Mode", Float) = 0
            [HideInInspector] m_end_debugOptions("Debug", Float) = 0
        
        [HideInInspector] m_end_renderingOptions("Rendering Options", Float) = 0
    }
    SubShader
    {
        Tags{ "RenderType"="Opaque" "Queue"="Geometry" }
        HLSLINCLUDE
        #include "UnityCG.cginc"
        #include "UnityPBSLighting.cginc"
        #include "UnityShaderVariables.cginc"
        #include "AutoLight.cginc"
        #include "UnityLightingCommon.cginc"
        #include "Lighting.cginc"
        // ==================================================== //
        float variant_selector;
        float _FilterLight;
        // === textures === //
        Texture2D _MainTex;
        SamplerState sampler_MainTex;
        float4 _MainTex_ST;
        Texture2D _BumpMap;
        Texture2D _NormalMap;
        SamplerState sampler_BumpMap;
        Texture2D _LightMapTex;
        SamplerState sampler_LightMapTex;
        Texture2D _FaceMapTex;
        SamplerState sampler_FaceMapTex;
        Texture2D _RampTex;
        SamplerState sampler_RampTex;
        Texture2D _MTMap;
        SamplerState sampler_MTMap;
        Texture2D _SpecularMaskMap;
        SamplerState sampler_SpecularMaskMap;
        Texture2D _RampMap;
        // SamplerState sampler_RampMap;
        Texture2D _JitterMap;
        float4 _JitterMap_ST;
        Texture2D _HairStripPatternsTex;
        float4 _HairStripPatternsTex_ST;
        SamplerState sampler_JitterMap;
        // Texture2D _DiffuseTex1;
        // SamplerState sampler_DiffuseTex1;
        // Texture2D _DiffuseTex2;
        // Texture2D _DissolveTex;
        // Texture2D _DissolveMask;
        // Texture2D _MaskTex;
        // Texture2D _NoiseTex;
        // Texture2D _VertexOffsetTex;
        Texture2D _FaceExpTex;
        SamplerState sampler_FaceExpTex;
        float4 _FaceExpTex_ST;
        
        // === diffuse === //
        float4 _Color;
        float4 _BackFaceColor;
        float _UseVFaceSwitch2UV;
        float _CutOff;
        float _Opaqueness;
        // === normal map === //
        float _BumpScale;
        // === shadow === //
        float _EnableFaceMap;
        float _HairShadowWidthX;
        float _HairShadowWidthY;
        float _ShadowRampTexUsed;
        float4 _ShadowMultColor;
        float4 _ShadowMultColor2;
        float4 _ShadowMultColor3;
        float4 _ShadowMultColor4;
        float4 _ShadowMultColor5;
        float4 _FirstShadowMultColor;
        float4 _SecondShadowMultColor;
        float _EnableBlack;
        float _ShadowContrast;
        float _SecondShadow;
        float _DiffuseOffset;
        float _ToneSoft;
        float _SceneShadowSoft;
        float _NormalBias;
        float _DepthBias;
        float _PowOfNormalBias;
        float _RampTexV;
        float _AmbientLerpValue;
        float _LightArea;
        float4 _headForwardVector;
        float4 _headRightVector;
        float4 _headUpVector;
        // === specular (non-hair) === //
        float _UseSoftSpecular;
        float _SpecularRampTexUsed;
        float4 _LightSpecColor;
        float4 _LightSpecColor2;
        float4 _LightSpecColor3;
        float4 _LightSpecColor4;
        float4 _LightSpecColor5;
        float _Shininess;
        float _SpecSoftRange;
        float _SpecMulti;
        // === specular (hair) === //
        float _SpecularMaskLerp;
        float4 _SpecularOffset;
        float _SpecularLowJitterRangeMin;
        float _SpecularLowJitterRangeMax;
        float _SpecularLowShininessRangeMin;
        float _SpecularLowShininessRangeMax;
        float _SpecularLowShift;
        float4 _SpecularLowColor;
        float _SpecularLowIntensity;
        float _SpecularHighJitterRangeMin;
        float _SpecularHighJitterRangeMax;
        float _SpecularHighShininessRangeMin;
        float _SpecularHighShininessRangeMax;
        float _SpecularHighShift;
        float4 _SpecularHighColor;
        float _SpecularHighIntensity;
        float _SpecularFresnelIntensity;
        float _SpecularShiftRange;
        // === metalic === //
        float _MTMapRampTexUsed;
        float _MTMapThreshold;
        float _MTMapBrightness;
        float _MTMapTileScale;
        float4 _MTMapLightColor;
        float4 _MTMapDarkColor;
        float4 _MTShadowMultiColor;
        float _MTShininess;
        float _MTSpecularAttenInShadow;
        float4 _MTSpecularColor;
        // === emission === //
        float _Emission_Type;
        float _EmissionRampTexUsed;
        float4 _EmissionColor;
        float4 _EmissionColor2;
        float4 _EmissionColor3;
        float4 _EmissionColor4;
        float4 _EmissionColor5;
        float _EmissionStrength;
        float _MulAlbedo;
        float _UseMainTexAsEmission;
        // === rim glow === //
        float _EnableRimGlow;
        float4 _RGColor;
        float _RGRampTexUsed;
        float4 _RGColor2;
        float4 _RGColor3;
        float4 _RGColor4;
        float4 _RGColor5;
        float _RGPower;
        float _RGSoftRange;
        float _RimGlowStrength;
        // === outline === //
        float _OutlinebyTangent; 
        float _OutlineWidth;
        float _Scale;
        float4 _GlobalOutlineScale;
        float _More_Outline_Color;
        float4 _OutlineColor;
        float4 _OutlineColor2;
        float4 _OutlineColor3;
        float4 _OutlineColor4;
        float4 _OutlineColor5;
        // === stencil === //
        float _HairBlendSilhouette;
        // ===  face expression === //
        float4 _ExpBlushColorR;
        float4 _ExpShadowColorG;
        float4 _ExpShadowColorB;
        float4 _ExpShadowColorA;
        float _ExpBlushIntensityR;
        float _ExpShadowIntensityG;
        float _ExpShadowIntensityB;
        float _ExpShadowIntensityA;
        float _ExpOutlineToggle;
        float _ExpOutlineFix;
        // === vfx shit === //
        float _IsVFX;
        // float _EmissionScaler;
        // float _Saturation;
        // float _Contrast;
        // float _UseCustomData;
        // float _DiffAngle1;
        // float _DiffAngleSpeed1;
        // float _USpeed1;
        // float _VSpeed1;
        // float _UseScreenUV;
        // float _Parallax_ON;
        // float _HeightFactor;
        // float _DifTex2_ON;
        // float _DiffAngle2;
        // float _DiffAngleSpeed2;
        // float _USpeed2;
        // float _VSpeed2;
        // float _UseRGBTint;
        // float4 _Diffuse2TintColorR;
        // float4 _Diffuse2TintColorG;
        // float4 _Diffuse2TintColorB;
        // float _Dissolve_ON;
        // float _DissolveMaskAngle;
        // float _DissolveMaskAngleSpeed;
        // float _DissMaskIntensity;
        // float _UseUV2;
        // float _DissAngle;
        // float _DissAngleSpeed;
        // float _DissUSpeed;
        // float _DissVSpeed;
        // float _DissolveRange;
        // float _Smooth;
        // float _DissEdge;
        // float _DissEdgeIntensity;
        // float4 _DissEdgeColor;
        // float _DissBlendType;
        // float _MaskTex_ON;
        // float _MaskAngle;
        // float _MaskAngleSpeed;
        // float _UseAChannel;
        // float _MaskIntensity;
        // float _MaskUSpeed;
        // float _MaskVSpeed;
        // float _NoiseTex_ON;
        // float _NoiseEffectDiffuse1;
        // float _NoiseEffectDiffuse2;
        // float _NoiseEffectDissolve;
        // float _NoiseUSpeed;
        // float _NoiseVSpeed;
        // float _NoiseIntensity;
        // float4 _NoiseAffectChannle;
        // float _UseUVMask;
        // float _MaskLevel;
        // float _NoiseMaskRotation;
        // float _NoiseOffset;
        // float _VertexOffset_ON;
        // float _OffsetUSpeed;
        // float _OffsetVSpeed;
        // float _UseOffsetMask;
        // float _OffsetMaskTex;
        // float _UseMaxOffset;
        // float4 _OffsetDir;
        // float _OffsetIntensity;
        // float _EnableDepthBias;
        // float _ZDepthBias;
        // float _Clip;
        // float _ClipA;
        // float _UseScreenVertex;
        // float _ScreenScale;
        // float _UseFresnel;
        // float4 _FresnelParams;
        // float4 _FresnelColor;
        // float _Inverse;
        // float _UseFresnelAbs;
        // float _FresnelChannel;
        // float _UseDepth;
        // float _DepthBlendType;
        // float _DepthCt;
        // float4 _EdgeLight;
        // float _EdgeBrightness;
        // float _EdgeContrast;
        // float _EdgeEffectCol;
        // === debug === //
        float _DebugMode;
        float _DebugDiffuse;
        float _DebugLightMap;
        float _DebugFaceMap;
        float _DebugExpMap;
        float _DebugNormalMap;
        float _DebugVertexColor;
        float _DebugRimLight;
        float _DebugNormalVector;
        float _DebugTangent;
        float _DebugMetal;
        float _DebugSpecular;
        float _DebugEmission;
        float _DebugFaceVector;
        float _DebugLights;
        float _DebugMaterialIDs;
        // ===  unity globals === //
        uniform float _GI_Intensity;
        uniform float4x4 _LightMatrix0;
        // ==================================================== //
        #include "Includes/Part2-inputs.hlsl"
        #include "Includes/Part2-common.hlsl"
        ENDHLSL

        Pass // main pass
        {
            Name "Character Pass"
            Tags{ "LightMode" = "ForwardBase" }
            Cull [_CullMode]
            Blend [_SrcBlend] [_DstBlend]
            Offset [_OffsetRate], [_OffsetUnits]
            Stencil
            {
                ref [_StencilRef]  
                Comp [_StencilCompA]
                Pass [_StencilPassA] // this doesn't even fucking matter like what?
                Fail Keep
                ZFail Keep
            }

            HLSLPROGRAM
            #pragma multi_compile_fwdbase
            #pragma multi_compile _IS_PASS_BASE
            #pragma vertex vs_model
            #pragma fragment ps_model

            #include "Includes/Part2-program.hlsl"
            ENDHLSL
        }

        Pass // main pass
        {
            Name "Character Pass"
            Tags{ "LightMode" = "ForwardAdd" }
            Cull [_CullMode]
            Blend One One
            Offset [_OffsetRate], [_OffsetUnits]
            Stencil
            {
                ref [_StencilRef]  
                Comp [_StencilCompA]
                Pass [_StencilPassA] // this doesn't even fucking matter like what?
                Fail Keep
                ZFail Keep
            }

            HLSLPROGRAM
            #pragma multi_compile_fwdadd
            #pragma multi_compile _IS_PASS_LIGHT
            #pragma vertex vs_model
            #pragma fragment ps_model

            #include "Includes/Part2-program.hlsl"
            ENDHLSL
        }

        Pass // stencil xray
        {
            Name "Character Pass X-RAY"
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
            
            HLSLPROGRAM
            
            #pragma multi_compile_fwdbase

            #define is_xray
            #pragma multi_compile _IS_PASS_BASE
            #pragma vertex vs_model
            #pragma fragment ps_model


            #include "Includes/Part2-program.hlsl"
            ENDHLSL
        }

        

        Pass // stencil xray
        {
            Name "Character Pass Light"
            Tags{ "LightMode" = "ForwardAdd" }
            Cull [_CullMode]
            Blend One One

            Stencil
            {
                ref [_StencilRef]              
                Comp [_StencilCompB]
                Pass [_StencilPassB]  
                Fail Keep
                ZFail Keep
            }
            
            HLSLPROGRAM
            
            #pragma multi_compile_fwdadd
            #pragma multi_compile _IS_PASS_LIGHT

            #define is_xray
            #pragma vertex vs_model
            #pragma fragment ps_model


            #include "Includes/Part2-program.hlsl"
            ENDHLSL
        }
        

        Pass // edge pass
        {
            Name "Edge Pass"
            Tags{ "LightMode" = "ForwardBase" }
            Cull Front
            Stencil
            {
				Comp Always
				Pass Replace
				Fail Keep
				ZFail Keep
				CompFront Always
				PassFront Replace
				FailFront Keep
				ZFailFront Keep
				CompBack Always
				PassBack Replace
				FailBack Keep
				ZFailBack Keep
			}
            Blend SrcAlpha OneMinusSrcAlpha
            HLSLPROGRAM
            
            #pragma multi_compile_fwdbase
            
            #pragma vertex vs_edge
            #pragma fragment ps_edge

            #include "Includes/Part2-program.hlsl"
            ENDHLSL
        }

        Pass // depth shadow pass
        {
            Name "Shadow Pass"
            Tags{ "LightMode" = "ShadowCaster" }
            Cull [_Cull]
            Blend [_SrcBlend] [_DstBlend]
            HLSLPROGRAM
            
            #pragma multi_compile_fwdbase
            
            #pragma vertex vs_shadow
            #pragma fragment ps_shadow

            #include "Includes/Part2-program.hlsl"
            ENDHLSL
        } 
    }
    CustomEditor "HoyoToon.ShaderEditor"
}
