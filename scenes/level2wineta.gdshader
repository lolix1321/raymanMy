shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float vignette_intensity = 0.4;
uniform float aberration_amount = 0.5;

void fragment() {
    // 1. Chromatic Aberration (rozszczepienie kolorów)
    float shift = aberration_amount * 0.001;
    float r = texture(SCREEN_TEXTURE, SCREEN_UV + vec2(shift, 0.0)).r;
    float g = texture(SCREEN_TEXTURE, SCREEN_UV).g;
    float b = texture(SCREEN_TEXTURE, SCREEN_UV - vec2(shift, 0.0)).b;

    vec3 color = vec3(r, g, b);

    // 2. Vignette (przyciemnienie rogów)
    float dist = distance(UV, vec2(0.5));
    color *= smoothstep(0.8, vignette_intensity * 0.2, dist);

    COLOR = vec4(color, 1.0);
}