class_name ArmedStateMachine extends StateMachine


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
	# Connect "wires"...
	for child: PlayerMotionState in get_children():
		if not child._animation_state_changed.is_connected(animated_model.on_state_machine_animation_state_changed):
			child._animation_state_changed.connect(animated_model.on_state_machine_animation_state_changed)
		if not child._rotate_model.is_connected(animated_model.on_input_direction_changed):
			child._rotate_model.connect(animated_model.on_input_direction_changed)

	# THEN start machine
	super._start()

func _stop():
	# _stop() in state_machine.gd will ALWAYS _exit() the current_state, THEREFORE...
	# Stop machine...
	super._stop()
	
	# THEN disconnect "wires"
	for child: PlayerMotionState in get_children():
		if child._animation_state_changed.is_connected(animated_model.on_state_machine_animation_state_changed):
			child._animation_state_changed.disconnect(animated_model.on_state_machine_animation_state_changed)
		if child._rotate_model.is_connected(animated_model.on_input_direction_changed):
			child._rotate_model.disconnect(animated_model.on_input_direction_changed)
