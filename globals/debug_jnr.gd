extends Node


# var, const
var debug_container: Node3D
var current_lines: Array[Dictionary]

@onready var debug_sphere: PackedScene = preload('res://debug/debug_sphere.tscn') # consider preloading the uid

const DEBUG_DRAW_3D_SCENE: PackedScene = preload('res://addons/debug_draw/debug_draw_3d.tscn') # consider preloading the uid
var debug_draw_3d: DebugDraw3D


### fn

## virtual
#
func _ready():
	debug_draw_3d = DEBUG_DRAW_3D_SCENE.instantiate()
	add_child(debug_draw_3d)

func _process(delta: float):
	if not debug_draw_3d:
		return

	for i in range(current_lines.size() - 1, -1, -1):
		var line: Dictionary = current_lines[i]
		if line['time_remaining'] > 0.0:
			debug_draw_3d.draw_line(line['origin'], line['end'], Color.RED, 2.0)
			line['time_remaining'] -= delta
		else:
			current_lines.remove_at(i)


## helper
#
func set_debug_container(container: Node3D):
	debug_container = container

func draw_between(origin: Vector3, end: Vector3, duration := 1.0, spawn_spheres_at_origin_and_end := false):
	var line_dict: Dictionary = {'origin': origin, 'end': end, 'time_remaining': duration}
	current_lines.append(line_dict)

	if spawn_spheres_at_origin_and_end and is_instance_valid(debug_container):
		var origin_sphere := debug_sphere.instantiate()
		origin_sphere.global_position = origin

		var end_sphere := debug_sphere.instantiate()
		end_sphere.global_position = end

		debug_container.add_child(origin_sphere)
		debug_container.add_child(end_sphere)
