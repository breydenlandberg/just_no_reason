class_name Weapon extends Resource


# var
@export var name: String
@export var weapon_model: PackedScene

@export var hand_position: Vector3
@export var hand_rotation: Vector3
@export var scale := Vector3(1.0, 1.0, 1.0)

@export var weapon_idle_animation: Animation
@export var weapon_aim_idle_animation: Animation 	# We will update the weapon_idle_animation to this in the AnimationTree when aim entered
													# and revert it back when exited. This is because the weapon_idle_animation is the final
													# animation in the weapon_blend OneShot chain.
@export var weapon_equip_animation: Animation
@export var weapon_unequip_animation: Animation
@export var weapon_shoot_animation: Animation
@export var weapon_reload_animation: Animation

@export var current_ammo: Ammo
@export var reserve_ammo: Array[Ammo]
