extends Node2D

## @onready var hex_map: TileMap = $HexMap
@onready var player: Node2D = $Player
@onready var hex_map_layer: TileMapLayer = $hex_map_layer

var current_hex:= Vector2i(10, 5)
var fuel:= 200

func _ready() -> void:
	#current_hex = Vector2i(10, 5)
	_update_player_position()


			
func _process(_delta: float) -> void:
	var move = Vector2i.ZERO

	# FLAT-TOP HEX MOVEMENT (axial q,r)
	# odd col
	
	if Input.is_action_just_pressed("move_northwest"):
		if current_hex.x % 2 != 0:move = Vector2i(-1, 0)
		else:move = Vector2i(-1, -1)
	elif Input.is_action_just_pressed("move_southwest"):
		if current_hex.x % 2 != 0:move = Vector2i(-1, 1)
		else:move = Vector2i(-1, 0)
	elif Input.is_action_just_pressed("move_northeast"):
		if current_hex.x % 2 != 0:move = Vector2i(1, 0)
		else:move = Vector2i(1, -1)
	elif Input.is_action_just_pressed("move_north"):
		move = Vector2i(0, -1)
	elif Input.is_action_just_pressed("move_southeast"):
		if current_hex.x % 2 != 0:move = Vector2i(1, 1)
		else:move = Vector2i(1, 0)
	elif Input.is_action_just_pressed("move_south"):
		move = Vector2i(0, 1)

	if move != Vector2i.ZERO:
		var target_hex = current_hex + move

		if _hex_exists(target_hex):
			current_hex = target_hex
			_update_player_position()

func _update_player_position() -> void:
	var local_pos: Vector2 = hex_map_layer.map_to_local(current_hex)
	var global_pos: Vector2 = hex_map_layer.to_global(local_pos)

## fuel costs
	var dice1 = randi_range(1,6)
	var dice2 = randi_range(1,6)
	fuel -= dice1 + dice2 - 1

	player.global_position = global_pos

func _hex_exists(hex_coord: Vector2i) -> bool:
	var source_id := hex_map_layer.get_cell_source_id(hex_coord)
	return source_id != -1
