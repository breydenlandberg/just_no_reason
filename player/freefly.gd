extends State


### fn

## virtual
#
func _enter():
	player = entity

func _state_physics_process(_delta: float):
	pass
	#var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
	#var motion := (camera.global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#motion *= freefly_speed * delta
#
	#if input_dir != Vector2(0, 0):
		#player_model.rotation_degrees.y = camera.rotation_degrees.y - rad_to_deg(input_dir.angle()) + 90
#
	#move_and_collide(motion)
	#return
