class_name WeaponManager extends Node3D


# signal
@warning_ignore('unused_signal')
signal weapon_changed(_status: String, _weapon: Weapon)
signal weapon_manager_started(_status: String, _weapon: Weapon)
signal weapon_manager_finished

# var
static var current_weapon: Weapon

@export var weapons: Array[Weapon]


### fn

## helper
#
func on_combat_status_changed(status: String):
	match status:
		'non_combat':
			weapon_manager_finished.emit(status)
		'combat':
			start_weapon_manager(status)

func start_weapon_manager(status: String):
	var weapon_i := 0
	weapon_manager_started.emit(status, weapons[weapon_i])
