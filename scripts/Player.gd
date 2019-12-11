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
var forward_slowdown = 0
var current_mapslice
var refill = 0
var input = Vector2(0, 0)

signal free_the_bullet

func _ready():
	camera_pos = $Camera.position
	UI = get_parent().get_node("UI").get_node("Fuel")
	UI.text = str(fuel)
	set_collision_mask_bit(0, 1)
	set_collision_mask_bit(1, 1)
	set_collision_mask_bit(2, 1)

func _input(event):
	if event.is_pressed():
		if event.is_action("ui_left"):
			input.x = -1
		elif event.is_action("ui_right"):
			input.x = 1
		elif event.is_action("ui_up"):
			forward_slowdown = 0
			acceleration_dir = 1
		elif event.is_action("ui_down"):
			forward_slowdown = 0
			acceleration_dir = -1
		elif event.is_action("ui_accept"):
			fuel_decrease_rate -= 0.1
			fuel_decrease_rate = abs(fuel_decrease_rate)
	elif event.is_action_released("ui_left") or event.is_action_released("ui_right"):
		input.x = 0
	if event.is_action_released("ui_up") or event.is_action_released("ui_down"):
		forward_slowdown = 1
		if forward_speed > def_forward_speed:
			acceleration_dir = -1
		else:
			acceleration_dir = 1
	if event.is_action_pressed("ui_select") and ammo > 0:
		var bullet = Bullet.instance()
		bullet.scale = Vector2(4, 4)
		add_child(bullet)
		bullet.connect("bullet_freed", self, "_on_bullet_freed")
		connect("free_the_bullet", bullet, "_death")
		ammo -= 1

func _process(delta):
	if forward_slowdown == 1:
		if forward_speed == def_forward_speed and acceleration_dir != 0:
			acceleration_dir = 0
			forward_slowdown = 0
	if fuel <= 0:
		_dead()
	fuel = clamp(fuel, 0, 100)
	UI.text = str(fuel)

func _physics_process(delta):
	var velocity = (input + Vector2(0, -1))*full_stop
	forward_speed += acceleration_speed * acceleration_dir
	forward_speed = clamp(forward_speed, min_forward_speed, max_forward_speed)	
	velocity.x *= movement_speed
	velocity.y *= forward_speed
	var collision = move_and_collide(velocity * delta)
	if collision:
		if collision.collider.is_in_group("terrain") or collision.collider.is_in_group("enemy"):
			_dead()
	fuel += -fuel_decrease_rate + fuel_refill_rate * refill
	position.x = clamp(position.x, camera_pos.x, camera_pos.x + $Camera.get_viewport_rect().size.x)

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
	if node.is_in_group("enemy") or node.is_in_group("fuel"):
		emit_signal("free_the_bullet")