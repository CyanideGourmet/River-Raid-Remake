extends StaticBody2D

export var point_value = 500

var player_node
var explosion = preload("res://scenes/BridgeExplosion.tscn")

signal destroyed
signal level_finished

func _ready():
	#player
	set_collision_layer_bit(10, 1)
	#bullet
	set_collision_layer_bit(-10, 1)
	#terrain
	get_parent().get_parent().set_collision_layer_bit(0, 1)
	#player_node = get_parent().get_parent().get_parent().get_parent().get_node("Player")
	yield(get_tree().create_timer(1),"script_changed")
	player_node = get_tree().root.get_node("Player")
	if (player_node):
		connect("destroyed", player_node, "_hit_a_node")
		connect("level_finished", player_node, "_current_mapslice_changed")

func _death():
	#death animation
	if (explosion):
		print("Bridge exploded")
		var explosionInstance = explosion.instance()
		get_parent().get_parent().get_parent().add_child(explosionInstance)
		explosionInstance._set_position(global_position)
	else:
		print("NO EXPLOSION!")
	emit_signal("level_finished", get_parent().get_parent().get_parent())
	emit_signal("destroyed", self)
	queue_free()