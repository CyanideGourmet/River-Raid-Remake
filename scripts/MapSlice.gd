extends TileMap

export var level_size = [60, 272]
export var fuel_number = [4, 10]
export var chopper_number = [1, 5]
export var plane_number = [3, 8]
export var heavy_number = [1, 3]
export var ship_number = [1, 5]
export var shooter_number = [1, 4]
export var tank_number = [0, 2]

signal mapslice_changed

var player_node
# warning-ignore:unused_class_variable
var FuelScene = preload("res://scenes/Fuel.tscn")
# warning-ignore:unused_class_variable
var ChopperScene = preload("res://scenes/Chopper.tscn")
# warning-ignore:unused_class_variable
var PlaneScene = preload("res://scenes/Plane.tscn")
# warning-ignore:unused_class_variable
var HeavyScene = preload("res://scenes/Heavy.tscn")
# warning-ignore:unused_class_variable
var ShipScene = preload("res://scenes/Ship.tscn")
# warning-ignore:unused_class_variable
var ShooterScene = preload("res://scenes/Shooter.tscn")
# warning-ignore:unused_class_variable
var TankScene = preload("res://scenes/Tank.tscn")
var RoadTankScene = preload("res://scenes/RoadTank.tscn")
var RoadScene = preload("res://scenes/Road.tscn")
var tiles = {[0, 0, 0]: 0, [1, 1, 0]: [1, 0, 0, 0], [2, 1, 0]: [3, 1, 0, 0], [2, 1, 1]: [4, 0, 0, 0], [2, 4, 0]: [2, 0, 1, 0], [2, 4, 1]: [2, 0, 0, 0], [3, 1, 0]: [2, 1, 0, 1], [3, 1, 1]: [2, 0, 0, 1], [3, 2, 0]: [3, 1, 1, 0], [3, 2, 1]: [4, 0, 1, 0], [3, 4, 0]: [4, 1, 1, 0], [3, 4, 1]: [3, 0, 1, 0], [4, 1, 0]: [4, 1, 0, 0], [4, 1, 1]: [3, 0, 0, 0], [4, 2, 0]: [2, 0, 0, 0], [4, 2, 1]: [2, 0, 1, 0]}
var map_matrix
var current_mapslice = false
var entities = []
var instanced_entities = []
var Road
var RoadTank
var chunk = 7
var thread

func _randint(x, y):
	seed(randi())
	return(randi()%(y+1-x)+x)

func _clear_matrix():
	map_matrix = []
	for i in range(level_size[0]):
		map_matrix.append([])
# warning-ignore:unused_variable
		for j in range(level_size[1]):
			map_matrix[i].append([0, 0, 0])

func _render_tiles(start_height, end_height):
	for i in range(level_size[0]):
		for j in range(start_height - end_height):
			var tile = tiles[map_matrix[i][start_height - j]]
			if tile:
				set_cell(i, start_height - j, tile[0], tile[1], tile[2], tile[3])
			else:
				set_cell(i, start_height - j, -1)

func _generate():
	thread = Thread.new()
	_clear_matrix()
	_clear_entities()
	chunk = 7
	var step_memory = _step_generation(level_size[0]/4, 30)
	var path_template = [[level_size[0]/4, 30], step_memory[0], step_memory[1]]
	thread.start(self, "_left_bank_generation", path_template)
	var left_bank_path = thread.wait_to_finish()
	thread.start(self, "_right_bank_generation", path_template)
	var right_bank_path = thread.wait_to_finish()
	thread.start(self, "_islands", step_memory)
	var islands = thread.wait_to_finish()
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
	call_deferred("add_child", Road)
	call_deferred("add_child", RoadTank)
	Road.position = Vector2(0, level_size[1]*32)
	RoadTank.position = Vector2(_randint(0, 1)*59*32, level_size[1]*32)
	thread.start(self, "_entities", 0)
	thread.wait_to_finish()
	_instance_entities(entities)

func _reset():
	_clear_entities()
	_instance_entities(entities)

func _islands(step_memory):
	var islands = [_island_generation(step_memory, _randint(40, 50), _randint(90, 100)), _island_generation(step_memory, _randint(110, 120), _randint(160, 170)), _island_generation(step_memory, _randint(180, 190), 230)]
	var left_side_island_path = [[islands[0][0][0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 1]+islands[0][1]+[1], islands[0][0][1]], [islands[1][0][0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 1]+islands[1][1]+[1], islands[1][0][1]], [islands[2][0][0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 1]+islands[2][1]+[1], islands[2][0][1]]]
	var right_side_island_path = [[islands[0][0][0], [1]+islands[0][1]+[1, 0, 0, 0, 0, 0, 0, 0, 0, 0], islands[0][0][1]], [islands[1][0][0], [1]+islands[1][1]+[1, 0, 0, 0, 0, 0, 0, 0, 0, 0], islands[1][0][1]], [islands[2][0][0], [1]+islands[2][1]+[1, 0, 0, 0, 0, 0, 0, 0, 0, 0], islands[2][0][1]]]
	return [left_side_island_path, right_side_island_path]

func _mapslice_entered(body):
	if body == player_node:
		current_mapslice = true
		emit_signal("mapslice_changed", self)
	

func _mapslice_exited(body):
	var Main = get_tree().get_root().get_node("Main")
	if body == player_node:
		yield(get_tree().create_timer(2), "timeout")
		Main.call_deferred("remove_child", self)
		Main.call_deferred("add_child", self)
		current_mapslice = false
		position.y -= level_size[1]*32*2
		Road.call_deferred("queue_free")
		_generate()
		_render_tiles(271, 204)

func _node_destroyed(node):
	instanced_entities.erase(node)

func _ready():
	$Area/CollisionShape2D.shape.set_extents(Vector2(level_size[0]*32/2, level_size[1]*32/2))
	$Area/CollisionShape2D.position = Vector2(level_size[0]*32/2, level_size[1]*32/2)
	player_node = get_tree().get_root().get_node("Main").get_node("Player")
	#player/chopper
	set_collision_layer_bit(0, 1)
	$Area.set_collision_layer_bit(0, 1)
	#bullet
	set_collision_layer_bit(-100, 1)
# warning-ignore:return_value_discarded
	connect("mapslice_changed", player_node, "_current_mapslice_changed")
	_generate()
	_render_tiles(271, 204)

# warning-ignore:unused_argument
func _physics_process(delta):
	if current_mapslice:
		var relative_position = (player_node.position - position)/32
		if chunk > 2:
			if int(relative_position.y/34)%2 == 1 and int(relative_position.y/34) > 2:
				_render_tiles(34*(chunk-1), 34*(chunk-3))
				chunk -= 1

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
			height %= level_size[1]
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
# warning-ignore:unused_variable
	for i in range(level_size[0]/2-(5+path[0][0])):
		up[1].append(1)
		up[1].append(0)
# warning-ignore:unused_variable
	for i in range(path[0][1] - (level_size[0]/2-(5+path[0][0]))):
		up[1].append(1)
# warning-ignore:unused_variable
	for i in range((level_size[1]-1-path[2][1])-(level_size[0]/2-(path[2][0]+5))):
		down[1].append(1)
# warning-ignore:unused_variable
	for i in range(level_size[0]/2-(path[2][0]+5)):
		down[1].append(1)
		down[1].append(2)
	return [up, down]

func _right_bank_generation(path):
	var up = [[level_size[0]/2+5, 0], []]
	var down = [[level_size[0]/2+5, level_size[1]-1], []]
# warning-ignore:unused_variable
	for i in range((path[0][0]+33) - (level_size[0]/2+5)):
		up[1].append(1)
		up[1].append(2)
# warning-ignore:unused_variable
	for i in range(path[0][1] - ((path[0][0]+33) - (level_size[0]/2+5))):
		up[1].append(1)
# warning-ignore:unused_variable
	for i in range((level_size[1]-1-path[2][1])-((path[2][0]+33) - (level_size[0]/2+5))):
		down[1].append(1)
# warning-ignore:unused_variable
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

func _instance_entities(entities_list):
	for i in range(entities_list.size()):
		if entities_list[entities_list.size()-1-i][0]:
			var entity = entities_list[entities_list.size()-1-i][1][0].instance()
			call_deferred("add_child", entity)
			entity.position = Vector2(entities_list[entities_list.size()-1-i][1][1]*32, (entities_list.size()-1-i+15)*32)
			instanced_entities.append(entity)
		if i > 10:
			yield(get_tree().create_timer(0.06), "timeout")

func _clear_entities():
	for i in instanced_entities:
		i.call_deferred("_clear")

# warning-ignore:unused_argument
func _entities(x):
	entities = []
	var entities_number = []
	entities_number.append(_randint(fuel_number[0], fuel_number[1]))
	entities_number.append(_randint(chopper_number[0], chopper_number[1]))
	entities_number.append(_randint(plane_number[0], plane_number[1]))
	entities_number.append(_randint(heavy_number[0], heavy_number[1]))
	entities_number.append(_randint(ship_number[0], ship_number[1]))
	entities_number.append(_randint(shooter_number[0], shooter_number[1]))
	entities_number.append(_randint(tank_number[0], tank_number[1]))
# warning-ignore:unused_variable
	for i in range(level_size[1] - 2*15):
		entities.append([false, [null, 0]])
	_fuel(entities_number[0])
	_choppers(entities_number[1])
	_planes(entities_number[2])
	_heavies(entities_number[3])
	_ships(entities_number[4])
	_shooters(entities_number[5])
	_tanks(entities_number[6])

# warning-ignore:unused_argument
func _fuel(fuel):
	var i = 0
	var n
	while fuel > 0:
		n = 0
		if !entities[i][0] and _randint(0, 100) == 0:
			while map_matrix[n][i+15] != [0, 0, 0]:
				n+=1
			if map_matrix[n+11][i+15+1] != [0, 0, 0]:
				n += _randint(1, 11) + _randint(0, 1)*10
				while map_matrix[n][i+15] != [0, 0, 0]:
					n += 1
			else:
				n += _randint(1, 32)
			entities[i] = [true, [FuelScene, n]]
			fuel -= 1
		i += 1
		i %= level_size[1] - 2*15

# warning-ignore:unused_argument
func _choppers(choppers):
	var i = 0
	var n
	while choppers > 0:
		n = 0
		if !entities[i][0] and _randint(0, 100) == 0:
			while map_matrix[n][i+15] != [0, 0, 0]:
				n+=1
			if map_matrix[n+11][i+15+1] != [0, 0, 0]:
				n += _randint(1, 11) + _randint(0, 1)*10
				while map_matrix[n][i+15] != [0, 0, 0]:
					n += 1
			else:
				n += _randint(1, 32)
			entities[i] = [true, [ChopperScene, n]]
			choppers -= 1
		i += 1
		i %= level_size[1] - 2*15

# warning-ignore:unused_argument
func _heavies(heavies):
	var i = 0
	var n
	while heavies > 0:
		n = 0
		if !entities[i][0] and _randint(0, 100) == 0:
			while map_matrix[n][i+15] != [0, 0, 0]:
				n+=1
			if map_matrix[n+11][i+15+1] != [0, 0, 0]:
				n += _randint(1, 11) + _randint(0, 1)*10
				while map_matrix[n][i+15] != [0, 0, 0]:
					n += 1
			else:
				n += _randint(1, 32)
			entities[i] = [true, [HeavyScene, n]]
			heavies -= 1
		i += 1
		i %= level_size[1] - 2*15

# warning-ignore:unused_argument
func _planes(planes):
	var i = 0
# warning-ignore:unused_variable
	var n
	while planes > 0:
		if !entities[i][0] and _randint(0, 100) == 0:
			entities[i] = [true, [PlaneScene, _randint(0, 1)*59]]
			planes -= 1
		i += 1
		i %= level_size[1] - 2*15

# warning-ignore:unused_argument
func _ships(ships):
	var i = 0
	var n
	while ships > 0:
		n = 0
		if !entities[i][0] and _randint(0, 100) == 0:
			while map_matrix[n][i+15] != [0, 0, 0]:
				n+=1
			if map_matrix[n+11][i+15+1] != [0, 0, 0]:
				n += _randint(1, 11) + _randint(0, 1)*10
				while map_matrix[n][i+15] != [0, 0, 0]:
					n += 1
			else:
				n += _randint(1, 32)
			entities[i] = [true, [ShipScene, n]]
			ships -= 1
		i += 1
		i %= level_size[1] - 2*15

# warning-ignore:unused_argument
func _shooters(shooters):
	var i = 0
	var n
	while shooters > 0:
		n = 0
		if !entities[i][0] and _randint(0, 100) == 0:
			while map_matrix[n][i+15] != [0, 0, 0]:
				n+=1
			if map_matrix[n+11][i+15+1] != [0, 0, 0]:
				n += _randint(1, 11) + _randint(0, 1)*10
				while map_matrix[n][i+15] != [0, 0, 0]:
					n += 1
			else:
				n += _randint(1, 32)
			entities[i] = [true, [ShooterScene, n]]
			shooters -= 1
		i += 1
		i %= level_size[1] - 2*15

# warning-ignore:unused_argument
func _tanks(tanks):
	var i = 0
	var n
	while tanks > 0:
		n = 0
		var side = 1 - _randint(0, 1)*2
		if !entities[i][0] and _randint(0, 100) == 0:
			while map_matrix[n][i+15] != [0, 0, 0]:
				n+=side
			n -= 2*side
			entities[i] = [true, [TankScene, (n+60)%60]]
			tanks -= 1
		i += 1
		i %= level_size[1] - 2*15