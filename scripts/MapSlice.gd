extends Area2D

export var level_size = 6895

func _on_MapSlice_body_exited(body):
	if body == get_parent().find_node("Player"):
		position.y -= 2 * level_size