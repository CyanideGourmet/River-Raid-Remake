extends "res://scripts/Classes/Ammunition.gd"

func _ready():
	add_to_group("EnemyBullet")
	collision_mask_bits = [-20, 0]
	_set_collision()
	collision_group_names = ["player"]
	speed = 500
	bullet_range = 50000
	velocity.x = get_parent().direction
	position.x += get_parent().direction*50