class_name StateMachine extends Node3D


# var
var states: Dictionary
var current_state: State

# @export
@export var animation: AnimationPlayer
@export var attack_animation: AnimationPlayer
@export var collider: CollisionShape3D
@export var entity: CharacterBody3D
@export var mesh: MeshInstance3D
@export var initial_state: State


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
func set_up_state_machine():
	# Set up states
	for child in get_children():
		if child is State:
			child.animation = animation
			child.attack_animation = attack_animation
			child.collider = collider
			child.entity = entity
			child.mesh = mesh

			states[child.name.to_lower()] = child

			child._transition.connect(transition)

			print('For ', self, ', initialise State: ', child)
		else:
			push_warning('Child \'' + child.name + '\' is not a valid State for the ' + entity.name + 'StateMachine')

	if initial_state:
		initial_state._enter()
		current_state = initial_state
		print('Entering initial_state: ', current_state)

	print('\n')

func transition(state, new_state_name):
	if state != current_state:
		push_warning('Passed state \'' + state.name.to_lower() + '\' does not equal current state \'' + current_state.name + '\'')
		return

	var new_state = states.get(new_state_name.to_lower())

	if !new_state:
		push_warning('New state not found')
		return

	if current_state:
		current_state._exit()
		current_state.previous_state = null

	new_state.previous_state = current_state
	new_state._enter()

	current_state = new_state

	print('Transitioned from ', state, ' to ', new_state, ' State')
	print('\n')
