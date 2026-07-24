class_name WeaponManager extends Node3D


# signal
@warning_ignore('unused_signal')
signal weapon_changed(_weapon: Weapon)
signal weapon_manager_started(_weapon: Weapon)
signal weapon_manager_stopped
signal unequip_animation_finished
signal weapon_fired
signal weapon_reload

# enum
enum WeaponManagerStatus {AVAILABLE, UNAVAILABLE}

# var
var current_status: WeaponManagerStatus = WeaponManagerStatus.UNAVAILABLE
var current_weapon: Weapon
var equip_weapon_wait_time := 0.0
var unequip_weapon_wait_time := 0.0
var shoot_weapon_wait_time := 0.0
var reload_weapon_wait_time := 0.0

@export var weapons: Array[Weapon]
@export var weapon_equip_change_timer: Timer
@export var weapon_unequip_timer: Timer


### fn

## virtual
#
func _unhandled_input(event: InputEvent):
	if current_status == WeaponManagerStatus.AVAILABLE:
		if event.is_action_pressed(InputManager.shoot):
			shoot()

		if event.is_action_pressed(InputManager.reload_input):
			reload()

		if event.is_action_pressed(InputManager.swap_weapon):
			swap_weapon()

func _process(_delta: float):
	if owner.is_aiming:
		pass
		#update current_weapon.weapon_idle_animation


## helper
#
func on_combat_status_changed(status: String):
	match status:
		'non_combat':
			stop_weapon_manager()
		'combat':
			start_weapon_manager()

func start_weapon_manager():
	if not current_weapon:
		current_weapon = weapons[0]

	set_weapon_wait_time(current_weapon)
	weapon_manager_started.emit(current_weapon)
	equip_or_change_weapon()

func stop_weapon_manager():
	if current_weapon:
		weapon_manager_stopped.emit()
		unequip_weapon()

func swap_weapon():
	var weapon_i: int = weapons.find(current_weapon)

	if weapon_i >= weapons.size() - 1:
		weapon_i = 0
	else:
		weapon_i = weapon_i + 1

	if not weapons[weapon_i] == current_weapon:
		current_weapon = weapons[weapon_i]
		set_weapon_wait_time(current_weapon)
		weapon_changed.emit(current_weapon)
		equip_or_change_weapon()

func shoot():
	weapon_fired.emit()

func reload():
	weapon_reload.emit()

func set_weapon_wait_time(weapon: Weapon):
	equip_weapon_wait_time = weapon.weapon_equip_animation.length
	unequip_weapon_wait_time = weapon.weapon_unequip_animation.length
	shoot_weapon_wait_time = weapon.weapon_shoot_animation.length
	reload_weapon_wait_time = weapon.weapon_reload_animation.length

func equip_or_change_weapon():
	weapon_unequip_timer.stop()
	set_weapon_manager_status(WeaponManagerStatus.UNAVAILABLE)
	weapon_equip_change_timer.start(equip_weapon_wait_time)

func unequip_weapon():
	weapon_equip_change_timer.stop()
	set_weapon_manager_status(WeaponManagerStatus.UNAVAILABLE)
	weapon_unequip_timer.start(unequip_weapon_wait_time)

func set_weapon_manager_status(status: WeaponManagerStatus):
	current_status = status


## signal
#
func _on_weapon_equip_change_timer_timeout():
	set_weapon_manager_status(WeaponManagerStatus.AVAILABLE)

func _on_weapon_unequip_timer_timeout():
	set_weapon_manager_status(WeaponManagerStatus.UNAVAILABLE)
	unequip_animation_finished.emit()
