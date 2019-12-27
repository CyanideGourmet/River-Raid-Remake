extends KinematicBody2D

export var bullet_distance = 800
export var velocity = 1000

var starting_position
signal bullet_freed

func _ready():
	#terrain
	set_collision_mask_bit(3, 1)
	set_collision_layer_bit(-4, 1)
	#chopper
	set_collision_mask_bit(4, 1)
	#fuel
	set_collision_mask_bit(5, 1)
	starting_position = position

func _process(delta):
	if abs(position.y) - abs(starting_position.y) > bullet_distance:
		_death()

func _physics_process(delta):
	var collision = move_and_collide(Vector2(0, -velocity) * delta)
	if collision:
		if collision.collider.is_in_group("enemy"):
			collision.collider._death()
		_death()

func _death():
	emit_signal("bullet_freed")
	queue_free()
