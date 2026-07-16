class_name PlayerModelAnimated extends Node3D


# enum
enum CombatStatus {COMBAT, NONCOMBAT}
var current_combat_status: CombatStatus = CombatStatus.NONCOMBAT

# var
var _input_dir: Vector2

@export var animation_tree: AnimationTree
@export var right_hand: Node3D
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

# called by rotate_model()
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

func on_combat_status_changed(status: String):
	match status:
		'non_combat':
			current_combat_status = CombatStatus.NONCOMBAT
		'combat':
			current_combat_status = CombatStatus.COMBAT

	animation_tree['parameters/combat_transition/transition_request'] = status

func load_new_weapon(weapon: Weapon):
	right_hand.position = weapon.hand_position
	right_hand.rotation = weapon.hand_rotation

	equip_weapon_animation()

	attach_weapon_to_hand(weapon.weapon_model)

func deload_current_weapon():
	# when we fix the animation and want to detach the weapon from the hand at the correct frame of the animation,
	# watch https://www.youtube.com/watch?v=tcmNGIyBXzo&list=PLhnGgh9GDmn6Cf4_ut7I0VJNHh9Vbfkjv
	unequip_weapon_animation()

func attach_weapon_to_hand(scene: PackedScene):
	var new_weapon: Node3D = scene.instantiate()
	right_hand.add_child(new_weapon)

func equip_weapon_animation():
	animation_tree['parameters/equip_weapon/request'] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

func unequip_weapon_animation():
	animation_tree['parameters/unequip_weapon/request'] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE


## signal
#
func _on_weapon_manager_started(_status: String, _weapon: Weapon):
	on_combat_status_changed(_status)
	load_new_weapon(_weapon)

func _on_weapon_manager_stopped(_status: String):
	on_combat_status_changed(_status)
	deload_current_weapon()

func _on_weapon_manager_unequip_animation_finished() -> void:
	if right_hand.get_child_count() > 0:
		var current_weapon: Node3D = right_hand.get_child(0)
		current_weapon.queue_free()
