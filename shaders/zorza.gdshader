shader_type canvas_item;

// --- PARAMETRY ---
uniform sampler2D noise_tex : repeat_enable, filter_linear_mipmap;

// Kolory (Realistyczna paleta: jasna zieleń u dołu, fiolet/czerwień u góry)
uniform vec4 color_base : source_color = vec4(0.2, 1.0, 0.6, 1.0); // Neonowa zieleń
uniform vec4 color_top : source_color = vec4(0.8, 0.2, 1.0, 1.0);   // Fiolet/Róż

// Kształt i Ruch
uniform float speed : hint_range(0.0, 0.1) = 0.03;
// Vertical Stretch: BARDZO MAŁA wartość = bardzo wysokie słupy
uniform float vertical_stretch : hint_range(0.001, 0.1) = 0.015; 
// Warping: Jak mocno zorza się "skręca" i fałduje
uniform float warping_strength : hint_range(0.0, 1.0) = 0.3;
// Sharpness: Klucz do realizmu. Wysoka wartość = ostre pasy zamiast mgły.
uniform float sharpness : hint_range(1.0, 20.0) = 10.0;
uniform float intensity : hint_range(1.0, 5.0) = 2.5;

// Funkcja pomocnicza do wyostrzania szumu
float sharp_streak(float noise_val, float sharp_factor) {
	// Odwracamy szum i potęgujemy go.
	// Sprawia to, że tylko "szczyty" szumu są widoczne jako cienkie linie.
	return pow(clamp(1.0 - noise_val, 0.0, 1.0), sharp_factor);
}

void fragment() {
	vec2 uv = UV;
	float time = TIME * speed;

	// --- FAZA 1: DOMAIN WARPING (Tworzenie fałd) ---
	// Próbkujemy szum, żeby dowiedzieć się, jak wygiąć przestrzeń.
	// Używamy dużej skali (uv * 0.5), żeby uzyskać szerokie zakola.
	vec2 warp_uv = vec2(uv.x * 0.5 + time * 0.5, uv.y * 0.3);
	float warp_noise = texture(noise_tex, warp_uv).r;
	
	// "Wyginamy" współrzędną X na podstawie szumu.
	uv.x += (warp_noise - 0.5) * warping_strength;

	// --- FAZA 2: GŁÓWNE PASY (Pionowe słupy) ---
	// Teraz używamy wygiętego UV, ale ekstremalnie rozciągamy je w pionie.
	vec2 streaks_uv = vec2(uv.x * 2.0, uv.y * vertical_stretch + time * 1.5);
	float base_noise = texture(noise_tex, streaks_uv).r;

	// Wyostrzamy szum, żeby uzyskać wyraźne pasy
	float streaks = sharp_streak(base_noise, sharpness);
	
	// --- FAZA 3: DETALE (Druga warstwa dla głębi) ---
	// Dodajemy drugą, szybciej poruszającą się warstwę mniejszych detali.
	vec2 detail_uv = vec2(uv.x * 4.0 + 0.5, uv.y * vertical_stretch * 2.0 + time * 2.5);
	float detail_noise = texture(noise_tex, detail_uv).r;
	streaks += sharp_streak(detail_noise, sharpness * 0.8) * 0.5;

	// --- MASKOWANIE I KOLOR ---
	// Zorza zanika na górze i na dole ekranu
	float mask = smoothstep(0.0, 0.2, UV.y) * (1.0 - smoothstep(0.7, 1.0, UV.y));
	
	// Realistyczne mieszanie kolorów: Zieleń na dole szybko przechodzi w fiolet
	vec3 final_color = mix(color_base.rgb, color_top.rgb, pow(UV.y, 0.7));
	
	// Składamy wszystko razem
	float final_alpha = streaks * mask * intensity;
	
	COLOR = vec4(final_color, clamp(final_alpha, 0.0, 1.0));
}