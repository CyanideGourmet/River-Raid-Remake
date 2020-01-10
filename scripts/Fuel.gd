extends Area2D
# warning-ignore:unused_class_variable
export var point_value = 80

var explosion = preload("res://scenes/FuelExplosion.tscn")
signal fuel
signal destroyed
signal clear_node

var player_node

func _ready():
	scale = Vector2(1.5, 1.5)
	#player
	set_collision_layer_bit(2, 1)
	#bullet
	set_collision_layer_bit(-2, 1)
	player_node = get_parent().get_parent().find_node("Player")
# warning-ignore:return_value_discarded
	connect("body_entered", self, "_fuel_entered")
# warning-ignore:return_value_discarded
	connect("body_exited", self, "_fuel_exited")
# warning-ignore:return_value_discarded
	connect("fuel", player_node, "_fuel")
# warning-ignore:return_value_discarded
	connect("destroyed", player_node, "_hit_a_node")
# warning-ignore:return_value_discarded
	connect("destroyed", get_parent(), "_node_destroyed")
# warning-ignore:return_value_discarded
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
	if (explosion):
		var explosionInstance = explosion.instance()
		get_parent().get_parent().get_parent().add_child(explosionInstance)
		explosionInstance._set_position(global_position)
	
	emit_signal("destroyed", self)
	queue_free()

func _clear():
	emit_signal("clear_node", self)
	queue_free()