extends PlayerMotionState


### fn

## virtual
#
func _enter():
	jump()
	super._enter()

func _state_input(_event: InputEvent):
	if _event.is_action_pressed(InputManager.freefly):
		_transition.emit(self, States.freefly)

func _state_physics_process(_delta: float):
	set_direction()
	calculate_gravity(_delta)
	calculate_velocity(base_speed, direction, PLAYER_MOVEMENT_STATS.in_air_acceleration, _delta)
	_rotate_model.emit(input_dir)

	if velocity.y <= 0.0:
		_transition.emit(self, States.fall)


## helper
#
func jump():
	velocity.y = jump_velocity
