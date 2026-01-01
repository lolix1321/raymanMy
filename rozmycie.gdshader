shader_type canvas_item;

// Te zmienne pojawią się w inspektorze w sekcji "Shader Parameters"
uniform float inner_radius : hint_range(0.0, 1.0) = 0.0;
uniform float outer_radius : hint_range(0.0, 2.0) = 1.0;
uniform vec4 vignette_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
    // Obliczamy dystans od środka ekranu (0.5, 0.5)
    float dist = distance(UV, vec2(0.5));
    
    // Tworzymy płynne przejście między wewnętrznym a zewnętrznym promieniem
    float vignette = smoothstep(inner_radius, outer_radius, dist);
    
    // Nakładamy kolor winiety z obliczoną przezroczystością
    COLOR = vec4(vignette_color.rgb, vignette * vignette_color.a);
}