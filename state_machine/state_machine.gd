class_name StateMachine extends Node3D


# var
var states: Dictionary
var current_state: State

@export var initial_state: State
@export var animated_model: PlayerModelAnimated


### fn

##
#
# To be used in child StateMachines that inherit from this parent class, e.g. PlayerStateMachine,
# ???StateMachine, etc.
#
# Used in _input
func handle_input(event: InputEvent):
	if current_state:
		current_state._state_input(event)

# Used in _physics_process
func handle_physics_process(delta: float):
	if current_state:
		current_state._state_physics_process(delta)

# Used in _process
func handle_process(delta: float):
	if current_state:
		current_state._state_process(delta)

# Used in _ready
func _start():
	print('╔= Starting ', self)

	# Set up states
	for child: State in get_children():
		print('╠= Initialise State: ', child, ' for ', self)
		child.animated_model = animated_model
		states[child.name] = child
		child._transition.connect(transition)

	if initial_state:
		print('╚= Entering initial_state: ', initial_state)
		print()
		initial_state._enter()
		current_state = initial_state

func _stop():
	print('╔= Stopping ', self)

	for child: State in get_children():
		child.animated_model = null
		states[child.name] = null
		child._transition.disconnect(transition)

		print('╠= Clear State: ', child, ' for ', self)

	print('╚= ', self, ' States have all their signals disconnected and vars emptied. All packed up!')
	print()

func transition(state, new_state_name):
	if state != current_state:
		push_warning('⛶ Passed state \'' + state.name + '\' does not equal current state \'' + current_state.name + '\'')
		return

	var new_state = states.get(new_state_name)

	if !new_state:
		push_warning('⛶ New state not found')
		return

	if current_state:
		current_state._exit()
		current_state.previous_state = null

	print('⛶ Transitioning from ', state, ' to ', new_state, ' State')
	print()
	new_state.previous_state = current_state
	new_state._enter()

	current_state = new_state
