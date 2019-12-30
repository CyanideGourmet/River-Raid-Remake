extends KinematicBody2D

export var velocity = 300

var movement = Vector2()

signal dead

func _ready():
	set_collision_mask_bit(-20, 1)
	set_collision_mask_bit(0, 1)
	connect("dead", get_parent(), "_shoot")

func _physics_process(delta):
	var collision = move_and_collide(movement*velocity*delta)
	if collision:
		if collision.collider.is_in_group("player"):
			collision.collider._dead()
			_death()
		elif collision.collider.is_in_group("terrain"):
			_death()

func _death():
	emit_signal("dead")
	queue_free()