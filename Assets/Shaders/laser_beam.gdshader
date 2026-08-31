shader_type spatial;
render_mode blend_mix, depth_draw_never, cull_disabled;

uniform vec4 core_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 beam_color : source_color = vec4(0.1, 0.6, 1.0, 1.0);
uniform vec4 outline_color : source_color = vec4(0.02, 0.02, 0.02, 1.0);
uniform float pulse_speed : hint_range(1.0, 20.0) = 12.0;

void fragment() {
    float edge = abs(UV.y - 0.5) * 2.0;
    
    if (edge > 0.68) {
        ALBEDO = outline_color.rgb;
        EMISSION = vec3(0.0);
        ROUGHNESS = 0.9;
        ALPHA = 1.0;
    } else {
        float core = 1.0 - (edge / 0.68);
        core = pow(clamp(core, 0.0, 1.0), 2.5);
        
        float pulse = sin(TIME * pulse_speed) * 0.15 + 0.85;
        vec3 col = mix(beam_color.rgb, core_color.rgb, core) * pulse;
        
        ALBEDO = col;
        EMISSION = col * 2.0;
        ROUGHNESS = 0.1;
        ALPHA = 1.0;
    }
}
