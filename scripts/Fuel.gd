extends Area2D

signal fuel

func _ready():
	var player_node = get_parent().get_parent().find_node("Player")
	connect("body_entered", self, "_fuel")
	connect("body_exited", self, "_fuel")
	connect("fuel", player_node, "_fuel")

func _fuel(body):

	emit_signal("fuel")