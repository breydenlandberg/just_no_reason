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
		weapon_detected.emit(body)
