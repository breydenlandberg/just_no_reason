class_name RigidBodyProjectile extends Projectile


# var
@export var projectile_velocity := 425
@export var expiry_time := 10
@export var rigid_body_bullet: PackedScene


### fn

## virtual
#
func _set_weapon_projectile(_weapon: Weapon, _model: WeaponModel):
	var camera_collision: Vector3 = camera_ray_cast()
	launch_rigid_projectile(camera_collision, _model, rigid_body_bullet)

## helper
#
func launch_rigid_projectile(point: Vector3, model: WeaponModel, bullet: PackedScene):
	var projectile: RigidBody3D = bullet.instantiate()
	projectile.top_level = true
	projectile.position = model.bullet_point.global_position

	add_child(projectile)
	projectile.look_at(point)

	var direction: Vector3 = (point - model.bullet_point.global_position).normalized()
	projectile.set_linear_velocity(direction * projectile_velocity)
