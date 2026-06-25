extends PlayerMotionState


### fn

## virtual
#
func _state_physics_process(_delta: float):
	set_direction()
	calculate_gravity(_delta)
	calculate_velocity(base_speed, direction, PLAYER_MOVEMENT_STATS.in_air_acceleration, _delta)
	_rotate_model.emit(input_dir)
	replenish_sprint(_delta)

	if is_on_floor():
		if direction != Vector3.ZERO:
			if Input.is_action_pressed('sprint'):
				_transition.emit(self, 'sprint')
			else:
				_transition.emit(self, 'walk')
		else:
			_transition.emit(self, 'idle')
