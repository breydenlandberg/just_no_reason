extends PlayerMotionState


# signal
# actually a better practice to have sprint_entered and sprint_exited here so they are not exposed to other States

# var
var land_after_these_states: Array[String] = ['jump', 'sprintjump', 'fall', 'sprintfall'] # i want land_move to keep playing if it's playing throughout the walk -> sprint transition


### fn

## virtual
#
func _enter():
	handle_animation_state_changed_signal()
	sprint_started.emit()

	if previous_state_in(land_after_these_states):
		_animation_state_changed.emit('land_move')
		await animation_finished()

	super._enter()

func _exit():
	handle_animation_state_changed_signal()

func _state_input(_event: InputEvent):
	if _event.is_action_pressed(InputManager.freefly):
		sprint_ended.emit()
		_transition.emit(self, States.freefly)

	if _event.is_action_pressed(InputManager.jump):
		_transition.emit(self, 'sprintjump')

func _state_process(_delta: float):
	if Input.is_action_just_released(InputManager.sprint):
		sprint_ended.emit()
		_transition.emit(self, 'walk')

# Rename _delta to delta
func _state_physics_process(_delta: float):
	set_direction()
	calculate_velocity(sprint_speed, direction, PLAYER_MOVEMENT_STATS.acceleration, _delta)
	_rotate_model.emit(input_dir)
	sprint_remaining -= _delta # Reduce sprint

	if direction == Vector3.ZERO:
		if Input.is_action_pressed(InputManager.aim):
			sprint_ended.emit()
			_transition.emit(self, 'aimidle')
		else:
			sprint_ended.emit()
			_transition.emit(self, 'idle')
	else:
		if Input.is_action_pressed(InputManager.aim):
			sprint_ended.emit()
			_transition.emit(self, 'aimwalk')

	if not is_on_floor():
		_transition.emit(self, States.sprint_fall)

	if sprint_remaining <= 0.0:
		sprint_ended.emit()
		_transition.emit(self, 'walk')
