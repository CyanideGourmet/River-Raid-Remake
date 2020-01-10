extends Sprite

export var percentage_ranges = [25.0, 50.0, 75.0]

signal clear_node

var BulletScene = preload("res://scenes/TankBullet.tscn")
var direction = -1
var ranges = []

func _ready():
	for i in range(percentage_ranges.size()):
		ranges.append(33*32*(percentage_ranges[i]/100))
	ranges = ranges[_random_int(0, 2)]
	if position.x < 960:
		rotation_degrees += 180
		direction = 1
# warning-ignore:return_value_discarded
	connect("clear_node", get_parent(), "_node_destroyed")
	yield(get_tree().create_timer(0.5), "timeout")
	_reload()

func _random_int(x, y):
	randomize()
	return(randi()%(y+1-x)+x)

func _reload():
	var bullet = BulletScene.instance()
	add_child(bullet)
	bullet.bullet_range = ranges

func _clear():
	emit_signal("clear_node", self)
	queue_free()