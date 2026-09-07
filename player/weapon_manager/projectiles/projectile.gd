class_name Projectile extends Node3D


# var
@export var debug_sphere: PackedScene

@onready var debug_draw := $DebugDraw3D

# debug stuff should be extracted to its own library in the debug folder
var _debug_start := Vector3.ZERO
var _debug_end := Vector3.ZERO
var _debug_line_time_remaining := 0.0


### fn

## virtual
#
func _ready() -> void:
	if debug_draw:
		debug_draw.top_level = true
		debug_draw.global_transform = Transform3D.IDENTITY

func _process(delta: float) -> void:
	if _debug_line_time_remaining > 0.0 and debug_draw:
		debug_draw.draw_line(_debug_start, _debug_end, Color.RED, 2.0)
		_debug_line_time_remaining -= delta

func _set_weapon_projectile(_weapon: Weapon, _model: WeaponModel):
	pass


## helper
#
func camera_ray_cast(_range := 100) -> Vector3:
	var viewport_size: Vector2i
	var window: Window = get_window()

	match window.content_scale_mode:
		window.CONTENT_SCALE_MODE_VIEWPORT, window.CONTENT_SCALE_MODE_CANVAS_ITEMS:
			viewport_size = window.content_scale_size
		window.CONTENT_SCALE_MODE_DISABLED:
			viewport_size = window.get_size()

	var camera: Camera3D = get_viewport().get_camera_3d()

	var ray_origin: Vector3 = camera.project_ray_origin(viewport_size / 2.0)
	var ray_end: Vector3 = ray_origin + camera.project_ray_normal(viewport_size / 2.0) * _range

	var new_ray_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	new_ray_query.set_hit_from_inside(false) # true?
	# Scaffolding (1) + World (2) + Enemies (8) = 11 (0b0001011)
	new_ray_query.set_collision_mask(0b0001011)

	var intersection: Dictionary = get_world_3d().direct_space_state.intersect_ray(new_ray_query)

	if not intersection.is_empty():
		var collision: Vector3 = intersection.position

		_debug_start = ray_origin
		_debug_end = collision
		_debug_line_time_remaining = 1.0

		var test := debug_sphere.instantiate()
		test.global_position = ray_origin
		var test2 := debug_sphere.instantiate()
		test2.global_position = collision
		get_tree().root.get_node('Main/Enemy/').add_child(test)
		get_tree().root.get_node('Main/Enemy/').add_child(test2)

		return collision
	else:
		_debug_start = ray_origin
		_debug_end = ray_end
		_debug_line_time_remaining = 1.0
		return ray_end
