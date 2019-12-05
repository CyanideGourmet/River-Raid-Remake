extends KinematicBody2D

export var movement_speed = 400
export var def_forward_speed = 200
export var max_forward_speed = 400
export var min_forward_speed = 50
export var acceleration_speed = 20
export var fuel_decrease_rate = 0.1

var camera_pos
var ammo = 1
var Bullet = preload("res://scenes/Bullet.tscn")
var fuel = 100
var acceleration_dir = 0
var forward_speed = def_forward_speed
var full_stop = 1

func _ready():
	camera_pos = $Camera.position
	$Label.text = str(fuel)

func get_input():
	var velocity = Vector2()
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_up"):
		acceleration_dir = 1
	elif Input.is_action_pressed("ui_down"):
		acceleration_dir = -1
	else:
		if forward_speed > def_forward_speed:
			acceleration_dir = -1
		elif forward_speed < def_forward_speed:
			acceleration_dir = 1
		else:
			acceleration_dir = 0
	return velocity

func _physics_process(delta):
	if fuel <= 0:
		movement_speed = 0
		forward_speed = 0
		max_forward_speed = 0
		min_forward_speed = 0
		acceleration_speed = 0
	var velocity = (get_input() + Vector2(0, -1))*full_stop
	if Input.is_action_just_pressed("ui_select") and ammo > 0:
		var bullet = Bullet.instance()
		add_child(bullet)
		bullet.connect("bullet_freed", self, "_on_bullet_freed")
		ammo -= 1
	forward_speed += acceleration_speed * acceleration_dir
	forward_speed = clamp(forward_speed, min_forward_speed, max_forward_speed)
	velocity.x *= movement_speed
	velocity.y *= forward_speed
	var collision = move_and_collide(velocity * delta)
	if collision:
		if collision.collider.is_in_group("terrain"):
			_dead(collision.collider)
	position.x = clamp(position.x, camera_pos.x, camera_pos.x + $Camera.get_viewport_rect().size.x)
	fuel -= fuel_decrease_rate
	fuel = clamp(fuel, 0, 100)
	$Label.text = str(fuel)

func _dead(node):
	position = node.position + Vector2(960, 8500)
	full_stop = 0
	yield(get_tree().create_timer(1), "timeout")
	full_stop = 1

func _on_bullet_freed():
	ammo += 1