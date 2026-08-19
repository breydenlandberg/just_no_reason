extends PlayerMotionState


# var
var land_after_these_states: Array[String] = ['jump', 'sprintjump', 'fall', 'sprintfall'] # use ArmedStates


### fn

## virtual
#
func _state_input(_event: InputEvent):
	if _event.is_action_pressed(InputManager.freefly):
		_transition.emit(self, UnarmedStates.freefly)

	if _event.is_action_pressed(InputManager.jump):
		_transition.emit(self, UnarmedStates.jump)

func _state_process(_delta: float):
	if Input.is_action_pressed(InputManager.aim):
		_transition.emit(self, UnarmedStates.aim_walk)

	if Input.is_action_pressed(InputManager.sprint) and sprint_remaining > PLAYER_MOVEMENT_STATS.minimum_sprint_threshold:
		_transition.emit(self, UnarmedStates.sprint)

func _state_physics_process(_delta: float):
	set_direction()
	calculate_velocity(crouch_speed, direction, PLAYER_MOVEMENT_STATS.acceleration, _delta)
	_rotate_model.emit(input_dir)
	replenish_sprint(_delta)

	if direction == Vector3.ZERO:
		_transition.emit(self, UnarmedStates.crouch_idle)
	else:
		if Input.is_action_just_released(InputManager.crouch):
			_transition.emit(self, UnarmedStates.walk)

	if not is_on_floor():
		_transition.emit(self, UnarmedStates.fall)
