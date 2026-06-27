extends PlayerMotionState


# var
var land_after_these_states: Array[String] = ['jump', 'sprintjump', 'fall', 'sprintfall']


### fn

## virtual
#
func _enter():
	handle_animation_state_changed_signal()

	if previous_state_in(land_after_these_states):
		_animation_state_changed.emit('land')
		await animation_finished()

	super._enter()

func _exit():
	handle_animation_state_changed_signal()

func _state_input(_event: InputEvent):
	if _event.is_action_pressed(InputManager.freefly):
		_transition.emit(self, States.freefly)

	if _event.is_action_pressed(InputManager.jump):
		_transition.emit(self, 'jump')

func _state_process(_delta: float):
	if Input.is_action_pressed(InputManager.aim):
		_transition.emit(self, 'aimidle')

	if Input.is_action_pressed(InputManager.crouch):
		_transition.emit(self, 'crouchidle')

func _state_physics_process(_delta: float):
	set_direction()
	calculate_velocity(base_speed, direction, PLAYER_MOVEMENT_STATS.acceleration, _delta)
	replenish_sprint(_delta)

	if direction != Vector3.ZERO:
		if Input.is_action_pressed(InputManager.sprint) and sprint_remaining > PLAYER_MOVEMENT_STATS.minimum_sprint_threshold:
			_transition.emit(self, 'sprint')
		else:
			_transition.emit(self, 'walk')

	if not is_on_floor():
		_transition.emit(self, 'fall')
