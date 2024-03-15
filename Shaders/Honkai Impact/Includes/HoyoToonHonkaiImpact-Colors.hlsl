float4 color_selection(float a, float4 color1, float4 color2, float4 color3, float4 color4, float4 color5) {
    float Map = max(a + 0.1f, 0.0);
    
    float4 color = Map >= 0.8 ? color5 :
                   Map >= 0.6 ? color4 :
                   Map >= 0.4 ? color3 :
                   Map >= 0.2 ? color2 : color1;

    return (variant_selector == 2)? color1 : color;
}


float4 rim_cols(float a) {
    return color_selection(a, _RGColor, _HRRimColor2, _HRRimColor3, _HRRimColor4, _HRRimColor5);
}

float4 shadow_cols(float a){
    return color_selection(a, _FirstShadowMultColor, _FirstShadowMultColor2, _FirstShadowMultColor3, _FirstShadowMultColor4, _FirstShadowMultColor5);
}

float4 edge_cols(float a) {
    return color_selection(a, _OutlineColor, _OutlineColor2, _OutlineColor3, _OutlineColor4, _OutlineColor5);
}

float4 emi_cols(float a) {
    return color_selection(a, _EmissionColor, _EmissionColor2, _EmissionColor3, _EmissionColor4, _EmissionColor5);
}


float3 SFX_Common(){
    return 0.0f;
}
float3 ExternalOutline(){
    return 0.0f;
}