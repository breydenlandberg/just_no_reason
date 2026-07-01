class_name UnarmedStateMachine extends StateMachine


### fn

## virtual
#
func _input(_event: InputEvent):
	handle_input(_event)

func _physics_process(_delta):
	handle_physics_process(_delta)

func _process(_delta):
	handle_process(_delta)

func _start():
	for child: PlayerMotionState in get_children():
		child._animation_state_changed.connect(animated_model.on_state_machine_animation_state_changed)
		child._rotate_model.connect(animated_model.on_input_direction_changed)

	super._start()

func _stop():
	for child: PlayerMotionState in get_children():
		child._animation_state_changed.disconnect(animated_model.on_state_machine_animation_state_changed)
		child._rotate_model.disconnect(animated_model.on_input_direction_changed)

	super._stop()
