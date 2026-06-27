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

func _state_input(_event: InputEvent):
	if _event.is_action_pressed(InputManager.freefly):
		_transition.emit(self, 'freefly')

	if _event.is_action_pressed(InputManager.jump):
		_transition.emit(self, 'jump')

	if _event.is_action_pressed(InputManager.aim):
		_transition.emit(self, 'aimidle')

	if _event.is_action_released(InputManager.crouch):
		_transition.emit(self, 'idle')
