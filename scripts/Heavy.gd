extends "res://scripts/Classes/Destructible.gd"

func _ready():
	point_value = 60
	movement_speed = 100
	var rotors = get_node("Body/Rotors").get_children()
	for i in rotors:
		i.get_children()[0].play("Rotor")
	#player
	set_collision_layer_bit(4, 1)
	$PlayerDetectionArea.set_collision_layer_bit(4, 1)
	#bullet
	set_collision_layer_bit(-4, 1)
	#terrain
	set_collision_mask_bit(0, 1)

func _physics_process(delta):
	velocity = Vector2(direction, 0) * full_stop

func _on_PlayerDetectionArea_body_entered(body):
	if body == player_node:
		full_stop = 1
		$PlayerDetectionArea.queue_free()