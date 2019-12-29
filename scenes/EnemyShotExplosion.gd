extends KinematicBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var lifetime = 7
export var damping = 0.02
export var identifier = ""
var timer = 0
var speed = 0
var ded = false
# Called when the node enters the scene tree for the first time.
func _ready():
	print (str(get_owner()) + " initialized, lifetime: " + str(lifetime))
	var timer = 0
	$Explosion.one_shot = true
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if (ded): 
		return
	if (!ded && timer >= lifetime):
		print (identifier + "'s wreckage removed after: " +  str(timer) + ", life time: " + str(lifetime))
		print (identifier + "'s parent: " + str(get_parent()))
		ded = true
		visible = false
		#queue_free()
		return
	if (speed != 0):
		position += speed * delta * Vector2(1, 0)
		
		speed *= (1- damping)
		#print ("Wreckage speed: " + str(speed))
	
	timer += delta

func _set_position(pos):
	if (pos is Vector2):
		global_position = pos

func _set_speed(var xSpeed):
	if (xSpeed is int or xSpeed is float):
		speed = xSpeed
		print ("Wreckage speed set to: " + str(speed))

func _init_explosion(var xSpeed, var spawnPos):
	
	_set_position(spawnPos)
	_set_speed(xSpeed)
	
func _exit_tree():
	#get_tree().
	if (timer < lifetime ):
		if(identifier != ""):
			print (identifier + "'s explosion deleted prematurely after: " + str(timer))
		else:
			print ("Explosion deleted prematurely after: " + str(timer))
		
		print ("Parent name: " + str(get_parent()))
