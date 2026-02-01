shader_type canvas_item;

// PARAMETRY DO EDYCJI W INSPEKTORZE
uniform float speed : hint_range(0.0, 1.0) = 0.1; // Szybkość przesuwania chmur
uniform float density : hint_range(0.0, 1.5) = 0.7; // Gęstość chmur
uniform float storm_darkness : hint_range(0.0, 1.0) = 0.6; // Jak ciemna jest burza
uniform vec4 storm_color : source_color = vec4(0.1, 0.1, 0.15, 1.0); // Kolor burzowy (szaro-granatowy)
uniform float lightning_frequency : hint_range(0.0, 1.0) = 0.5; // Częstotliwość błyskawic

// --- FUNKCJE SZUMU (Tworzą ładne, kłębiaste kształty) ---

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);
    // Interpolacja (wygładzanie krawędzi)
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

// Fractal Brownian Motion (FBM) - to tworzy efekt "kłębowiska"
float fbm(vec2 st) {
    float value = 0.0;
    float amplitude = 0.5;
    for (int i = 0; i < 4; i++) {
        value += amplitude * noise(st);
        st *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

void fragment() {
    vec4 base_color = texture(TEXTURE, UV);
    
    // 1. MASKA PLANETY (Koło)
    float dist = distance(UV, vec2(0.5));
    // Używamy smoothstep dla gładszej krawędzi maski (antyaliasing)
    float planet_mask = 1.0 - smoothstep(0.49, 0.5, dist);
    
    // Jeśli poza planetą lub pixel przezroczysty, nie rysuj nic
    if (base_color.a == 0.0 || planet_mask <= 0.0) {
        COLOR = base_color;
    } else {
        
        // 2. TWORZENIE CHMUR (Dwie warstwy dla efektu głębi)
        vec2 uv1 = UV * 4.0;
        vec2 uv2 = UV * 4.0;
        
        // Ruch chmur (Turbulencje)
        uv1.x += TIME * speed;
        uv1.y += TIME * speed * 0.2; // Lekki ruch w pionie
        
        uv2.x -= TIME * speed * 0.8; // Druga warstwa w przeciwnym kierunku
        uv2.y -= TIME * speed * 0.1;
        
        // Generowanie wzoru
        float clouds = fbm(uv1) * fbm(uv2); // Mnożenie warstw zagęszcza chmury
        
        // Wzmocnienie kontrastu chmur (żeby były wyraźniejsze)
        clouds = smoothstep(1.0 - density, 1.0, clouds);
        
        // 3. EFEKT BŁYSKAWIC
        // Losowy błysk bazujący na czasie
        float lightning = 0.0;
        float flash_trigger = random(vec2(floor(TIME * 10.0), 0.0)); // Próbkujemy czas co 0.1s
        if (flash_trigger > (1.0 - lightning_frequency * 0.1)) {
            lightning = 0.3; // Siła błysku
        }
        
        // 4. MIESZANIE KOLORÓW
        // Ciemna burza nakładana na planetę
        vec3 stormy_overlay = mix(base_color.rgb, storm_color.rgb, clouds * storm_darkness);
        
        // Dodajemy błyskawicę (rozjaśnienie) tam, gdzie są chmury
        stormy_overlay += vec3(lightning) * clouds;
        
        COLOR = vec4(stormy_overlay, base_color.a);
    }
	
	
}