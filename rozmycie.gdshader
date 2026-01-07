shader_type canvas_item;
render_mode blend_mul; // Kluczowa zmiana: mnożenie kolorów

uniform float inner_radius : hint_range(0.0, 1.0) = 0.0;
uniform float outer_radius : hint_range(0.0, 2.0) = 1.0;
// Kolor powinien być ciemny (szary/czarny), aby "gasić" światło
uniform vec4 vignette_color : source_color = vec4(0.1, 0.1, 0.1, 1.0); 

void fragment() {
    float dist = distance(UV, vec2(0.5));
    
    // Odwracamy działanie smoothstep, aby środek był jasny (1.0), a brzegi ciemne
    float mask = 1.0 - smoothstep(inner_radius, outer_radius, dist);
    
    // Miksujemy kolor winiety z białym (biały w trybie multiply = przezroczysty)
    vec3 final_color = mix(vignette_color.rgb, vec3(1.0), mask);
    
    COLOR = vec4(final_color, 1.0);
}