 extends StaticBody2D

export var point_value = 500

var player_node

var tankstate = false

var explosion = preload("res://scenes/BridgeExplosion.tscn")
signal destroyed
signal level_finished

func _ready():
	#player
	set_collision_layer_bit(10, 1)
	#bullet
	set_collision_layer_bit(-10, 1)
	#roadtank
	$RoadTankDetection.set_collision_layer_bit(1, 1)
	#terrain
	get_parent().get_parent().set_collision_layer_bit(0, 1)
	player_node = get_parent().get_parent().get_parent().find_node("Player")
	#player_node = get_tree().root.find_node("Player")
	
		
	connect("destroyed", player_node, "_hit_a_node")
	connect("level_finished", player_node, "_current_mapslice_changed")

func _tankstate(node):
	print("a")
	tankstate = !tankstate

func _death():
	#death animation
	if (explosion):
		var explosionInstance = explosion.instance()
		get_parent().get_parent().get_parent().add_child(explosionInstance)
		explosionInstance._set_position(global_position)
	
	if tankstate:
		get_parent().get_parent().get_parent().RoadTank.call_deferred("_death")
	else:
		get_parent().get_parent().get_parent().RoadTank.full_stop = 0
	emit_signal("level_finished", get_parent().get_parent().get_parent())

	emit_signal("destroyed", self)
	
	#if player_node:	
	#	player_node._increment_level()	
	
	queue_free()