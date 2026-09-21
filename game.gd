extends Node3D


# var
@export var debug_container: Node3D
@export var main_menu: CanvasLayer
@export var current_level_container: Node3D
#@export var player: CharacterBody3D


### fn

## virtual / private
#
func _ready():
	DebugJnr.set_debug_container(debug_container)
	SceneLoader.scene_loaded.connect(_on_level_loaded)
	PauseManager.pause_requested.connect(_on_pause_requested)

func _on_level_loaded(level_packed_scene: PackedScene) -> void:
	# clear out our current level
	if current_level_container:
		for child in current_level_container.get_children():
			current_level_container.remove_child(child)
			child.queue_free()

	# clear accumulated debug nodes
	if debug_container:
		for child in debug_container.get_children():
			#debug_container.remove_child(child)
			child.queue_free()

	# hide main menu
	#main_menu.hide()
	# DESTROY MAIN MENU!
	main_menu.queue_free()

	# instantiate and mount new level
	var new_level = level_packed_scene.instantiate()
	current_level_container.add_child(new_level)

	# position player at spawn point
	#var spawn_point = level_instance.player_spawn
	#if spawn_point and player:
	#	player.global_transform = spawn_point.global_transform

	PauseManager.can_pause = true
	# remember to set can_pause = false, currently_paused = false when going back to MainMenu ie deloading a level

func _on_pause_requested() -> void:
	if PauseManager.currently_paused:
		current_level_container.process_mode = PROCESS_MODE_DISABLED
	else:
		current_level_container.process_mode = PROCESS_MODE_INHERIT
