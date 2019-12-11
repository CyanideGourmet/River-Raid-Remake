extends KinematicBody2D

export var movement_speed = 100

var player_node
var direction = 0

signal destroyed
signal left_the_screen

func _ready():
	set_collision_layer_bit(1, 1)
	set_collision_layer_bit(4, 1)
	player_node = get_parent().get_parent().find_node("Player")
	connect("destroyed", player_node, "_hit_a_node")
	connect("destroyed", get_parent(), "_node_destroyed")
	connect("left_the_screen", get_parent(), "_node_destroyed")

func _process(delta):
	if position.x < 0 or position.x > 1950:
		_left_the_screen()

func _physics_process(delta):
	var velocity = Vector2(direction, 0) * movement_speed
	var collision = move_and_collide(velocity*delta)
	if collision:
		if collision.collider.is_in_group("PlayerBullet"):
			_death()

func _death():
	#death animation
	emit_signal("destroyed", self)
	queue_free()

func _left_the_screen():
	emit_signal("left_the_screen", self)
	queue_free()