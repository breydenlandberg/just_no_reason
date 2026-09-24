class_name Level extends Node3D


# var
@export var player_spawn: Marker3D
@export var dropped_weapons_container: Node3D


### fn

## virtual
#
func _ready():
	SignalBus.weapon_dropped.connect(_on_weapon_dropped)


## signal
#
func _on_weapon_dropped(pickup: WeaponPickup):
	if dropped_weapons_container:
		dropped_weapons_container.add_child(pickup)
	else:
		add_child(pickup)
