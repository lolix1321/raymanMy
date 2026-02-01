shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float vignette_intensity = 0.4;
uniform float aberration_amount = 1.5;

void fragment() {
    vec2 uv = SCREEN_UV;

    // Aberracja (rozszczepienie kolorów na krawędziach)
    // Pobieramy kanał R, G i B z lekko przesuniętych pozycji
    float shift = aberration_amount * 0.001;
    float r = texture(SCREEN_TEXTURE, uv + vec2(shift, 0.0)).r;
    float g = texture(SCREEN_TEXTURE, uv).g;
    float b = texture(SCREEN_TEXTURE, uv - vec2(shift, 0.0)).b;

    vec3 color = vec3(r, g, b);

    // Winieta (przyciemnienie rogów)
    float dist = distance(uv, vec2(0.5));
    // smoothstep tworzy miękkie przejście
    color *= 1.0 - smoothstep(0.5, 1.5, dist * vignette_intensity + 0.5);

    COLOR = vec4(color, 1.0);
}