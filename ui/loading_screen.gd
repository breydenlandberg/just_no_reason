extends CanvasLayer


# signal
signal loading_screen_ready


# var
@export var animation_player: AnimationPlayer


### fn

## virtual
#
func _ready():
	await animation_player.animation_finished
	loading_screen_ready.emit()

func _on_progress_changed(_new_value: float) -> void:
	pass

func _on_load_finished() -> void:
	animation_player.play_backwards('fade_in')
	await animation_player.animation_finished
	queue_free()
