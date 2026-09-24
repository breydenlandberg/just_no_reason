extends Node3D


# var
@export var debug_container: Node3D
@export var current_menu_container: Node
@export var current_hud_container: Node
@export var current_level_container: Node3D
@export var main_menu: PackedScene
@export var pause_menu: PackedScene
@export var game_hud: PackedScene
@export var player: Player


### fn

## virtual / private
#
func _ready():
	DebugJnr.set_debug_container(debug_container)
	LevelLoader.scene_loaded.connect(_on_level_loaded)
	PauseManager.pause_requested.connect(_on_pause_requested)
	PauseManager.return_to_title_requested.connect(_on_return_to_title_requested)

	# Disable Player when we start the Game
	if player:
		player.deactivate()

	# Load Main Menu when we start the Game
	load_menu(main_menu)


## helper
#
func load_menu(menu_scene: PackedScene) -> void:
	clear_menu()
	if current_menu_container:
		var menu_instance = menu_scene.instantiate()
		current_menu_container.add_child(menu_instance)

func clear_menu() -> void:
	if current_menu_container:
		for child in current_menu_container.get_children():
			current_menu_container.remove_child(child)
			child.queue_free()

func load_hud(hud_scene: PackedScene) -> void:
	clear_hud()
	if current_hud_container:
		var hud_instance = hud_scene.instantiate()
		current_hud_container.add_child(hud_instance)

func clear_hud() -> void:
	if current_hud_container:
		for child in current_hud_container.get_children():
			current_hud_container.remove_child(child)
			child.queue_free()

func load_current_level(level_scene: PackedScene) -> Level:
	clear_current_level()

	if current_level_container:
		current_level_container.process_mode = PROCESS_MODE_INHERIT
		var level_instance = level_scene.instantiate()
		current_level_container.add_child(level_instance)

		return level_instance as Level

	return null

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

func spawn_player(spawn_transform: Transform3D) -> void:
	if player:
		player.activate(spawn_transform)


## signal
#
func _on_level_loaded(level_packed_scene: PackedScene) -> void:
	clear_debug()
	clear_menu()

	if game_hud:
		load_hud(game_hud)

	var current_level = load_current_level(level_packed_scene)
	if current_level and current_level.player_spawn and player:
		spawn_player(current_level.player_spawn.global_transform)

	PauseManager.can_pause = true

func _on_pause_requested() -> void:
	if PauseManager.currently_paused:
		if current_level_container:
			current_level_container.process_mode = PROCESS_MODE_DISABLED
		if player:
			player.process_mode = PROCESS_MODE_DISABLED
		load_menu(pause_menu)
	else:
		if current_level_container:
			current_level_container.process_mode = PROCESS_MODE_INHERIT
		if player:
			player.process_mode = PROCESS_MODE_INHERIT
		clear_menu()

func _on_return_to_title_requested() -> void:
	clear_debug()
	clear_hud()
	clear_current_level()

	if player:
		player.deactivate()

	load_menu(main_menu)
