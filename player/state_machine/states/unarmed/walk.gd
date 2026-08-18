extends PlayerMotionState


# var
var land_after_these_states: Array[StringName] = [UnarmedStates.jump, UnarmedStates.sprint_jump, UnarmedStates.fall, UnarmedStates.sprint_fall]


### fn

## virtual
#
func _enter():
	handle_animation_state_changed_signal()

	if previous_state_in(land_after_these_states):
		_animation_state_changed.emit('land_move') # instead of land, Animations.land_move
		await animation_finished()

	super._enter()

func _exit():
	handle_animation_state_changed_signal()

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

	if Input.is_action_pressed(InputManager.crouch):
		_transition.emit(self, UnarmedStates.crouch_walk)

func _state_physics_process(_delta: float):
	set_direction()
	calculate_velocity(base_speed, direction, PLAYER_MOVEMENT_STATS.acceleration, _delta)
	_rotate_model.emit(input_dir)
	replenish_sprint(_delta)

	if direction == Vector3.ZERO:
		_transition.emit(self, UnarmedStates.idle)

	if not is_on_floor():
		_transition.emit(self, UnarmedStates.fall)
