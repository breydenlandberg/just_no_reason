extends PlayerMotionState


### fn

## virtual
#
func _state_process(_delta: float):
	if Input.is_action_pressed(InputManager.aim):
		_transition.emit(self, UnarmedStates.aim_walk)

func _state_physics_process(_delta: float):
	set_direction()
	calculate_velocity(base_speed, direction, PLAYER_MOVEMENT_STATS.acceleration, _delta)
	_rotate_model.emit(input_dir)
	replenish_sprint(_delta)

	if direction == Vector3.ZERO:
		_transition.emit(self, ArmedStates.idle)
