extends Area2D

export var movement_speed = 400
export var forward_speed = 400
var screen_size

func _ready():
	screen_size = get_viewport_rect().size

func _process(delta):
	var velocity = Vector2()
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	velocity.y -= 1
	if velocity.length() > 0:
		velocity = velocity.normalized()
		velocity.x *= movement_speed
		velocity.y *= forward_speed
	position += velocity * delta