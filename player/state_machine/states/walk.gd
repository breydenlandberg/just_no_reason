extends PlayerMotionState


# var
var land_after_these_states: Array[String] = ['jump', 'sprintjump', 'fall', 'sprintfall']


### fn

## virtual
#
func _enter():
	handle_animation_state_changed_signal()

	if previous_state_in(land_after_these_states):
		_animation_state_changed.emit('land_move')
		await animation_finished()

	super._enter()

func _exit():
	handle_animation_state_changed_signal()

func _state_input(_event: InputEvent):
	if Input.is_action_just_pressed('jump'):
		_transition.emit(self, 'jump')

	if Input.is_action_pressed('sprint') and sprint_remaining > PLAYER_MOVEMENT_STATS.minimum_sprint_threshold:
		_transition.emit(self, 'sprint')

	if Input.is_action_pressed('aim'):
		_transition.emit(self, 'aimwalk')

func _state_physics_process(_delta: float):
	set_direction()
	calculate_velocity(base_speed, direction, PLAYER_MOVEMENT_STATS.acceleration, _delta)
	_rotate_model.emit(input_dir)
	replenish_sprint(_delta)

	if direction == Vector3.ZERO:
		_transition.emit(self, 'idle')

	if not is_on_floor():
		_transition.emit(self, 'fall')
