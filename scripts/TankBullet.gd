extends KinematicBody2D

var movement = Vector2()
var tank_position
var shot_range

signal dead

func _ready():
	connect("dead", get_parent(), "_shoot")

func _physics_process(delta):
	var distance = sqrt(pow(position.x, 2)+pow(position.y, 2))
	if distance >= shot_range*5:
		_explode()
	if movement.x < 0:
		movement.x += 1.15
	if $ExplosionArea/Explosion.frame == 7:
		_reload()
	move_and_collide(movement*delta)

func _explode():
	movement = Vector2(0, 0)
	$Body.hide()
	$ExplosionArea/Explosion.show()
	$ExplosionArea/Explosion.play()
	$ExplosionArea.set_collision_layer_bit(-21, 1)

func _kill(node):
	if node.is_in_group("player"):
		node.call_deferred("_dead")
	elif node.is_in_group("enemy"):
		node.call_deffered("_death")

func _reload():
	emit_signal("dead")
	queue_free()