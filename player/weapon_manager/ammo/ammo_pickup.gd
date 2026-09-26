class_name AmmoPickup extends RigidBody3D

# var
@export var internal_ammo: Array[Ammo]


### fn

## helper
#
func _ready():
	for i in range(internal_ammo.size()):
		internal_ammo[i] = internal_ammo[i].duplicate()
