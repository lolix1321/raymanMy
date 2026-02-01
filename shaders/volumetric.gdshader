shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Pozycja słońca na ekranie (wartości od 0.0 do 1.0) - będziemy to aktualizować skryptem
uniform vec2 light_position = vec2(0.5, 0.5);

// USTAWIENIA
uniform float density = 1.0;   // Długość promieni
uniform float weight = 0.05;   // Jasność/siła promieni
uniform float decay = 0.95;    // Jak szybko promienie zanikają
uniform float exposure = 1.0;  // Ogólna jasność efektu
uniform int samples = 50;      // Jakość (im więcej, tym gładsze, ale bardziej obciąża PC)

void fragment() {
    vec2 uv = SCREEN_UV;
    
    // Wektor od piksela do słońca
    vec2 delta_text_coord = uv - light_position;
    
    // Dzielimy ten wektor, żeby robić małe kroczki w pętli
    delta_text_coord *= 1.0 / float(samples) * density;
    
    vec4 color = texture(SCREEN_TEXTURE, uv);
    
    // W zmiennej 'illumination_decay' trzymamy "energię" promienia
    float illumination_decay = 1.0;
    
    // Pętla rozmycia (Raymarching)
    for(int i = 0; i < samples; i++) {
        // Przesuwamy się w stronę słońca
        uv -= delta_text_coord;
        
        // Pobieramy próbkę koloru z ekranu w tym miejscu
        vec4 sample_color = texture(SCREEN_TEXTURE, uv);
        
        // Jeśli trafimy na coś ciemnego (wyspa), 'sample_color' będzie ciemny,
        // więc promień zostanie przygaszony.
        sample_color *= illumination_decay * weight;
        
        // Dodajemy światło do naszego piksela
        color += sample_color;
        
        // Z każdym krokiem światło słabnie
        illumination_decay *= decay;
    }
    
    COLOR = color * exposure;
}