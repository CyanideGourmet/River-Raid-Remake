extends RigidBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var initial_velocity = Vector2(0, 0)
export var delay = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	_launch()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func physics_process(delta):
	
		
	_launch()
	delay -= delta
	
func _launch():
	if delay <= 0:
		linear_velocity = initial_velocity
		set_process(false)
