extends "res://scripts/Classes/Destructible.gd"

func _ready():
	point_value = 60
	movement_speed = 200
	$Body/Rotor/AnimationPlayer.play()
	#player
	set_collision_layer_bit(1, 1)
	$PlayerDetectionArea.set_collision_layer_bit(1, 1)
	#bullet
	set_collision_layer_bit(-1, 1)
	#terrain
	set_collision_mask_bit(0, 1)

func _on_PlayerDetectionArea_body_entered(body):
	if body == player_node:
		full_stop = 1
		$PlayerDetectionArea.queue_free()
