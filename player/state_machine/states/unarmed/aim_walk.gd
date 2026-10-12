extends PlayerMotionState


### fn

## virtual
#
func _enter():
	set_aiming(true)
	super._enter()

func _state_input(_event: InputEvent):
	if _event.is_action_pressed(InputManager.freefly):
		set_aiming(false)
		_transition.emit(self, UnarmedStates.freefly)

	if _event.is_action_pressed(InputManager.jump):
		set_aiming(false)
		_transition.emit(self, UnarmedStates.jump)

func _state_process(_delta: float):
	if Input.is_action_just_released(InputManager.aim):
		set_aiming(false)
		_transition.emit(self, UnarmedStates.walk)

func _state_physics_process(_delta: float):
	set_direction()
	calculate_velocity(aim_speed, direction, PLAYER_MOVEMENT_STATS.acceleration, _delta)
	_rotate_model.emit(input_dir)
	replenish_sprint(_delta)

	if direction == Vector3.ZERO:
		_transition.emit(self, UnarmedStates.aim_idle)

	if not is_on_floor():
		set_aiming(false)
		_transition.emit(self, UnarmedStates.fall)
