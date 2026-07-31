extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var delay = 0.0
	
	for card in get_children():
		if card is TextureRect:
			card.modulate.a = 0.0
			
			var tween = create_tween()
			# Delay the start of this specific button's fade
			tween.tween_property(card, "modulate:a", 1.0, 1.5)\
				.set_delay(delay)\
				.set_trans(Tween.TRANS_SINE)
				
			# Increase delay for the next button in line
			delay += 1.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_button_pressed() -> void:
	# Switches to the main game scene
	get_tree().change_scene_to_file("res://world.tscn")

func _on_quit_button_pressed() -> void:
	# Closes the game application
	get_tree().quit()
