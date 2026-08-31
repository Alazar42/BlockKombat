shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled;

uniform vec4 core_color : source_color = vec4(1.0, 0.9, 0.2, 1.0);
uniform vec4 flame_color : source_color = vec4(1.0, 0.2, 0.0, 1.0);
uniform vec4 outline_color : source_color = vec4(0.05, 0.05, 0.05, 1.0);
uniform float outline_threshold : hint_range(0.1, 0.9) = 0.55;
uniform float speed : hint_range(0.1, 10.0) = 4.5;
uniform float frequency : hint_range(1.0, 30.0) = 10.0;

void fragment() {
    vec3 normal = normalize(NORMAL);
    vec3 view = normalize(VIEW);
    float NdotV = abs(dot(normal, view));
    float fresnel = 1.0 - NdotV;

    float noise = sin(UV.x * frequency + TIME * speed) * cos(UV.y * frequency + TIME * speed * 0.8);
    float pulse = 0.5 + 0.5 * noise;

    vec4 fire = mix(core_color, flame_color, clamp(fresnel * 1.2 + pulse * 0.3, 0.0, 1.0));

    // Sharp black outline rim on the silhouette
    if (fresnel > outline_threshold) {
        ALBEDO = outline_color.rgb;
        EMISSION = vec3(0.0);
        ROUGHNESS = 0.9;
    } else {
        ALBEDO = fire.rgb;
        EMISSION = fire.rgb * 1.5;
        ROUGHNESS = 0.2;
    }
}
