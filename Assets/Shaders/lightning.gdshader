shader_type spatial;
render_mode blend_mix, depth_draw_never, cull_disabled;

uniform vec4 bolt_color : source_color = vec4(1.0, 1.0, 0.4, 1.0);
uniform vec4 outline_color : source_color = vec4(0.02, 0.02, 0.02, 1.0);
uniform float flicker_speed : hint_range(5.0, 50.0) = 30.0;

void fragment() {
    float edge = abs(UV.x - 0.5) * 2.0;
    float flicker = sin(TIME * flicker_speed) * 0.2 + 0.8;

    if (edge > 0.65) {
        ALBEDO = outline_color.rgb;
        EMISSION = vec3(0.0);
        ALPHA = 1.0;
    } else {
        ALBEDO = bolt_color.rgb * flicker;
        EMISSION = bolt_color.rgb * flicker * 2.5;
        ALPHA = 1.0;
    }
}
