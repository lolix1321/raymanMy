shader_type canvas_item;
render_mode blend_mul; // Tryb mnożenia - im jaśniejszy kolor w shaderze, tym bardziej przezroczysty

uniform float inner_radius : hint_range(0.0, 1.0) = 0.0;
uniform float outer_radius : hint_range(0.0, 2.0) = 1.0;
uniform vec4 vignette_color : source_color = vec4(0.1, 0.1, 0.1, 1.0);

// Parametry pasków
uniform float scanline_count : hint_range(10.0, 1000.0) = 600.0;
uniform float scanline_speed : hint_range(0.0, 2.0) = 0.1;
uniform float scanline_thickness : hint_range(0.0, 0.2) = 0.05; // Kontrast pasków

void fragment() {
	// 1. Obliczanie winiety
	float dist = distance(UV, vec2(0.5));
	float vignette_mask = 1.0 - smoothstep(inner_radius, outer_radius, dist);
	vec3 vignette_part = mix(vignette_color.rgb, vec3(1.0), vignette_mask);

	// 2. Obliczanie płynących pasków (scanlines)
	// scanline_count decyduje o grubości (im więcej, tym cieńsze)
	float scanline_pos = UV.y * scanline_count - (TIME * scanline_speed * 100.0);
	// Tworzymy falę sin, która będzie mnożyć obraz (paski będą lekko przyciemniać)
	float scanline_factor = sin(scanline_pos) * scanline_thickness + (1.0 - scanline_thickness);

	// 3. Połączenie efektów
	// Mnożymy winietę przez paski.
	// W trybie blend_mul wynik 1.0 oznacza brak zmian, a wartości niższe to przyciemnienie.
	vec3 final_color = vignette_part * scanline_factor;

	COLOR = vec4(final_color, 1.0);
}