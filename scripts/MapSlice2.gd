extends Area2D

export var level_size = 6895

func _on_MapSlice2_body_exited(body):
	if body == get_tree().get_root().get_node("Main").find_node("Player"):
		position.y -= 2 * level_size