extends Area3D


# signal
@warning_ignore('unused_signal')
signal ammo_detected(ammo_pickup: AmmoPickup)
@warning_ignore('unused_signal')
signal weapon_detected(weapon_pickup: WeaponPickup)


### fn
##

# signal
func _on_body_entered(body: Node3D):
	if body is AmmoPickup:
		ammo_detected.emit(body)
	elif body is WeaponPickup:
		if body.pickup_ready:
			weapon_detected.emit(body)
		else:
			if not body.became_ready.is_connected(_on_weapon_became_ready):
				body.became_ready.connect(_on_weapon_became_ready, CONNECT_ONE_SHOT)

func _on_weapon_became_ready(weapon_pickup: WeaponPickup):
	if overlaps_body(weapon_pickup):
		weapon_detected.emit(weapon_pickup)
