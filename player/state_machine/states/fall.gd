extends Motion


### fn

## virtual
#
func _enter():
	_animation_state_changed.emit('fall')

	if not entity.is_attacking:
		entity.animation.play('Jump')

func _state_physics_process(_delta: float):
	set_direction()
	calculate_gravity(_delta)
	calculate_velocity(base_speed, direction, PLAYER_MOVEMENT_STATS.in_air_acceleration, _delta)
	rotate_model()

	if is_on_floor():
		if direction != Vector3.ZERO:
			if Input.is_action_pressed('sprint'):
				_transition.emit(self, 'sprint')
			else:
				_transition.emit(self, 'walk')
		else:
			_transition.emit(self, 'idle')
