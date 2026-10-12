class_name LevelButton extends Button


# vars
@export var level_path: String = ''


### fn

## helper
#
func setup(display_name: String, path: String) -> void:
	text = display_name
	level_path = path


## signals
#
func _on_pressed() -> void:
	if not level_path.is_empty():
		LevelLoader.load_level(level_path)
