extends Node


static var currently_paused := false
static var can_pause := false


# signals
@warning_ignore('unused_signal')
signal pause_requested


### fn

## virtual / private
#
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	pause_requested.connect(_on_pause_requested)

func _unhandled_input(event: InputEvent):
	if can_pause and event.is_action_pressed(InputManager.escape):
		pause_requested.emit()

func _on_pause_requested():
	currently_paused = not currently_paused
