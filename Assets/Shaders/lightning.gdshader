shader_type spatial;
render_mode blend_add, depth_draw_opaque, cull_disabled, unshaded;

uniform vec4 bolt_color : source_color = vec4(1.0, 1.0, 0.6, 1.0);
uniform float flicker_speed : hint_range(5.0, 50.0) = 25.0;

void fragment() {
    float flicker = sin(TIME * flicker_speed) * 0.25 + 0.75;
    float core = 1.0 - abs(UV.x - 0.5) * 2.0;
    core = pow(clamp(core, 0.0, 1.0), 2.5);

    ALBEDO = bolt_color.rgb * core * flicker * 4.0;
    ALPHA = bolt_color.a * core * flicker;
}
