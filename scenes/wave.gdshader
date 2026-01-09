shader_type canvas_item;

uniform float base_y : hint_range(0.0, 1.0) = 0.5;

uniform sampler2D waterNoise : hint_default_white;
uniform sampler2D waterDistortionNoise : hint_default_white;
uniform vec4 waterColor : source_color = vec4(0.069, 0.333, 0.58, 1.0);
uniform float colorCorection : hint_range(0.0, 1.0) = 0.0;

uniform float distortionForce : hint_range(0.0, 0.2) = 0.026;
uniform float WDBrightness : hint_range(0.0, 2.0) = 0.386;
uniform float WDFreq : hint_range(0.0, 1.0) = 0.39;
uniform float WDSize : hint_range(0.0, 2.0) = 2.0;
uniform float WDSpeed : hint_range(0.0, 10.0) = 3.658;
uniform vec2 tiling = vec2(1.164, 1.0);
uniform vec2 offSetSpeed = vec2(0.035, 0.01);

uniform float wave_frequency = 15.0;
uniform float wave_amplitude = 0.02; // Zmniejszone dla lepszego efektu
uniform float wave_speed = 3.0;

// Parametry płynących pasków
uniform float scanline_count = 400.0;
uniform float scanline_speed = 0.1;

void fragment() {
    vec2 uv = UV;

    // 1. Obliczanie falującej krawędzi wody
    float wave1 = sin(uv.x * wave_frequency + TIME * wave_speed);
    float wave2 = sin(uv.x * wave_frequency * 0.7 + TIME * wave_speed * 1.2);
    float combined_wave = (wave1 + wave2) * 0.5;
    float dynamic_water_level = base_y + (combined_wave * wave_amplitude);

    // 2. Distorted UV dla szumu wody
    vec2 noiseUV = uv * tiling + offSetSpeed * TIME;
    float noiseValue = texture(waterDistortionNoise, noiseUV).r;

    vec2 waterUV = uv * tiling;
    waterUV += offSetSpeed * TIME;
    waterUV += (noiseValue - 0.5) * distortionForce; // Poprawiona dystorsja
    
    vec4 noiseColor = texture(waterNoise, waterUV);
    float intensity = smoothstep(WDFreq, WDSize, noiseColor.r);
    vec3 addLight = intensity * vec3(WDBrightness);

    // 3. Kolor powierzchni wody
    vec4 water_surface_color = vec4(waterColor.rgb + addLight, 1.0);
    water_surface_color.rgb = mix(water_surface_color.rgb, waterColor.rgb, colorCorection);

    // 4. Płynące paski (tylko dla wody)
    float scanline_pos = uv.y * scanline_count - (TIME * scanline_speed * 100.0);
    float scanlines = sin(scanline_pos) * 0.05 + 0.95;
    water_surface_color.rgb *= scanlines;

    // 5. Maska wody (co jest pod linią fal, a co nad)
    // Używamy step lub smoothstep, aby oddzielić wodę od nieba
    float water_mask = step(dynamic_water_level, uv.y);

    // 6. Finalny kolor
    // Gdzie maska = 0 (góra), dajemy przezroczystość (vec4(0.0))
    // Gdzie maska = 1 (dół), dajemy kolor wody
    vec4 sky_color = vec4(0.0, 0.0, 0.0, 0.0);
    COLOR = mix(sky_color, water_surface_color, water_mask);
}