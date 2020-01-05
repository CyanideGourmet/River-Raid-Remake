extends KinematicBody2D

export var movement_speed = 400
export var def_forward_speed = 200
export var max_forward_speed = 400
export var min_forward_speed = 50
export var acceleration_speed = 20

export var fuel_decrease_rate = 0.1
export var fuel_refill_rate = 0.2
export var low_fuel_threshold = 30

export var score_multiplier = 1

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


var engine_sound
var isLowOnFuel = false
var current_pitch_scale = 1

var points = 0

var level = 0
var cam

var hp = 3
var hpgained = 0
#Hubert
var GUI
var GUI_Dam
var GUI_Score
var GUI_HiScore
var GUI_FuelIndicator
var GUI_Lives = []
#/Hubert

signal free_the_bullet
signal player_died

func _ready():
	#cam = $ViewportContainer/Viewport/Camera
	cam = $Camera
	camera_pos = cam.position

	UI = get_parent().get_node("UI").get_node("Fuel")
	UI.text = str(fuel)
	
	current_mapslice = get_parent().find_node("MapSlice")
	UI = get_parent().get_node("UI")
	Fuel_t = UI.find_node("Fuel")
	Points_t = UI.find_node("Points")
	HP_t = UI.find_node("HP")
	Fuel_t.text = str(fuel)
	HP_t.text = "Lives: " + str(hp)
	
	#Hubert
	GUI = get_parent().get_node("UI_Root")
	if GUI:
		GUI_Score = GUI.find_node("ScoreValue")
		GUI_Dam = GUI.find_node("DamValue")
		GUI_HiScore = GUI.find_node("HiScoreValue")
		GUI_FuelIndicator = GUI.find_node("FuelPointer")
		
		_set_dam_score(0)
		
		if GUI_Score:
			GUI_Score.text = "0"
			
		if GUI_HiScore:
			GUI_HiScore.text = "0"
		
		var lives_group = GUI.find_node("LivesGroup")
		if lives_group:			
			for i in range(0, lives_group.get_child_count()):
				var child  = lives_group.get_child(i)
				if child && "Live" in child.name:
					GUI_Lives.append(child)
					child.visible = i < hp
		
	$LowFuelSound.stop()
	$RefillSound.stop()
	#/Hubert
	
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
	connect("player_died", current_mapslice, "_reset")
	

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

#		bullet.connect("bullet_freed", self, "_on_bullet_freed")
		connect("free_the_bullet", bullet, "_death")
		
		ammo -= 1
		#Hubert
		$Pew.play(0.0)
		#/Hubert

func _process(delta):
	if forward_slowdown == 1:
		if forward_speed == def_forward_speed and acceleration_dir != 0:
			acceleration_dir = 0
			forward_slowdown = 0
	
	#Hubert
	if !isLowOnFuel && fuel < low_fuel_threshold:
		isLowOnFuel = true
		$LowFuelSound.play(0)
	elif isLowOnFuel && fuel >= low_fuel_threshold:
		isLowOnFuel = false
		$LowFuelSound.stop()
	else:
		pass
	
	$EngineSound.pitch_scale = current_pitch_scale
	#/Hubert
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
	fuel += -fuel_decrease_rate + fuel_refill_rate * refill
	
	position.x = clamp(position.x, camera_pos.x, camera_pos.x + cam.get_viewport_rect().size.x)
	
	#Hubert (dodane do physics_process())
	var lerpPitch = 1
	if (forward_speed>= def_forward_speed):
		lerpPitch = (1+  inverse_lerp(def_forward_speed, max_forward_speed, forward_speed) )* 0.5
	else:
		lerpPitch =   inverse_lerp(min_forward_speed, def_forward_speed,  forward_speed)*0.5
	
	current_pitch_scale = lerp(0.8, 1.2, lerpPitch)
	if (refill > 0):
		$RefillSound.pitch_scale = lerp(1, 10, fuel * 0.01)
	if GUI_FuelIndicator:
		GUI_FuelIndicator.position = Vector2.RIGHT * lerp(0.0, 175.0, fuel * 0.01)
	#/Hubert (koniec do physics_process())

func _death():

	if hp == 0:
		get_tree().change_scene("res://scenes/Menu.tscn")
	
	hp -= 1
	HP_t.text = "Lives: " + str(hp)
	#Hubert
	$EngineSound.stop()
	current_pitch_scale = 1
	if (hp < len(GUI_Lives)):
		GUI_Lives[hp].visible = false
	#/Hubert

	emit_signal("player_died")
	
	if current_mapslice:
		position = current_mapslice.position + Vector2(960, 8500)
		
	full_stop = 0
	yield(get_tree().create_timer(1), "timeout")
	full_stop = 1
	fuel = 100
	#Hubert
	$EngineSound.play(0)
	#/Hubert

func _reload():
	ammo = 1

func _fuel():
	if refill == 0:
		refill = 1
		#Hubert
		$RefillSound.play(0)
		#/Hubert
	else:
		refill = 0
		#Hubert
		$RefillSound.stop()
		#/Hubert

func _current_mapslice_changed(node):
	if !node:
		return
	#Hubert
	_increment_level()
	#/Hubert
	disconnect("player_died", current_mapslice, "_reset")
	
	current_mapslice = node
	connect("player_died", current_mapslice, "_reset")
	
func _hit_a_node(node):
	if node.is_in_group("enemy") or node.is_in_group("fuel"):
		points += node.point_value * score_multiplier
		if points >= 10000*(hpgained+1):
			#Hubert
			if (hp < len(GUI_Lives)):
				GUI_Lives[hp].visible = true
			#/Hubert
			hp += 1
			hpgained += 1
			HP_t.text = "Lives: " + str(hp)
		Points_t.text = "Points: " + str(points)
		#Hubert
		if GUI_Score:
			GUI_Score.text = str(points)
		#/Hubert	
		#emit_signal("free_the_bullet")
	#elif node.is_in_group("fuel"):
		#emit_signal("free_the_bullet")

#Hubert
func _on_bullet_freed():
	pass
	
func _set_dam_score( var lvl):
	level = lvl
	if GUI_Dam:
		GUI_Dam.text = str(level)

func _increment_level():
	_set_dam_score(level + 1)
#/Hubert