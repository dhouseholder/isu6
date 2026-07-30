extends VBoxContainer

func _ready() -> void:
	var delay = 0.0
	
	for button in get_children():
		if button is Button or Label:
			button.modulate.a = 0.0
			
			var tween = create_tween()
			# Delay the start of this specific button's fade
			tween.tween_property(button, "modulate:a", 1.0, 6.5)\
				.set_delay(delay)\
				.set_trans(Tween.TRANS_SINE)
				
			# Increase delay for the next button in line
			delay += 5.0 
