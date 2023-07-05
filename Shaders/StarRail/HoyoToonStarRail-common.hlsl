float shadow_rate(float ndotl, float lightmap_ao, float vertex_ao)
{
    float shadow_ndotl  = ndotl * 0.5f + 0.5f;
    float shadow_thresh = (lightmp.y + lightmp.y) * vcol.x;
    float shadow_area   = min(1.0f, dot(shadow_ndotl.xx, shadow_thresh.xx));
    shadow_area = max(0.001f, shadow_area) * 0.85f + 0.15f;
    shadow_area = (shadow_area > _ShadowRamp) ? 0.99f : shadow_area;
    return shadow_area;
}

float3 specular_base(float ndoth, float lightmap_spec, float3 specular_color, float3 specular_values)
{
    float3 specular = ndoth;
    specular = pow(max(specular, 0.01f), specular_values.x);
}