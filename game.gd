extends Node3D


# var
@export var debug_container: Node3D
@export var current_ui_container: Node
@export var current_level_container: Node3D
@export var main_menu: PackedScene
@export var pause_menu: PackedScene
#@export var player: CharacterBody3D


### fn

## virtual / private
#
func _ready():
	DebugJnr.set_debug_container(debug_container)
	LevelLoader.scene_loaded.connect(_on_level_loaded)
	PauseManager.pause_requested.connect(_on_pause_requested)
	PauseManager.return_to_title_requested.connect(_on_return_to_title_requested)

	# Load Main Menu when we start the Game
	load_ui(main_menu)


## helper
#
func load_ui(ui_scene: PackedScene) -> void:
	clear_ui() # Should this be here or in _on_level_loaded?
	if current_ui_container:
		var ui_instance = ui_scene.instantiate()
		current_ui_container.add_child(ui_instance)

func clear_ui() -> void:
	if current_ui_container:
		for child in current_ui_container.get_children():
			current_ui_container.remove_child(child)
			child.queue_free()

func load_current_level(level_scene: PackedScene) -> void:
	clear_current_level()
	if current_level_container:
		current_level_container.process_mode = PROCESS_MODE_INHERIT
		var new_level = level_scene.instantiate()
		current_level_container.add_child(new_level)

func clear_current_level() -> void:
	if current_level_container:
		current_level_container.process_mode = PROCESS_MODE_INHERIT
		for child in current_level_container.get_children():
			current_level_container.remove_child(child)
			child.queue_free()

	InteractManager.reset() # This will be deleted from here one day

func clear_debug() -> void:
	if debug_container:
		for child in debug_container.get_children():
			debug_container.remove_child(child)
			child.queue_free()


## signal
#
func _on_level_loaded(level_packed_scene: PackedScene) -> void:
	clear_debug()
	clear_ui()

	load_current_level(level_packed_scene)
	#later on: load_ui(ingame_hud)

	# position player at spawn point
	#var spawn_point = level_instance.player_spawn
	#if spawn_point and player:
	#	player.global_transform = spawn_point.global_transform

	PauseManager.can_pause = true

func _on_pause_requested() -> void:
	if PauseManager.currently_paused:
		current_level_container.process_mode = PROCESS_MODE_DISABLED
		load_ui(pause_menu)
	else:
		current_level_container.process_mode = PROCESS_MODE_INHERIT
		clear_ui()
		#later on: load_ui(ingame_hud) ?

func _on_return_to_title_requested() -> void:
	clear_debug()
	clear_current_level()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	load_ui(main_menu)
