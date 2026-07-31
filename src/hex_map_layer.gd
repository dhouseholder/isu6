extends TileMapLayer

var shader_material: ShaderMaterial
var last_hovered_tile: Vector2i = Vector2i(-1, -1)

func _ready() -> void:
	# Extract the assigned material from the node
	if material is ShaderMaterial:
		shader_material = material as ShaderMaterial
		
		# Pro-tip: Dynamically calculate half-size from your active TileSet configuration
		#var half_size: Vector2 = Vector2(tile_set.tile_size) / 2.0
		#shader_material.set_shader_parameter("tile_half_size", half_size)
	else:
		push_error("Please assign a ShaderMaterial to this TileMapLayer node!")

func _process(_delta: float) -> void:
	if not shader_material:
		return
		
	var mouse_pos: Vector2 = get_global_mouse_position()
	var current_tile: Vector2i = local_to_map(mouse_pos)
	
	# Only update shader variables if the mouse actually changed tile cells
	if current_tile != last_hovered_tile:
		# Get the exact center coordinate of the tile in world space
		var tile_world_center: Vector2 = map_to_local(current_tile)
		print("Current tile", current_tile)
		# Send the updated world position vector straight into the shader
		shader_material.set_shader_parameter("hovered_tile_world_pos", tile_world_center)
		
		last_hovered_tile = current_tile
