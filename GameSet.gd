extends Node

# Ta funkcja sprawdza co klatkę rozmiar okna.
# Jak gracz spróbuje je zmniejszyć poniżej limitu, gra natychmiast je powiększy.
func _process(_delta: float) -> void:
	var size = DisplayServer.window_get_size()
	var target_size = size
	var need_fix = false
	
	if size.x < 960:
		target_size.x = 960
		need_fix = true
		
	if size.y < 540:
		target_size.y = 540
		need_fix = true
		
	if need_fix:
		DisplayServer.window_set_size(target_size)
