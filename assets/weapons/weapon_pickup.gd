class_name WeaponPickup extends RigidBody3D


# var
@export var internal_weapon: Weapon
@export var internal_ammo: Array[Ammo]

var pickup_ready := false


### fn

## virtual
#
func _ready():
	await get_tree().create_timer(2.5).timeout
	pickup_ready = true
