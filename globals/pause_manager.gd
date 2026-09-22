extends Node


# signals
@warning_ignore('unused_signal')
signal pause_requested
@warning_ignore('unused_signal')
signal return_to_title_requested


# var
var currently_paused := false
var can_pause := false


### fn

## virtual / private
#
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	pause_requested.connect(_on_pause_requested)
	return_to_title_requested.connect(_on_return_to_title_requested)

func _unhandled_input(event: InputEvent):
	if can_pause and event.is_action_pressed(InputManager.escape):
		pause_requested.emit()


## helper
#
func reset():
	currently_paused = false
	can_pause = false


## signal
#
func _on_pause_requested():
	currently_paused = not currently_paused

func _on_return_to_title_requested():
	reset()
