class_name Hitbox extends Area3D # More appropriate as Hurtbox I think...


# signal
signal damage_take(damage: float)


### fn

## virtual
#
func _ready():
	body_entered.connect(on_damage_body_entered)


## helper
#
func on_damage_body_entered(body: Node3D):
	if body is RigidBodyBullet:
		# Do everything we want with the damaging body that just entered our hitbox
		damage_take.emit(body.damage)

		# Destroy the damaging body once we've done everything we want to with it
		#print(self, ' destroying ', body, ' as we are done with it')
		#print()
		body.queue_free()
