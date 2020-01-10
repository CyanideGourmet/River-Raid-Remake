extends Control
onready var quit_yes = find_node("Yes")
onready var quit_no = find_node("No")

# warning-ignore:unused_class_variable
var high_score = 0

func _start():

	seed(2137)
	yield(get_tree().create_timer(1), "timeout")
# warning-ignore:return_value_discarded
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

func _quit_game():
	yield(get_tree().create_timer(0.35), "timeout")
	get_tree().quit()
	
func _are_u_sure():
	_button_state(quit_yes, true)
	_button_state(quit_no, true)
	
func _cancel_quit():
	_button_state(quit_yes, false)
	_button_state(quit_no, false)	
	#if (quit_no):
	#	quit_no.visible = false
	#	quit_no.disabled = true

func _credits():
	yield(get_tree().create_timer(0.6), "timeout")
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/Credits.tscn")

func _button_state(var button, var state):
	if !button || !(button is Button) || !(state is bool):
		return
	
	button.disabled = !state
	yield(get_tree().create_timer(0.1), "timeout")
	button.visible = state
	