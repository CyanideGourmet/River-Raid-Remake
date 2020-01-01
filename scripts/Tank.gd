extends Sprite

export var ranges = [300, 800, 1300]

var BulletScene = preload("res://scenes/TankBullet.tscn")

func _ready():
	_shoot()

func _random_int(x, y):
	randomize()
	return(randi()%(y+1-x)+x)

func _shoot():
	var bullet = BulletScene.instance()
	add_child(bullet)
	bullet.shot_range = ranges[_random_int(0, 2)]
	bullet.movement = Vector2(-500, 10)