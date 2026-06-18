class_name PlayerModelAnimated extends Node3D


# @export var
@export var animation_tree: AnimationTree

### fn

## helper
#
func on_state_machine_animation_state_changed(state: String):
	animation_tree['parameters/unarmed_movement/transition_request'] = state
