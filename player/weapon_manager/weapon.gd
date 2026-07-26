class_name Weapon extends Resource


# var
@export var name: String
@export var weapon_model: PackedScene

@export var hand_position: Vector3
@export var hand_rotation: Vector3
@export var scale := Vector3(1.0, 1.0, 1.0)

@export var weapon_idle_animation: Animation
@export var weapon_equip_animation: Animation
@export var weapon_unequip_animation: Animation
@export var weapon_shoot_animation: Animation
@export var weapon_reload_animation: Animation
