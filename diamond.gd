extends Area2D

@onready var start_y: float = position.y
var collected: bool = false

func _ready() -> void:
	add_to_group("Collectibles")

func _process(_delta: float) -> void:
	if not collected:
		position.y = start_y + sin(Time.get_ticks_msec() / 300.0) * 10

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not collected:
		collect()

func collect():
	collected = true
	visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	Global.add_diamond()

func reset_diamond():
	if collected:
		collected = false
		visible = true
		$CollisionShape2D.set_deferred("disabled", false)
	
