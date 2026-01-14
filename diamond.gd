extends Area2D

@onready var start_y: float = position.y
var collected: bool = false

func _ready() -> void:
	add_to_group("Collectibles")
	
	# KLUCZOWY MOMENT:
	# Sprawdzamy, czy mój adres (ścieżka w drzewie) jest na liście zapisanych w Globalu
	var my_path = str(get_path())
	
	if my_path in Global.permanent_collected_list:
		# Jeśli jestem na liście, to znaczy, że byłem zebrany i zapisany. Znikam.
		queue_free()
		return

func _process(_delta: float) -> void:
	# Prosta animacja tylko jeśli istnieje i nie zebrany
	if not collected:
		position.y = start_y + sin(Time.get_ticks_msec() / 300.0) * 10

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not collected:
		collect()

func collect():
	collected = true
	visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	
	# Wysyłamy do Globala mój ADRES (ścieżkę), żeby wiedział kogo skreślić
	Global.add_diamond(str(get_path()))

# UWAGA: Usunąłem funkcje 'reset_diamond', 'make_permanent' itp.
# Są już NIEPOTRZEBNE, bo reload sceny robi całą robotę za nas.
