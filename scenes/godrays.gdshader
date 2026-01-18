shader_type canvas_item;

// --- USTAWIENIA ---
uniform vec4 ray_color : source_color = vec4(1.0, 0.9, 0.65, 1.0); // Kolor promieni (jasnożółty/biały)
uniform vec2 ray_origin = vec2(0.5, 1.0); // Skąd wychodzą promienie (0.5, 1.0 to dół-środek ekranu)
uniform float ray_speed = 0.1; // Jak szybko się obracają
uniform float ray_density = 10.0; // Ile jest promieni
uniform float ray_width = 0.5; // Jak szerokie są promienie

void fragment() {
    // Przeliczamy UV względem punktu źródłowego
    vec2 uv = UV - ray_origin;
    
    // Konwersja na współrzędne biegunowe (kąt i odległość)
    float angle = atan(uv.y, uv.x);
    float dist = length(uv);
    
    // --- GENEROWANIE PROMIENI ---
    // Używamy sinusa opartego na kącie, aby stworzyć paski wokół środka
    // Dodajemy TIME, aby się obracały
    float rays = sin(angle * ray_density + TIME * ray_speed);
    
    // Nakładamy drugą warstwę, żeby było bardziej nieregularnie
    rays += sin(angle * ray_density * 2.3 - TIME * ray_speed * 1.5) * 0.5;
    
    // Przycinamy wartości ujemne (zostawiamy tylko jasne paski)
    rays = max(0.0, rays);
    
    // Zwiększamy kontrast promieni (smoothstep)
    rays = smoothstep(1.0 - ray_width, 1.0, rays);
    
    // --- ZANIKANIE (FADE OUT) ---
    // Promienie powinny być jasne u źródła i zanikać w górę
    float fade = 1.0 - smoothstep(0.0, 0.8, dist); // Im dalej od źródła, tym słabiej
    
    // Dodatkowo wygaszamy je, jeśli są "pod" źródłem światła (opcjonalne)
    // fade *= step(0.0, -uv.y); 

    // --- FINALNY KOLOR ---
    vec3 color = ray_color.rgb;
    float alpha = rays * fade * ray_color.a; // Łączymy kształt promieni z zanikaniem i przezroczystością koloru
    
    // Ważne: W trybie "Add" (Screen) często lepiej operować na kolorze RGB przy niskiej alpha
    COLOR = vec4(color, alpha * 0.5); // * 0.5 dla subtelności
}