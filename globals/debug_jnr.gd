extends Node


# var, const
var debug_node # Used to add debug nodes (eg DebugSphere) live in game
var current_lines: Array[Dictionary]

@onready var debug_sphere: PackedScene = preload('res://debug/debug_sphere.tscn')

const DEBUG_DRAW_3D_SCENE: PackedScene = preload("res://addons/debug_draw/debug_draw_3d.tscn")
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
func set_debug_node(debug_node_param: Node3D):
	debug_node = debug_node_param

func draw_between(origin: Vector3, end: Vector3, duration := 1.0, spawn_spheres_at_origin_and_end := false):
	var line_dict: Dictionary = {'origin': origin, 'end': end, 'time_remaining': duration}
	current_lines.append(line_dict)

	if spawn_spheres_at_origin_and_end and debug_node:
		var origin_sphere := debug_sphere.instantiate()
		origin_sphere.global_position = origin

		var end_sphere := debug_sphere.instantiate()
		end_sphere.global_position = end

		debug_node.add_child(origin_sphere)
		debug_node.add_child(end_sphere)
