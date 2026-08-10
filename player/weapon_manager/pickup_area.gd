extends Area3D


# signal
@warning_ignore('unused_signal')
signal ammo_detected(_ammo_pickup: AmmoPickup)


### fn
##

# signal
func _on_body_entered(body: Node3D):
	if body is AmmoPickup:
		ammo_detected.emit(body)
