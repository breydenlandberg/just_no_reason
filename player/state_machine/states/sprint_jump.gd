extends PlayerMotionState


### fn

## virtual
#
func _enter():
	jump()
	super._enter()

func _state_physics_process(_delta: float):
	set_direction()
	calculate_gravity(_delta)
	calculate_velocity(sprint_speed, direction, PLAYER_MOVEMENT_STATS.in_air_acceleration, _delta)
	_rotate_model.emit(input_dir)

	if velocity.y <= 0.0:
		_transition.emit(self, 'sprintfall')


## helper
#
func jump():
	velocity.y = jump_velocity
