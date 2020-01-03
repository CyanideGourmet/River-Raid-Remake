extends "res://scripts/Classes/Destructible.gd"

var BulletScene = preload("res://scenes/EnemyBullet.tscn")

var explosion = preload("res://scenes/Chopper_Explosion.tscn")
func _ready():
	point_value = 150
	velocity = Vector2(0, 0)
	movement_speed = 0
	$Body/Rotor/AnimationPlayer.play("Rotor")
	#player
	set_collision_layer_bit(6, 1)
	#bullet
	set_collision_layer_bit(-6, 1)

func _reload():
	var bullet = BulletScene.instance()
	add_child(bullet)
