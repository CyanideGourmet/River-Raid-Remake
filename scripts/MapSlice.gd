extends TileMap

export var level_size = [60, 272]
export var fuel_number = [4, 10]
export var chopper_number = [1, 5]
export var plane_number = [3, 8]
export var heavy_number = [1, 3]
export var ship_number = [1, 5]
export var shooter_number = [1, 4]
export var tank_number = [0, 2]

var player_node
var FuelScene = preload("res://scenes/Fuel.tscn")
var ChopperScene = preload("res://scenes/Chopper.tscn")
var PlaneScene = preload("res://scenes/Plane.tscn")
var HeavyScene = preload("res://scenes/Heavy.tscn")
var ShipScene = preload("res://scenes/Ship.tscn")
var ShooterScene = preload("res://scenes/Shooter.tscn")
var TankScene = preload("res://scenes/Tank.tscn")
var RoadTankScene = preload("res://scenes/RoadTank.tscn")
var RoadScene = preload("res://scenes/Road.tscn")
var tiles = {[0, 0, 0]: 0, [1, 1, 0]: [1, 0, 0, 0], [2, 1, 0]: [3, 1, 0, 0], [2, 1, 1]: [4, 0, 0, 0], [2, 4, 0]: [2, 0, 1, 0], [2, 4, 1]: [2, 0, 0, 0], [3, 1, 0]: [2, 1, 0, 1], [3, 1, 1]: [2, 0, 0, 1], [3, 2, 0]: [3, 1, 1, 0], [3, 2, 1]: [4, 0, 1, 0], [3, 4, 0]: [4, 1, 1, 0], [3, 4, 1]: [3, 0, 1, 0], [4, 1, 0]: [4, 1, 0, 0], [4, 1, 1]: [3, 0, 0, 0], [4, 2, 0]: [2, 0, 0, 0], [4, 2, 1]: [2, 0, 1, 0]}
var map_matrix
var current_mapslice = false
var Road
var RoadTank

func _randint(x, y):
	randomize()
	return(randi()%(y+1-x)+x)

func _clear_matrix():
	map_matrix = []
	for i in range(level_size[0]):
		map_matrix.append([])
		for j in range(level_size[1]):
			map_matrix[i].append([0, 0, 0])

func _render_tiles():
	for i in range(level_size[0]):
		for j in range(level_size[1]):
			var tile = tiles[map_matrix[i][j]]
			if tile:
				set_cell(i, j, tile[0], tile[1], tile[2], tile[3])
			else:
				set_cell(i, j, -1)

func _generate():
	_clear_matrix()
	var step_memory = _step_generation(level_size[0]/4, 30)
	var path_template = [[level_size[0]/4, 30], step_memory[0], step_memory[1]]
	var left_bank_path = _left_bank_generation(path_template)
	var right_bank_path = _right_bank_generation(path_template)
	var islands = _islands(step_memory)
	Road = RoadScene.instance()
	RoadTank = RoadTankScene.instance()
	islands.append([0, 0, 0])
	left_bank_path = [left_bank_path[0][0], left_bank_path[0][1]+path_template[1]+left_bank_path[1][1], left_bank_path[1][0]]
	right_bank_path = [right_bank_path[0][0], right_bank_path[0][1]+path_template[1]+right_bank_path[1][1], right_bank_path[1][0]]
	for i in range(3):
		if _randint(0, 1):
			_path_process(islands[0][i], 1, 3, 1)
			_path_process(islands[1][i], 0, 4, 1)
			map_matrix[islands[0][i][2][0]][islands[1][i][2][1]] = [3, 2, 1]
			islands[-1][i] = 1
	_path_process(left_bank_path, 0, 3, 1)
	_path_process(right_bank_path, 1, 3, 1)
	_fill_terrain(islands)
	add_child(Road)
	add_child(RoadTank)
	Road.position = Vector2(0, level_size[1]*32)
	RoadTank.position = Vector2(0, level_size[1]*32)
	RoadTank.direction = 1
	RoadTank.rotation_degrees += 180

func _islands(step_memory):
	var islands = [_island_generation(step_memory, _randint(40, 50), _randint(90, 100)), _island_generation(step_memory, _randint(110, 120), _randint(160, 170)), _island_generation(step_memory, _randint(180, 190), 230)]
	var left_side_island_path = [[islands[0][0][0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 1]+islands[0][1]+[1], islands[0][0][1]], [islands[1][0][0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 1]+islands[1][1]+[1], islands[1][0][1]], [islands[2][0][0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 1]+islands[2][1]+[1], islands[2][0][1]]]
	var right_side_island_path = [[islands[0][0][0], [1]+islands[0][1]+[1, 0, 0, 0, 0, 0, 0, 0, 0, 0], islands[0][0][1]], [islands[1][0][0], [1]+islands[1][1]+[1, 0, 0, 0, 0, 0, 0, 0, 0, 0], islands[1][0][1]], [islands[2][0][0], [1]+islands[2][1]+[1, 0, 0, 0, 0, 0, 0, 0, 0, 0], islands[2][0][1]]]
	return [left_side_island_path, right_side_island_path]

func _mapslice_entered(body):
	if body == player_node:
		current_mapslice = true

func _mapslice_exited(body):
	var Main = get_tree().get_root().get_node("Main")
	Main.call_deferred("remove_child", self)
	Main.call_deferred("add_child", self)
	if body == player_node:
		current_mapslice = false
		position.y -= level_size[1]*32*2
		Road.call_deferred("queue_free")
		if weakref(RoadTank).get_ref():
			RoadTank.call_deferred("_clear")
		_generate()
		_render_tiles()

func _ready():
	$Area/CollisionShape2D.shape.set_extents(Vector2(level_size[0]*32/2, level_size[1]*32/2))
	$Area/CollisionShape2D.position = Vector2(level_size[0]*32/2, level_size[1]*32/2)
	player_node = get_tree().get_root().get_node("Main").get_node("Player")
	#player/chopper
	set_collision_layer_bit(0, 1)
	$Area.set_collision_layer_bit(0, 1)
	#bullet
	set_collision_layer_bit(-100, 1)
	_generate()
	_render_tiles()

func _path_process(path, side, in_side, out_side): #Left - 0, Right - 1
	var width = path[0][0]
	var height = path[0][1]
	map_matrix[width][height][0] = in_side
	for i in path[1]:
		if i == 0:
			map_matrix[width][height][1] = 4
			map_matrix[width][height][2] = side
			width -= 1
			map_matrix[width][height][0] = 2
			map_matrix[width][height][2] = side
		elif i == 1:
			map_matrix[width][height][1] = 1
			map_matrix[width][height][2] = side
			height += 1
			map_matrix[width][height][0] = 3
			map_matrix[width][height][2] = side
		elif i == 2:
			map_matrix[width][height][1] = 2
			map_matrix[width][height][2] = side
			width += 1
			map_matrix[width][height][0] = 4
			map_matrix[width][height][2] = side
	map_matrix[width][height][1] = out_side

func _step_errorproof(step_memory, width, direction):
	var is_toolong = step_memory[0] == step_memory[1] and step_memory[1] == step_memory[2] and step_memory[2] == direction and direction != 1
	var is_outofbounds = (width <= 1 and direction == 0) or (width >= level_size[0]/2-5 and direction == 2)
	var is_error = (step_memory[2] == 0 and direction == 2) or (step_memory[2] == 2 and direction == 0)
	return is_error or is_outofbounds or is_toolong

func _step_generation(width, height):
	var step_memory = [1, 1, 1]
	var coordinates = [[15, 30], [15, 31], [15, 32]]
	height += 3
	while height < level_size[1]-31:
		var direction = _randint(0, 2)
		while _step_errorproof([step_memory[-3], step_memory[-2], step_memory[-1]], width, direction):
			direction = _randint(0, 2)
		if direction == 0:
			width -= 1
		elif direction == 1:
			height += 1
		elif direction == 2:
			width += 1
		step_memory.append(direction)
		coordinates.append([width, height])
	return [step_memory, [width, height], coordinates] 

func _left_bank_generation(path):
	var up = [[level_size[0]/2-5, 0], []]
	var down = [[level_size[0]/2-5, level_size[1]-1], []]
	for i in range(level_size[0]/2-(5+path[0][0])):
		up[1].append(1)
		up[1].append(0)
	for i in range(path[0][1] - (level_size[0]/2-(5+path[0][0]))):
		up[1].append(1)
	for i in range((level_size[1]-1-path[2][1])-(level_size[0]/2-(path[2][0]+5))):
		down[1].append(1)
	for i in range(level_size[0]/2-(path[2][0]+5)):
		down[1].append(1)
		down[1].append(2)
	return [up, down]

func _right_bank_generation(path):
	var up = [[level_size[0]/2+5, 0], []]
	var down = [[level_size[0]/2+5, level_size[1]-1], []]
	for i in range((path[0][0]+33) - (level_size[0]/2+5)):
		up[1].append(1)
		up[1].append(2)
	for i in range(path[0][1] - ((path[0][0]+33) - (level_size[0]/2+5))):
		up[1].append(1)
	for i in range((level_size[1]-1-path[2][1])-((path[2][0]+33) - (level_size[0]/2+5))):
		down[1].append(1)
	for i in range((path[2][0]+33) - (level_size[0]/2+5)):
		down[1].append(1)
		down[1].append(0)
	return [up, down]

func _island_generation(steps, start_height, end_height):
	var i = 0
	var island_path = [[], []]
	while steps[2][i][1] < start_height+1:
		i += 1
	island_path[0].append([steps[2][i][0]+21, steps[2][i][1]-1])
	while steps[2][i][1] < end_height:
		island_path[1].append(steps[0][i])
		i += 1
	i-=1
	island_path[0].append([steps[2][i][0]+12, steps[2][i][1]+2])
	return island_path

func _fill_terrain(islands):
	var n = 0
	for i in range(level_size[1]):
		while map_matrix[n][i] == [0, 0, 0]:
			map_matrix[n][i] = [1, 1, 0]
			n += 1
		n = -1
		while map_matrix[n][i] == [0, 0, 0]:
			map_matrix[n][i] = [1, 1, 0]
			n -= 1
		n = 0
	for i in range(3):
		if islands[-1][i] == 1:
			for j in range(islands[0][i][2][1] - islands[0][i][0][1] - 1):
				while map_matrix[n][islands[0][i][0][1]+1+j] != [0, 0, 0]:
					n += 1
				while map_matrix[n][islands[0][i][0][1]+1+j] == [0, 0, 0]:
					n += 1
				while map_matrix[n][islands[0][i][0][1]+1+j] != [0, 0, 0]:
					n += 1
				while map_matrix[n][islands[0][i][0][1]+1+j] == [0, 0, 0]:
					map_matrix[n][islands[0][i][0][1]+1+j] = [1, 1, 0]
					n += 1
				n = 0