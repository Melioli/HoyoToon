﻿/// Material/Shader Inspector for Unity 2022
// Copyright (C) 2024 Thryrallo + Meliodas

using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;
using System;
using System.Linq;
using HoyoToon.HoyoToonEditor;

namespace HoyoToon
{
    public class ShaderEditor : ShaderGUI
    {
        public const string EXTRA_OPTIONS_PREFIX = "--";
        public const float MATERIAL_NOT_RESET = 69.12f;

        public const string PROPERTY_NAME_MASTER_LABEL = "shader_master_label";
        public const string PROPERTY_NAME_MASTER_BG = "shader_master_bg";
        public const string PROPERTY_NAME_MASTER_LOGO = "shader_master_Logo";
        public const string PROPERTY_NAME_LABEL_FILE = "shader_properties_label_file";
        public const string PROPERTY_NAME_LOCALE = "shader_locale";
        public const string PROPERTY_NAME_ON_SWAP_TO_ACTIONS = "shader_on_swap_to";
        public const string PROPERTY_NAME_SHADER_VERSION = "shader_version";

        //Static
        private static string s_edtiorDirectoryPath;

        public static InputEvent Input = new InputEvent();
        public static ShaderEditor Active;

        // Stores the different shader properties
        public ShaderGroup MainGroup;
        private RenderQueueProperty _renderQueueProperty;
        private VRCFallbackProperty _vRCFallbackProperty;

        // UI Instance Variables

        public bool DoShowSearchBar;
        private string _enteredSearchTerm = "";
        private string _appliedSearchTerm = "";

        // shader specified values
        private ShaderHeaderProperty _shaderHeader = null;
        private List<FooterButton> _footers;

        // sates
        private bool _isFirstOnGUICall = true;
        private bool _doReloadNextDraw = false;
        private bool _didSwapToShader = false;

        //EditorData
        public MaterialEditor Editor;
        public MaterialProperty[] Properties;
        public Material[] Materials;
        public Shader Shader;
        public ShaderPart CurrentProperty;
        public Dictionary<string, ShaderProperty> PropertyDictionary;
        public List<ShaderPart> ShaderParts;
        public List<ShaderProperty> TextureArrayProperties;
        public bool IsFirstCall;
        public bool DoUseShaderOptimizer;
        public bool IsLockedMaterial;
        public bool IsInAnimationMode;
        public Renderer ActiveRenderer;
        public string RenamedPropertySuffix;
        public bool HasCustomRenameSuffix;
        public Localization Locale;
        public ShaderTranslator SuggestedTranslationDefinition;
        private string _duplicatePropertyNamesString = null;

        //Shader Versioning
        private Version _shaderVersionLocal;
        private Version _shaderVersionRemote;
        private bool _hasShaderUpdateUrl = false;
        private bool _isShaderUpToDate = true;
        private string _shaderUpdateUrl = null;

        //other
        ShaderProperty ShaderOptimizerProperty { get; set; }

        private DefineableAction[] _onSwapToActions = null;

        public bool IsDrawing { get; private set; } = false;

        public bool HasMixedCustomPropertySuffix
        {
            get
            {
                if (Materials.Length == 1) return false;
                string suffix = ShaderOptimizer.GetRenamedPropertySuffix(Materials[0]);
                for (int i = 1; i < Materials.Length; i++)
                {
                    if (suffix != ShaderOptimizer.GetRenamedPropertySuffix(Materials[i])) return true;
                }
                return false;
            }
        }

        public bool DidSwapToNewShader
        {
            get
            {
                return _didSwapToShader;
            }
        }

        //-------------Init functions--------------------

        private Dictionary<string, string> LoadDisplayNamesFromFile()
        {
            //load display names from file if it exists
            MaterialProperty label_file_property = GetMaterialProperty(PROPERTY_NAME_LABEL_FILE);
            Dictionary<string, string> labels = new Dictionary<string, string>();
            if (label_file_property != null)
            {
                string[] guids = AssetDatabase.FindAssets(label_file_property.displayName);
                if (guids.Length == 0)
                {
                    Debug.LogWarning("Label File could not be found");
                    return labels;
                }
                string path = AssetDatabase.GUIDToAssetPath(guids[0]);
                string[] data = Regex.Split(HoyoToon.FileHelper.ReadFileIntoString(path), @"\r?\n");
                foreach (string d in data)
                {
                    string[] set = Regex.Split(d, ":=");
                    if (set.Length > 1) labels[set[0]] = set[1];
                }
            }
            return labels;
        }

        public static string SplitOptionsFromDisplayName(ref string displayName)
        {
            if (displayName.Contains(EXTRA_OPTIONS_PREFIX))
            {
                string[] parts = displayName.Split(new string[] { EXTRA_OPTIONS_PREFIX }, 2, System.StringSplitOptions.None);
                displayName = parts[0];
                return parts[1];
            }
            return null;
        }

        private enum HoyoToonPropertyType
        {
            none, property, master_label, footer, header, header_end, header_start, group_start, group_end, section_start, section_end, instancing, dsgi, lightmap_flags, locale, on_swap_to, space, shader_version
        }

        private HoyoToonPropertyType GetPropertyType(MaterialProperty p)
        {
            string name = p.name;
            MaterialProperty.PropFlags flags = p.flags;

            if (flags == MaterialProperty.PropFlags.HideInInspector)
            {
                if (name == PROPERTY_NAME_MASTER_LABEL)
                    return HoyoToonPropertyType.master_label;
                if (name == PROPERTY_NAME_ON_SWAP_TO_ACTIONS)
                    return HoyoToonPropertyType.on_swap_to;
                if (name == PROPERTY_NAME_SHADER_VERSION)
                    return HoyoToonPropertyType.shader_version;

                if (name.StartsWith("m_start", StringComparison.Ordinal))
                    return HoyoToonPropertyType.header_start;
                if (name.StartsWith("m_end", StringComparison.Ordinal))
                    return HoyoToonPropertyType.header_end;
                if (name.StartsWith("m_", StringComparison.Ordinal))
                    return HoyoToonPropertyType.header;
                if (name.StartsWith("g_start", StringComparison.Ordinal))
                    return HoyoToonPropertyType.group_start;
                if (name.StartsWith("g_end", StringComparison.Ordinal))
                    return HoyoToonPropertyType.group_end;
                if (name.StartsWith("s_start", StringComparison.Ordinal))
                    return HoyoToonPropertyType.section_start;
                if (name.StartsWith("s_end", StringComparison.Ordinal))
                    return HoyoToonPropertyType.section_end;
                if (name.StartsWith("footer_", StringComparison.Ordinal))
                    return HoyoToonPropertyType.footer;
                if (name == "Instancing")
                    return HoyoToonPropertyType.instancing;
                if (name == "DSGI")
                    return HoyoToonPropertyType.dsgi;
                if (name == "LightmapFlags")
                    return HoyoToonPropertyType.lightmap_flags;
                if (name == PROPERTY_NAME_LOCALE)
                    return HoyoToonPropertyType.locale;
                if (name.StartsWith("space"))
                    return HoyoToonPropertyType.space;
            }
            else if (flags.HasFlag(MaterialProperty.PropFlags.HideInInspector) == false)
            {
                return HoyoToonPropertyType.property;
            }
            return HoyoToonPropertyType.none;
        }

        private void LoadLocales()
        {
            MaterialProperty locales_property = GetMaterialProperty(PROPERTY_NAME_LOCALE);
            Locale = null;
            if (locales_property != null)
            {
                string guid = locales_property.displayName;
                Locale = Localization.Load(guid);
            }
            else
            {
                Locale = Localization.Create();
            }
        }

        public void FakePartialInitilizationForLocaleGathering(Shader s)
        {
            Material material = new Material(s);
            Materials = new Material[] { material };
            Editor = MaterialEditor.CreateEditor(new UnityEngine.Object[] { material }) as MaterialEditor;
            Properties = MaterialEditor.GetMaterialProperties(Materials);
            RenamedPropertySuffix = ShaderOptimizer.GetRenamedPropertySuffix(Materials[0]);
            HasCustomRenameSuffix = ShaderOptimizer.HasCustomRenameSuffix(Materials[0]);
            ShaderEditor.Active = this;
            CollectAllProperties();
            UnityEngine.Object.DestroyImmediate(Editor);
            UnityEngine.Object.DestroyImmediate(material);
        }

        //finds all properties and headers and stores them in correct order
        private void CollectAllProperties()
        {
            //load display names from file if it exists
            MaterialProperty[] props = Properties;
            Dictionary<string, string> labels = LoadDisplayNamesFromFile();
            LoadLocales();

            PropertyDictionary = new Dictionary<string, ShaderProperty>();
            ShaderParts = new List<ShaderPart>();
            MainGroup = new ShaderGroup(this); //init top object that all Shader Objects are childs of
            Stack<ShaderGroup> groupStack = new Stack<ShaderGroup>(); //header stack. used to keep track if editorData header to parent new objects to
            groupStack.Push(MainGroup); //add top object as top object to stack
            groupStack.Push(MainGroup); //add top object a second time, because it get's popped with first actual header item
            _footers = new List<FooterButton>(); //init footer list
            int offsetDepthCount = 0;
            DrawingData.IsCollectingProperties = true;

            HashSet<string> duplicatePropertiesSearch = new HashSet<string>(); // for debugging
            List<string> duplicateProperties = new List<string>(); // for debugging

            for (int i = 0; i < props.Length; i++)
            {
                string displayName = props[i].displayName;

                //Load from label file
                if (labels.ContainsKey(props[i].name)) displayName = labels[props[i].name];

                //extract json data from display name
                string optionsRaw = SplitOptionsFromDisplayName(ref displayName);

                displayName = Locale.Get(props[i], displayName);

                int offset = offsetDepthCount;

                // Duplicate property name check
                if (duplicatePropertiesSearch.Contains(props[i].name))
                    duplicateProperties.Add(props[i].name);
                else
                    duplicatePropertiesSearch.Add(props[i].name);

                DrawingData.ResetLastDrawerData();

                HoyoToonPropertyType type = GetPropertyType(props[i]);
                ShaderProperty NewProperty = null;
                ShaderPart newPart = null;
                // -- Group logic --
                // Change offset if needed
                if (type == HoyoToonPropertyType.header_start)
                    offset = ++offsetDepthCount;
                if (type == HoyoToonPropertyType.header_end)
                    offsetDepthCount--;
                // Create new group if needed
                switch (type)
                {
                    case HoyoToonPropertyType.group_start:
                        newPart = new ShaderGroup(this, props[i], Editor, displayName, offset, optionsRaw, i);
                        break;
                    case HoyoToonPropertyType.section_start:
                        newPart = new ShaderSection(this, props[i], Editor, displayName, offset, optionsRaw, i);
                        break;
                    case HoyoToonPropertyType.header:
                    case HoyoToonPropertyType.header_start:
                        newPart = new ShaderHeader(this, props[i], Editor, displayName, offset, optionsRaw, i);
                        break;
                }
                // pop if needed
                if (type == HoyoToonPropertyType.header || type == HoyoToonPropertyType.header_end || type == HoyoToonPropertyType.group_end || type == HoyoToonPropertyType.section_end)
                {
                    groupStack.Pop();
                }
                // push if needed
                if (newPart != null)
                {
                    groupStack.Peek().addPart(newPart);
                    groupStack.Push(newPart as ShaderGroup);
                }

                switch (type)
                {
                    case HoyoToonPropertyType.on_swap_to:
                        _onSwapToActions = PropertyOptions.Deserialize(optionsRaw).actions;
                        break;
                    case HoyoToonPropertyType.master_label:
                        _shaderHeader = new ShaderHeaderProperty(this, props[i], displayName, 0, optionsRaw, false, i);
                        break;
                    case HoyoToonPropertyType.footer:
                        _footers.Add(new FooterButton(Parser.Deserialize<ButtonData>(displayName)));
                        break;
                    case HoyoToonPropertyType.none:
                    case HoyoToonPropertyType.property:
                        if (props[i].type == MaterialProperty.PropType.Texture)
                            NewProperty = new TextureProperty(this, props[i], displayName, offset, optionsRaw, props[i].flags.HasFlag(MaterialProperty.PropFlags.NoScaleOffset) == false, false, i);
                        else
                            NewProperty = new ShaderProperty(this, props[i], displayName, offset, optionsRaw, false, i);
                        break;
                    case HoyoToonPropertyType.lightmap_flags:
                        NewProperty = new GIProperty(this, props[i], displayName, offset, optionsRaw, false, i);
                        break;
                    case HoyoToonPropertyType.dsgi:
                        NewProperty = new DSGIProperty(this, props[i], displayName, offset, optionsRaw, false, i);
                        break;
                    case HoyoToonPropertyType.instancing:
                        NewProperty = new InstancingProperty(this, props[i], displayName, offset, optionsRaw, false, i);
                        break;
                    case HoyoToonPropertyType.locale:
                        NewProperty = new LocaleProperty(this, props[i], displayName, offset, optionsRaw, false, i);
                        break;
                    case HoyoToonPropertyType.shader_version:
                        PropertyOptions options = PropertyOptions.Deserialize(optionsRaw);
                        _shaderVersionRemote = new Version(WebHelper.GetCachedString(options.remote_version_url));
                        _shaderVersionLocal = new Version(displayName);
                        _isShaderUpToDate = _shaderVersionLocal >= _shaderVersionRemote;
                        _shaderUpdateUrl = options.generic_string;
                        _hasShaderUpdateUrl = _shaderUpdateUrl != null;
                        break;
                }
                if (NewProperty != null)
                {
                    newPart = NewProperty;
                    if (type != HoyoToonPropertyType.none)
                        groupStack.Peek().addPart(NewProperty);
                }
                if (newPart != null)
                {
                    if (!PropertyDictionary.ContainsKey(props[i].name))
                        PropertyDictionary.Add(props[i].name, NewProperty);
                    ShaderParts.Add(newPart);
                }
            }

            if (duplicateProperties.Count > 0 && Config.Singleton.enableDeveloperMode)
                _duplicatePropertyNamesString = string.Join("\n ", duplicateProperties.ToArray());

            DrawingData.IsCollectingProperties = false;
        }

        //-------------Draw Functions----------------

        public void InitlizeHoyoToonUI()
        {
            Config config = Config.Singleton;
            Active = this;

            //get material targets
            Materials = Editor.targets.Select(o => o as Material).ToArray();

            Shader = Materials[0].shader;

            RenamedPropertySuffix = ShaderOptimizer.GetRenamedPropertySuffix(Materials[0]);
            HasCustomRenameSuffix = ShaderOptimizer.HasCustomRenameSuffix(Materials[0]);

            //collect shader properties
            CollectAllProperties();

            if (ShaderOptimizer.IsShaderUsingHoyoToonOptimizer(Shader))
            {
                ShaderOptimizerProperty = PropertyDictionary[ShaderOptimizer.GetOptimizerPropertyName(Shader)];
                if (ShaderOptimizerProperty != null) ShaderOptimizerProperty.ExemptFromLockedDisabling = true;
            }

            _renderQueueProperty = new RenderQueueProperty(this);
            _vRCFallbackProperty = new VRCFallbackProperty(this);
            ShaderParts.Add(_renderQueueProperty);
            ShaderParts.Add(_vRCFallbackProperty);

            if (Config.Singleton.forceAsyncCompilationPreview)
            {
                ShaderUtil.allowAsyncCompilation = true;
            }

            _isFirstOnGUICall = false;
        }

        private Dictionary<string, MaterialProperty> materialPropertyDictionary;
        public MaterialProperty GetMaterialProperty(string name)
        {
            if (materialPropertyDictionary == null)
            {
                materialPropertyDictionary = new Dictionary<string, MaterialProperty>();
                foreach (MaterialProperty p in Properties)
                    if (materialPropertyDictionary.ContainsKey(p.name) == false) materialPropertyDictionary.Add(p.name, p);
            }
            if (materialPropertyDictionary.ContainsKey(name))
                return materialPropertyDictionary[name];
            return null;
        }

        public override void OnClosed(Material material)
        {
            base.OnClosed(material);
            _isFirstOnGUICall = true;
        }

        public override void AssignNewShaderToMaterial(Material material, Shader oldShader, Shader newShader)
        {
            //Unity sets the render queue to the shader defult when changing shader
            //This seems to be some deeper process that cant be disabled so i just set it again after the swap
            //Even material.shader = newShader resets the queue. (this is actually the only thing the base function does)
            int previousQueue = material.renderQueue;
            base.AssignNewShaderToMaterial(material, oldShader, newShader);
            material.renderQueue = previousQueue;
            SuggestedTranslationDefinition = ShaderTranslator.CheckForExistingTranslationFile(oldShader, newShader);
            FixKeywords(new Material[] { material });
            _doReloadNextDraw = true;
            _didSwapToShader = true;
        }

        void InitEditorData(MaterialEditor materialEditor)
        {
            Editor = materialEditor;
            TextureArrayProperties = new List<ShaderProperty>();
            IsFirstCall = true;
        }

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
        {
            IsDrawing = true;
            //Init
            bool reloadUI = _isFirstOnGUICall || (_doReloadNextDraw && Event.current.type == EventType.Layout) || (materialEditor.target as Material).shader != Shader;
            if (reloadUI)
            {
                InitEditorData(materialEditor);
                Properties = props;
                InitlizeHoyoToonUI();
            }

            //Update Data
            Properties = props;
            Shader = Materials[0].shader;
            Input.Update(IsLockedMaterial);
            ActiveRenderer = Selection.activeTransform?.GetComponent<Renderer>();
            IsInAnimationMode = AnimationMode.InAnimationMode();

            Active = this;

            DoVariantWarning();
            GUIManualReloadButton();
            GUIDevloperMode();
            GUIShaderVersioning();

            // Get the logo path from the shader property
            MaterialProperty logoPathProperty = GetMaterialProperty("shader_master_logo");
            MaterialProperty bgPathProperty = GetMaterialProperty("shader_master_bg");

            Rect bgRect = GUILayoutUtility.GetRect(GUIContent.none, GUIStyle.none, GUILayout.ExpandWidth(true), GUILayout.Height(145.0f));
            bgRect.x = 0;
            bgRect.width = EditorGUIUtility.currentViewWidth;
            Rect logoRect = new Rect(bgRect.width / 2 - 375f, bgRect.height / 2 - 65f, 750f, 130f);

            if (bgPathProperty != null && !string.IsNullOrEmpty(bgPathProperty.displayName))
            {
                // Load the background from the path
                Texture2D bg = Resources.Load<Texture2D>(bgPathProperty.displayName);

                if (bg != null)
                {
                    GUI.DrawTexture(bgRect, bg, ScaleMode.ScaleAndCrop);
                }
            }

            if (logoPathProperty != null && !string.IsNullOrEmpty(logoPathProperty.displayName))
            {
                // Load the logo from the path
                Texture2D logo = Resources.Load<Texture2D>(logoPathProperty.displayName);

                if (logo != null)
                {
                    GUI.DrawTexture(logoRect, logo, ScaleMode.ScaleToFit);
                }
            }

            GUITopBar();
            GUISearchBar();
            ShaderTranslator.SuggestedTranslationButtonGUI(this);

            //PROPERTIES
            foreach (ShaderPart part in MainGroup.parts)
            {
                part.Draw();
            }

            //Render Queue selection
            if (VRCInterface.IsVRCSDKInstalled()) _vRCFallbackProperty.Draw();
            if (Config.Singleton.showRenderQueue) _renderQueueProperty.Draw();

            BetterTooltips.DrawActive();

            GUIFooters();

            HandleEvents();

            IsDrawing = false;
            _didSwapToShader = false;
        }

        private void GUIManualReloadButton()
        {
            if (Config.Singleton.showManualReloadButton)
            {
                if (GUILayout.Button("Manual Reload"))
                {
                    this.Reload();
                }
            }
        }

        private void GUIDevloperMode()
        {
            if (Config.Singleton.enableDeveloperMode)
            {
                // Show duplicate property names
                if (_duplicatePropertyNamesString != null)
                {
                    EditorGUILayout.HelpBox("Duplicate Property Names:\n" + _duplicatePropertyNamesString, MessageType.Warning);
                }
            }
        }

        private void GUIShaderVersioning()
        {
            if (!_isShaderUpToDate)
            {
                Rect r = EditorGUILayout.GetControlRect(false, _hasShaderUpdateUrl ? 30 : 15);
                EditorGUI.LabelField(r, $"[New Shader Version available] {_shaderVersionLocal} -> {_shaderVersionRemote}" + (_hasShaderUpdateUrl ? "\n    Click here to download." : ""), Styles.redStyle);
                if (Input.HadMouseDownRepaint && _hasShaderUpdateUrl && GUILayoutUtility.GetLastRect().Contains(Input.mouse_position)) Application.OpenURL(_shaderUpdateUrl);
            }
        }

        private void GUITopBar()
        {
            //if header is texture, draw it first so other ui elements can be positions below
            if (_shaderHeader != null && _shaderHeader.Options.texture != null) _shaderHeader.Draw();

            bool drawAboveToolbar = EditorGUIUtility.wideMode == false;
            if (_shaderHeader != null && drawAboveToolbar) _shaderHeader.Draw(new CRect(EditorGUILayout.GetControlRect()));

            Rect mainHeaderRect = EditorGUILayout.BeginHorizontal();
            if (GuiHelper.ButtonWithCursor(Styles.icon_style_search, "Search", 25, 25))
            {
                DoShowSearchBar = !DoShowSearchBar;
                if (!DoShowSearchBar) ClearSearch();
            }

            //draw master label text after ui elements, so it can be positioned between
            if (_shaderHeader != null && !drawAboveToolbar)
            {
                GUILayout.Space(-10); // Decrease the space before the label
                _shaderHeader.Draw(new CRect(mainHeaderRect));
                GUILayout.Space(-10); // Decrease the space after the label
            }

            GUILayout.FlexibleSpace();
            Rect popupPosition;
            if (GuiHelper.ButtonWithCursor(Styles.icon_style_tools, "Tools", 25, 25, out popupPosition))
            {
                PopupTools(popupPosition);
            }
            EditorGUILayout.EndHorizontal();
        }

        private void GUISearchBar()
        {
            if (DoShowSearchBar)
            {
                EditorGUI.BeginChangeCheck();
                _enteredSearchTerm = EditorGUILayout.TextField(_enteredSearchTerm);
                if (EditorGUI.EndChangeCheck())
                {
                    _appliedSearchTerm = _enteredSearchTerm.ToLower();
                    UpdateSearch(MainGroup);
                }
            }
        }

        private void GUIFooters()
        {
            try
            {
                FooterButton.DrawList(_footers);
            }
            catch (Exception ex)
            {
                Debug.LogWarning(ex);
            }
            if (GUILayout.Button("✧UI Made by Meliodas✧", Styles.made_by_style))
                Application.OpenURL("https://twitter.com/Meliodas7DL");
            EditorGUIUtility.AddCursorRect(GUILayoutUtility.GetLastRect(), MouseCursor.Link);
        }

        private void DoVariantWarning()
        {
#if UNITY_2022_1_OR_NEWER
            if (Materials[0].isVariant)
            {
                EditorGUILayout.HelpBox("This material is a variant. It cannot be locked or uploaded to VRChat.", MessageType.Warning);
            }
#endif
        }

        private void PopupTools(Rect position)
        {
            var menu = new GenericMenu();

            menu.AddItem(new GUIContent("Fix Keywords"), false, delegate ()
            {
                FixKeywords(Materials);
            });
            menu.AddSeparator("");

            int unboundTextures = MaterialCleaner.CountUnusedProperties(MaterialCleaner.CleanPropertyType.Texture, Materials);
            int unboundProperties = MaterialCleaner.CountAllUnusedProperties(Materials);
            List<string> unusedTextures = new List<string>();
            MainGroup.FindUnusedTextures(unusedTextures, true);
            if (unboundTextures > 0 && !IsLockedMaterial)
            {
                menu.AddItem(new GUIContent($"Unbound Textures: {unboundTextures}/List in console"), false, delegate ()
                {
                    MaterialCleaner.ListUnusedProperties(MaterialCleaner.CleanPropertyType.Texture, Materials);
                });
                menu.AddItem(new GUIContent($"Unbound Textures: {unboundTextures}/Remove"), false, delegate ()
                {
                    MaterialCleaner.RemoveUnusedProperties(MaterialCleaner.CleanPropertyType.Texture, Materials);
                });
            }
            else
            {
                menu.AddDisabledItem(new GUIContent($"Unbound textures: 0"));
            }
            if (unusedTextures.Count > 0 && !IsLockedMaterial)
            {
                menu.AddItem(new GUIContent($"Unused Textures: {unusedTextures.Count}/List in console"), false, delegate ()
                {
                    Out("Unused textures", unusedTextures.Select(s => $"↳{s}"));
                });
                menu.AddItem(new GUIContent($"Unused Textures: {unusedTextures.Count}/Remove"), false, delegate ()
                {
                    foreach (string t in unusedTextures) if (PropertyDictionary.ContainsKey(t)) PropertyDictionary[t].MaterialProperty.textureValue = null;
                });
            }
            else
            {
                menu.AddDisabledItem(new GUIContent($"Unused textures: 0"));
            }
            if (unboundProperties > 0 && !IsLockedMaterial)
            {
                menu.AddItem(new GUIContent($"Unbound properties: {unboundProperties}/List in console"), false, delegate ()
                {
                    MaterialCleaner.ListUnusedProperties(MaterialCleaner.CleanPropertyType.Texture, Materials);
                    MaterialCleaner.ListUnusedProperties(MaterialCleaner.CleanPropertyType.Float, Materials);
                    MaterialCleaner.ListUnusedProperties(MaterialCleaner.CleanPropertyType.Color, Materials);
                });
                menu.AddItem(new GUIContent($"Unbound properties: {unboundProperties}/Remove"), false, delegate ()
                {
                    MaterialCleaner.RemoveAllUnusedProperties(MaterialCleaner.CleanPropertyType.Texture, Materials);
                });
            }
            else
            {
                menu.AddDisabledItem(new GUIContent($"Unbound properties: 0"));
            }
            menu.DropDown(position);
        }

        public static void Out(string s)
        {
            Debug.Log($"<color=#ff80ff>[HoyoToon]</color> {s}");
        }
        public static void Out(string header, params string[] lines)
        {
            Debug.Log($"<color=#ff80ff>[HoyoToon]</color> <b>{header}</b>\n{lines.Aggregate((s1, s2) => s1 + "\n" + s2)}");
        }
        public static void Out(string header, IEnumerable<string> lines)
        {
            if (lines.Count() == 0) Out(header);
            else Debug.Log($"<color=#ff80ff>[HoyoToon]</color> <b>{header}</b>\n{lines.Aggregate((s1, s2) => s1 + "\n" + s2)}");
        }
        public static void Out(string header, Color c, IEnumerable<string> lines)
        {
            if (lines.Count() == 0) Out(header);
            else Debug.Log($"<color=#ff80ff>[HoyoToon]</color> <b><color={ColorUtility.ToHtmlStringRGB(c)}>{header}</b></color> \n{lines.Aggregate((s1, s2) => s1 + "\n" + s2)}");
        }

        private void HandleEvents()
        {
            Event e = Event.current;
            //if reloaded, set reload to false
            if (_doReloadNextDraw && Event.current.type == EventType.Layout) _doReloadNextDraw = false;

            //if was undo, reload
            bool isUndo = (e.type == EventType.ExecuteCommand || e.type == EventType.ValidateCommand) && e.commandName == "UndoRedoPerformed";
            if (isUndo) _doReloadNextDraw = true;


            //on swap
            if (_onSwapToActions != null && _didSwapToShader)
            {
                foreach (DefineableAction a in _onSwapToActions)
                    a.Perform(Materials);
                _onSwapToActions = null;
            }

            // if (e.type == EventType.Used) _wasUsed = true;
            if (Input.HadMouseDownRepaint) Input.HadMouseDown = false;
            Input.HadMouseDownRepaint = false;
            IsFirstCall = false;
            materialPropertyDictionary = null;
        }

        //iterate the same way drawing would iterate
        //if display part, display all parents parts
        private void UpdateSearch(ShaderPart part)
        {
            part.has_not_searchedFor = part.Content.text.ToLower().Contains(_appliedSearchTerm) == false;
            if (part is ShaderGroup)
            {
                foreach (ShaderPart p in (part as ShaderGroup).parts)
                {
                    UpdateSearch(p);
                    part.has_not_searchedFor &= p.has_not_searchedFor;
                }
            }
        }

        private void ClearSearch()
        {
            _appliedSearchTerm = "";
            UpdateSearch(MainGroup);
        }

        private void HandleReset()
        {
            MaterialLinker.UnlinkAll(Materials[0]);
            ShaderOptimizer.DeleteTags(Materials);
        }

        public void Repaint()
        {
            if (Materials.Length > 0)
                EditorUtility.SetDirty(Materials[0]);
        }

        public static void RepaintActive()
        {
            if (ShaderEditor.Active != null)
                Active.Repaint();
        }

        public void Reload()
        {
            this._isFirstOnGUICall = true;
            this._doReloadNextDraw = true;
            // this.Repaint();
            HoyoToonWideEnumDrawer.Reload();
        }

        public static void ReloadActive()
        {
            if (ShaderEditor.Active != null)
                Active.Reload();
        }

        public void ApplyDrawers()
        {
            foreach (Material target in Materials)
                MaterialEditor.ApplyMaterialPropertyDrawers(target);
        }

        public static string GetShaderEditorDirectoryPath()
        {
            if (s_edtiorDirectoryPath == null)
            {
                IEnumerable<string> paths = AssetDatabase.FindAssets("HoyoToonEditor").Select(g => AssetDatabase.GUIDToAssetPath(g));
                foreach (string p in paths)
                {
                    if (p.EndsWith("/HoyoToonEditor.cs"))
                        s_edtiorDirectoryPath = Directory.GetParent(Path.GetDirectoryName(p)).FullName;
                }
            }
            return s_edtiorDirectoryPath;
        }

        // Cache property->keyword lookup for performance
        static Dictionary<Shader, List<(string prop, List<string> keywords)>> PropertyKeywordsByShader = new Dictionary<Shader, List<(string prop, List<string> keywords)>>();

        /// <summary> Iterate through all materials to ensure keywords list matches properties. </summary>
        public static void FixKeywords(IEnumerable<Material> materialsToFix)
        {
            // Process Shaders
            IEnumerable<Material> uniqueShadersMaterials = materialsToFix.GroupBy(m => m.shader).Select(g => g.First());
            IEnumerable<Shader> shadersWithHoyoToonEditor = uniqueShadersMaterials.Where(m => ShaderHelper.IsShaderUsingHoyoToonEditor(m)).Select(m => m.shader);

            // Clear cache every time if in developer mode, so that changes aren't missed
            if (Config.Singleton.enableDeveloperMode)
                PropertyKeywordsByShader.Clear();

            float f = 0;
            int count = shadersWithHoyoToonEditor.Count();

            if (count > 1) EditorUtility.DisplayProgressBar("Validating Keywords", "Processing Shaders", 0);

            foreach (Shader s in shadersWithHoyoToonEditor)
            {
                if (count > 1) EditorUtility.DisplayProgressBar("Validating Keywords", $"Processing Shader: {s.name}", f++ / count);
                if (!PropertyKeywordsByShader.ContainsKey(s))
                    PropertyKeywordsByShader[s] = ShaderHelper.GetPropertyKeywordsForShader(s);
            }
            // Find Materials
            IEnumerable<Material> materials = materialsToFix.Where(m => PropertyKeywordsByShader.ContainsKey(m.shader));
            f = 0;
            count = materials.Count();

            // Set Keywords
            foreach (Material m in materials)
            {
                if (count > 1) EditorUtility.DisplayProgressBar("Validating Keywords", $"Validating Material: {m.name}", f++ / count);

                List<string> keywordsInMaterial = m.shaderKeywords.ToList();

                foreach ((string prop, List<string> keywords) in PropertyKeywordsByShader[m.shader])
                {
                    switch (keywords.Count)
                    {
                        case 0:
                            break;
                        case 1:
                            string keyword = keywords[0];
                            keywordsInMaterial.Remove(keyword);

                            if (m.GetFloat(prop) == 1)
                                m.EnableKeyword(keyword);
                            else
                                m.DisableKeyword(keyword);
                            break;
                        default: // KeywordEnum
                            for (int i = 0; i < keywords.Count; i++)
                            {
                                keywordsInMaterial.Remove(keywords[i]);
                                if (m.GetFloat(prop) == i)
                                    m.EnableKeyword(keywords[i]);
                                else
                                    m.DisableKeyword(keywords[i]);
                            }
                            break;
                    }
                }

                // Disable any remaining keywords
                foreach (string keyword in keywordsInMaterial)
                    m.DisableKeyword(keyword);
            }
            if (count > 1) EditorUtility.ClearProgressBar();
        }
    }
}
