extends KinematicBody2D

export var speed = 100000000
export var bullet_range = 100000000
export var collision_mask_bits = []
export var collision_group_names = [] #no terrain

var velocity = Vector2(0, 0)
var starting_position
var collision

signal reload

func _ready():
	starting_position = position
	connect("reload", get_parent(), "_reload")

func _set_collision():
	for bit in collision_mask_bits:
		set_collision_mask_bit(bit, 1)

func _process(delta):
	if sqrt(pow(position.y - starting_position.y, 2)) >= bullet_range:
		_reload()

func _physics_process(delta):
	collision = move_and_collide(velocity * speed)
	if collision:
		if collision.collider.is_in_group("terrain"):
			_reload()
		for group_name in collision_group_names:
			if collision.collider.is_in_group(group_name):
				collision.collider.call_deferred("_death")
				_reload()

func _reload():
	emit_signal("reload")
	call_deferred("queue_free")