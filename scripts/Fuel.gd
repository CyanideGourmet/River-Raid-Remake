extends Area2D
var explosion = preload("res://scenes/FuelExplosion.tscn")
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
		_death()

func _death():
	#death animation
	if (explosion):
		print("Fuel exploded")
		var explosionInstance = explosion.instance()
		get_parent().get_parent().get_parent().add_child(explosionInstance)
		explosionInstance._set_position(global_position)
	else:
		print("NO EXPLOSION!")
	
	emit_signal("destroyed", self)
	queue_free()