extends Control

@onready var progress_bar = $ProgressBar # Upewnij się, że nazwa w drzewku to ProgressBar!

func _ready():
	if GlobalLoader.target_scene_path == "":
		print("nie podales sciezki")
		return
	ResourceLoader.load_threaded_request(GlobalLoader.target_scene_path)

func _process(_delta):
	var progress = []
	var status = ResourceLoader.load_threaded_get_status(GlobalLoader.target_scene_path, progress)
	
	if progress.size() > 0:
		progress_bar.value = progress[0] * 100
		# DEBUG: wypisuj status w konsoli
		print("Status: ", status, " Progress: ", progress[0])
	
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		print("PRZEŁĄCZAM!") # Sprawdź czy to się wyświetla
		var res = ResourceLoader.load_threaded_get(GlobalLoader.target_scene_path)
		if res:
			get_tree().change_scene_to_packed(res)
		else:
			print("ResourceLoader zwrócił null!")
