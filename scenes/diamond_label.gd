extends Label

func _ready() -> void:
	# Ustawiamy tekst na start
	text = "Diamonds: " + str(Global.diamonds) + "/25"
	
	# Łączymy się z sygnałem z global.gd
	Global.diamonds_updated.connect(_on_diamonds_updated)

func _on_diamonds_updated(new_amount):
	# Ta funkcja wykona się za każdym razem, gdy podniesiesz diament
	text = "Diamonds: " + str(new_amount) + "/25"
