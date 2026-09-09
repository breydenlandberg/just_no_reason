class_name WeaponPickup extends RigidBody3D


# signal
signal became_ready(weapon_pickup: WeaponPickup)

# var
@export var internal_weapon: Weapon
@export var internal_ammo: Array[Ammo]

var pickup_ready := true


### fn

## helper
#
func start_drop_cooldown(duration := 2.5):
	pickup_ready = false
	await get_tree().create_timer(duration).timeout
	pickup_ready = true
	became_ready.emit(self)
