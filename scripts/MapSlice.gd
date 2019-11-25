extends TileMap

export var level_size = 8704

func _ready():
	$Area.connect("body_exited", self, "_on_MapSlice_body_exited")

func _on_MapSlice_body_exited(body):
	yield(get_tree().create_timer(1), "timeout")
	if body == get_parent().find_node("Player"):
		position.y -= 2 * level_size