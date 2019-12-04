extends TileMap

export var level_size = 8704
var map_array = []
var start_end_width = [0, 0]
var start_end_height = [20, 252]
var max_width = 0
var copy_offset
var step_memory = []
var randomization_safelock = [0, 0]

func _ready():
	$Area.connect("body_exited", self, "_on_MapSlice_body_exited")
	_generate()

func _on_MapSlice_body_exited(body):
	yield(get_tree().create_timer(1), "timeout")
	if body == get_parent().find_node("Player"):
		position.y -= 2 * level_size
		_generate()

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
	for i in range(60):
		map_array.append([])
		for j in range(272):
			map_array[i].append([0, 0, 0])
	_template()
	_right_side_copy()
	_island()
	_place_tiles()
    #PRINT
	for i in range(272):
		var a = []
		for j in range(60):
			a.append(map_array[j][i][0])
		#print(a)
	print("\n\n")

func _template():
	var last = [0, 0]
	var n = _random_int(5, 12)
	var m = 20
	var x
	start_end_width[0] = n
	max_width = n
	map_array[n][m][0] = 3
	while(m <= 252):
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
		max_width = max(max_width, n)
	map_array[n][m][1] = 1
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
	var island_params = [10, _random_int(39, 79), _random_int(192, 232)]
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

func _place_tiles():
	var x
	for i in range(60):
		for j in range(272):
			x = map_array[i][j]
			if x == [2, 1, 1]:
				set_cell(i, j, 4)
			elif x == [2, 1, 0]:
				set_cell(i, j, 3, true)
			elif x == [4, 1, 1]:
				set_cell(i, j, 3)
			elif x == [4, 1, 0]:
				set_cell(i, j, 4, true)
			elif x == [3, 1, 1]:
				set_cell(i, j, 2, false, false, true)
			elif x == [3, 1, 0]:
				set_cell(i, j, 2, true, false, true)
			elif x == [2, 4, 0] or x == [4, 2, 1]:
				set_cell(i, j, 2, false, true)
			elif x == [2, 4, 1] or x == [4, 2, 0]:
				set_cell(i, j, 2)
			elif x == [3, 4, 0]:
				set_cell(i, j, 4, true, true)
			elif x == [3, 4, 1]:
				set_cell(i, j, 3, false, true)
			elif x == [3, 2, 0]:
				set_cell(i, j, 3, true, true)
			elif x == [3, 2, 1]:
				set_cell(i, j, 4, false, true)
			elif x == [1, 1, 0]:
				set_cell(i, j, 1)
			else:
				set_cell(i, j, -1)