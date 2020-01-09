extends "res://scripts/Classes/Destructible.gd"

func _ready():
	explosion = preload("res://scenes/ShipExplosion.tscn")
	#point_value = 30
	#movement_speed = 150
	#player
	set_collision_layer_bit(5, 1)
	$PlayerDetectionArea.set_collision_layer_bit(5, 1)
	#bullet
	set_collision_layer_bit(-5, 1)
	#terrain
	set_collision_mask_bit(0, 1)

func _physics_process(delta):
	velocity = Vector2(direction, 0) * full_stop

func _on_PlayerDetectionArea_body_entered(body):
	if body == player_node:
		full_stop = 1
		$PlayerDetectionArea.queue_free()
