extends "res://scripts/Classes/Ammunition.gd"

export var explosion_length = 1

func _ready():
	add_to_group("TankBullet")
	speed = 500
	velocity = Vector2(get_parent().direction, 0)

func _physics_process(delta):
	var distance = sqrt(pow(position.x, 2)+pow(position.y, 2))
	if distance >= bullet_range*5:
		_explode()
	if velocity.x < 0:
		velocity.x += 0.0023
	if velocity.x > 0:
		velocity.x -= 0.0023
	if $ExplosionArea/Explosion.frame == 7:
		_reload()

func _explode():
	velocity = Vector2(0, 0)
	$Body.hide()
	$ExplosionArea/Explosion.speed_scale = 8/explosion_length
	$ExplosionArea/Explosion.show()
	$ExplosionArea/Explosion.play()
	$ExplosionArea.set_collision_layer_bit(-21, 1)

func _kill(node):
	if node.is_in_group("player") or node.is_in_group("enemy"):
		node.call_deferred("_death")