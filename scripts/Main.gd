extends Node

func _ready():
	var map_slice_0 = get_node("MapSlice")
	var map_slice_1 = get_node("MapSlice2")
	map_slice_1.position = Vector2(0, 0)
	map_slice_0.position = Vector2(0, map_slice_0.level_size[1]*32)