extends CanvasLayer


# var
@export var current_menu_selection_context_container: Control
@export var level_selection_menu: PackedScene

var active_context_node: Control = null


### fn

## helper
#
func set_context(new_scene: PackedScene) -> void:
	if active_context_node:
		active_context_node.queue_free()
		active_context_node = null

	if(new_scene):
		active_context_node = new_scene.instantiate()
		current_menu_selection_context_container.add_child(active_context_node)


## signal
#
func _on_play_button_pressed():
	if active_context_node and active_context_node.scene_file_path == level_selection_menu.resource_path:
		set_context(null)
	else:
		set_context(level_selection_menu)

func _on_quit_button_pressed():
	get_tree().quit()
