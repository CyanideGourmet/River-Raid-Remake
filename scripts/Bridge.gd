 extends StaticBody2D

export var point_value = 500

var player_node
var tankstate = false
var tankcase = 0

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
	player_node = get_parent().get_parent().get_parent().get_parent().get_node("Player")
	connect("destroyed", player_node, "_hit_a_node")
	connect("level_finished", player_node, "_current_mapslice_changed")

func _tankstate(node):
	tankstate = !tankstate
	tankcase += 1

func _death():
	#death animation
	if tankstate:
		get_parent().get_parent().get_parent().RoadTank.call_deferred("_death")
	elif tankcase == 2:
		get_parent().get_parent().get_parent().RoadTank.full_stop = 0
	elif tankcase == 0:
		var Shoot = get_parent().get_parent().get_parent().TankScene.instance()
		get_parent().get_parent().get_parent().add_child(Shoot)
		Shoot.transform = get_parent().get_parent().get_parent().RoadTank.transform
		Shoot.direction = get_parent().get_parent().get_parent().RoadTank.direction
		get_parent().get_parent().get_parent().RoadTank.call_deferred("_clear")
		Shoot._reload()
	emit_signal("level_finished", get_parent().get_parent().get_parent())
	emit_signal("destroyed", self)
	queue_free()