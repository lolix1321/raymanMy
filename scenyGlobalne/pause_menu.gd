extends Control
var cr = "nic"
func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	self.hide()
	
	self.mouse_filter = Control.MOUSE_FILTER_IGNORE
func pause():
	get_tree().paused = true
	$AnimationPlayer.play("blur")
	self.show()
	self.mouse_filter = Control.MOUSE_FILTER_STOP


func testEsc():
	if Input.is_action_just_pressed("esc") and get_tree().paused == false:
		$PanelContainer/kontenerMENU.visible = true
		$PanelContainer/kontenerAREUSURE.visible = false
		print("odpalonmo setingsy")
		pause()
	elif Input.is_action_just_pressed("esc") and get_tree().paused == true:
		print("powrot")
		
		resume()


func _on_resume_pressed() -> void:
	resume()


func _on_settings_pressed() -> void:
	resume()


func _on_reset_pressed() -> void:
	cr="reset"
	areusureShow()
	
	


func _on_lobby_pressed() -> void:
	cr="lobby"
	areusureShow()
	

	
	
func _on_quit_pressed() -> void:
	cr = "quit"
	areusureShow()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	$AnimationPlayer.play("RESET")
	$PanelContainer/kontenerMENU.visible = true
	$PanelContainer/kontenerAREUSURE.visible = false
	
	
func _process(_delta: float) -> void:
	testEsc()



func _on_yes_pressed() -> void:
	if cr=="quit":
		get_tree().quit()
		cr = "nic"
	elif cr == "lobby":
		resume()
		cr = "nic"
		get_tree().change_scene_to_file("res://scenes/level.tscn")
	elif cr == "reset":
		resume()
		cr = "nic"
		get_tree().reload_current_scene()
		
	


func _on_no_pressed() -> void:
	resume()


func areusureShow():
	$PanelContainer/kontenerMENU.visible = false
	$PanelContainer/kontenerAREUSURE.visible = true

	
