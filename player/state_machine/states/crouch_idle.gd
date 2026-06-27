extends PlayerMotionState


### fn

## virtual
#
func _state_input(_event: InputEvent):
	if _event.is_action_pressed(InputManager.freefly):
		_transition.emit(self, States.freefly)

	if _event.is_action_pressed(InputManager.jump):
		_transition.emit(self, States.jump)

func _state_process(_delta: float):
	if Input.is_action_pressed(InputManager.aim):
		_transition.emit(self, States.aim_idle)

	if Input.is_action_just_released(InputManager.crouch):
		_transition.emit(self, States.idle)

func _state_physics_process(_delta: float):
	set_direction()
	calculate_velocity(crouch_speed, direction, PLAYER_MOVEMENT_STATS.acceleration, _delta)
	replenish_sprint(_delta)

	if direction != Vector3.ZERO:
		if Input.is_action_pressed(InputManager.sprint) and sprint_remaining > PLAYER_MOVEMENT_STATS.minimum_sprint_threshold:
			_transition.emit(self, States.sprint)
		else:
			_transition.emit(self, States.crouch_walk)

	if not is_on_floor():
		_transition.emit(self, States.fall)
