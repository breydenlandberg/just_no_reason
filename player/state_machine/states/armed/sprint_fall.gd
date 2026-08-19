extends PlayerMotionState


# signal
@warning_ignore('unused_signal')
signal sprint_started
signal sprint_ended


### fn

## virtual
#
func _state_input(_event: InputEvent):
	if _event.is_action_pressed(InputManager.freefly):
		pass

func _state_physics_process(_delta: float):
	set_direction()
	calculate_gravity(_delta)
	calculate_velocity(sprint_speed, direction, PLAYER_MOVEMENT_STATS.in_air_acceleration, _delta)
	_rotate_model.emit(input_dir)

	if is_on_floor():
		if direction != Vector3.ZERO:
			if Input.is_action_pressed(InputManager.aim):
				_transition.emit(self, ArmedStates.aim_walk)
			elif Input.is_action_pressed(InputManager.sprint):
				_transition.emit(self, ArmedStates.sprint)
			elif Input.is_action_pressed(InputManager.crouch):
				_transition.emit(self, ArmedStates.crouch_walk)
			else:
				sprint_ended.emit()
				_transition.emit(self, ArmedStates.walk)
		else:
			sprint_ended.emit()
			_transition.emit(self, ArmedStates.idle)
