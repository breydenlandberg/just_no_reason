extends PlayerMotionState


# signal
signal aim_entered
signal aim_exited

### fn

## virtual
#
func _enter():
	aim_entered.emit()
	super._enter()

func _state_input(_event: InputEvent):
	if _event.is_action_pressed(InputManager.freefly):
		aim_exited.emit()
		_transition.emit(self, States.freefly)

	if _event.is_action_pressed(InputManager.jump):
		aim_exited.emit()
		_transition.emit(self, 'jump')

func _state_process(_delta: float):
	if Input.is_action_just_released(InputManager.aim):
		aim_exited.emit()
		_transition.emit(self, 'idle')

func _state_physics_process(_delta: float):
	set_direction()
	calculate_velocity(aim_speed, direction, PLAYER_MOVEMENT_STATS.acceleration, _delta)
	replenish_sprint(_delta)

	if direction != Vector3.ZERO:
		_transition.emit(self, 'aimwalk')

	if not is_on_floor():
		aim_exited.emit()
		_transition.emit(self, 'fall')
