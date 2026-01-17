shader_type canvas_item;

// --- KONFIGURACJA ---
uniform float speed = 2.0;
uniform float minStrength : hint_range(0.0, 5.0) = 0.05;
uniform float maxStrength : hint_range(0.0, 50.0) = 10.0;
uniform float detail = 1.0;

// --- NAPRAWIACZE ---
// Włącz to, żeby zobaczyć strefy ruchu! (Czerwony = ruch, Niebieski = stop)
uniform bool debug_mode = false;

// Gdzie zaczyna się ruch (od dołu obrazka).
// 0.0 = sam dół, 1.0 = sama góra.
// Ustaw to tak, żeby niebieski kolor przykrył całą skałę.
uniform float rock_limit : hint_range(0.0, 1.0) = 0.4;

// Jak płynne jest przejście między skałą a trawą.
// 0.0 = ostre cięcie (jak nożem), 0.2 = miękkie przejście.
uniform float softness : hint_range(0.0, 1.0) = 0.1;

void vertex() {
	// 1. Obliczamy pozycję "od dołu" (0 na dole obrazka, 1 na górze)
	float height = 1.0 - UV.y;

	// 2. Tworzymy TWARDĄ maskę
	// Funkcja smoothstep tworzy wartość od 0 do 1.
	// Wszystko poniżej 'rock_limit' będzie zerem (beton).
	// Wszystko powyżej 'rock_limit + softness' będzie się ruszać.
	float mask = smoothstep(rock_limit, rock_limit + softness, height);

	// 3. Obliczamy ruch
	float time = TIME * speed;
	float movement = sin(time + VERTEX.x * detail);

	// 4. Aplikujemy ruch tylko tam, gdzie maska pozwala
	// mix(0.0, movement, mask) oznacza: jeśli maska to 0, ruch to 0.
	float final_move = movement * mix(minStrength, maxStrength, mask);

	VERTEX.x += final_move;
}

void fragment() {
	// Ten fragment służy tylko do debugowania (kolorowania)
	if (debug_mode) {
		float height = 1.0 - UV.y;
		float mask = smoothstep(rock_limit, rock_limit + softness, height);

		// Niebieski (0.0) -> Czerwony (1.0)
		vec4 debug_color = mix(vec4(0,0,1,0.8), vec4(1,0,0,0.8), mask);

		// Nakładamy kolor debugowania na oryginalną teksturę
		vec4 tex_color = texture(TEXTURE, UV);
		COLOR = mix(tex_color, debug_color, 0.7); // 0.7 to siła koloru debugowania
		COLOR.a = tex_color.a; // Zachowujemy przezroczystość tła
	}
}