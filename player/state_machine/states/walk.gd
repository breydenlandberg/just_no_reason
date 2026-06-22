extends Motion


### fn

## virtual
#
func _enter():
	_animation_state_changed.emit('walk')

	#if previous_state and previous_state.name.to_lower() == 'fall' and not entity.is_attacking:
		#animation.play('Jump_Land')
	#else:
		#animation.play('Walk')

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
	#rotate_model()
	_input_direction_changed.emit(input_dir)
	replenish_sprint(_delta)

	if direction == Vector3.ZERO:
		_transition.emit(self, 'idle')

	if not is_on_floor():
		_transition.emit(self, 'fall')
