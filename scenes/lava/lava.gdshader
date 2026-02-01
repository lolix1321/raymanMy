shader_type canvas_item;

varying vec2 world_pos;

uniform float base_y : hint_range(0.0, 1.0) = 0.5;
uniform vec4 lava_color : source_color = vec4(0.8, 0.2, 0.0, 1.0);
uniform vec4 glow_color : source_color = vec4(1.0, 0.6, 0.0, 1.0);

uniform float wave_amplitude = 0.04;
uniform float wave_speed = 0.5;

// Funkcja pomocnicza do generowania szumu
float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
    vec2 uv = UV;
    
    // 1. Złożone fale
    float time = TIME * wave_speed;
    float w1 = sin(world_pos.x * 0.05 + time);
    float w2 = sin(world_pos.x * 0.12 + time * 1.5) * 0.5;
    float w3 = sin(world_pos.x * 0.02 - time * 0.8) * 2.0;
    
    float combined_wave = (w1 + w2 + w3) * wave_amplitude;
    float dynamic_lava_level = base_y + combined_wave;

    // 2. Maska lawy
    float lava_mask = smoothstep(dynamic_lava_level + 0.01, dynamic_lava_level, uv.y);

    // 3. Tekstura wnętrza (Mniej intensywne pulsowanie)
    float noise = hash(world_pos * 0.01 + vec2(TIME * 0.1));
    // Zmniejszono amplitudę z 0.1 na 0.03 i spowolniono czas (0.8 zamiast 1.5)
    float pulse = sin(TIME * 0.8) * 0.1 + 0.97; 
    
    // 4. Tworzenie koloru
    float edge_thickness = 0.08;
    float edge = smoothstep(dynamic_lava_level + edge_thickness, dynamic_lava_level, uv.y);
    
    // Mieszanie kolorów
    vec3 final_color = mix(lava_color.rgb, glow_color.rgb, edge);
    final_color += noise * 0.04; // Delikatnie mniejsze ziarno
    final_color *= pulse;        

    // PRZYCIEMNIENIE: Mnożnik obniżający ogólną jasność (np. 0.8 = 80% jasności)
    float darkness_factor = 0.85; 
    final_color *= darkness_factor;

    // 5. Scanlines
    float scanline_pos = uv.y * 150.0 - (TIME * 2.0);
    float scanlines = smoothstep(0.4, 0.5, sin(scanline_pos)) * 0.1 + 0.9;
    final_color *= scanlines;

    COLOR = vec4(final_color, lava_mask);
}