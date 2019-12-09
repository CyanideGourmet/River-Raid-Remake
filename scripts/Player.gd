extends KinematicBody2D

export var movement_speed = 400
export var def_forward_speed = 200
export var max_forward_speed = 400
export var min_forward_speed = 50
export var acceleration_speed = 20
export var fuel_decrease_rate = 0.1
export var fuel_refill_rate = 0.2

var camera_pos
var UI
var ammo = 1
var Bullet = preload("res://scenes/Bullet.tscn")
var fuel = 100
var acceleration_dir = 0
var forward_speed = def_forward_speed
var full_stop = 1
var current_mapslice
var refill = 0
var velocity
var sideways_velocity = Vector2(0, 0)

signal free_the_bullet

func _ready():
	camera_pos = $Camera.position
	UI = get_parent().get_node("UI").get_node("Fuel")
	UI.text = str(fuel)

func get_input():
	var velocity = Vector2(0, 0)
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

func _process(delta):
	sideways_velocity = get_input()
	if fuel <= 0:
		_dead()
	if Input.is_action_just_pressed("ui_select") and ammo > 0:
		var bullet = Bullet.instance()
		bullet.scale = Vector2(4, 4)
		add_child(bullet)
		bullet.connect("bullet_freed", self, "_on_bullet_freed")
		connect("free_the_bullet", bullet, "_death")
		ammo -= 1
	forward_speed = clamp(forward_speed, min_forward_speed, max_forward_speed)
	position.x = clamp(position.x, camera_pos.x, camera_pos.x + $Camera.get_viewport_rect().size.x)
	fuel = clamp(fuel, 0, 100)
	UI.text = str(fuel)

func _physics_process(delta):
	velocity = (sideways_velocity + Vector2(0, -1))*full_stop
	forward_speed += acceleration_speed * acceleration_dir
	velocity.x *= movement_speed
	velocity.y *= forward_speed
	var collision = move_and_collide(velocity * delta)
	if collision:
		if collision.collider.is_in_group("terrain"):
			_dead()
	fuel += -fuel_decrease_rate + fuel_refill_rate * refill

func _dead():
	position = current_mapslice.position + Vector2(960, 8500)
	full_stop = 0
	yield(get_tree().create_timer(1), "timeout")
	full_stop = 1
	fuel = 100

func _on_bullet_freed():
	ammo += 1
	ammo = clamp(ammo, 0, 1)

func _fuel():
	if refill == 0:
		refill = 1
	else:
		refill = 0

func _current_mapslice_changed(node):
	current_mapslice = node

func _hit_a_node(node):
	if node.is_in_group("enemy"):
		emit_signal("free_the_bullet")