class_name PlayerModelAnimated extends Node3D


# enum
enum CombatStatus {COMBAT, NONCOMBAT}

# var
var current_combat_status: CombatStatus = CombatStatus.NONCOMBAT
var input_direction: Vector2

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
func on_input_direction_changed(_input_dir: Vector2):
	if _input_dir != Vector2(0, 0):
		input_direction = input_direction.slerp(_input_dir, turn_rate)

		match current_combat_status:
			CombatStatus.NONCOMBAT:
				pass
			CombatStatus.COMBAT:
				if owner.is_aiming:
					animation_tree["parameters/rifle_aim_walk/blend_position"] = input_direction

		rotation_degrees.y = owner.camera.rotation_degrees.y - rad_to_deg(input_direction.angle()) + 90

func on_combat_status_changed(status: String):
	match status:
		'non_combat':
			current_combat_status = CombatStatus.NONCOMBAT
		'combat':
			current_combat_status = CombatStatus.COMBAT

	animation_tree['parameters/combat_transition/transition_request'] = status

func load_new_weapon(weapon: Weapon):
	clear_weapon_from_hand()

	animation_tree.tree_root.get_node('weapon_idle_animation').set_animation(weapon.weapon_idle_animation.resource_name)
	animation_tree.tree_root.get_node('weapon_equip_animation').set_animation(weapon.weapon_equip_animation.resource_name)
	animation_tree.tree_root.get_node('weapon_unequip_animation').set_animation(weapon.weapon_unequip_animation.resource_name)
	animation_tree.tree_root.get_node('weapon_shoot_animation').set_animation(weapon.weapon_shoot_animation.resource_name)
	animation_tree.tree_root.get_node('weapon_reload_animation').set_animation(weapon.weapon_reload_animation.resource_name)

	right_hand.position = weapon.hand_position
	right_hand.rotation = weapon.hand_rotation

	animation_tree['parameters/equip_weapon/request'] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	attach_weapon_to_hand(weapon)

func deload_current_weapon():
	# when we fix the animation and want to detach the weapon from the hand at the correct frame of the animation,
	# watch https://www.youtube.com/watch?v=tcmNGIyBXzo&list=PLhnGgh9GDmn6Cf4_ut7I0VJNHh9Vbfkjv
	animation_tree['parameters/unequip_weapon/request'] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

func attach_weapon_to_hand(weapon: Weapon):
	var new_weapon: Node3D = weapon.weapon_model.instantiate()
	new_weapon.scale = weapon.scale
	right_hand.add_child(new_weapon)

func clear_weapon_from_hand():
	if right_hand.get_child_count() > 0:
		for child in right_hand.get_children():
			child.queue_free()


## signal
#
func _on_weapon_manager_started(_weapon: Weapon):
	on_combat_status_changed('combat') # this param used to be passed all the way from weapon_manager on_combat_status_changed... i'm not sure the pros and cons of this vs that
	load_new_weapon(_weapon)

func _on_weapon_manager_stopped():
	on_combat_status_changed('non_combat') # this param used to be passed all the way from weapon_manager on_combat_status_changed... i'm not sure the pros and cons of this vs that
	deload_current_weapon()

func _on_weapon_manager_weapon_changed(_weapon: Weapon):
	load_new_weapon(_weapon)

func _on_weapon_manager_unequip_animation_finished():
	clear_weapon_from_hand()

func _on_weapon_manager_weapon_fired():
	animation_tree['parameters/shoot/request'] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

func _on_weapon_manager_weapon_reload():
	animation_tree['parameters/reload/request'] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
