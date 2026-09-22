extends CanvasLayer


### fn

## signal
#
func _on_resume_button_pressed() -> void:
	PauseManager.pause_requested.emit()

func _on_return_to_title_button_pressed() -> void:
	PauseManager.return_to_title_requested.emit()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
