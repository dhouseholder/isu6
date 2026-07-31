extends Node

func _ready():
	var layer_path = "/root/World/hex_map_layer"  # use the printed path you already have
	var layer = get_node_or_null(layer_path)
	if layer == null:
		print("TileMapLayer not found at", layer_path)
		return
	print("Inspecting children of", layer_path)
	for child in layer.get_children():
		print(" child:", child.get_path(), "class:", child.get_class())
		if child.has_method("get_tileset") or "tile_set" in child:
			print("  -> Drawing node candidate:", child.get_path(), "class:", child.get_class())
