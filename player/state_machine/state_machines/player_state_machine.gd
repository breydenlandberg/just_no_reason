class_name PlayerStateMachine extends StateMachine


# var
@export var weapon_manager: WeaponManager


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
		child._combat_status_changed.connect(weapon_manager.on_combat_status_changed)
		child.process_mode = Node.PROCESS_MODE_DISABLED

	_start()

# This allows us to go straight from eg Unarmed/AimWalk -> Armed/AimWalk and the reverse when equipping / unequipping weapon
func transition(state, new_state_name):
	var motion_state_to_preserve: StringName = &''

	if current_state is PlayerCombatTransitionState and current_state.state_machine:
		if current_state.state_machine.current_state:
			motion_state_to_preserve = current_state.state_machine.current_state.name

	var new_state = states.get(new_state_name)
	if new_state is PlayerCombatTransitionState:
		new_state.entry_substate = motion_state_to_preserve

	super.transition(state, new_state_name)
