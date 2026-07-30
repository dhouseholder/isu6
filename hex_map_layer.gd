

# Called when the node enters the scene tree for the first time.
extends TileMapLayer

# Optional configuration to adjust label layout
@export var font_size: int = 12
@export var text_color: Color = Color.WHITE
func remove_myself():
	set_script(null) 
	
func _ready() -> void:
	# DISABLED BY ME
	process_mode = Node.PROCESS_MODE_DISABLED
	if process_mode == Node.PROCESS_MODE_DISABLED:
		return 
	# Force the node to redraw whenever it loads or updates
	queue_redraw()

func _draw() -> void:
	# DISABLED BY ME
	process_mode = Node.PROCESS_MODE_DISABLED
	if process_mode == Node.PROCESS_MODE_DISABLED:
		return 
	# 1. Fetch the default engine font for drawing text
	var default_font: Font = ThemeDB.get_fallback_font()
	
	# 2. Loop through every active tile coordinate in the layer
	for cell_coord in get_used_cells():
		# 3. Convert the cell's grid coordinates to local pixel position
		var local_pos: Vector2 = map_to_local(cell_coord)
		
		# 4. Format the Vector2i coordinate into a text string
		var coord_text: String = str(cell_coord)
		
		# 5. Dynamically center the text over the middle of the tile
		var text_size: Vector2 = default_font.get_string_size(coord_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		var center_offset: Vector2 = Vector2(-text_size.x / 2.0, text_size.y / 4.0)
		var final_text_pos: Vector2 = local_pos + center_offset
		
		# 6. Paint the coordinate text directly onto the window canvas
		draw_string(default_font, final_text_pos, coord_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, text_color)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# DISABLED BY ME
	process_mode = Node.PROCESS_MODE_DISABLED
	if process_mode == Node.PROCESS_MODE_DISABLED:
		return 
	pass
