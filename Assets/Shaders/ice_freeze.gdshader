shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled;

uniform vec4 ice_color : source_color = vec4(0.15, 0.7, 1.0, 1.0);
uniform vec4 frost_glow : source_color = vec4(0.6, 0.95, 1.0, 1.0);
uniform vec4 outline_color : source_color = vec4(0.04, 0.04, 0.06, 1.0);
uniform float outline_threshold : hint_range(0.1, 0.9) = 0.52;
uniform float shimmer_speed : hint_range(0.1, 5.0) = 2.5;

void fragment() {
    vec3 normal = normalize(NORMAL);
    vec3 view = normalize(VIEW);
    float NdotV = abs(dot(normal, view));
    float fresnel = 1.0 - NdotV;

    float shimmer = sin((UV.x + UV.y) * 25.0 + TIME * shimmer_speed) * 0.5 + 0.5;
    vec4 col = mix(ice_color, frost_glow, fresnel * 0.7 + shimmer * 0.3);

    if (fresnel > outline_threshold) {
        ALBEDO = outline_color.rgb;
        EMISSION = vec3(0.0);
        ROUGHNESS = 0.8;
    } else {
        ALBEDO = col.rgb;
        EMISSION = col.rgb * 1.2;
        ROUGHNESS = 0.15;
    }
}
