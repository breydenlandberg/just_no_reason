class_name WeaponPickup extends RigidBody3D


# signal
signal became_ready(weapon_pickup: WeaponPickup)

# var
@export var internal_weapon: Weapon
@export var internal_ammo: Array[Ammo]
@export var visual_node: Node3D

var pickup_ready := true
var custom_visual_scale := Vector3.ZERO


### fn

# virtual / private
#
func _ready():
	if internal_ammo:
		for i in range(internal_ammo.size()):
			internal_ammo[i] = internal_ammo[i].duplicate()

	if visual_node:
		_apply_visual_scale()
	else:
		push_error('visual_node not assigned in ', self)

func _apply_visual_scale() -> void:
	if not visual_node:
		return

	if custom_visual_scale != Vector3.ZERO:
		visual_node.scale = custom_visual_scale
	elif internal_weapon:
		visual_node.scale = internal_weapon.get_world_scale()


## helper
#
func start_drop_cooldown(duration := 2.5) -> void:
	pickup_ready = false
	await get_tree().create_timer(duration).timeout
	pickup_ready = true
	became_ready.emit(self)

func set_visual_scale(target_scale: Vector3) -> void:
	custom_visual_scale = target_scale

	if visual_node:
		visual_node.scale = target_scale
