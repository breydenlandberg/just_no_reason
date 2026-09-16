extends Node3D


# var
@export var debug_container: Node3D # This means we don't need whatever's in debug.gd
@export var main_menu: CanvasLayer
@export var current_level_container: Node3D
#@export var player: CharacterBody3D


### fn

## virtual / private
#
func _ready():
	SceneLoader.scene_loaded.connect(_on_level_loaded)

func _on_level_loaded(level_packed_scene: PackedScene) -> void:
	# clear out our current level
	for child in current_level_container.get_children():
		current_level_container.remove_child(child)
		child.queue_free()

	# hide main menu
	main_menu.hide()

	# instantiate and mount new level
	var new_level = level_packed_scene.instantiate()
	current_level_container.add_child(new_level)

	# position player at spawn point
	#var spawn_point = level_instance.player_spawn
	#if spawn_point and player:
	#	player.global_transform = spawn_point.global_transform
