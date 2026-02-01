shader_type canvas_item;

// brightness: jak mocno wybielić gracza pod spodem
uniform float brightness : hint_range(0.0, 2.0) = 0.5;
// opacity: jak bardzo widoczna ma być sama tarcza (1.0 = całkowicie wyraźna)
uniform float opacity : hint_range(0.0, 1.0) = 0.9;

void fragment() {
    // Pobieramy oryginalny kolor Twojej grafiki
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Ustawiamy kolor końcowy na taki sam jak w Twoim pliku
    COLOR = tex_color;
    
    // ZMIANA OPACITY:
    // Mnożymy alfę Twojego pliku przez suwak opacity.
    // Jeśli w programie graficznym tarcza była półprzezroczysta, 
    // ustawienie opacity na 1.0 sprawi, że będzie tak wyraźna, jak ją narysowałeś.
    COLOR.a = tex_color.a * opacity;
    
    // Efekt wybielenia gracza (dodawanie jasności)
    COLOR.rgb += brightness * tex_color.a;
}