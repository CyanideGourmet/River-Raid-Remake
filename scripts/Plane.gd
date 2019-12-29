extends KinematicBody2D

export var movement_speed = 400
export var point_value = 100

var player_node
var direction = 0
var full_stop = 0
var explosion = preload("res://scenes/JetExplosion.tscn")

signal destroyed
signal left_the_screen

func _ready():
	#player
	set_collision_layer_bit(3, 1)
	$PlayerDetectionArea.set_collision_layer_bit(3, 1)
	#bullet
	set_collision_layer_bit(-3, 1)
	player_node = get_parent().get_parent().find_node("Player")
	connect("destroyed", player_node, "_hit_a_node")
	connect("destroyed", get_parent(), "_node_destroyed")
	connect("left_the_screen", get_parent(), "_node_destroyed")

func _process(delta):
	if position.x < 0 or position.x > 1950:
		_left_the_screen()

func _physics_process(delta):
	var velocity = Vector2(direction, 0) * movement_speed * full_stop
	var collision = move_and_collide(velocity*delta)
	if collision:
		if collision.collider.is_in_group("PlayerBullet"):
			_death()

func _death():
	if (explosion):
		print("Jet exploded")
		var explosionInstance = explosion.instance()
		get_parent().get_parent().get_parent().add_child(explosionInstance)
		explosionInstance._init_explosion(movement_speed * direction, global_position)
	else:
		print("NO EXPLOSION!")
	#death animation
	emit_signal("destroyed", self)
	queue_free()

func _left_the_screen():
	emit_signal("left_the_screen", self)
	queue_free()

func _on_PlayerDetectionArea_body_entered(body):
	if body == player_node:
		full_stop = 1
		$PlayerDetectionArea.queue_free()