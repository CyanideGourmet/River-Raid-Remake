extends TileMap

export var level_size = 8704
export var min_fuel_number = 4
export var max_fuel_number = 10
export var min_chopper_number = 3
export var max_chopper_number = 8
export var min_plane_number = 3
export var max_plane_number = 8
export var min_heavy_number = 1
export var max_heavy_number = 3
export var min_generate_start_n = 3
export var max_generate_start_n = 5
export var min_generate_start_m = 10
export var max_generate_start_m = 20

signal current_mapslice_changed

var player_node
var FuelScene = preload("res://scenes/Fuel.tscn")
var ChopperScene = preload("res://scenes/Chopper.tscn")
var PlaneScene = preload("res://scenes/Plane.tscn")
var HeavyScene = preload("res://scenes/Heavy.tscn")
var RoadScene = preload("res://scenes/Road.tscn")
var map_array = []
var instantiated_nodes_coordinates = []
var start_end_width = [0, 0]
var start_end_height = [0, 272]
var min_width = 60
var max_width = 0
var copy_offset = 30
var step_memory = []
var randomization_safelock = [0, 0]
var island_params = [10, 39, 232]
var tiles = {[0, 0, 0]: 0, [1, 1, 0]: [1, 0, 0, 0], [2, 1, 0]: [3, 1, 0, 0], [2, 1, 1]: [4, 0, 0, 0], [2, 4, 0]: [2, 0, 1, 0], [2, 4, 1]: [2, 0, 0, 0], [3, 1, 0]: [2, 1, 0, 1], [3, 1, 1]: [2, 0, 0, 1], [3, 2, 0]: [3, 1, 1, 0], [3, 2, 1]: [4, 0, 1, 0], [3, 4, 0]: [4, 1, 1, 0], [3, 4, 1]: [3, 0, 1, 0], [4, 1, 0]: [4, 1, 0, 0], [4, 1, 1]: [3, 0, 0, 0], [4, 2, 0]: [2, 0, 0, 0], [4, 2, 1]: [2, 0, 1, 0]}
var entities = []

func _ready():
	#player/chopper
	set_collision_layer_bit(0, 1)
	$Area.set_collision_layer_bit(0, 1)
	#bullet
	set_collision_layer_bit(-100, 1)
	player_node = get_parent().find_node("Player")
	$Area.connect("body_exited", self, "_on_MapSlice_body_exited")
	connect("current_mapslice_changed", player_node, "_current_mapslice_changed")
	_generate()

func _on_MapSlice_body_exited(body):
	yield(get_tree().create_timer(1), "timeout")
	if body == player_node:
		position.y -= 2 * level_size
		_clear_entities()
		_generate()

func _node_destroyed(body):
	for i in entities:
		i.erase(body)

func _random_int(x, y):
	randomize()
	return(randi()%(y+1-x)+x)

func _choose_dir(last, n):
	var x
	if last[0] == 0:
			if last[1] == 0:
				x = _random_int(0, 2)
			else:
				x = 0
	elif last[0] == 1:
		x = _random_int(0, 1)
	elif last[0] == 2:
		x = _random_int(0, 1)
		x *= 2
	if (n > 25 and x == 1) or (n < 2 and x == 2) or (randomization_safelock[0] > 3 or randomization_safelock[1] > 3):
		x = 0
	step_memory.append(x)
	return x

func _generate():
	step_memory = []
	max_width = 0
	map_array = []
	var timers = []
	var time = Timer.new()
	for i in range(60):
		map_array.append([])
		for j in range(272):
			map_array[i].append([0, 0, 0])
	_template()
	_right_side_copy()
	_island()
	_join_up()
	_join_down()
	_fill()
	_place_tiles()
	_instantiated_nodes_coordinates()
	_place_entities()
	var Road = RoadScene.instance()
	add_child(Road)
	Road.position = Vector2(0, 8640)

func _reset():
	_clear_entities()
	_place_entities()

func _template():
	var last = [0, 0]
	var n = _random_int(min_generate_start_n, max_generate_start_n)
	var m = _random_int(min_generate_start_m, max_generate_start_m)
	var x
	start_end_width[0] = n
	start_end_height = [m, 272-m]
	max_width = n
	map_array[n][m][0] = 3
	while(m <= start_end_height[1]):
		x = _choose_dir(last, n)
		if x == 0:
			map_array[n][m][1] = 1
			m += 1
			map_array[n][m][0] = 3
			last[1] = last[0]
			last[0] = 0
			randomization_safelock = [0, 0]
		elif x == 1:
			map_array[n][m][1] = 2
			n += 1
			map_array[n][m][0] = 4
			last[1] = last[0]
			last[0] = 1
			randomization_safelock[0] += 1
			randomization_safelock[1] = 0
		elif x == 2:
			map_array[n][m][1] = 4
			n -= 1
			map_array[n][m][0] = 2
			last[1] = last[0]
			last[0] = 2
			randomization_safelock[0] = 0
			randomization_safelock[1] += 1
		min_width = min(min_width, n)
		max_width = max(max_width, n)
	start_end_width[1] = n
	copy_offset = 59-max_width

func _right_side_copy():
	var n = start_end_width[0]
	var m = start_end_height[0]
	for i in step_memory:
		map_array[n+copy_offset][m] = map_array[n][m].duplicate()
		map_array[n+copy_offset][m][2] = 1
		if i == 0:
			m += 1
		elif i == 1:
			n += 1
		elif i == 2:
			n -= 1
	map_array[n+copy_offset][m] = map_array[n][m]
	map_array[n+copy_offset][m][2] = 1

func _island():
	island_params = [12, _random_int(39, 79), _random_int(192, 232)]
	var start_n
	var end_n
	if island_params[0]:
		var n = start_end_width[0]
		var m = start_end_height[0] 
		for i in step_memory:
			if m > island_params[1] and m < island_params[2]:
				map_array[n+island_params[0]][m] = map_array[n+copy_offset][m].duplicate()
				map_array[n+copy_offset-island_params[0]][m] = map_array[n][m].duplicate()
			elif m == island_params[1]:
				map_array[n+island_params[0]][m] = map_array[n+copy_offset][m].duplicate()
				map_array[n+copy_offset-island_params[0]][m] = map_array[n][m].duplicate()
				if map_array[n][m][0] == 3:
					start_n = [n+island_params[0], n+copy_offset-island_params[0]]
			elif m == island_params[2]:
				map_array[n+island_params[0]][m] = map_array[n+copy_offset][m].duplicate()
				map_array[n+copy_offset-island_params[0]][m] = map_array[n][m].duplicate()
				if map_array[n][m][1] == 1:
					end_n = [n+island_params[0], n+copy_offset-island_params[0]]
			if i == 0:
				m += 1
			elif i == 1:
				n += 1
			elif i == 2:
				n -= 1
		map_array[start_n[0]][island_params[1]-1] = [2, 1, 1]
		map_array[start_n[1]][island_params[1]-1] = [4, 1, 0] 
		map_array[end_n[0]][island_params[2]+1] = [3, 2, 1]
		map_array[end_n[1]][island_params[2]+1] = [3, 4, 0]
		for i in range(start_n[1]-start_n[0]-1):
			map_array[start_n[0]+1+i][island_params[1]-1] = [4, 2, 0]
			map_array[end_n[0]+1+i][island_params[2]+1] = [2, 4, 0]

func _join_up():
	var m = [start_end_height[0]-1, start_end_height[0]-1]
	var n = [start_end_width[0], start_end_width[0]+copy_offset]
	while m[0] > 25-n[0]:
		map_array[n[0]][m[0]] = [3, 1, 0]
		m[0] -= 1
	while m[1] > n[1]-35:
		map_array[n[1]][m[1]] = [3, 1, 1]
		m[1] -= 1
	var x = 0
	while m[0] >= 1:
		if x == 0:
			map_array[n[0]][m[0]] = [2, 1, 0]
			n[0] += 1
			x = 1
		if x == 1:
			map_array[n[0]][m[0]] = [3, 4, 0]
			m[0] -= 1
			x = 0
	x = 0 
	while m[1] >= 1:
		if x == 0:
			map_array[n[1]][m[1]] = [4, 1, 1]
			n[1] -= 1
			x = 1
		if x == 1:
			map_array[n[1]][m[1]] = [3, 2, 1]
			m[1] -= 1
			x = 0

func _join_down():
	var m = [start_end_height[1]+1, start_end_height[1]+1]
	var n = [start_end_width[1], start_end_width[1]+copy_offset]
	while 272 - m[0] > max(25-n[0], 3):
		map_array[n[0]][m[0]] = [3, 1, 0]
		m[0] += 1
	while 272 - m[1] > max(n[1]-35, 3):
		map_array[n[1]][m[1]] = [3, 1, 1]
		m[1] += 1
	var x = 0
	while m[0] < 272:
		if x == 0:
			map_array[n[0]][m[0]] = [3, 2, 0]
			n[0] += 1
			x = 1
		if x == 1:
			map_array[n[0]][m[0]] = [4, 1, 0]
			m[0] += 1
			x = 0
	x = 0 
	while m[1] < 272:
		if x == 0:
			map_array[n[1]][m[1]] = [3, 4, 1]
			n[1] -= 1
			x = 1
		if x == 1:
			map_array[n[1]][m[1]] = [2, 1, 1]
			m[1] += 1
			x = 0

func _fill():
	var n = 0
	for i in range(island_params[2]-island_params[1]+1):
		var m = island_params[1]+i
		while map_array[n][m] == [0, 0, 0]:
			map_array[n][m] = [1, 1, 0]
			n += 1
		while map_array[n][m] != [0, 0, 0]:
			n += 1
		n += island_params[0]
		while map_array[n][m] == [0, 0, 0]:
			map_array[n][m] = [1, 1, 0]
			n += 1
		n = 0
	n = [0, -1]
	for i in range(271):
		while map_array[n[0]][i+1] == [0, 0, 0]:
			map_array[n[0]][i+1] = [1, 1, 0]
			n[0] += 1
		while map_array[n[1]][i+1] == [0, 0, 0]:
			map_array[n[1]][i+1] = [1, 1, 0]
			n[1] -= 1
		n = [0, -1] 

func _place_tiles():
	clear()
	for i in range(60):
		for j in range(272):
			var x = map_array[i][j]
			x = tiles[x]
			if x:
				set_cell(i, j, x[0], x[1], x[2], x[3])

func _instantiated_nodes_coordinates():
	instantiated_nodes_coordinates = []
	var fuel_number = _random_int(min_fuel_number, max_fuel_number)
	var chopper_number = _random_int(min_chopper_number, max_chopper_number)
	var plane_number = _random_int(min_plane_number, max_plane_number)
	var heavy_number = _random_int(min_heavy_number, max_heavy_number)
	var fuel_coords = []
	var chopper_coords = []
	var plane_coords = []
	var heavy_coords = []
	while fuel_number > 0:
		var coordinates = [0, _random_int(20, 251)]
		while(map_array[coordinates[0]][coordinates[1]] != [0, 0, 0]):
			coordinates[0] += 1
		coordinates[0] += island_params[0]/2
		coordinates[0] += (copy_offset-island_params[0])*_random_int(0, 1)
		fuel_coords.append(coordinates)
		fuel_number -= 1
	instantiated_nodes_coordinates.append(fuel_coords)
	while chopper_number > 0:
		var coordinates = [_random_int(0, 1)*59, _random_int(50, 221)]
		var k = 0
		if coordinates[0] == 0:
			k = 1
		else:
			k = -1
		while map_array[coordinates[0]][coordinates[1]] != [0, 0, 0]:
			coordinates[0] += k
		chopper_coords.append(coordinates)
		chopper_number -= 1
	instantiated_nodes_coordinates.append(chopper_coords)
	while plane_number > 0:
		var coordinates = [_random_int(0, 1)*59, _random_int(50, 221)]
		plane_coords.append(coordinates)
		plane_number -= 1
	instantiated_nodes_coordinates.append(plane_coords)
	while heavy_number > 0:
		var coordinates = [_random_int(0, 1)*59, _random_int(50, 221)]
		var k = 0
		if coordinates[0] == 0:
			k = 1
		else:
			k = -1
		while map_array[coordinates[0]][coordinates[1]] != [0, 0, 0]:
			coordinates[0] += k
		coordinates[0] += k
		heavy_coords.append(coordinates)
		heavy_number -= 1
	instantiated_nodes_coordinates.append(heavy_coords)

func _place_entities():
	_fuel_entities()
	_enemies()

func _fuel_entities():
	var fuel_entities = []
	for i in instantiated_nodes_coordinates[0]:
		var x = FuelScene.instance()
		add_child(x)
		x.position = Vector2(16 + 32 * i[0], 16 + 32 * i[1])
		x.scale = Vector2(2, 2)
		fuel_entities.append(x)
	entities.append(fuel_entities)

func _enemies():
	_choppers()
	_planes()
	_heavies()

func _choppers():
	var chopper_entities = []
	for i in instantiated_nodes_coordinates[1]:
		var x = ChopperScene.instance()
		add_child(x)
		x.position = Vector2(16 + 32 * i[0], 16 + 32 * i[1])
		x.direction = -1
		if i[0] == 0:
			var x_body = x.get_node("Body")
			x_body.flip_v = !x_body.flip_v
			x.direction = 1
		chopper_entities.append(x)
	entities.append(chopper_entities)

func _planes():
	var plane_entities = []
	for i in instantiated_nodes_coordinates[2]:
		var x = PlaneScene.instance()
		add_child(x)
		x.position = Vector2(16 + 32 * i[0], 16 + 32 * i[1])
		x.direction = -1
		if i[0] == 0:
			var x_body = x.get_node("Body")
			x_body.flip_v = !x_body.flip_v
			x.direction = 1
		plane_entities.append(x)
	entities.append(plane_entities)

func _heavies():
	var heavy_entities = []
	for i in instantiated_nodes_coordinates[3]:
		var x = HeavyScene.instance()
		add_child(x)
		x.position = Vector2(16 + 32 * i[0], 16 + 32 * i[1])
		x.direction = -1
		if i[0] == 0:
			var x_body = x.get_node("Body")
			x_body.flip_v = !x_body.flip_v
			x.direction = 1
		heavy_entities.append(x)
	entities.append(heavy_entities)

func _clear_entities():
	for i in entities:
		for j in i:
			j.queue_free()
	entities = []