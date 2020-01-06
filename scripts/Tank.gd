extends Sprite

export var percentage_ranges = [25.0, 50.0, 75.0]

var BulletScene = preload("res://scenes/TankBullet.tscn")
var direction = -1
var ranges = []

func _ready():
	print ("Tank parent: %s"% get_parent().name)
	for i in range(percentage_ranges.size()):
		
		ranges.append(get_parent().copy_offset*32*(percentage_ranges[i]/100))

func _random_int(x, y):
	randomize()
	return(randi()%(y+1-x)+x)

func _reload():
	var bullet = BulletScene.instance()
	add_child(bullet)
	bullet.bullet_range = ranges[_random_int(0, 2)]