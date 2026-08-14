class_name WeaponPickup extends RigidBody3D


# var
@export var internal_weapon: Weapon
@export var internal_ammo: Array[Ammo]
@export var pickup_ready := false # does need to be an export var?


### fn

## virtual
#
func _ready():
	await get_tree().create_timer(2.5).timeout
	pickup_ready = true
