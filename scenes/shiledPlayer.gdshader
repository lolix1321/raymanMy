shader_type canvas_item;

// Ten parametr będziemy zmieniać, gdy tarcza jest aktywna
uniform float whiteness : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    vec3 white = vec3(1.0, 1.0, 1.0);

    // Mix miesza oryginalny kolor z białym na podstawie suwaka whiteness
    COLOR.rgb = mix(tex_color.rgb, white, whiteness * tex_color.a);
    COLOR.a = tex_color.a;
}