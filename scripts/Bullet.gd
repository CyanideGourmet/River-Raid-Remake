extends KinematicBody2D

export var bullet_distance = 800
export var velocity = 1000

var starting_position
signal bullet_freed

func _ready():
	starting_position = position

func _physics_process(delta):
	if abs(position.y) - abs(starting_position.y) > bullet_distance:
		emit_signal("bullet_freed")
		queue_free()
	var collision = move_and_collide(Vector2(0, -velocity) * delta)
	if collision:
		if collision.collider.is_in_group("terrain"):
			emit_signal("bullet_freed")
			queue_free()

func _on_Bullet_body_entered(body):
	emit_signal("bullet_freed")
	queue_free()
