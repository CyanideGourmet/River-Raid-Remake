extends StaticBody2D

export var point_value = 150

var player_node
var BulletScene = preload("res://scenes/EnemyBullet.tscn")

signal destroyed

func _ready():
	$Body/Rotor/AnimationPlayer.play("Rotor")
	#player
	set_collision_layer_bit(6, 1)
	#bullet
	set_collision_layer_bit(-6, 1)
	player_node = get_parent().get_parent().get_node("Player")
	connect("destroyed", player_node, "_hit_a_node")
	connect("destroyed", get_parent(), "_node_destroyed")
	_shoot()

func _shoot():
	var bullet = BulletScene.instance()
	bullet.movement = -transform.y.normalized()
	add_child(bullet)

func _death():
	#death animation
	emit_signal("destroyed", self)
	queue_free()