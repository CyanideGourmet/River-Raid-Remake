extends "res://scripts/Classes/Destructible.gd"

var BulletScene = preload("res://scenes/EnemyBullet.tscn")

func _ready():
	explosion = preload("res://scenes/Chopper_Explosion.tscn")
	point_value = 150
	movement_speed = 200
	$Body/Rotor/AnimationPlayer.play("Rotor")
	#player
	set_collision_layer_bit(6, 1)
	$PlayerDetectionArea.set_collision_layer_bit(6, 1)
	#bullet
	set_collision_layer_bit(-6, 1)
	#terrain
	set_collision_mask_bit(0, 1)
	_reload()

func _physics_process(delta):
	velocity = Vector2(direction, 0) * full_stop

func _on_PlayerDetectionArea_body_entered(body):
	if body == player_node:
		full_stop = 1
		$PlayerDetectionArea.queue_free()

func _reload():
	var bullet = BulletScene.instance()
	add_child(bullet)
