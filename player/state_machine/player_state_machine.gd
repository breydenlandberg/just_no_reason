class_name PlayerStateMachine extends StateMachine


@export var player_movement_stats: MovementStats
@export var player_model: PlayerModelAnimated


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
	for child: Motion in get_children():
		child._animation_state_changed.connect(player_model.on_state_machine_animation_state_changed)

	set_up_state_machine()
