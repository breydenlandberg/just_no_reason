class_name WeaponManager extends Node3D


# signal
signal weapon_manager_started(_weapon: Weapon, _weapon_model: WeaponModel)
signal weapon_manager_stopped
signal unequip_animation_finished
signal weapon_changed(_weapon: Weapon, _weapon_model: WeaponModel)
signal weapon_aim_entered(_weapon: Weapon)
signal weapon_aim_exited(_weapon: Weapon)
signal weapon_fired
signal weapon_reload
signal ammo_updated(_weapon: Weapon)

# enum
enum WeaponManagerStatus {AVAILABLE, UNAVAILABLE}

# var
var current_status: WeaponManagerStatus = WeaponManagerStatus.UNAVAILABLE
var current_weapon: Weapon
var current_weapon_model: WeaponModel
var equip_weapon_wait_time := 0.0
var unequip_weapon_wait_time := 0.0
var shoot_weapon_wait_time := 0.0
var reload_weapon_wait_time := 0.0

@export var weapons: Array[Weapon]
@export var weapon_timer: Timer # Weapon equip, change, shoot, reload - we want to make the WeaponManager unavailable during known animations
@export var weapon_unequip_timer: Timer # Separate timer since we need to despawn the weapon specifically after unequipping


### fn

## virtual
#
func _unhandled_input(event: InputEvent):
	if current_status == WeaponManagerStatus.AVAILABLE:
		if event.is_action_pressed(InputManager.shoot):
			shoot()

		if event.is_action_pressed(InputManager.reload_input):
			reload()

		if event.is_action_pressed(InputManager.change_weapon):
			change_weapon()


func _process(_delta: float):
	if current_status == WeaponManagerStatus.AVAILABLE:
		if Input.is_action_pressed(InputManager.aim):
			weapon_aim_entered.emit(current_weapon)

		if Input.is_action_just_released(InputManager.aim):
			weapon_aim_exited.emit(current_weapon)

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
	set_current_weapon_model(current_weapon)
	weapon_manager_started.emit(current_weapon, current_weapon_model)
	equip_or_change_weapon()

func stop_weapon_manager():
	if current_weapon:
		weapon_manager_stopped.emit()
		unequip_weapon()

func change_weapon():
	var weapon_i: int = weapons.find(current_weapon)

	weapon_i = wrapi(weapon_i + 1, 0, weapons.size())

	if not weapons[weapon_i] == current_weapon:
		current_weapon = weapons[weapon_i]
		set_weapon_wait_time(current_weapon)
		set_current_weapon_model(current_weapon)
		weapon_changed.emit(current_weapon, current_weapon_model)
		ammo_updated.emit(current_weapon)
		equip_or_change_weapon()

func shoot():
	if has_current_ammo():
		weapon_manager_unavailable_for(shoot_weapon_wait_time)
		weapon_fired.emit()
		var projectile: Projectile = get_projectile()
		add_child(projectile)
		projectile._set_weapon_projectile(current_weapon, current_weapon_model)
		reduce_ammo()
	else:
		reload()

func get_projectile() -> Projectile:
	var projectile: Projectile = current_weapon.current_ammo.projectile.instantiate()
	return projectile

# This comment encompasses the logic in calculate_reload() as well
#
# The ammo system works on the principles that the player:
# - Handles discrete "magazines" (i.e. Ammo Resources), which realistically retain their own ammo counts
# - Performs "tactical" reloads
#
# This means that:
# - Fully expending a magazine will cause it to be completely discarded. You will have no ammo left once you've expended all your magazines.
# - If the player reloads before fully expending a magazine, it will be put back and retained as reserve ammo
# - You will always reload to the largest magazine you have in reserve ammo.
# - You will only be allowed to reload if your current magazine is smaller than your largest magazine in reserve ammo
#
# As a side note, it is therefore possible to have a total ammo count greater than a full magazine, but since each magazine
# you currently have is not full, you would not be able to reload to get a full magazine.
func reload():
	if has_reserve_ammo():
		var has_largest_ammo := current_weapon.reserve_ammo[0].ammo_count <= current_weapon.current_ammo.ammo_count

		if not has_largest_ammo:
			weapon_manager_unavailable_for(reload_weapon_wait_time)
			weapon_reload.emit()
			calculate_reload()

func set_weapon_wait_time(weapon: Weapon):
	equip_weapon_wait_time = weapon.weapon_equip_animation.length
	unequip_weapon_wait_time = weapon.weapon_unequip_animation.length
	shoot_weapon_wait_time = weapon.weapon_shoot_animation.length
	reload_weapon_wait_time = weapon.weapon_reload_animation.length

func equip_or_change_weapon():
	weapon_manager_unavailable_for(equip_weapon_wait_time)

func unequip_weapon():
	weapon_manager_unavailable_for(unequip_weapon_wait_time, weapon_unequip_timer)

func weapon_manager_unavailable_for(wait_time: float, timer := weapon_timer):
	stop_timers()
	set_weapon_manager_status(WeaponManagerStatus.UNAVAILABLE)
	timer.start(wait_time)

# Stop timers from overlapping before handling weapon manager availability during animations
func stop_timers():
	weapon_timer.stop()
	weapon_unequip_timer.stop()

func set_weapon_manager_status(status: WeaponManagerStatus):
	current_status = status

func has_current_ammo():
	return current_weapon.current_ammo and current_weapon.current_ammo.ammo_count > 0

func has_reserve_ammo():
	return current_weapon.reserve_ammo.size() > 0

func reduce_ammo(by := 1):
	current_weapon.current_ammo.ammo_count -= by
	ammo_updated.emit(current_weapon)

# See comment at reload()
func calculate_reload():
	#print('BEFORE:')
	#print('current_ammo: ', current_weapon.current_ammo.ammo_count)
	#print('reserve_ammo:')
	#for ammo in current_weapon.reserve_ammo:
		#print(ammo.ammo_count)
	#print()

	if has_current_ammo():
		current_weapon.reserve_ammo.push_back(current_weapon.current_ammo)

	if has_reserve_ammo():
		current_weapon.current_ammo = current_weapon.reserve_ammo.pop_front().duplicate(true)
		current_weapon.reserve_ammo.sort_custom(func(a, b): return a.ammo_count > b.ammo_count)

	ammo_updated.emit(current_weapon)

	#print('AFTER:')
	#print('current_ammo: ', current_weapon.current_ammo.ammo_count)
	#print('reserve_ammo:')
	#for ammo in current_weapon.reserve_ammo:
		#print(ammo.ammo_count)
	#print()

func set_current_weapon_model(weapon: Weapon):
	var new_weapon_model: WeaponModel = weapon.weapon_model.instantiate()
	current_weapon_model = new_weapon_model


## signal
#
func _on_weapon_timer_timeout():
	set_weapon_manager_status(WeaponManagerStatus.AVAILABLE)

func _on_weapon_unequip_timer_timeout():
	set_weapon_manager_status(WeaponManagerStatus.UNAVAILABLE)
	unequip_animation_finished.emit()
