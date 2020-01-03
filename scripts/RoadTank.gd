extends "res://scripts/Classes/Destructible.gd"

func _ready():
	point_value = 250
	movement_speed = 400
	set_collision_mask_bit(1, 1)
	$PlayerDetectionArea.set_collision_layer_bit(7, 1)

func _physics_process(delta):
	velocity = Vector2(direction, 0) * full_stop

func _on_PlayerDetectionArea_body_entered(body):
	if body == player_node:
		full_stop = 1
		$PlayerDetectionArea.queue_free()