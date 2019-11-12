extends KinematicBody2D

export var movement_speed = 400
export var forward_speed = 400
export var max_forward_speed = 800
export var min_forward_speed = 150
export var acceleration_speed = 20
var camera_pos

func _ready():
	camera_pos = $Camera.position

func _physics_process(delta):
	var velocity = Vector2()
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_up") and forward_speed < max_forward_speed:
		forward_speed += acceleration_speed
	if Input.is_action_pressed("ui_down") and forward_speed > min_forward_speed:
		forward_speed -= acceleration_speed
	velocity.y -= 1
	if velocity.length() > 0:
		velocity = velocity.normalized()
		velocity.x *= movement_speed
		velocity.y *= forward_speed
	position += velocity * delta
	position.x = clamp(position.x, camera_pos.x, camera_pos.x + 1280)