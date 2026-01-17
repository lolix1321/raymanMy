shader_type canvas_item;

uniform vec4 fog_color : source_color = vec4(0.3, 0.0, 0.5, 1.0); // Kolor tła/zorzy
uniform float fog_height : hint_range(0.0, 1.0) = 0.5; // Jak wysoko sięga mgła
uniform float intensity : hint_range(0.0, 1.0) = 0.8;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	
	// Obliczamy mgłę bazując na wysokości (UV.y im bliżej 1.0 tym niżej na ekranie)
	// smoothstep sprawia, że przejście jest miękkie
	float fog_amount = smoothstep(1.0 - fog_height, 1.0, UV.y);
	
	// Mieszamy oryginalny kolor góry z kolorem mgły
	COLOR = mix(tex_color, fog_color, fog_amount * intensity);
	
	// Zachowujemy oryginalną przezroczystość (żeby nie zrobiło się tło tam gdzie góry nie ma)
	COLOR.a = tex_color.a;
}