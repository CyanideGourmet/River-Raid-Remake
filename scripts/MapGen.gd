extends TileMap

var tab = []

func _random_int(x, y):
	randomize()
	return randi()%(y+x+1)+x

func _ready():
	for i in range(30):
		tab.append([])
		for j in range(136):
			tab[i].append([0,0])
	tab[13][135] = [1, 3]
	tab[16][135] = [1, 3]
	var i = [13, 16]
	var j = 134
	var x = 1
	while(i[0] > 8 and i[1] < 21 and j > 128):
		if x == 0:
			tab[i[0]][j] = [2, 3]
			tab[i[1]][j] = [4, 3]
			j -= 1
			x = 1
		elif x == 1:
			tab[i[0]][j] = [1, 4]
			tab[i[1]][j] = [1, 2]
			i[0] -= 1
			i[1] += 1
			x = 0
	_generate_left()
	_place_tiles()

func _generate_left():
	var i = 9
	var j = 130
	var last = 0
	var x
	while j > 7:
		if(i > 8):
			x = _random_int(0, 2)
			while (last == 1 and x == 2) or (last == 2 and x == 1) or (x == 2 and i == 13):
				x = _random_int(0, 2)
		else:
			x = _random_int(0, 1)
			if x == 1:
				if last == 1:
					x = 0
				else:
					x = 2
		if x == 0:
			tab[i][j][1] = 3
			tab[i][j-1][0] = 1
			j -= 1
		if x == 1:
			tab[i][j][1] = 4
			tab[i-1][j][0] = 2
			i -= 1
		if x == 2:
			tab[i][j][1] = 2
			tab[i+1][j][0] = 4
			i += 1
		last = x

func _place_tiles():
	var x
	var a
	for i in range(30):
		for j in range(136):
			a = tab[i][j]
			if a == [1, 3]:
				set_cell(i, j, 2, true, false, true)
			elif a == [2, 4]:
				set_cell(i, j, 2)
			elif a == [4, 2]:
				set_cell(i, j, 2, false, true)
			elif a == [1, 2]:
				set_cell(i, j, 4)
			elif a == [2, 3]:
				set_cell(i, j, 4, false, true)
			elif a == [1, 4]:
				set_cell(i, j, 4, true)
			elif a == [4, 3]:
				set_cell(i ,j, 4, true, true)



