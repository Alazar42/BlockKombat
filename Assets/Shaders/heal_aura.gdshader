shader_type spatial;
render_mode blend_mix, depth_draw_never, cull_disabled;

uniform vec4 aura_color : source_color = vec4(0.2, 0.95, 0.4, 0.9);
uniform vec4 divine_gold : source_color = vec4(1.0, 0.9, 0.2, 1.0);
uniform vec4 outline_color : source_color = vec4(0.02, 0.02, 0.02, 1.0);
uniform float flow_speed : hint_range(0.5, 10.0) = 3.5;

void fragment() {
    vec3 normal = normalize(NORMAL);
    vec3 view = normalize(VIEW);
    float NdotV = abs(dot(normal, view));
    float fresnel = 1.0 - NdotV;

    float flow = sin(UV.y * 12.0 - TIME * flow_speed) * 0.5 + 0.5;
    
    if (fresnel > 0.6) {
        ALBEDO = outline_color.rgb;
        EMISSION = vec3(0.0);
        ALPHA = 1.0;
    } else {
        vec4 col = mix(aura_color, divine_gold, flow);
        ALBEDO = col.rgb;
        EMISSION = col.rgb * 1.5;
        ALPHA = 0.85;
    }
}
