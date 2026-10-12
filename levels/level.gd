class_name Level extends Node3D


# vars
@export var player_spawn: Marker3D
@export var dropped_weapons_container: Node3D


### fn

## virtual
#
func _ready():
	SignalBus.weapon_dropped.connect(_on_weapon_dropped)

	if not dropped_weapons_container:
		dropped_weapons_container = get_node_or_null('DroppedWeapons')


## signals
#
func _on_weapon_dropped(pickup: WeaponPickup) -> void:
	var drop_transform = pickup.transform

	if dropped_weapons_container:
		dropped_weapons_container.add_child(pickup)
	else:
		add_child(pickup)

	pickup.global_transform = drop_transform
