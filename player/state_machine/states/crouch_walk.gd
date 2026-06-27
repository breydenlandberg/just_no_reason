extends PlayerMotionState


# var
var land_after_these_states: Array[String] = ['jump', 'sprintjump', 'fall', 'sprintfall']


### fn

## virtual
#
func _state_input(_event: InputEvent):
	if _event.is_action_pressed(InputManager.freefly):
		_transition.emit(self, 'freefly')

	if Input.is_action_just_pressed(InputManager.jump):
		_transition.emit(self, 'jump')

	if Input.is_action_pressed(InputManager.sprint) and sprint_remaining > PLAYER_MOVEMENT_STATS.minimum_sprint_threshold:
		_transition.emit(self, 'sprint')

	if Input.is_action_pressed(InputManager.aim):
		_transition.emit(self, 'aimwalk')
