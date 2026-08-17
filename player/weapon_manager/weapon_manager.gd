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

# enum
enum WeaponManagerStatus {AVAILABLE, UNAVAILABLE}

# var
var current_status: WeaponManagerStatus = WeaponManagerStatus.UNAVAILABLE
var current_weapon: Weapon
var current_weapon_model: WeaponModel
var action_queue: Callable
var equip_weapon_wait_time := 0.0
var unequip_weapon_wait_time := 0.0
var shoot_weapon_wait_time := 0.0
var reload_weapon_wait_time := 0.0
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
		if Input.is_action_pressed(InputManager.aim):
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
		current_weapon = weapons.front()

		set_weapon_wait_time(current_weapon)
		set_current_weapon_model(current_weapon)

		weapon_manager_started.emit(current_weapon, current_weapon_model)
		equip_or_change_weapon()

func stop_weapon_manager():
	print('Stopping weapon manager')
	print()

	if current_weapon:
		unequip_weapon()

	weapon_manager_stopped.emit()

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
		weapon_manager_unavailable_for(shoot_weapon_wait_time, weapon_timer, check_auto_fire)
		weapon_fired.emit()

		var projectile: Projectile = get_projectile()
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
		var has_largest_ammo: bool = current_weapon.reserve_ammo.front().ammo_count <= current_weapon.current_ammo.ammo_count

		if not has_largest_ammo:
			weapon_reload.emit()
			weapon_manager_unavailable_for(reload_weapon_wait_time, weapon_timer, calculate_reload)

func set_weapon_wait_time(weapon: Weapon):
	equip_weapon_wait_time = weapon.weapon_equip_animation.length
	unequip_weapon_wait_time = weapon.weapon_unequip_animation.length
	shoot_weapon_wait_time = weapon.weapon_shoot_animation.length
	reload_weapon_wait_time = weapon.weapon_reload_animation.length

func equip_or_change_weapon():
	weapon_manager_unavailable_for(equip_weapon_wait_time)

func unequip_weapon():
	weapon_manager_unavailable_for(unequip_weapon_wait_time, weapon_unequip_timer)

func weapon_manager_unavailable_for(wait_time: float, timer := weapon_timer, action := Callable()):
	stop_timers()
	set_weapon_manager_status(WeaponManagerStatus.UNAVAILABLE)
	timer.start(wait_time)
	action_queue = action

# Stop timers from overlapping before handling weapon manager availability during animations
func stop_timers():
	weapon_timer.stop()
	weapon_unequip_timer.stop()

func set_weapon_manager_status(status: WeaponManagerStatus):
	current_status = status

func has_current_ammo():
	return current_weapon.current_ammo and current_weapon.current_ammo.ammo_count > 0

func has_reserve_ammo():
	return current_weapon.reserve_ammo and current_weapon.reserve_ammo.size() > 0

func reduce_ammo(by := 1):
	current_weapon.current_ammo.ammo_count -= by
	ammo_updated.emit(current_weapon)

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

func get_projectile() -> Projectile:
	var projectile: Projectile = current_weapon.current_ammo.projectile.instantiate()
	return projectile

func check_auto_fire():
	if current_weapon.auto_fire and Input.is_action_pressed(InputManager.shoot):
		shoot()

# take as much ammo as allowed from a magazine and return it less what was taken from it
func add_ammo(ammo_arr: Array[Ammo]) -> Array[Ammo]:
	var ammo_taken := ammo_arr.size()
	for ammo in ammo_arr:
		for weapon in weapons:
			if ammo.ammo_type == weapon.name:
				if weapon.reserve_ammo.size() < weapon.max_ammo_magazines or weapon.max_ammo_magazines < 0:
					ammo_taken -= 1
					weapon.reserve_ammo.push_back(ammo)
					break

	ammo_arr.resize(ammo_taken)
	ammo_updated.emit(current_weapon)

	return ammo_arr

func add_weapon(weapon_pickup: WeaponPickup):
	var new_weapon: Weapon = weapon_pickup.internal_weapon

	new_weapon.reserve_ammo.append_array(weapon_pickup.internal_ammo)
	if not new_weapon.reserve_ammo.is_empty():
		new_weapon.current_ammo = new_weapon.reserve_ammo.pop_front()

	weapons.push_back(new_weapon)

	if not current_weapon:
		current_weapon = weapons.front()

		set_weapon_wait_time(current_weapon)
		set_current_weapon_model(current_weapon)

func drop_weapon() -> int:
	var weapon_to_load: WeaponPickup = current_weapon.weapon_to_drop.instantiate()

	weapon_to_load.internal_weapon = current_weapon
	weapon_to_load.global_transform = current_weapon_model.global_transform

	weapon_to_load.internal_ammo.append_array(current_weapon.reserve_ammo)
	current_weapon.reserve_ammo.clear()

	weapon_to_load.internal_ammo.append(current_weapon.current_ammo)
	current_weapon.current_ammo = null

	current_weapon_model.queue_free()
	weapons_node.add_child(weapon_to_load)

	var weapon_i := weapons.find(current_weapon)
	weapons.remove_at(weapon_i)

	if weapons.size() <= 0:
		current_weapon = null
		set_weapon_manager_status(WeaponManagerStatus.UNAVAILABLE)
	else:
		change_weapon()

	return weapons.size()


## signal
#
func _on_weapon_timer_timeout():
	set_weapon_manager_status(WeaponManagerStatus.AVAILABLE)

	if action_queue.is_valid():
		action_queue.call_deferred()
		action_queue = Callable()

func _on_weapon_unequip_timer_timeout():
	set_weapon_manager_status(WeaponManagerStatus.UNAVAILABLE)
	unequip_animation_finished.emit()

func _on_pickup_area_ammo_detected(ammo_pickup: AmmoPickup):
	var pickup: Array[Ammo] = add_ammo(ammo_pickup.internal_ammo.duplicate())

	if pickup.is_empty():
		ammo_pickup.queue_free()

func _on_pickup_area_weapon_detected(weapon_pickup: WeaponPickup):
	if not weapons.has(weapon_pickup.internal_weapon):
		add_weapon(weapon_pickup)
		weapon_pickup.queue_free()
	else:
		var pickup: Array[Ammo]

		pickup.append_array(weapon_pickup.internal_ammo)
		pickup = add_ammo(pickup)

		if pickup.is_empty():
			weapon_pickup.queue_free()
		else:
			weapon_pickup.internal_ammo = pickup
