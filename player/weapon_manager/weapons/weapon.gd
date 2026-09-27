class_name Weapon extends Resource


# var
@export var name: String
@export var weapon_model: PackedScene
@export var auto_fire := false
@export_file('*.tscn') var weapon_to_drop: String

@export var hand_position: Vector3
@export var hand_rotation: Vector3
## This is the ultimate determination of a weapon's 3D model size - the game code will automatically synchronise the 3D model scale of a WeaponPickup and a WeaponInstance. A WeaponPickup's 3D model size can therefore be set to [b]0.01 * scale_value[/b][br][br]
## 0.01 is the standard Mixamo bone unit scale. This can allow us to get accurate visuals in editor (eg for setting correct CollisionShape3D size)[br][br]
## [b]Current values:[/b][br]
## AssaultRifle scale_value = [b]18[/b], AssaultRiflePickup 3D model scale = [b]0.18[/b][br]
## Quasar scale_value = [b]3[/b], QuasarPickup 3D model scale = [b]0.03[/b]
@export var scale_value := 1.0

@export var weapon_idle_animation: Animation
@export var weapon_aim_idle_animation: Animation 	# We will update the weapon_idle_animation to this in the AnimationTree when aim entered
													# and revert it back when exited. This is because the weapon_idle_animation is the final
													# animation in the weapon_blend OneShot chain.
@export var weapon_equip_animation: Animation
@export var weapon_unequip_animation: Animation
@export var weapon_shoot_animation: Animation
@export var weapon_reload_animation: Animation

var current_ammo: Ammo
var reserve_ammo: Array[Ammo]
@export var max_ammo_magazines := 2


### fn

## helper
#
func get_world_scale() -> Vector3:
	var current_weapon_scale = Vector3.ONE * scale_value
	return current_weapon_scale * PlayerModelAnimated.get_hand_rig_scale()
