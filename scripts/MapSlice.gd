extends TileMap

export var level_size = [60, 300]
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
var render_height = 0
var current_mapslice = false

func _randint(x, y):
	randomize()
	return(randi()%(y+1-x)+x)

func _clear_matrix():
	map_matrix = []
	for i in range(level_size[0]):
		map_matrix.append([])
		for j in range(level_size[1]):
			map_matrix[i].append([0, 0, 0])

func _render_tiles(height):
	for i in range(level_size[0]):
		for j in range(60):
			var tile = tiles[map_matrix[i][height-j]]
			if tile:
				set_cell(i, height-j, tile[0], tile[1], tile[2], tile[3])
			else:
				set_cell(i, height-j, -1)

func _generate():
	_clear_matrix()
	var step_memory = _step_generation([0, 0, 0], level_size[0]/4, 33)
	var path_template = [[level_size[0]/4, 30], step_memory[0], step_memory[1]]
	var left_bank_path = _bank_completion(path_template, "L")
	var right_bank_path
	_path_process(left_bank_path)

func _mapslice_entered(body):
	if body == player_node:
		current_mapslice = true
		add_child(player_node)

func _mapslice_exited(body):
	if body == player_node:
		current_mapslice = false
		position.y -= level_size[1]*32*2
		_generate()
		render_height = level_size[1]*32*2
		_render_tiles(level_size[1]-1)
		_render_tiles(level_size[1]-61)

func _ready():
	$Area/CollisionShape2D.shape.set_extents(Vector2(level_size[0]*32/2, level_size[1]*32/2))
	$Area/CollisionShape2D.position = Vector2(level_size[0]*32/2, level_size[1]*32/2)
	#player/chopper
	set_collision_layer_bit(0, 1)
	$Area.set_collision_layer_bit(0, 1)
	#bullet
	set_collision_layer_bit(-100, 1)
	player_node = get_parent().find_node("Player")
	_generate()
	render_height = level_size[1]*32*2
	_render_tiles(level_size[1]-1)
	_render_tiles(level_size[1]-61)

func _process(delta):
	if current_mapslice:
		if abs(render_height-player_node.position.y) >= 1080:
			_render_tiles(int(abs(player_node.position.y - 840 - position.y)/32))
			render_height = player_node.position.y - 840

func _step_errorproof(step_memory, width, direction):
	var is_stale = step_memory[2] == step_memory[1] and step_memory[1] == step_memory[0] and step_memory[0] == direction
	var is_error = (step_memory[2] == 0 and direction == 2) or (step_memory[2] == 2 and direction == 0)
	var is_outofbounds = (width < 2 and direction == 0) or (width > level_size[0]/2-2 and direction == 2)
	return is_stale or is_error or is_outofbounds

func _step_generation(step_memory, width, height):
	while height < level_size[1]-30:
		var direction = _randint(0, 2)
		var error = _step_errorproof([step_memory[-3], step_memory[-2], step_memory[-1]], width, direction)
		while error:
			direction = _randint(0, 2)
			error = _step_errorproof([step_memory[-3], step_memory[-2], step_memory[-1]], width, direction)
		if direction == 0:
			width -= 1
		elif direction == 1:
			height += 1
		elif direction == 2:
			width += 1
		step_memory.append(direction)
	return [step_memory, [width, height]]

func _path_process(path):
	var width = path[0][0]
	var height = path[0][1]
	map_matrix[width][height][0] = 3
	for i in path[1]:
		if i == 0:
			map_matrix[width][height][1] = 4
			width -= 1
			map_matrix[width][height][0] = 2
		elif i == 1:
			map_matrix[width][height][1] = 1
			height += 1
			map_matrix[width][height][0] = 3
		elif i == 2:
			
			map_matrix[width][height][1] = 2
			width += 1
			map_matrix[width][height][0] = 4
	map_matrix[width][height][1] = 1

func _bank_completion(path, side):
	var width = [path[0][0], path[2][0]]
	var height = [path[0][1], path[2][1]]
	while height[0] > (level_size[0]/2-7-width[0]):
		height[0] -= 1
		path[1].insert(0, 1)
	while height[0] > 0:
		path[1].insert(0, 0)
		width[0] += 1
		path[1].insert(0, 1)
		height[0] -= 1
	while level_size[1] - height[1] > (level_size[0]/2-8-width[1]):
		height[1] += 1
		path[1].append(1)
	while height[1] < level_size[1]:
		path[1].append(2)
		width[1] += 1
		path[1].append(1)
		height[1] += 1
	return [[width[0], height[0]], path[1], [width[1], height[1]]]

