extends "res://scripts/Classes/Ammunition.gd"

func _ready():
	add_to_group("PlayerBullet")
	collision_mask_bits = [-1,     -2,     -3,     -4,     -5,     -6,     -10,     -100]
#                          Chopper Fuel    Plane   Heavy   Ship    Shooter Bridge   Terrain
	_set_collision()
	collision_group_names = ["enemy"]
	#speed = 1000
	#bullet_range = 800
	velocity = Vector2(0, -1)