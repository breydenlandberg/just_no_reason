extends Motion

# signal
# actually a better practice to have sprint_entered and sprint_exited here so they are not exposed to other States

### fn

## virtual
#
func _enter():
	#if previous_state and previous_state.name.to_lower() == 'fall' and not entity.is_attacking:
		#animation.play('Jump_Land')
	#else:
		sprint_started.emit()
		animation.play('Jog_Fwd')

func _state_input(_event: InputEvent):
	if Input.is_action_just_released('sprint'):
		sprint_ended.emit()
		_transition.emit(self, 'walk')

	if Input.is_action_just_pressed('jump'):
		_transition.emit(self, 'sprintjump')

# Rename _delta to delta
func _state_physics_process(_delta: float):
	set_direction()
	calculate_velocity(sprint_speed, direction, PLAYER_MOVEMENT_STATS.acceleration, _delta)
	rotate_model()
	sprint_remaining -= _delta # Reduce sprint

	if direction == Vector3.ZERO:
		sprint_ended.emit()
		_transition.emit(self, 'idle')

	if not is_on_floor():
		sprint_ended.emit()
		_transition.emit(self, 'fall')

	if sprint_remaining <= 0.0:
		sprint_ended.emit()
		_transition.emit(self, 'walk')
