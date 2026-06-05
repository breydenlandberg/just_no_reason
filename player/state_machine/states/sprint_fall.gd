extends Motion


### fn

## virtual
#
func _enter():
	if not entity.is_attacking:
		entity.animation.play('Jump')

func _state_physics_process(_delta: float):
	set_direction()
	calculate_gravity(_delta)
	calculate_velocity(sprint_speed, direction, _delta)
	rotate_model()

	if is_on_floor():
		if direction != Vector3.ZERO:
			if Input.is_action_pressed('sprint'):
				_transition.emit(self, 'sprint')
			else:
				sprint_ended.emit()
				_transition.emit(self, 'walk')
		else:
			sprint_ended.emit()
			_transition.emit(self, 'idle')
