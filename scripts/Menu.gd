extends Control

func _start():
	yield(get_tree().create_timer(0.05), "timeout")
	get_tree().change_scene("res://scenes/Main.tscn")
