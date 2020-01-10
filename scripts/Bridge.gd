 extends StaticBody2D

# warning-ignore:unused_class_variable
export var point_value = 500

var player_node

var tankstate = false

var explosion = preload("res://scenes/BridgeExplosion.tscn")
var tank_sprite = preload("res://assets/Images/Sprites/tank 02.png")

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
	player_node = get_parent().get_parent().get_parent().get_parent().find_node("Player")
	
	if (player_node):
		print ("Player Node found: %s"%player_node)
	else:
		print("Player Node not found!!!! Root: %s"%get_parent().get_parent().get_parent().get_parent())
		
# warning-ignore:return_value_discarded
	connect("destroyed", player_node, "_hit_a_node")
# warning-ignore:return_value_discarded
	connect("level_finished", player_node, "_current_mapslice_changed")

# warning-ignore:unused_argument
func _tankstate(node):
	tankstate = !tankstate
	tankcase += 1

func _death():
	#death animation
	if (explosion):
		var explosionInstance = explosion.instance()
		get_parent().get_parent().get_parent().add_child(explosionInstance)
		explosionInstance._set_position(global_position)
	
	if tankstate:
		get_parent().get_parent().get_parent().RoadTank.call_deferred("_death")
	if tankcase == 2:
		get_parent().get_parent().get_parent().RoadTank.full_stop = 0
	elif tankcase == 0:
		var Shoot = get_parent().get_parent().get_parent().TankScene.instance()
		get_parent().get_parent().get_parent().add_child(Shoot)
		get_parent().get_parent().get_parent().instanced_entities.append(Shoot)
		Shoot.transform = get_parent().get_parent().get_parent().RoadTank.transform
		Shoot.direction = get_parent().get_parent().get_parent().RoadTank.direction
		Shoot.set_texture(tank_sprite)
		get_parent().get_parent().get_parent().RoadTank.call_deferred("_clear")
	emit_signal("level_finished", get_parent().get_parent().get_parent())
	print ("Bridge emitted signal to %s"%get_parent().get_parent())
	emit_signal("destroyed", self)
	
	queue_free()