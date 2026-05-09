extends Motion


### fn

## virtual
#
func _enter():
	jump()

func _state_physics_process(_delta: float):
	set_direction()
	calculate_gravity(_delta)
	calculate_velocity(base_speed, direction, _delta)
	rotate_model()

	if velocity.y <= 0.0:
		_transition.emit(self, 'fall')


## helper
#
func jump():
	velocity.y = jump_velocity
	
	if not entity.is_attacking:
		entity.animation.play('Jump_Start')
