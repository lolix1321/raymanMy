shader_type canvas_item;

uniform float speed = 0.5;        // Jak szybko falują
uniform float amplitude = 10.0;   // Jak mocno (góra/dół w pikselach)
uniform float frequency = 0.002;  // Jak gęsta jest fala (kluczowe dla jednego obrazka!)

void vertex() {
    // VERTEX.x to pozycja pozioma każdego punktu obrazka.
    // Dodajemy ją do czasu w funkcji sinus.
    // Dzięki temu lewa strona obrazka jest w innej fazie ruchu niż prawa.

    float wave = sin(TIME * speed + VERTEX.x * frequency);

    // Przesuwamy punkt w górę/dół
    VERTEX.y += wave * amplitude;
}