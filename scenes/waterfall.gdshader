shader_type canvas_item;

// TEKSTURA SZUMU: Ustaw tutaj New NoiseTexture2D
uniform sampler2D noise_texture : repeat_enable, filter_nearest;

// KOLORY
uniform vec4 water_color_light : source_color = vec4(0.4, 0.8, 1.0, 1.0); // Jasna woda
uniform vec4 water_color_dark : source_color = vec4(0.2, 0.5, 0.9, 1.0);  // Ciemna woda (głębia)

// USTAWIENIA FIZYKI
uniform float speed = 0.8;         // Prędkość spadania
uniform float distortion_strength : hint_range(0.0, 0.1) = 0.02; // Jak mocno woda "wężykuje" na boki
uniform float scale_y = 0.5;       // Rozciągnięcie szumu w pionie (mniejsze = dłuższe strugi)

// PIXEL ARTOWY ROZPAD (Disintegrate)
uniform float dissolve_start : hint_range(0.0, 1.0) = 0.6; // W jakiej części wysokości zaczyna znikać

void fragment() {
	// 1. ZNIEKSZTAŁCENIE (WOBBLE)
	// Przesuwamy współrzędną X w oparciu o czas i wysokość (sinusoida).
	// To sprawia, że strumień wygląda jakby płynął, a nie był sztywną teksturą.
	float wobble = sin(UV.y * 10.0 + TIME * 5.0) * distortion_strength;
	
	// 2. RUCH W DÓŁ
	// Tworzymy UV dla szumu. Dodajemy 'wobble' do X i przesuwamy Y w czasie.
	vec2 noise_uv = vec2(UV.x + wobble, (UV.y * scale_y) + (TIME * speed));
	
	// 3. PRÓBKOWANIE SZUMU
	// Pobieramy wartość z tekstury.
	float noise_val = texture(noise_texture, noise_uv).r;
	
	// 4. EFEKT "CIĘCIA" (Thresholding)
	// Zamiast gładkich przejść, robimy ostre granice kolorów (styl pixel art).
	// Jeśli szum > 0.5 to jasny kolor, jeśli mniej to ciemny.
	float shape = step(0.5, noise_val);
	vec4 final_color = mix(water_color_dark, water_color_light, shape);
	
	// 5. ROZPAD NA DOLE (Pixel Disintegrate)
	// Zamiast przezroczystości (alpha), używamy szumu do "wygryzania" pikseli.
	// Im niżej (większe UV.y), tym wyższy próg znikania.
	// (UV.y - dissolve_start) / (1.0 - dissolve_start) normalizuje wartość od 0 do 1 w strefie zanikania.
	float fade_zone = max(0.0, (UV.y - dissolve_start) / (1.0 - dissolve_start));
	
	// Jeśli wartość szumu jest mniejsza niż siła zanikania, piksel znika (alpha = 0).
	// Daje to efekt rozpryskiwania się kropel w powietrzu.
	float dissolve_mask = step(fade_zone, noise_val); // Używamy tego samego szumu co do kształtu
	
	// 6. MASKOWANIE BOKÓW
	// Żeby Line2D nie miało idealnie prostych krawędzi po bokach, przyciemniamy je lekko.
	float side_mask = 1.0 - pow(abs(UV.x - 0.5) * 2.0, 4.0); // Wygładzanie krawędzi
	
	COLOR = final_color;
	COLOR.a = dissolve_mask * side_mask;
}