extends KinematicBody2D

export var point_value = 0
export var movement_speed = 0
export var wreckage_speed_multiplier = 0

var player_node
var direction = -1
var full_stop = 0
var velocity = Vector2(0, 0)
var collision

var explosion

signal destroyed
signal clear_node

func _ready():
	add_to_group("enemy")
	player_node = get_tree().get_root().get_node("Main").get_node("Player")
	connect("destroyed", player_node, "_hit_a_node")
	connect("destroyed", get_parent(), "_node_destroyed")
	connect("clear_node", get_parent(), "_node_destroyed")
	set_collision_mask_bit(-21, 1)
	yield(get_tree().create_timer(1), "timeout")
	if position.x < 960:
		rotation_degrees += 180
		direction = 1
	velocity = Vector2(direction, 0)
	

func _physics_process(delta):
	if full_stop:
		collision = move_and_collide(velocity*movement_speed*delta)
		if collision:
			if collision.collider.is_in_group("PlayerBullet"):
				collision.collider._reload()
				_death()
			elif collision.collider == player_node:
				player_node.call_deferred("_death")
				_death()
			elif collision.collider.is_in_group("terrain"):
				direction *= -1
				velocity = Vector2(direction, 0)
				rotation_degrees += 180

func _death():
	_explode(explosion)
	emit_signal("destroyed", self)
	queue_free()



func _explode(explosion_node):
	if !explosion_node:
		return
		
	var explosionInstance = explosion_node.instance()
	get_parent().get_parent().get_parent().add_child(explosionInstance)
	explosionInstance._init_explosion(movement_speed * wreckage_speed_multiplier * direction, global_position)  #_set_position(global_position)
		

func _clear():
	emit_signal("clear_node", self)
	queue_free()
