extends Motion


# @export var
@export var floor_ray_cast: RayCast3D


### fn

## virtual
#
#func _enter():
	#_animation_state_changed.emit('fall')

	#if not entity.is_attacking:
		#entity.animation.play('Jump')
	#return super._enter()

func _state_physics_process(_delta: float):
	set_direction()
	calculate_gravity(_delta)
	calculate_velocity(base_speed, direction, PLAYER_MOVEMENT_STATS.in_air_acceleration, _delta)
	#rotate_model()
	_input_direction_changed.emit(input_dir)
	replenish_sprint(_delta)

	#if floor_ray_cast.is_colliding():
		#_animation_state_changed.emit('land')

	if is_on_floor():
		if direction != Vector3.ZERO:
			if Input.is_action_pressed('sprint'):
				_transition.emit(self, 'sprint')
			else:
				_transition.emit(self, 'walk')
		else:
			_transition.emit(self, 'idle')
