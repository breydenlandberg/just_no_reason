extends CanvasLayer


# var
@export var initial_scene: StringName = &''


func _on_play_button_pressed():
	SceneLoader.load_scene(initial_scene)
