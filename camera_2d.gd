extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = get_parent().get_node("Player").global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
@export var camera_speed := 8.0
func _process(delta):
	global_position = global_position.lerp(
		get_parent().get_node("Player").global_position,
		delta * camera_speed
	)
func _input(event):
	if event.is_action_pressed("zoom_in"):
		zoom *= 0.9
	elif event.is_action_pressed("zoom_out"):
		zoom *= 1.1
