extends CanvasLayer

func _ready():
	get_tree().paused = !get_tree().paused

func _input(event):
	if Input.is_key_pressed(KEY_P):
		get_tree().paused = !get_tree().paused