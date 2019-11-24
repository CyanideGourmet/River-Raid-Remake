extends Area2D

export var level_size = 6895

func _ready():
	$Sectors.connect("_crashed", self, "_on_crashed")

func _on_MapSlice2_body_exited(body):
	if body == get_parent().find_node("Player"):
		position.y -= 2 * level_size

func _on_crashed(body):
	print("a")
	var player_node = get_parent().find_node("Player")
	if body == player_node:
		player_node.fuel = 0