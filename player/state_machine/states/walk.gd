extends Motion


### fn

## virtual
#
func _enter():
	#if previous_state and previous_state.name.to_lower() == 'fall' and not entity.is_attacking:
		#animation.play('Jump_Land')
	#else:
		animation.play('Walk')

func _state_input(_event: InputEvent):
	if Input.is_action_just_pressed('jump'):
		_transition.emit(self, 'jump')

func _state_physics_process(_delta: float):
	set_direction()
	calculate_velocity(base_speed, direction, _delta)
	rotate_model()

	if direction == Vector3.ZERO:
		_transition.emit(self, 'idle')

	if not is_on_floor():
		_transition.emit(self, 'fall')
