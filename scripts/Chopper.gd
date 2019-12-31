extends KinematicBody2D

export var movement_speed = 200
export var point_value = 60

var player_node
var direction = 0
var full_stop = 0
var explosion = preload("res://scenes/Chopper_Explosion.tscn")

signal destroyed
signal left_the_screen

func _ready():
	$Body/Rotor/AnimationPlayer.play()
	
	#player
	set_collision_layer_bit(1, 1)
	$PlayerDetectionArea.set_collision_layer_bit(1, 1)
	#bullet
	set_collision_layer_bit(-1, 1)
	#terrain
	set_collision_mask_bit(0, 1)
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
	if collision && collision.collider:
		if collision.collider.is_in_group("terrain"):
			direction *= -1
			#$Body.flip_v = !$Body.flip_v
			rotation_degrees += 180.0
		if collision.collider.is_in_group("PlayerBullet"):	
			_death()

func _death():
	#death animation
	if (explosion):
		var explosionInstance = explosion.instance()
		get_parent().get_parent().get_parent().add_child(explosionInstance)
		
		explosionInstance._init_explosion(movement_speed * direction , global_position, direction)
		explosionInstance.scale = Vector2 (direction, direction) #Vector2.ONE * direction
		
	emit_signal("destroyed", self)
	queue_free()

func _left_the_screen():
	emit_signal("left_the_screen", self)
	queue_free()

func _on_PlayerDetectionArea_body_entered(body):
	if body == player_node:
		full_stop = 1
		$PlayerDetectionArea.queue_free()
