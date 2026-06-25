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
	if _event.is_action_pressed(InputManager.input_freefly):
		_transition.emit(self, 'freefly')

	if _event.is_action_pressed(InputManager.input_jump):
		_transition.emit(self, 'jump')

	if Input.is_action_pressed('aim'):#InputManager.input_aim
		_transition.emit(self, 'aimidle')

func _state_physics_process(_delta: float):
	set_direction() # Do these need to be in idle?
	calculate_velocity(base_speed, direction, PLAYER_MOVEMENT_STATS.acceleration, _delta) # Do these need to be in idle?
	replenish_sprint(_delta)

	if direction != Vector3.ZERO:
		_transition.emit(self, 'walk')

	if not is_on_floor():
		_transition.emit(self, 'fall')
