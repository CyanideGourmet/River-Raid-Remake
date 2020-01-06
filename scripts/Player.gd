extends KinematicBody2D

export var movement_speed = 400
export var def_forward_speed = 200
export var max_forward_speed = 400
export var min_forward_speed = 50
export var acceleration_speed = 20
export var fuel_decrease_rate = 0.05
export var fuel_refill_rate = 0.5

var camera_pos
var UI
var Fuel_t
var Points_t
var HP_t
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
var points = 0
var hp = 3
var hpgained = 0

signal free_the_bullet
signal player_died

func _ready():
	camera_pos = $Camera.position
	current_mapslice = get_parent().find_node("MapSlice")
	UI = get_parent().get_node("UI")
	Fuel_t = UI.find_node("Fuel")
	Points_t = UI.find_node("Points")
	HP_t = UI.find_node("HP")
	Fuel_t.text = str(fuel)
	HP_t.text = "Lives: " + str(hp)
	#terrain
	set_collision_mask_bit(0, 1)
	#chopper
	set_collision_mask_bit(1, 1)
	#fuel
	set_collision_mask_bit(2, 1)
	#plane
	set_collision_mask_bit(3, 1)
	#heavy
	set_collision_mask_bit(4, 1)
	#ship
	set_collision_mask_bit(5, 1)
	#shooter
	set_collision_mask_bit(6, 1)
	#roadtank
	set_collision_mask_bit(7, 1)
	#bridge
	set_collision_mask_bit(10, 1)
	#enemybullet
	set_collision_layer_bit(-20, 1)
	#explosion
	set_collision_mask_bit(-21, 1)

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
	elif event.is_action_released("ui_left") or event.is_action_released("ui_right"):
		input.x = 0
	if event.is_action_released("ui_up") or event.is_action_released("ui_down"):
		forward_slowdown = 1
		if forward_speed > def_forward_speed:
			acceleration_dir = -1
		else:
			acceleration_dir = 1
	if event.is_action_pressed("ui_select") and ammo > 0:
		refill = (refill+1)%2
		var bullet = Bullet.instance()
		bullet.scale = Vector2(4, 4)
		add_child(bullet)
		ammo -= 1

func _process(delta):
	if forward_slowdown == 1:
		if forward_speed == def_forward_speed and acceleration_dir != 0:
			acceleration_dir = 0
			forward_slowdown = 0
	if fuel <= 0:
		_death()
	fuel = clamp(fuel, 0, 100)
	Fuel_t.text = str(fuel)

func _physics_process(delta):
	var velocity = (input + Vector2(0, -1))*full_stop
	forward_speed += acceleration_speed * acceleration_dir
	forward_speed = clamp(forward_speed, min_forward_speed, max_forward_speed)	
	velocity.x *= movement_speed
	velocity.y *= forward_speed
	var collision = move_and_collide(velocity * delta)
	if collision:
		if collision.collider.is_in_group("terrain"):
			_death()
		elif collision.collider.is_in_group("enemy"):
			collision.collider.call_deferred("_death")
			_death()
	fuel += (-fuel_decrease_rate + fuel_refill_rate * refill)*full_stop
	position.x = clamp(position.x, camera_pos.x, camera_pos.x + $Camera.get_viewport_rect().size.x)

func _death():
	fuel = 100
	full_stop = 0
	if hp == 0:
		get_tree().change_scene("res://scenes/Menu.tscn")
	hp -= 1
	HP_t.text = "Lives: " + str(hp)
	position = Vector2(960, 8500)
	yield(get_tree().create_timer(1), "timeout")
	full_stop = 1

func _reload():
	ammo = 1

func _fuel():
	if refill == 0:
		refill = 1
	else:
		refill = 0

func _current_mapslice_changed(node):
	disconnect("player_died", current_mapslice, "_reset")
	current_mapslice = node
	connect("player_died", current_mapslice, "_reset")

func _hit_a_node(node):
	if node.is_in_group("enemy") or node.is_in_group("fuel"):
		points += node.point_value
		if points >= 10000*(hpgained+1):
			hp += 1
			hpgained += 1
			HP_t.text = "Lives: " + str(hp)
		Points_t.text = "Points: " + str(points)