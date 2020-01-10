extends Node2D

export var credits_speed = 20.0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	credits_speed = abs(credits_speed)
	pass # Replace with function body.
func _process(delta):
	position += Vector2(0, -credits_speed*delta)
	if (Input.is_action_just_pressed("ui_cancel")):
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://scenes/Menu.tscn")
# 