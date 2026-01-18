extends Camera2D

@export var decay := 0.8  
@export var max_offset := Vector2(100, 75)  
@export var max_roll := 0.1  

#SKALOWANIE 
const TARGET_VISIBLE_WIDTH = 463.0 

const TARGET_VISIBLE_HEIGHT = 230.0


var base_offset := Vector2.ZERO
var trauma := 0.0  
var trauma_power := 2  
var is_shaking := false

func _ready():
	base_offset = offset
	make_current()

func _process(delta):
	# LOGIKA SKALOWANIA
	var screen_size = get_viewport_rect().size
	

	var zoom_width = screen_size.x / TARGET_VISIBLE_WIDTH
	var zoom_height = screen_size.y / TARGET_VISIBLE_HEIGHT
	
	var final_zoom = max(zoom_width, zoom_height)
	
	zoom = Vector2(final_zoom, final_zoom)

	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()
	elif offset != base_offset:
		offset = base_offset
		rotation = 0

func shake():
	var amount = pow(trauma, trauma_power)
	rotation = max_roll * amount * randf_range(-1, 1)
	offset.x = base_offset.x + max_offset.x * amount * randf_range(-1, 1)
	offset.y = base_offset.y + max_offset.y * amount * randf_range(-1, 1)

func add_trauma(amount: float):
	if is_shaking: return
	trauma = min(trauma + amount, 1.0)
	is_shaking = true
	await get_tree().create_timer(0.3).timeout
	is_shaking = false
