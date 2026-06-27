class_name PlayerModelAnimated extends Node3D


# var
var _input_dir: Vector2

@export var animation_tree: AnimationTree
@export var turn_rate := 0.7

### fn

## helper
#
func on_state_machine_animation_state_changed(state: String):
	animation_tree['parameters/unarmed_movement/transition_request'] = state

func on_input_direction_changed(input_direction: Vector2):
	if input_direction != Vector2(0, 0):
		_input_dir = _input_dir.slerp(input_direction, turn_rate)
		rotation_degrees.y = owner.camera.rotation_degrees.y - rad_to_deg(_input_dir.angle()) + 90
