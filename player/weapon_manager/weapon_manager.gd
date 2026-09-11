class_name WeaponManager extends Node3D


# signal
signal weapon_manager_started(_weapon: Weapon, _weapon_model: WeaponModel)
signal weapon_manager_stopped()
signal unequip_animation_finished
signal weapon_changed(_weapon: Weapon, _weapon_model: WeaponModel)
signal weapon_aim_entered(_weapon: Weapon)
signal weapon_aim_exited(_weapon: Weapon)
signal weapon_fired
signal weapon_reload
signal ammo_updated(_weapon: Weapon)
signal ammo_magazines_updated(_weapon: Weapon)

# enum
enum WeaponManagerStatus {AVAILABLE, UNAVAILABLE}

# var
var current_status: WeaponManagerStatus = WeaponManagerStatus.UNAVAILABLE
var current_weapon: Weapon
var current_weapon_model: WeaponModel
var action_queue: Callable
var weapons_node: Node3D

static var combat_status: StringName = 'combat'
static var non_combat_status: StringName = 'non_combat'

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
		if Input.is_action_just_pressed(InputManager.aim):
			weapon_aim_entered.emit(current_weapon)

		if Input.is_action_just_released(InputManager.aim):
			weapon_aim_exited.emit(current_weapon)


## helper
#
func on_combat_status_changed(status: StringName):
	match status:
		combat_status:
			start_weapon_manager()
		non_combat_status:
			stop_weapon_manager()

func start_weapon_manager():
	print('Starting weapon manager')
	print()

	if not weapons.is_empty():
		if not current_weapon or not weapons.has(current_weapon):
			current_weapon = weapons.front()

		set_current_weapon_model(current_weapon)

		weapon_manager_started.emit(current_weapon, current_weapon_model)
		weapon_manager_unavailable_for(current_weapon.weapon_equip_animation.length)

func stop_weapon_manager():
	print('Stopping weapon manager')
	print()

	if current_weapon:
		weapon_manager_unavailable_for(current_weapon.weapon_unequip_animation.length, weapon_unequip_timer)

	weapon_manager_stopped.emit()

func change_weapon():
	var weapon_i: int = weapons.find(current_weapon)

	weapon_i = wrapi(weapon_i + 1, 0, weapons.size())

	if not weapons[weapon_i] == current_weapon:
		current_weapon = weapons[weapon_i]

		set_current_weapon_model(current_weapon)

		weapon_changed.emit(current_weapon, current_weapon_model)
		weapon_manager_unavailable_for(current_weapon.weapon_equip_animation.length)
		ammo_updated.emit(current_weapon)
		ammo_magazines_updated.emit(current_weapon)

func shoot():
	if has_current_ammo():
		weapon_manager_unavailable_for(current_weapon.weapon_shoot_animation.length, weapon_timer, check_auto_fire)
		weapon_fired.emit()

		var projectile: Projectile = current_weapon.current_ammo.projectile.instantiate()
		add_child(projectile)
		projectile._set_weapon_projectile(current_weapon, current_weapon_model)

		reduce_ammo()
	else:
		reload()

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
		var current_count := current_weapon.current_ammo.ammo_count if current_weapon.current_ammo else 0
		var has_largest_ammo: bool = current_weapon.reserve_ammo.front().ammo_count <= current_count

		if not has_largest_ammo:
			weapon_reload.emit()
			weapon_manager_unavailable_for(current_weapon.weapon_reload_animation.length, weapon_timer, calculate_reload)

func weapon_manager_unavailable_for(wait_time: float, timer := weapon_timer, action := Callable()):
	stop_timers()
	current_status = WeaponManagerStatus.UNAVAILABLE
	timer.start(wait_time)
	action_queue = action

# Stop timers from overlapping before handling weapon manager availability during animations
func stop_timers():
	weapon_timer.stop()
	weapon_unequip_timer.stop()

func has_current_ammo():
	return current_weapon.current_ammo and current_weapon.current_ammo.ammo_count > 0

func has_reserve_ammo():
	return current_weapon.reserve_ammo and current_weapon.reserve_ammo.size() > 0

func reduce_ammo(by := 1):
	current_weapon.current_ammo.ammo_count -= by
	ammo_updated.emit(current_weapon)

func sort_reserve_ammo(weapon: Weapon):
	# Largest magazine first, smallest magazine last
	weapon.reserve_ammo.sort_custom(func(a: Ammo, b: Ammo): return a.ammo_count > b.ammo_count)

# See comment at reload()
func calculate_reload():
	# These print statements will illustrate how ammo is handled in this game
	#print('BEFORE:')
	#print('current_ammo: ', current_weapon.current_ammo.ammo_count)
	#print('reserve_ammo:')
	#for ammo in current_weapon.reserve_ammo:
		#print(ammo.ammo_count)
	#print()

	if has_current_ammo():
		current_weapon.reserve_ammo.push_back(current_weapon.current_ammo)

	if has_reserve_ammo():
		sort_reserve_ammo(current_weapon)
		current_weapon.current_ammo = current_weapon.reserve_ammo.pop_front()

	ammo_updated.emit(current_weapon)
	ammo_magazines_updated.emit(current_weapon)
	$PickupArea.check_overlapping_pickups()

	#print('AFTER:')
	#print('current_ammo: ', current_weapon.current_ammo.ammo_count)
	#print('reserve_ammo:')
	#for ammo in current_weapon.reserve_ammo:
		#print(ammo.ammo_count)
	#print()

func set_current_weapon_model(weapon: Weapon):
	var new_weapon_model: WeaponModel = weapon.weapon_model.instantiate()
	current_weapon_model = new_weapon_model

func check_auto_fire():
	if current_weapon.auto_fire and Input.is_action_pressed(InputManager.shoot):
		shoot()

# take as much ammo as allowed from a magazine and return it less what was taken from it
func add_ammo(ammo_arr: Array[Ammo]) -> Array[Ammo]:
	var remaining_ammo: Array[Ammo] = []

	# Largest magazine first, smallest magazine last
	ammo_arr.sort_custom(func(a: Ammo, b: Ammo): return a.ammo_count > b.ammo_count)
	for ammo in ammo_arr:
		var collected := false
		for weapon in weapons:
			if ammo.ammo_type == weapon.name:
				if weapon.reserve_ammo.size() < weapon.max_ammo_magazines or weapon.max_ammo_magazines < 0:
					weapon.reserve_ammo.push_back(ammo)
					collected = true
					sort_reserve_ammo(weapon)
					break
		if not collected:
			remaining_ammo.append(ammo)

	ammo_updated.emit(current_weapon)
	ammo_magazines_updated.emit(current_weapon)
	return remaining_ammo

func add_weapon(weapon_pickup: WeaponPickup):
	var new_weapon: Weapon = weapon_pickup.internal_weapon

	new_weapon.reserve_ammo.clear()
	new_weapon.reserve_ammo.append_array(weapon_pickup.internal_ammo)

	if not new_weapon.reserve_ammo.is_empty():
		new_weapon.current_ammo = new_weapon.reserve_ammo.pop_front()
	else:
		new_weapon.current_ammo = null
	sort_reserve_ammo(new_weapon)

	weapons.push_back(new_weapon)

	if not current_weapon:
		current_weapon = weapons.front()

func drop_weapon() -> int:
	var weapon_to_load: WeaponPickup = current_weapon.weapon_to_drop.instantiate()

	weapon_to_load.internal_weapon = current_weapon
	weapon_to_load.global_transform = current_weapon_model.global_transform

	if current_weapon.current_ammo: # has_current_ammo() confusion?
		weapon_to_load.internal_ammo.append(current_weapon.current_ammo)
		current_weapon.current_ammo = null

	weapon_to_load.internal_ammo.append_array(current_weapon.reserve_ammo)
	current_weapon.reserve_ammo.clear()

	current_weapon_model.queue_free()
	weapons_node.add_child(weapon_to_load)
	weapon_to_load.start_drop_cooldown()

	var weapon_i := weapons.find(current_weapon)
	weapons.remove_at(weapon_i)

	if weapons.size() <= 0:
		current_weapon = null
		stop_timers()
		current_status = WeaponManagerStatus.UNAVAILABLE
	else:
		change_weapon()

	return weapons.size()


## signal
#
func _on_weapon_timer_timeout():
	if current_weapon:
		current_status = WeaponManagerStatus.AVAILABLE

		if action_queue.is_valid():
			action_queue.call_deferred()
			action_queue = Callable()

func _on_weapon_unequip_timer_timeout():
	current_status = WeaponManagerStatus.UNAVAILABLE
	unequip_animation_finished.emit()

func _on_pickup_area_ammo_detected(ammo_pickup: AmmoPickup):
	var remaining: Array[Ammo] = add_ammo(ammo_pickup.internal_ammo)

	if remaining.is_empty():
		ammo_pickup.queue_free()
	else:
		ammo_pickup.internal_ammo = remaining

func _on_pickup_area_weapon_detected(weapon_pickup: WeaponPickup):
	if not weapons.has(weapon_pickup.internal_weapon):
		add_weapon(weapon_pickup)
		weapon_pickup.queue_free()
		# If we decide that there's ever a scenario in which, while we're inside an ammo pickup, we also enter a weapon pickup...
		#$PickupArea.check_overlapping_pickups()
	else:
		var remaining: Array[Ammo] = add_ammo(weapon_pickup.internal_ammo)

		if remaining.is_empty():
			weapon_pickup.queue_free()
		else:
			weapon_pickup.internal_ammo = remaining
