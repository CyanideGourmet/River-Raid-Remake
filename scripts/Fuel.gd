extends Area2D

export var point_value = 60

signal fuel
signal destroyed
var player_node

func _ready():
	#player
	set_collision_layer_bit(2, 1)
	#bullet
	set_collision_layer_bit(-2, 1)
	player_node = get_parent().get_parent().find_node("Player")
	connect("body_entered", self, "_fuel")
	connect("body_exited", self, "_fuel")
	connect("fuel", player_node, "_fuel")
	connect("destroyed", player_node, "_hit_a_node")
	connect("destroyed", get_parent(), "_node_destroyed")

func _fuel(body):
	if body == player_node:
		emit_signal("fuel")
	elif body.is_in_group("PlayerBullet"):
		body._reload()
		_death()

func _death():
	#death animation
	emit_signal("destroyed", self)
	queue_free()