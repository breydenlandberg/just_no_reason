class_name PickupArea extends Area3D


# signal
@warning_ignore('unused_signal')
signal ammo_detected(ammo_pickup: AmmoPickup)
@warning_ignore('unused_signal')
signal weapon_detected(weapon_pickup: WeaponPickup)


### fn
##

# helper
func check_overlapping_pickups():
	for body in get_overlapping_bodies():
		if is_instance_valid(body) and not body.is_queued_for_deletion():
			detect_pickup(body)

func detect_pickup(body: Node3D):
	if body is WeaponPickup:
		if body.pickup_ready:
			weapon_detected.emit(body)
		else:
			if not body.became_ready.is_connected(_on_weapon_became_ready):
				body.became_ready.connect(_on_weapon_became_ready, CONNECT_ONE_SHOT)
	elif body is AmmoPickup:
		ammo_detected.emit(body)

# signal
func _on_body_entered(body: Node3D):
	detect_pickup(body)

func _on_weapon_became_ready(weapon_pickup: WeaponPickup):
	if overlaps_body(weapon_pickup):
		weapon_detected.emit(weapon_pickup)
