class_name State extends Node3D


# signals
signal _transition(state, new_state)

# var
var animation: AnimationPlayer
var attack_animation: AnimationPlayer
var collider: CollisionShape3D # ?
var entity: CharacterBody3D
var mesh: MeshInstance3D # ?
var previous_state: State


### fn

## virtual
#
# Used when entering a new_state
func _enter():
	pass

# Used when exiting the current_state
func _exit():
	pass

# Handle an input event in the current state
func _state_input(event: InputEvent):
	pass

# Whenever the state machine is processing, we also want the current state to process (NON-PHYSICS)
func _state_process(delta: float):
	pass

# Whenever the state machine is processing, we also want the current state to process (PHYSICS)
func _state_physics_process(delta: float):
	pass
