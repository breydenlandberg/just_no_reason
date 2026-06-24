extends Motion


### fn

## virtual
#
func _enter():
	#_animation_state_changed.emit('jump')
	jump()
	super._enter()

func _state_physics_process(_delta: float):
	set_direction()
	calculate_gravity(_delta)
	calculate_velocity(base_speed, direction, PLAYER_MOVEMENT_STATS.in_air_acceleration, _delta)
	rotate_model()

	if velocity.y <= 0.0:
		_transition.emit(self, 'fall')


## helper
#
func jump():
	velocity.y = jump_velocity
	
	if not entity.is_attacking:
		entity.animation.play('Jump_Start')
