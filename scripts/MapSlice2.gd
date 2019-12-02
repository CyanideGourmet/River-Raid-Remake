extends TileMap

export var level_size = 8704
var temp = []
var left
var right
var middle
var map_array = []
var end_n = 0

func _random_int(x, y):
	randomize()
	return randi()%(y+x+1)+x

func _zero_temp():
	temp = []
	for i in range(20):
		temp.append([])
		for j in range(272):
			temp[i].append([0, 0, 0])

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
	if n > 18 and x == 1:
		x = 0
	if n < 2 and x == 2:
		x = 0
	return x

func _ready():
	$Area.connect("body_exited", self, "_on_MapSlice2_body_exited")
	for i in range(60):
		map_array.append([])
		for j in range(272):
			map_array[i].append([0, 0, 0])
	_generate()

func _on_MapSlice2_body_exited(body):
	yield(get_tree().create_timer(1), "timeout")
	if body == get_parent().find_node("Player"):
		position.y -= 2 * level_size
		_generate()

func _generate():
	_temp()
	_left()
	_right()
	_middle()
	_merge()
	_place_tiles()

func _merge():
	for i in range(20):
		for j in range(272):
			map_array[i][j] = left[i][j]
			map_array[i+40][j] = right[i][j]

func _temp():
	_zero_temp()
	var last = [0, 0]
	var n = 9
	var m = 20
	var x
	temp[n][m][0] = 3
	while(m <= 252):
		x = _choose_dir(last, n)
		if x == 0:
			temp[n][m][1] = 1
			m += 1
			temp[n][m][0] = 3
			last[1] = last[0]
			last[0] = 0
		elif x == 1:
			temp[n][m][1] = 2
			n += 1
			temp[n][m][0] = 4
			last[1] = last[0]
			last[0] = 1
		elif x == 2:
			temp[n][m][1] = 4
			n -= 1
			temp[n][m][0] = 2
			last[1] = last[0]
			last[0] = 2
	temp[n][m][1] = 1
	end_n = n

func _left():
	left = temp.duplicate(true)
	#UP
	var n = 9
	var m = 19
	var x = 1
	left[n][m][1] = 1
	for i in range(11):
		left[n][m][0] = 3
		m -= 1
		left[n][m][1] = 1
	while(m > 0):
		if x == 1:
			left[n][m][0] = 2
			n += 1
			left[n][m][1] = 4
			x = 0
		elif x == 0:
			left[n][m][0] = 3
			m -= 1
			left[n][m][1] = 1
			x = 1
	left[n][m][0] = 3
	#DOWN
	n = end_n
	m = 253
	x = 1
	left[n][m][1] = 1
	for i in range((272-252)-(20-n)-1):
		left[n][m][0] = 3
		m += 1
		left[n][m][1] = 1
	left[n][m][0] = 3
	while(m < 271):
		if x == 1:
			left[n][m][1] = 2
			n += 1
			left[n][m][0] = 4
			x = 0
		elif x == 0:
			left[n][m][1] = 1
			m += 1
			left[n][m][0] = 3
			x = 1
	left[n][m][1] = 1
	#FILL
	n = 0
	m = 0
	for i in range(272):
		while(left[n][m] == [0, 0, 0]):
			left[n][m] = [1, 1, 0]
			n += 1
		n = 0
		m += 1

func _right():
	right = temp.duplicate(true)
	#UP
	var n = 9
	var m = 19
	var x = 1
	right[n][m][1] = 1
	for i in range(12):
		right[n][m][0] = 3
		m -= 1
		right[n][m][1] = 1
	while(m > 0):
		if x == 1:
			right[n][m][0] = 4
			n -= 1
			right[n][m][1] = 2
			x = 0
		elif x == 0:
			right[n][m][0] = 3
			m -= 1
			right[n][m][1] = 1
			x = 1
	right[n][m][0] = 3
	#DOWN
	n = end_n
	m = 253
	x = 1
	right[n][m][1] = 1
	for i in range((272-252)-n-1):
		right[n][m][0] = 3
		m += 1
		right[n][m][1] = 1
	right[n][m][0] = 3
	while(m < 271):
		if x == 1:
			right[n][m][1] = 4
			n -= 1
			right[n][m][0] = 2
			x = 0
		elif x == 0:
			right[n][m][1] = 1
			m += 1
			right[n][m][0] = 3
			x = 1
	right[n][m][1] = 1
	#FILL
	n = 19
	m = 0
	for i in range(272):
		while(right[n][m] == [0, 0, 0]):
			right[n][m] = [1, 1, 0]
			n -= 1
		while n >= 0 and right[n][m] != [0, 0, 0]:
			right[n][m][2] = 1
			n -= 1
		n = 19
		m += 1

func _middle():
	pass

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