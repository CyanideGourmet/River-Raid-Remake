extends Area2D

export var point_value = 80

signal fuel
signal destroyed
signal clear_node

var player_node

func _ready():
	#player
	set_collision_layer_bit(2, 1)
	#bullet
	set_collision_layer_bit(-2, 1)
	player_node = get_parent().get_parent().find_node("Player")
	connect("body_entered", self, "_fuel_entered")
	connect("body_exited", self, "_fuel_exited")
	connect("fuel", player_node, "_fuel")
	connect("destroyed", player_node, "_hit_a_node")
	connect("destroyed", get_parent(), "_node_destroyed")
	connect("clear_node", get_parent(), "_node_destroyed")

func _fuel_entered(body):
	if body == player_node:
		emit_signal("fuel")
	elif body.is_in_group("PlayerBullet"):
		body._reload()
		_death()

func _fuel_exited(body):
	if body == player_node:
		emit_signal("fuel")

func _death():
	#death animation
	emit_signal("destroyed", self)
	queue_free()

func _clear():
	emit_signal("clear_node", self)
	queue_free()