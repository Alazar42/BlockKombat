shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled;

uniform vec4 shield_color : source_color = vec4(0.15, 0.65, 1.0, 0.85);
uniform vec4 rim_color : source_color = vec4(0.7, 0.95, 1.0, 1.0);
uniform vec4 outline_color : source_color = vec4(0.02, 0.02, 0.04, 1.0);
uniform float scanline_speed : hint_range(0.1, 10.0) = 3.0;
uniform float hex_scale : hint_range(1.0, 50.0) = 22.0;

void fragment() {
    vec3 normal = normalize(NORMAL);
    vec3 view = normalize(VIEW);
    float NdotV = abs(dot(normal, view));
    float fresnel = 1.0 - NdotV;

    float grid = sin(UV.y * hex_scale + TIME * scanline_speed) * sin(UV.x * hex_scale * 1.5);
    bool is_grid_line = abs(grid) < 0.18;

    if (fresnel > 0.65 or is_grid_line) {
        ALBEDO = outline_color.rgb;
        EMISSION = vec3(0.0);
        ROUGHNESS = 0.9;
        ALPHA = 0.95;
    } else {
        vec4 col = mix(shield_color, rim_color, fresnel);
        ALBEDO = col.rgb;
        EMISSION = col.rgb * 1.4;
        ROUGHNESS = 0.2;
        ALPHA = 0.75;
    }
}
