class_name Hitbox extends Area3D


# signal
signal damage_take(_damage: float)


### fn

## virtual
#
func _ready():
	body_entered.connect(on_damage_body_entered)


## helper
#
func on_damage_body_entered(body: Node3D):
	if body is RigidBodyBullet:
		print('hi')
		damage_take.emit(body.damage)
