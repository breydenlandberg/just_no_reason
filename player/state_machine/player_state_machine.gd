class_name PlayerStateMachine extends StateMachine


@export var player_movement_stats: MovementStats


### fn

## virtual
#
func _input(_event: InputEvent):
	handle_input(_event)

func _physics_process(_delta):
	handle_physics_process(_delta)

func _process(_delta):
	handle_process(_delta)

func _ready():
	set_up_state_machine()
