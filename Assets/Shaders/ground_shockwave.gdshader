shader_type spatial;
render_mode blend_mix, depth_draw_never, cull_disabled;

uniform vec4 ring_color : source_color = vec4(1.0, 0.8, 0.1, 1.0);
uniform vec4 outline_color : source_color = vec4(0.02, 0.02, 0.02, 1.0);

void fragment() {
    float dist = length(UV - vec2(0.5));
    float diff = abs(dist - 0.38);

    if (diff < 0.12) {
        if (diff > 0.07) {
            ALBEDO = outline_color.rgb;
            EMISSION = vec3(0.0);
            ALPHA = 1.0;
        } else {
            ALBEDO = ring_color.rgb;
            EMISSION = ring_color.rgb * 2.0;
            ALPHA = 1.0;
        }
    } else {
        ALPHA = 0.0;
    }
}
