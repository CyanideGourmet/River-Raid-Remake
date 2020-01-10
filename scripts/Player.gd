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
var explosion = preload("res://scenes/PlayerExplosion.tscn")
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
var isFullOnFuel = false
var current_pitch_scale = 1

var points = 0

var level = 0

var hp = 3
var hpgained = 0
#Hubert
var GUI
var GUI_Dam
var GUI_Score
var GUI_HiScore
var GUI_FuelIndicator
var GUI_Lives = []
onready var GUI_default_fuel_color = Color(200.0/255.0, 1.0, 1.0, 1.0)
#/Hubert

signal free_the_bullet
signal player_died

func _ready():
	camera_pos = $Camera.position
	current_mapslice = get_parent().get_node("MapSlice")
	UI = get_tree().get_root().get_node("Main").get_node("UI")
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
		GUI_FuelIndicator = GUI.find_node("FuelPointerVert")
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
	set_collision_mask_bit(101, 1)
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
		if event.is_action("ui_up"):
			forward_slowdown = 0
			acceleration_dir = 1
		if event.is_action("ui_down"):
			forward_slowdown = 0
			acceleration_dir = -1
	if event.is_action_pressed("ui_left"):
		input.x += -1
	if event.is_action_pressed("ui_right"):
		input.x += 1
	if event.is_action_released("ui_left"):
		input.x -= -1
	if event.is_action_released("ui_right"):
		input.x -= 1
	if event.is_action_released("ui_up") or event.is_action_released("ui_down"):
		forward_slowdown = 1
		
		if forward_speed > def_forward_speed:
			acceleration_dir = -1
		else:
			acceleration_dir = 1	
	if event.is_action("ui_select") and ammo > 0:
		var bullet = Bullet.instance()
		bullet.scale = Vector2(4, 4)
		add_child(bullet)
#		bullet.connect("bullet_freed", self, "_on_bullet_freed")
		connect("free_the_bullet", bullet, "_death")
		ammo -= 1
		#Hubert
		$Pew.play(0.0)
		#/Hubert
	#cheats
	if Input.is_key_pressed(KEY_F1):
		hp = 9999999
	if Input.is_key_pressed(KEY_F2):
		refill = (refill+1)%2
	if Input.is_key_pressed(KEY_F3):
		set_collision_mask_bit(0, 0)
	if Input.is_key_pressed(KEY_F4):
		set_collision_mask_bit(0, 1)

func _process(delta):
	_hub_input()
	if forward_slowdown == 1:
		if forward_speed == def_forward_speed and acceleration_dir != 0:
			acceleration_dir = 0
			forward_slowdown = 0
	if !isLowOnFuel && fuel < low_fuel_threshold:
			isLowOnFuel = true
			$LowFuelSound.play(0)
	elif isLowOnFuel && fuel >= low_fuel_threshold:
			isLowOnFuel = false
			$LowFuelSound.stop()			
	else:
		pass
	$EngineSound.pitch_scale = current_pitch_scale
	if fuel <= 0:
		_death()
	fuel = clamp(fuel, 0, 100)
	Fuel_t.text = str(fuel)

func _physics_process(delta):
	var velocity = (input + Vector2(0, -1))*full_stop
	if (acceleration_dir!= 0):
		forward_speed += acceleration_speed * acceleration_dir
	if (forward_slowdown!=0 && acceleration_dir == 0):
		forward_speed = forward_speed + sign(def_forward_speed - forward_speed) * acceleration_speed
		#forward_speed += acceleration_speed * 
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
	var lerpPitch = 1
	if (forward_speed>= def_forward_speed):
		lerpPitch = (1+  inverse_lerp(def_forward_speed, max_forward_speed, forward_speed) )* 0.5
	else:
		lerpPitch =   inverse_lerp(min_forward_speed, def_forward_speed,  forward_speed)*0.5
	current_pitch_scale = lerp(0.8, 1.2, lerpPitch)
	if (refill > 0):
		$RefillSound.pitch_scale = lerp(1, 10, fuel * 0.01)
	if (GUI_FuelIndicator):
		if fuel >= 100:
			GUI_FuelIndicator.modulate = Color.green
		elif fuel < low_fuel_threshold:
			GUI_FuelIndicator.modulate = Color.red
		else:
			GUI_FuelIndicator.modulate = Color.cyan
		if GUI_FuelIndicator.region_rect:
			var rect = GUI_FuelIndicator.region_rect
			GUI_FuelIndicator.region_rect = Rect2(rect.position.x, lerp(435.0, 0.0, fuel * 0.01), rect.size.x, lerp(0, 435.0, fuel * 0.01))
			GUI_FuelIndicator.position = Vector2.UP * lerp(-217.5, 0, fuel * 0.01)

func _death():

	var explosionInstance = explosion.instance()
	if (explosionInstance):
		add_child(explosionInstance)
		explosionInstance._init_explosion(0, global_position)
	
	$CollisionShape2D.disabled = true

	fuel = 100
	full_stop = 0
	refill = 1
	yield(get_tree().create_timer(3), "timeout")
	position = current_mapslice.position + Vector2(960, 8500)
	$CollisionShape2D.disabled = false
	emit_signal("player_died")
	if hp == 0:
		get_tree().change_scene("res://scenes/Menu.tscn")
	hp -= 1
	HP_t.text = "Lives: " + str(hp)
	$EngineSound.stop()
	current_pitch_scale = 1
	if (hp < len(GUI_Lives)):
		GUI_Lives[hp].visible = false
	forward_speed = def_forward_speed
	forward_slowdown = 0
	input = Vector2(0, 0)
	full_stop = 1
	refill = 0
	yield(get_tree().create_timer(0.1), "timeout")
	get_tree().paused = true
	$EngineSound.play(0)

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
	if (!node):
		print("No target mapslice node!!")
		return
	#Hubert
	_increment_level()
	#/Hubert
	disconnect("player_died", current_mapslice, "_reset")
	
	current_mapslice = node
	connect("player_died", current_mapslice, "_reset")
	
func _hit_a_node(node):
	if node.is_in_group("enemy") or node.is_in_group("fuel"):
		#points += node.point_value
		points += node.point_value * score_multiplier
		if points > global.high_score:
			global.high_score = points
			if GUI_HiScore:
				GUI_HiScore.text = str(points)
		if points >= 10000*(hpgained+1) and hp < 9:
			#Hubert
			GUI_Lives[hp].visible = true
			#/Hubert
			hp += 1
			$LiveUp.play(0)
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
	print ("Player advanced to level %s!"%level)
	print_stack()
	
func _hub_input():
	if (Input.is_action_pressed("ui_left") && !Input.is_action_pressed("ui_right")):
		input.x = -1
	elif (Input.is_action_pressed("ui_right") && !Input.is_action_pressed("ui_left") ):
		input.x = 1
	else:
		input.x = 0
	
	if (Input.is_action_pressed("ui_up") && !Input.is_action_pressed("ui_down")):
		forward_slowdown = 0
		acceleration_dir = 1
	elif (Input.is_action_pressed("ui_down") && !Input.is_action_pressed("ui_up") ):
		forward_slowdown = 0
		acceleration_dir = -1
	
	else:
		acceleration_dir = 0
		forward_slowdown = 1
	
	if Input.is_action_pressed("ui_select") and ammo > 0:
		var bullet = Bullet.instance()
		bullet.scale = Vector2(4, 4)
		add_child(bullet)

		connect("free_the_bullet", bullet, "_death")
		
		ammo -= 1
		#Hubert
		$Pew.play(0.0)
		#/Hubert
#/Hubert