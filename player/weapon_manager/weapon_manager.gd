class_name WeaponManager extends Node3D


# signal
@warning_ignore('unused_signal')
signal weapon_changed(_status: String, _weapon: Weapon)
signal weapon_manager_started(_status: String, _weapon: Weapon)
signal weapon_manager_finished

# enum
enum WeaponManagerStatus {AVAILABLE, UNAVAILABLE}

# var
static var current_status: WeaponManagerStatus = WeaponManagerStatus.UNAVAILABLE
static var current_weapon: Weapon
static var equip_weapon_wait_time := 0.0
#static var change_weapon_wait_time := 0.0
static var shoot_weapon_wait_time := 0.0
static var reload_weapon_wait_time := 0.0

@export var weapons: Array[Weapon]
@export var weapon_status_timer: Timer


### fn

## virtual
#
func _ready():
	current_weapon = weapons[0]
	set_weapon_wait_time(current_weapon)


## helper
#
func on_combat_status_changed(status: String):
	match status:
		'non_combat':
			set_weapon_manager_status(WeaponManagerStatus.UNAVAILABLE)
			weapon_manager_finished.emit(status)
		'combat':
			start_weapon_manager(status)

func set_weapon_manager_status(status: WeaponManagerStatus):
	current_status = status

func set_weapon_wait_time(weapon: Weapon):
	equip_weapon_wait_time = weapon.weapon_equip_animation.length
	#shoot_weapon_wait_time = weapon.weapon_shoot_animation.length
	#reload_weapon_wait_time = weapon.weapon_reload_animation.length

func wait_for_action_completion(wait_time: float):
	set_weapon_manager_status(WeaponManagerStatus.UNAVAILABLE)
	weapon_status_timer.start(equip_weapon_wait_time)

func start_weapon_manager(status: String):
	weapon_manager_started.emit(status, current_weapon)
	wait_for_action_completion(current_weapon.weapon_equip_animation.length)


## signal
#
func _on_weapon_status_timer_timeout():
	set_weapon_manager_status(WeaponManagerStatus.AVAILABLE)
