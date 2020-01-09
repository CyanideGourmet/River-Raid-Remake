extends Control

func _start():
	seed(2137)
	get_tree().change_scene("res://scenes/Main.tscn")
