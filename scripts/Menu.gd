extends Control

func _start():

	seed(2137)
	yield(get_tree().create_timer(0.05), "timeout")
	get_tree().change_scene("res://scenes/Main.tscn")

func _beep(var soundName):
	var sound = find_node(soundName)
	if (sound):
		if (sound is AudioStreamPlayer2D):
			sound.play(0)
		else:
			print ("%s is not a sound!" % sound.name)
	else:
		print ("No node named: %s!"%soundName)
		
