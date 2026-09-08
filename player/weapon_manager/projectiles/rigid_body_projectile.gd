class_name RigidBodyProjectile extends Projectile


# var
@export var projectile_velocity := 180
@export var expiry_time := 2
@export var rigid_body_bullet: PackedScene

var bullet_instance: RigidBodyBullet
var sweep_query: PhysicsRayQueryParameters3D
var has_hit := false


### fn

## virtual
#
func _ready():
	sweep_query = PhysicsRayQueryParameters3D.new()
	# Scaffolding (1) + World (2) + Enemies (32) = 35 (0b0100011)
	sweep_query.collision_mask = 0b0100011
	sweep_query.collide_with_areas = true
	sweep_query.collide_with_bodies = true
	sweep_query.hit_from_inside = true

func _physics_process(delta: float):
	if has_hit or not is_instance_valid(bullet_instance):
		return

	var current_pos := bullet_instance.global_position
	var step := bullet_instance.linear_velocity * delta

	sweep_query.from = current_pos
	sweep_query.to = current_pos + step
	sweep_query.exclude = [bullet_instance]

	var result := get_world_3d().direct_space_state.intersect_ray(sweep_query)
	if not result.is_empty():
		has_hit = true
		var collider: Object = result.collider
		var damage: float = bullet_instance.damage if 'damage' in bullet_instance else 1.0

		if collider is Hurtbox:
			collider.damage_take.emit(damage)
		elif 'hurtbox' in collider and collider.hurtbox is Hurtbox:
			collider.hurtbox.damage_take.emit(damage)

		#print('Hit', collider, ', freeing ', bullet_instance)
		bullet_instance.queue_free()

func _set_weapon_projectile(_weapon: Weapon, _model: WeaponModel):
	var camera_collision: Vector3 = camera_ray_cast()
	launch_rigid_projectile(camera_collision, _model, rigid_body_bullet)
	get_tree().create_timer(expiry_time).timeout.connect(on_expiry_timeout)


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

	bullet_instance = projectile


func on_expiry_timeout():
	queue_free()
