extends Motion


### fn

## virtual
#
func _enter():
	_animation_state_changed.connect(player_model.on_state_machine_animation_state_changed)

	if previous_state and previous_state.name.to_lower() in ['jump', 'sprintjump', 'fall', 'sprintfall']:
		_animation_state_changed.emit('land')
		await animation_tree.animation_finished

	super._enter()

func _exit():
	_animation_state_changed.disconnect(player_model.on_state_machine_animation_state_changed)

func _state_input(_event: InputEvent):
	if Input.is_action_just_pressed('jump'):
		_transition.emit(self, 'jump')

	if Input.is_action_pressed('aim'):
		_transition.emit(self, 'aimidle')

func _state_physics_process(_delta: float):
	set_direction() # Do these need to be in idle?
	calculate_velocity(base_speed, direction, PLAYER_MOVEMENT_STATS.acceleration, _delta) # Do these need to be in idle?
	replenish_sprint(_delta)

	if direction != Vector3.ZERO:
		_transition.emit(self, 'walk')

	if not is_on_floor():
		_transition.emit(self, 'fall')


# signals
