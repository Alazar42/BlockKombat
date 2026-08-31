shader_type spatial;
render_mode blend_add, depth_draw_opaque, cull_disabled, unshaded;

uniform vec4 ring_color : source_color = vec4(1.0, 0.8, 0.3, 0.9);
uniform float ring_width : hint_range(0.05, 0.5) = 0.2;

void fragment() {
    float dist = length(UV - vec2(0.5));
    float ring = 1.0 - abs(dist - 0.4) / ring_width;
    ring = clamp(ring, 0.0, 1.0);
    ring = pow(ring, 2.0);

    ALBEDO = ring_color.rgb * ring * 3.0;
    ALPHA = ring_color.a * ring;
}
