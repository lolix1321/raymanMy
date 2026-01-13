shader_type canvas_item;

/* ================= SETTINGS ================= */
uniform vec3 whiteness_color : source_color = vec3(1.0);
uniform float amount : hint_range(0.0, 1.0) = 0.0;

// Explode & Dissolve
uniform float glitch_chance : hint_range(0.0, 1.0) = 0.0; 
uniform float explosion_speed : hint_range(0.0, 10.0) = 2.0; // Prędkość rozlatywania się
uniform float particle_size : hint_range(1.0, 100.0) = 30.0; // Rozmiar kawałków (im więcej tym drobniejsze)

uniform float glitch_speed = 7.0;
uniform float shake_strength = 0.02;
uniform float noise_strength = 0.2;

/* ================= RANDOM FUNCTIONS ================= */
float rand(float x) {
	return fract(sin(x * 143758.5453) * 43758.5453);
}

float rand2(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

/* ================= FRAGMENT SHADER ================= */
void fragment() {
	vec2 uv = UV;
	
	// --- SEKCJA EKSPLOZJI (Rozpad na piksele w różne strony) ---
	if (glitch_chance > 0.01) {
		// Dzielimy postać na siatkę
		vec2 grid_uv = floor(uv * particle_size) / particle_size;
		
		// Generujemy unikalny kierunek dla każdego kwadracika (kawałka)
		// Używamy rand2, aby uzyskać wartości od 0 do 1, a potem mapujemy na -1 do 1
		vec2 direction = vec2(
			rand2(grid_uv) - 0.5, 
			rand2(grid_uv + vec2(1.0)) - 0.5
		);
		
		// fall_progress kontroluje jak daleko kawałki odleciały
		float explosion_progress = glitch_chance;
		
		// Przesuwamy UV w wygenerowanym kierunku
		// Dodajemy lekką grawitację (opcjonalnie: direction.y += explosion_progress)
		uv -= direction * explosion_progress * explosion_speed;
		
		// Sprawiamy, że kawałki znikają w miarę postępu
		float mask = rand2(grid_uv + vec2(0.5));
		if (mask < explosion_progress * 0.7) {
			discard;
		}
	}

	// Efekt glitcha (miganie/shake)
	float glitch = step(1.0 - glitch_chance, rand(floor(TIME * glitch_speed)));
	uv += vec2(rand(TIME) - 0.5, rand(TIME + 1.0) - 0.5) * shake_strength * glitch;

	/* ----- KOLORY ----- */
	vec4 base_tex = texture(TEXTURE, uv);
	
	// Ukrywamy piksele, które wyleciały poza ramkę tekstury
	if (uv.y < 0.0 || uv.y > 1.0 || uv.x < 0.0 || uv.x > 1.0) {
		base_tex.a = 0.0;
	}

	vec3 final_color = base_tex.rgb;
	
	// Nakładamy wybielenie (hit effect)
	final_color = mix(final_color, whiteness_color, amount);
	
	// Dodajemy szum cyfrowy podczas rozpadu
	final_color += (rand2(uv * TIME) - 0.5) * noise_strength * glitch_chance;

	COLOR = vec4(final_color, base_tex.a);
}