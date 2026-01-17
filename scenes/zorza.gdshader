shader_type canvas_item;

uniform vec4 color_top : source_color = vec4(0.0, 1.0, 0.8, 0.5); // Turkus/Zieleń
uniform vec4 color_bottom : source_color = vec4(0.5, 0.0, 1.0, 0.0); // Fiolet/Przezroczysty
uniform float speed : hint_range(0.1, 5.0) = 0.5;
uniform float frequency : hint_range(0.1, 10.0) = 2.0;
uniform float amplitude : hint_range(0.0, 1.0) = 0.2;

void fragment() {
    vec2 uv = UV;
    
    // Tworzymy falowanie na podstawie czasu i pozycji X
    float wave = sin(uv.x * frequency + TIME * speed) * amplitude;
    wave += sin(uv.x * frequency * 2.0 + TIME * speed * 1.5) * (amplitude * 0.5);
    
    // Zniekształcamy UV.y, aby góra "tańczyła"
    float mask = smoothstep(0.4 + wave, 0.8 + wave, uv.y);
    
    // Miksujemy kolory
    vec4 final_color = mix(color_top, color_bottom, uv.y);
    
    // Nakładamy maskę, żeby dół był przezroczysty, a góra falowała
    COLOR = vec4(final_color.rgb, final_color.a * (1.0 - mask));
}