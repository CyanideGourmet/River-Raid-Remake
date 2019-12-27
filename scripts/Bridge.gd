extends StaticBody2D

export var point_value = 500

var player_node

signal destroyed
signal level_finished

func _ready():
	#player
	set_collision_layer_bit(10, 1)
	#bullet
	set_collision_layer_bit(-10, 1)
	#terrain
	get_parent().get_parent().set_collision_layer_bit(0, 1)
	player_node = get_parent().get_parent().get_parent().get_parent().get_node("Player")
	connect("destroyed", player_node, "_hit_a_node")
	connect("level_finished", player_node, "_current_mapslice_changed")

func _death():
	#death animation
	emit_signal("level_finished", get_parent().get_parent().get_parent())
	emit_signal("destroyed", self)
	queue_free()