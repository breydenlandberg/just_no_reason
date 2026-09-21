class_name LevelButton extends Button


# var
@export var level_path: String = ''


### fn

## helper
#
func setup(display_name: String, path: String):
	text = display_name
	level_path = path

## signal
#
func _on_pressed():
	if not level_path.is_empty():
		SceneLoader.load_scene(level_path)
