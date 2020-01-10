extends KinematicBody2D

# Declare member variables here. Examples:

export var lifetime = 7.0
export var one_shot_delay = 0.0
export var damping = 0.02
export var angular_speed = 0.0
export var identifier = ""
var timer = 0
var speed = 0
var explosions = []
var is_set_one_shot = false

# Called when the node enters the scene tree for the first time.
func _ready():
	#print (str(get_owner()) + " initialized, lifetime: " + str(lifetime))
# warning-ignore:unused_variable
	var timer = 0
	_find_explosions_recursive(self)
	
	_set_one_shot()
		
	
func _find_explosions_recursive(var node):
	if !node:
		#print ("Null node. Aborting...")
		return
		
	var count = node.get_child_count()
	if count == 0:
		#print ("%s has no children. Returning...")
		return
		
	for i in range(0, count):
		var child_node = node.get_child(i)
		
		if child_node is Particles2D:
			explosions.append(child_node)
		else:
			#print ("%s is not an explosion, recurring..." % child_node)
			_find_explosions_recursive(child_node)
		#child_node.one_shot = true
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if (!is_set_one_shot):
		_set_one_shot()
		
	if (timer >= lifetime):
		#print (identifier + "'s wreckage removed after: " +  str(timer) + ", life time: " + str(lifetime))
		#print (identifier + "'s parent: " + str(get_parent()))
		queue_free()
		return
		
	if (speed != 0):
		position += speed * delta * Vector2(1, 0)
		speed *= (1- damping)
		#print ("Wreckage speed: " + str(speed))
	rotate(angular_speed * delta)
	timer += delta

func _set_position(pos):
	if (pos is Vector2):
		global_position = pos

func _set_speed(var xSpeed):
	if (xSpeed is int or xSpeed is float):
		speed = xSpeed
		#print ("Wreckage speed set to: " + str(speed))

func _init_explosion(var xSpeed, var spawnPos, var rot_direction = 1):	
	_set_position(spawnPos)
	_set_speed(xSpeed)
	angular_speed *= rot_direction
	
func _set_one_shot():
	if (timer >= one_shot_delay):
		for i in range(0, len(explosions)):
			explosions[i].one_shot = true
			#print ("%s was set OneShot!" %explosions[i])
		is_set_one_shot = true

func _exit_tree():
	return
# warning-ignore:unreachable_code
	if (timer < lifetime ):
		if(identifier != ""):
			print (identifier + "'s explosion deleted prematurely after: " + str(timer))
		else:
			print ("Explosion deleted prematurely after: " + str(timer))
		
		print ("Parent name: " + str(get_parent()))
