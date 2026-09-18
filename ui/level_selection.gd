extends Control


# var
@export var levels: Array[LevelData]
@export var level_container: Control
@export var level_button: PackedScene


### fn

## virtual / private
#
func _ready():
	for level in levels:
		if not level or not level.level_scene:
			continue

		var new_level_button: LevelButton = level_button.instantiate()

		var title: String = level.display_name
		if title.is_empty():
			title = level.level_scene.resource_path.get_file().get_basename()

		new_level_button.setup(title, level.level_scene.resource_path)

		level_container.add_child(new_level_button)
