shader_type canvas_item;

// --- ZMIENNE ---
uniform vec2 camera_offset = vec2(0.0, 0.0);

// --- USTAWIENIA ---
uniform vec4 flake_color : source_color = vec4(0.8, 0.9, 1.0, 1.0);
uniform float fall_speed = 0.2;
uniform float sparsity = 5.0;

// Funkcja losująca
float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

// Funkcja tworząca warstwę
float make_layer(vec2 uv, float scale, float speed_mod, float size_mod, float time, float parallax_factor, float fade_mode) {
    
    // Paralaksa i spadanie
    uv += (camera_offset * parallax_factor) / scale;
    uv.y -= time * fall_speed * speed_mod; 
    uv *= scale;
    
    vec2 id = floor(uv);
    vec2 gv = fract(uv) - 0.5;
    
    vec2 rand_pos = vec2(rand(id), rand(id + vec2(3.14, 1.59))) * 0.8 - 0.4;
    float dist = length(gv - rand_pos);
    float random_size = rand(id + vec2(7.1, 9.3));
    float mask = step(sparsity * 0.1, random_size); 

    float size = 0.05 * size_mod * random_size;
    float circle = smoothstep(size, size * 0.5, dist);
    
    // --- ZANIKANIE ---
    if (fade_mode > 0.5) {
        // TRYB WYPAROWYWANIA (dla bliskiej warstwy)
        float cycle = sin(time * 0.7 + rand(id) * 15.0);
        float evaporation = smoothstep(-0.6, 0.6, cycle);
        circle *= evaporation;
    } else {
        // TRYB STANDARDOWY (dla tła)
        float twinkle = sin(time * 2.5 + rand(id)*10.0) * 0.35 + 0.65;
        circle *= twinkle;
    }
    // -----------------

    return circle * mask;
}

void fragment() {
    vec2 uv = UV;
    float aspect = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
    uv.x *= aspect;
    
    float final_mask = 0.0;
    float t = TIME;
    
    // --- WARSTWY ---
    
    // 1. Daleko
    final_mask += make_layer(uv, 40.0, 0.5, 0.8, t, 1.0, 0.0);
    
    // 2. Średnio
    final_mask += make_layer(uv, 25.0, 1.0, 1.0, t, 3.0, 0.0) * 1.2;
    
    // 3. Blisko (JESZCZE MNIEJSZE)
    // Zmieniłem 4. parametr na 0.8 (było 1.5)
    float close_layer = make_layer(uv, 10.0, 2.0, 0.8, t, 6.0, 1.0);
    final_mask += close_layer * 1.5;

    vec3 col = flake_color.rgb * final_mask;
    COLOR = vec4(col, final_mask);
}