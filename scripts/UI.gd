extends CanvasLayer

func _ready():
	get_tree().paused = true

func _input(event):
	if event.is_pressed() and get_tree().paused:
		get_tree().paused = false