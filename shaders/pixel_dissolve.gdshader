shader_type canvas_item;

// Parametry, którymi sterujemy w kodzie
uniform float pixel_size : hint_range(1.0, 64.0) = 1.0;
uniform float dissolve_amount : hint_range(0.0, 1.0) = 0.0;

// Funkcja generująca matematyczny wzór "rozsypywania"
float hash(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

void fragment() {
	// 1. Pobieramy rozmiar tekstury
	vec2 size = vec2(textureSize(TEXTURE, 0));
	
	// 2. Obliczamy pozycję piksela (efekt mozaiki)
	// Jeśli pixel_size wynosi 1.0, obraz jest normalny.
	vec2 pixelated_uv = floor(UV * size / pixel_size) / (size / pixel_size);
	
	// 3. Pobieramy kolor z tego piksela
	vec4 color = texture(TEXTURE, pixelated_uv);
	
	// 4. Generujemy losowość dla każdego "dużego piksela"
	float noise = hash(pixelated_uv);
	
	// 5. Jeśli losowość jest mniejsza niż suwak zniknięcia - usuwamy piksel (Alpha = 0)
	if (noise < dissolve_amount) {
		color.a = 0.0;
	}
	
	COLOR = color;
}