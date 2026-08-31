shader_type spatial;
render_mode blend_add, depth_draw_opaque, cull_disabled, unshaded;

uniform vec4 aura_color : source_color = vec4(0.2, 1.0, 0.4, 0.7);
uniform vec4 divine_gold : source_color = vec4(1.0, 0.9, 0.3, 0.9);
uniform float flow_speed : hint_range(0.5, 10.0) = 3.5;

void fragment() {
    vec3 normal = normalize(NORMAL);
    vec3 view = normalize(VIEW);
    float fresnel = 1.0 - abs(dot(normal, view));
    fresnel = pow(fresnel, 2.0);

    float flow = sin(UV.y * 12.0 - TIME * flow_speed) * 0.5 + 0.5;
    vec4 col = mix(aura_color, divine_gold, flow * 0.5 + fresnel * 0.5);

    ALBEDO = col.rgb * (1.8 + fresnel * 1.5);
    ALPHA = clamp(col.a * (0.4 + fresnel * 0.8 + flow * 0.3), 0.0, 1.0);
}
