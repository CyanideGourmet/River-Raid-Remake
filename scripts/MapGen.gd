extends TileMap

var tab = []

func _ready():
	for i in range(40):
		tab.append([])
		for j in range(216):
			tab[i].append(0)
	for i in range(40):
		print(tab[i])