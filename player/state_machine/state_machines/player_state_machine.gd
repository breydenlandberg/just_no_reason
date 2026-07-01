class_name PlayerStateMachine extends StateMachine


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
	for child: PlayerCombatTransitionState in get_children():
		child._combat_status_changed.connect(animated_model.on_combat_status_changed)
		child.process_mode = Node.PROCESS_MODE_DISABLED

	_start()
