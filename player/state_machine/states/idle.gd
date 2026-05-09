extends Motion


### fn

## virtual
#
func _enter():
	animation.play('Idle')

func _state_physics_process(_delta: float):
	set_direction()
	calculate_velocity(base_speed, direction, _delta)

	if direction != Vector3.ZERO:
		_transition.emit(self, 'walk')
