extends Sprite

export var ranges = [300, 800, 1300]

var BulletScene = preload("res://scenes/TankBullet.tscn")
var direction = -1

func _random_int(x, y):
	randomize()
	return(randi()%(y+1-x)+x)

func _reload():
	var bullet = BulletScene.instance()
	add_child(bullet)
	bullet.bullet_range = ranges[_random_int(0, 2)]