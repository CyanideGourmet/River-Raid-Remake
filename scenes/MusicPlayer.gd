extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var repetitions = 1
export var crossfade = 1.0
export var fade_in_multiplier = 2.0
export var maxVolume = -12.0
export var minVolume = -60.0
var all_tracks = []
var current_track
var previous_track
var current_track_index
var track_start_time
var next_track_start_time

var is_crossfading = true
var crossfade_timer = 0

var scriptTimer = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	repetitions = max(repetitions, 0)
	for i in range(0, get_child_count()):
		if (get_child(i) is AudioStreamPlayer):
			var track = (get_child(i) as AudioStreamPlayer)
			all_tracks.append(track)
			track.volume_db = minVolume
			
	print ("Found " + str(len(all_tracks)) + " tracks")
	randomize()
	all_tracks.shuffle()
	
	current_track_index = 0
	current_track = all_tracks[current_track_index]
	
	if current_track:
		current_track.play(0.0)
		track_start_time = 0
		_set_next_track_start_time()
	else:
		print ("Track 0 doesn'y exist!")
	
func _physics_process(delta):
	if current_track: 
		if scriptTimer >= next_track_start_time:
			_play_next_track()
			
		if is_crossfading:
			_crossfade_tracks(delta)
			
	scriptTimer += delta
	
func _crossfade_tracks(var delta):	
	
	var fade_ratio =  crossfade_timer / crossfade
	var fade_in_ratio = min (1, fade_ratio * fade_in_multiplier)
	current_track.volume_db = lerp(minVolume, maxVolume, fade_in_ratio)
	
	if crossfade_timer > crossfade:
		is_crossfading = false
		crossfade_timer = 0.0
		if previous_track:
			previous_track.stop()
	else:
		if previous_track:
			previous_track.volume_db = lerp(maxVolume, minVolume, fade_ratio)
		crossfade_timer += delta
	
func _play_next_track():
	if current_track_index < len(all_tracks) - 1:
		current_track_index += 1
	else:
		randomize()
		all_tracks.shuffle()
		current_track_index = 0
	previous_track = current_track
	current_track = all_tracks[current_track_index]
	current_track.play(0.0)
	_set_next_track_start_time()
	is_crossfading = true

func _set_next_track_start_time():
	if !current_track || !current_track.stream:
		return
	next_track_start_time = scriptTimer + current_track.stream.get_length() * (repetitions + 1) - crossfade
	#print ("Next track will be played at: " + str(next_track_start_time))