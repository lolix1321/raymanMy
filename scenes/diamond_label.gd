extends Label
var maxDiamenty = 25
func _ready() -> void:
	wyswietlijDiamenty() 

func _on_diamonds_updated(new_amount):
	text = "Diamonds: " + str(new_amount) + "/" + str(maxDiamenty)

func wyswietlijDiamenty():
   
	var current_total = Global.permanent_diamonds + Global.temporary_diamonds
	text = "Diamonds: " + str(current_total) + "/" + str(maxDiamenty)
	
   
	if not Global.diamonds_updated.is_connected(_on_diamonds_updated):
		Global.diamonds_updated.connect(_on_diamonds_updated)
