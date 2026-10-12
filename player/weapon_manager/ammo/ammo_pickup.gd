class_name AmmoPickup extends RigidBody3D


# vars
@export var internal_ammo: Array[Ammo]


### fn

## virtual
#
func _ready():
	for i in range(internal_ammo.size()):
		internal_ammo[i] = internal_ammo[i].duplicate()
