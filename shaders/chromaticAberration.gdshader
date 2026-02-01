shader_type canvas_item;

// Pobieramy teksturę ekranu
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float amount : hint_range(0.0, 5.0) = 0.0;

void fragment() {
	// W Godot 4 używamy SCREEN_UV zamiast SCREEN_TEXTURE_UV
	vec2 uv = SCREEN_UV;

	// Przesunięcie dla efektu Chromatic Aberration
	float r = texture(screen_texture, uv + vec2(amount * 0.005, 0.0)).r;
	float g = texture(screen_texture, uv).g;
	float b = texture(screen_texture, uv - vec2(amount * 0.005, 0.0)).b;

	COLOR = vec4(r, g, b, 1.0);
}