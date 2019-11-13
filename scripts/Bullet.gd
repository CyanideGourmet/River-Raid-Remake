extends KinematicBody2D

var velocity = Vector2(0, -1000)
var starting_position
signal bullet_freed

func _ready():
	position.y -= 64
	starting_position = position

func _physics_process(delta):
	if abs(position.y) - abs(starting_position.y) > 500:
		emit_signal("bullet_freed")
		queue_free()
	position += velocity * delta

func _on_Bullet_body_entered(body):
	emit_signal("bullet_freed")
	queue_free()
