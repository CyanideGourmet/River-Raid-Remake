extends Control

var high_score = 0

func _start():
	seed(2137)
	get_tree().change_scene("res://scenes/Main.tscn")
