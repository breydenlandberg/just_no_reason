class_name PlayerModelAnimated extends Node3D


# enum
enum CombatStatus {COMBAT, NONCOMBAT}
var current_combat_status: CombatStatus = CombatStatus.NONCOMBAT

# var
var _input_dir: Vector2

@export var animation_tree: AnimationTree
@export var turn_rate := 0.6


### fn

## helper
#
func on_state_machine_animation_state_changed(state: String):
	match current_combat_status:
		CombatStatus.NONCOMBAT:
			animation_tree['parameters/unarmed_movement/transition_request'] = state
		CombatStatus.COMBAT:
			animation_tree['parameters/armed_movement/transition_request'] = state

func on_combat_status_changed(status: String):
	match status:
		'non_combat':
			current_combat_status = CombatStatus.NONCOMBAT
		'combat':
			current_combat_status = CombatStatus.COMBAT

	animation_tree['parameters/combat_transition/transition_request'] = status

func on_input_direction_changed(input_direction: Vector2):
	if input_direction != Vector2(0, 0):
		_input_dir = _input_dir.slerp(input_direction, turn_rate)

		match current_combat_status:
			CombatStatus.NONCOMBAT:
				pass
			CombatStatus.COMBAT:
				if owner.is_aiming:
					animation_tree["parameters/rifle_aim_walk/blend_position"] = _input_dir

		rotation_degrees.y = owner.camera.rotation_degrees.y - rad_to_deg(_input_dir.angle()) + 90
